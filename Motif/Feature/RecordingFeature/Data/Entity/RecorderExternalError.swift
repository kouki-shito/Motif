//
//  RecorderExternalError.swift
//  Motif
//
//  Created by 市東 on 2026/05/17.
//

enum RecorderExternalError: Error {
    case alreadyFileExists
    case writeFailed
    case formatIsIncorrect
    case notInitedEngine
    case alreadyRecording
    case permissionDenied
}
