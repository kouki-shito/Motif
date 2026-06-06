//
//  AudioWaveView.swift
//  Motif
//
//  Created by 市東 on 2026/05/21.
//

import Foundation
import SwiftUI
import UIKit

struct RecordingWaveView: UIViewRepresentable {
    
    private let barHeights: [CGFloat]
    
    init(barHeights: [CGFloat]) {
        self.barHeights = barHeights
    }
    
    final class BarsView: UIView {
        var barHeights = [CGFloat]() { didSet { setNeedsDisplay() } }
        let barWidth: CGFloat = 2
        let barSpacing: CGFloat = 2
        
        override func draw(_ rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext(), !barHeights.isEmpty else { return }
            context.clear(rect)
            context.setFillColor(UIColor(.primaryBlue).cgColor)
            let centerY = rect.midY
            var x: CGFloat = 0
            
            for height in barHeights {
                let barRect = CGRect(x: x, y: centerY - (height / 2), width: barWidth, height: height)
                let path = UIBezierPath(roundedRect: barRect, cornerRadius: barWidth / 2)
                context.addPath(path.cgPath)
                context.fillPath()
                x += barWidth + barSpacing
            }
        }
    }
    
    class Coordinator: NSObject {
        weak var scrollView: UIScrollView?
        let barsView = BarsView()
        var barsWidthConstraint: NSLayoutConstraint?
        
        func updateBars(with heights: [CGFloat]) {
            barsView.barHeights = heights
            let width = CGFloat(heights.count) * (barsView.barWidth + barsView.barSpacing)
            barsWidthConstraint?.constant = width
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        scrollView.isUserInteractionEnabled = false
        scrollView.backgroundColor = .clear
        scrollView.isOpaque = false
        context.coordinator.scrollView = scrollView
        
        let barsView = context.coordinator.barsView
        barsView.translatesAutoresizingMaskIntoConstraints = false
        barsView.backgroundColor = .clear
        barsView.isOpaque = false
        scrollView.addSubview(barsView)
        
        let widthConstraint = barsView.widthAnchor.constraint(equalToConstant: 0)
        context.coordinator.barsWidthConstraint = widthConstraint
        
        NSLayoutConstraint.activate([
            barsView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            barsView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            barsView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            barsView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            barsView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            widthConstraint
        ])
        updateBarsAndScrollRightEdge(scrollView: scrollView, context: context)
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        updateBarsAndScrollRightEdge(scrollView: scrollView, context: context)
    }
    
    private func updateBarsAndScrollRightEdge(scrollView: UIScrollView, context: Context) {
        context.coordinator.updateBars(with: barHeights)
        scrollView.layoutIfNeeded()
        let targetX = max(0, scrollView.contentSize.width - scrollView.bounds.width)
        scrollView.contentOffset = CGPoint(x: targetX, y: 0)
    }
}
