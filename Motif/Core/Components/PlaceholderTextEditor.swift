//
//  PlaceholderTextEditor.swift
//  Motif
//
//  Created by 市東 on 2026/05/11.
//

import SwiftUI

struct PlaceholderTextEditor: View {
    @Binding var text: String

    let placeholder: String
    
    init(text: Binding<String>, placeholder: String) {
        self._text = text
        self.placeholder = placeholder
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .padding(4)
                .background(Color.clear)

            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    PlaceholderTextEditor(text: .constant(""), placeholder: "aaa")
}
