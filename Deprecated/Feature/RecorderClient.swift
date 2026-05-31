////
////  RecorderClient.swift
////  Motif
////
////  Created by 市東 on 2026/05/16.
////
//
//import Foundation
//import Dependencies
//import DependenciesMacros
//import AVFoundation
//
//@DependencyClient
//struct RecorderClient: Sendable {
//    var requestRecordPermission: @Sendable () async throws -> Bool
//    var start: @Sendable () async throws -> (AsyncThrowingStream<RecordingSample, any Error>, UUID)
//    var stop: @Sendable () async throws -> Void
//    var togglePauseAndResume: @Sendable () async throws -> Void
//    var cancel: @Sendable () async throws -> Void
//    var status: @Sendable () async throws -> RecordingStatus
//}
//
//extension RecorderClient: DependencyKey {
//    static var liveValue: Self {
//        let session = RecorderSession()
//        return Self(
//            requestRecordPermission: {
//                return await AVAudioApplication.requestRecordPermission()
//            }, start: {
//                guard await AVAudioApplication.requestRecordPermission() else { throw RecorderExternalError.permissionDenied }
//                let (stream, continuation) = AsyncThrowingStream.makeStream(of: RecordingSample.self, bufferingPolicy: .bufferingNewest(1))
//                let id = UUID()
//                try await session.startSession(continuation: continuation, id: id)
//                continuation.onTermination = { ter in
//                    switch ter {
//                    case .cancelled:
//                        Task {
//                            guard await session.recorder?.id == id else { return }
//                            await session.cancelSession()
//                        }
//                    case .finished:
//                        Task {
//                            guard await session.recorder?.id == id else { return }
//                            await session.deleteSession()
//                        }
//                    @unknown default:
//                        fatalError()
//                    }
//                }
//                return (stream, id)
//            }, stop: {
//                await session.deleteSession()
//            }, togglePauseAndResume: {
//                try await session.recorder?.togglePauseAndResume()
//            }, cancel: {
//                await session.cancelSession()
//            }, status: {
//                await session.recorder?.status ?? .idle
//            }
//        )
//    }
//}
//
//extension RecorderClient: TestDependencyKey {
//    static let previewValue = Self()
//    static let testValue = Self()
//}
//
//extension DependencyValues {
//    var recorderClient: RecorderClient {
//        get { self[RecorderClient.self] }
//        set { self[RecorderClient.self] = newValue }
//    }
//}
//
//private final actor RecorderSession {
//    
//    private(set) var recorder: Recorder? = nil
//    
//    func startSession(continuation: AsyncThrowingStream<RecordingSample, any Error>.Continuation, id: UUID) async throws {
//        await recorder?.stop()
//        let url = try getFileURL(id: id)
//        let recorder = Recorder(continuation: continuation, id: id, url: url)
//        try await recorder.start()
//        self.recorder = recorder
//    }
//    
//    func deleteSession() async {
//        await recorder?.stop()
//        recorder = nil
//    }
//    
//    func cancelSession() async {
//        await recorder?.cancel()
//        recorder = nil
//    }
//    
//    private func getFileURL(id: UUID) throws -> URL {
//        let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let recordingDir = documentDir.appending(component: "Recording", directoryHint: .isDirectory)
//        try FileManager.default.createDirectory(at: recordingDir, withIntermediateDirectories: true)
//        let fileURL = recordingDir.appending(component: "\(id.uuidString).aac", directoryHint: .notDirectory)
//        return fileURL
//    }
//}
//
//private final actor Recorder: Sendable {
//    
//    private let engine: AVAudioEngine = AVAudioEngine()
//    private let continuation: AsyncThrowingStream<RecordingSample, any Error>.Continuation
//    private(set) var status: RecordingStatus = .idle
//    private let url: URL
//    let id: UUID
//    
//    init(continuation: AsyncThrowingStream<RecordingSample, any Error>.Continuation, id: UUID, url: URL) {
//        self.continuation = continuation
//        self.id = id
//        self.url = url
//    }
//    
//    func start() async throws {
//        guard await AVAudioApplication.requestRecordPermission() else { throw RecorderExternalError.permissionDenied }
//        guard !FileManager.default.fileExists(atPath: url.path) else { throw RecorderExternalError.alreadyFileExists }
//        initEngine()
//        do {
//            try prepare(url: url)
//            try engine.start()
//            status = .recording
//        } catch {
//            initEngine()
//            try deleteRecord(url: url)
//            throw error
//        }
//    }
//    
//    func togglePauseAndResume() throws {
//        switch status {
//        case .idle:
//            return
//        case .recording:
//            engine.pause()
//            status = .pausing
//        case .pausing:
//            try engine.start()
//            status = .recording
//        }
//    }
//    
//    func stop() {
//        continuation.finish()
//        initEngine()
//    }
//    
//    func cancel() {
//        continuation.finish()
//        initEngine()
//        try? deleteRecord(url: url)
//    }
//    
//    private func initEngine() {
//        engine.stop()
//        engine.inputNode.removeTap(onBus: 0)
//        engine.reset()
//        status = .idle
//    }
//    
//    private func prepare(url: URL) throws {
//        try AVAudioSession.sharedInstance().setCategory(.record, mode: .default)
//        try AVAudioSession.sharedInstance().setActive(true)
//        let format = engine.inputNode.outputFormat(forBus: 0)
//        guard format.sampleRate > 0, format.channelCount > 0 else {
//            throw RecorderExternalError.formatIsIncorrect
//        }
//        let settings = [
//            AVFormatIDKey: kAudioFormatMPEG4AAC,
//            AVSampleRateKey: 44100,
//            AVNumberOfChannelsKey: format.channelCount,
//            AVEncoderBitRateKey: 128000
//        ] as [String : Any]
//        let audioFile = try AVAudioFile(forWriting: url, settings: settings, commonFormat: .pcmFormatFloat32, interleaved: false)
//        let writer = RecorderWriter(audioFile: audioFile, inputFormat: format, continuation: continuation)
//        let inputNode = engine.inputNode
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
//            guard let self else { return }
//            guard let copiedBuffer = buffer.copy() as? AVAudioPCMBuffer else { return }
//            Task {
//                do {
//                    try await writer.write(buffer: copiedBuffer)
//                } catch {
//                    continuation.finish(throwing: error)
//                }
//            }
//        }
//        let sinkNode = AVAudioSinkNode { _, frameCount, bufferList in
//            let ablPointer = UnsafePointer<AudioBufferList>(bufferList)
//            let audioBuffer = ablPointer.pointee.mBuffers
//            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
//                return noErr
//            }
//            buffer.frameLength = frameCount
//            let sourceData = audioBuffer.mData?.assumingMemoryBound(to: Float.self)
//            if let bufferChannelData = buffer.floatChannelData, let source = sourceData {
//                bufferChannelData[0].update(from: source, count: Int(frameCount))
//            }
//            Task {
//                await writer.sendSample(buffer: buffer)
//            }
//            return noErr
//        }
//        engine.attach(sinkNode)
//        engine.connect(inputNode, to: sinkNode, format: format)
//        engine.prepare()
//    }
//    
//    private func deleteRecord(url: URL) throws {
//        guard FileManager.default.fileExists(atPath: url.path) else { return }
//        try FileManager.default.removeItem(at: url)
//    }
//}
//
//private final actor RecorderWriter: Sendable {
//    private let audioFile: AVAudioFile
//    private let inputFormat: AVAudioFormat
//    private let continuation: AsyncThrowingStream<RecordingSample, any Error>.Continuation
//    private var recordedFrames: AVAudioFramePosition = 0
//    
//    init(audioFile: AVAudioFile, inputFormat: AVAudioFormat, continuation: AsyncThrowingStream<RecordingSample, any Error>.Continuation) {
//        self.audioFile = audioFile
//        self.inputFormat = inputFormat
//        self.continuation = continuation
//    }
//    
//    func write(buffer: AVAudioPCMBuffer) throws {
//        try audioFile.write(from: buffer)
//        recordedFrames += AVAudioFramePosition(buffer.frameLength)
//    }
//    
//    func sendSample(buffer: AVAudioPCMBuffer) {
//        let time = Double(recordedFrames) / inputFormat.sampleRate
//        let height = volumeBarHeight(from: buffer)
//        continuation.yield(RecordingSample(currentTime: time, volumeBarHeight: height))
//    }
//    
//    private func volumeBarHeight(from buffer: AVAudioPCMBuffer) -> CGFloat {
//        guard let channelData = buffer.floatChannelData?[0] else {
//            return 5.0
//        }
//        let samples = UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength))
//        let maxValue = samples.reduce(Float.zero) { max($0, abs($1)) }
//        guard maxValue > 0 else { return 5.0 }
//        let db = 20 * log10(maxValue)
//        let adjustedDB = max(0, db + 40)
//        let normalizedDB = adjustedDB / 40
//        let height = Float(normalizedDB * 200)
//        return CGFloat(max(5, height))
//    }
//    
//}
