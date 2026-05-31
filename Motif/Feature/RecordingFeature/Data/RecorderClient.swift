//
//  RecorderClient.swift
//  Motif
//
//  Created by 市東 on 2026/05/16.
//

import Foundation
import Dependencies
import DependenciesMacros
import AVFoundation

@DependencyClient
struct RecorderClient: Sendable {
    var requestRecordPermission: @Sendable () async throws -> Bool
    var start: @Sendable (_ id: UUID) async throws -> AsyncThrowingStream<RecordingSample, any Error>
    var stop: @Sendable () async throws -> Void
    var togglePauseAndResume: @Sendable () async throws -> Void
    var cancel: @Sendable () async throws -> Void
    var getStatus: @Sendable () async throws -> RecordingStatus
    var getDuration: @Sendable (_ id: UUID) async throws -> TimeInterval
}

extension RecorderClient: DependencyKey {
    static var liveValue: Self {
        let session = RecorderSession()
        return Self(
            requestRecordPermission: {
                return await AVAudioApplication.requestRecordPermission()
            }, start: { id in
                guard await AVAudioApplication.requestRecordPermission() else { throw RecorderExternalError.permissionDenied }
                let (stream, continuation) = AsyncThrowingStream.makeStream(of: RecordingSample.self, bufferingPolicy: .bufferingNewest(1))
                try await session.startSession(continuation: continuation, id: id)
                continuation.onTermination = { ter in
                    switch ter {
                    case .cancelled:
                        Task {
                            guard await session.recorder?.id == id else { return }
                            await session.cancelSession()
                        }
                    case .finished:
                        Task {
                            guard await session.recorder?.id == id else { return }
                            await session.deleteSession()
                        }
                    @unknown default:
                        Task {
                            guard await session.recorder?.id == id else { return }
                            await session.deleteSession()
                        }
                    }
                }
                return stream
            }, stop: {
                await session.deleteSession()
            }, togglePauseAndResume: {
                try await session.recorder?.togglePauseAndResume()
            }, cancel: {
                await session.cancelSession()
            }, getStatus: {
                await session.recorder?.status ?? .idle
            }, getDuration: { id in
                try await session.getDuration(id: id)
            }
        )
    }
}

extension RecorderClient: TestDependencyKey {
    static let previewValue = Self()
    static let testValue = Self()
}

extension DependencyValues {
    var recorderClient: RecorderClient {
        get { self[RecorderClient.self] }
        set { self[RecorderClient.self] = newValue }
    }
}

private final actor RecorderSession {
    
    private(set) var recorder: Recorder? = nil
    
    func startSession(continuation: AsyncThrowingStream<RecordingSample, any Error>.Continuation, id: UUID) async throws {
        await recorder?.stop()
        let url = try getFileURL(id: id)
        let settings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: 64000
        ] as [String : Any]
        let recorder = try Recorder(continuation: continuation, url: url, id: id, settings: settings)
        try await recorder.start()
        self.recorder = recorder
    }
    
    func deleteSession() async {
        await recorder?.stop()
        recorder = nil
    }
    
    func cancelSession() async {
        await recorder?.cancel()
        recorder = nil
    }
    
    func getDuration(id: UUID) async throws -> TimeInterval {
        let url = try getFileURL(id: id)
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)
        return duration.seconds
    }
    
    private func getFileURL(id: UUID) throws -> URL {
        let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recordingDir = documentDir.appending(component: "Recording", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: recordingDir, withIntermediateDirectories: true)
        let fileURL = recordingDir.appending(component: "\(id.uuidString).m4a", directoryHint: .notDirectory)
        return fileURL
    }
}

