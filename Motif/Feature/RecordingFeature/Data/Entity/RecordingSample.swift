//
//  RecordingSample.swift
//  Motif
//
//  Created by 市東 on 2026/05/20.
//

import Foundation
import AVFoundation

struct RecordingSample: Sendable, Equatable {
    let currentTime: TimeInterval
    let volumeBarHeight: CGFloat
}

