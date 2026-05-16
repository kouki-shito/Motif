//
//  TagItem.swift
//  Motif
//
//  Created by 市東 on 2026/05/13.
//

import SwiftUI

struct TagItem<Style: ShapeStyle>: View {
    let text: String
    let iconName: String?
    let style: Style
    
    init(text: String, iconName: String? = nil, style: Style = .secondary) {
        self.text = text
        self.iconName = iconName
        self.style = style
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(style)
            }
            Text(text)
                .lineLimit(1)
                .font(.system(size: 16))
                .fontWeight(.semibold)
                .foregroundStyle(style)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(style.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    TagItem(text: "125 BPM", iconName: "timer", style: .black)
}