private final actor Recorder: Sendable {
    
    private let engine: AVAudioEngine = AVAudioEngine()
    private let recorder: AVAudioRecorder
    private let delegate: Delegate
    private let continuation: AsyncThrowingStream<RecordingSample, any Error>.Continuation
    private(set) var status: RecordingStatus = .idle
    private let url: URL
    let id: UUID
    
    init(continuation: AsyncThrowingStream<RecordingSample, any Error>.Continuation, url: URL, id: UUID, settings: [String: Any]) throws {
        let recorder =  try AVAudioRecorder(url: url, settings: settings)
        self.delegate = Delegate(didFinishRecording: { bool in
            continuation.finish()
            try? AVAudioSession.sharedInstance().setActive(false)
        }, encodeErrorDidOccur: { err in
            continuation.finish(throwing: err)
            try? AVAudioSession.sharedInstance().setActive(false)
        })
        recorder.delegate = self.delegate
        self.recorder = recorder
        self.continuation = continuation
        self.url = url
        self.id = id
    }
    
    func start() async throws {
        guard await AVAudioApplication.requestRecordPermission() else { throw RecorderExternalError.permissionDenied }
        guard !FileManager.default.fileExists(atPath: url.path) else { throw RecorderExternalError.alreadyFileExists }
        initialize()
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            try prepareEngine()
            try engine.start()
            recorder.record()
            status = .recording
        } catch {
            initialize()
            try deleteRecord(url: url)
            throw error
        }
    }
    
    func togglePauseAndResume() throws {
        switch status {
        case .idle:
            return
        case .recording:
            engine.pause()
            recorder.pause()
            status = .pausing
        case .pausing:
            try engine.start()
            recorder.record()
            status = .recording
        }
    }
    
    func stop() {
        initialize()
    }
    
    func cancel() {
        initialize()
        try? deleteRecord(url: url)
    }
    
    private func initialize() {
        recorder.stop()
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        engine.reset()
        status = .idle
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    private func prepareEngine() throws {
        let format = engine.inputNode.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else {
            throw RecorderExternalError.formatIsIncorrect
        }
        let writer = RecorderWriter(sampleRate: format.sampleRate, continuation: continuation)
        let inputNode = engine.inputNode
        let sinkNode = AVAudioSinkNode { _, frameCount, bufferList in
            let ablPointer = UnsafePointer<AudioBufferList>(bufferList)
            let audioBuffer = ablPointer.pointee.mBuffers
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                return noErr
            }
            buffer.frameLength = frameCount
            let sourceData = audioBuffer.mData?.assumingMemoryBound(to: Float.self)
            if let bufferChannelData = buffer.floatChannelData, let source = sourceData {
                bufferChannelData[0].update(from: source, count: Int(frameCount))
            }
            Task {
                await writer.sendSample(buffer: buffer)
            }
            return noErr
        }
        engine.attach(sinkNode)
        engine.connect(inputNode, to: sinkNode, format: format)
        engine.prepare()
    }
    
    private func deleteRecord(url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }
}

private final class Delegate: NSObject, AVAudioRecorderDelegate, Sendable {
    let didFinishRecording: @Sendable (Bool) -> Void
    let encodeErrorDidOccur: @Sendable ((any Error)?) -> Void
    
    init(
        didFinishRecording: @escaping @Sendable (Bool) -> Void,
        encodeErrorDidOccur: @escaping @Sendable ((any Error)?) -> Void
    ) {
        self.didFinishRecording = didFinishRecording
        self.encodeErrorDidOccur = encodeErrorDidOccur
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.didFinishRecording(flag)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: (any Error)?) {
        self.encodeErrorDidOccur(error)
    }
}

private final actor RecorderWriter: Sendable {
    private let sampleRate: Double
    private let continuation: AsyncThrowingStream<RecordingSample, any Error>.Continuation
    private var recordedFrames: AVAudioFramePosition = 0
    
    init(sampleRate: Double, continuation: AsyncThrowingStream<RecordingSample, any Error>.Continuation) {
        self.sampleRate = sampleRate
        self.continuation = continuation
    }
    
    func sendSample(buffer: AVAudioPCMBuffer) {
        recordedFrames += AVAudioFramePosition(buffer.frameLength)
        let time = Double(recordedFrames) / sampleRate
        let height = volumeBarHeight(from: buffer)
        continuation.yield(RecordingSample(currentTime: time, volumeBarHeight: height))
    }
    
    private func volumeBarHeight(from buffer: AVAudioPCMBuffer) -> CGFloat {
        guard let channelData = buffer.floatChannelData?[0] else {
            return 5.0
        }
        let samples = UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength))
        let maxValue = samples.reduce(Float.zero) { max($0, abs($1)) }
        guard maxValue > 0 else { return 5.0 }
        let db = 20 * log10(maxValue)
        let adjustedDB = max(0, db + 40)
        let normalizedDB = adjustedDB / 40
        let height = Float(normalizedDB * 200)
        return CGFloat(max(5, height))
    }
    
}
