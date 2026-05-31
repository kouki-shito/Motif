//
//  AVAudioFoundation+Extension.swift
//  Motif
//
//  Created by 市東 on 2026/05/21.
//

import AVFoundation

extension AVAudioPCMBuffer: @retroactive @unchecked Sendable {}

extension AudioBufferList: @retroactive @unchecked Sendable {}
