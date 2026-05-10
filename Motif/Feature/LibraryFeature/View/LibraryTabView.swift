//
//  LibraryTabView.swift
//  Motif
//
//  Created by 市東 on 2026/05/06.
//

import SwiftUI

struct LibraryTabView: View {
    let project: [Project] = [
        Project(id: UUID(), createdAt: Date(), title: "青春", description: "a", bpm: 170, key: .b, genre_id: UUID()),
        Project(id: UUID(), createdAt: Date(), title: "自然", description: "b", bpm: 170, key: .b, genre_id: UUID()),
        Project(id: UUID(), createdAt: Date(), title: "パレード", description: "c", key: .b, genre_id: UUID()),
        Project(id: UUID(), createdAt: Date(), title: "冒険", description: "d", bpm: 170, key: .b, genre_id: UUID()),
    ]
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(project, id: \.id) { project in
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(project.title)
                                        .font(.system(size: 20))
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Button {
                                        
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .foregroundStyle(.gray)
                                    }
                                }
                                Text(project.createdAt.dateToString(formatter: Date.defaultFormatter))
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondary)
                            }
                            HStack(spacing: 8) {
                                if let _ = project.genre_id {
                                    tagItem(text: "Lofi", style: .selection )
                                }
                                if let bpm = project.bpm {
                                    tagItem(text: "\(bpm) BPM", iconName: "timer")
                                }
                                if let key = project.key {
                                    tagItem(text: key.description, iconName: "music.quarternote.3")
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                Button {
                    
                } label: {
                    ZStack(alignment: .center) {
                        Circle()
                            .foregroundStyle(.orange)
                            .glassEffect()
                            .frame(width: 64, height: 64)
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.trailing, 24)
                .padding(.bottom, 8)
            }
            .navigationTitle("ライブラリ")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func tagItem(text: String, iconName: String? = nil, style: some ShapeStyle = .secondary) -> some View {
        HStack(spacing: 8) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(style)
            }
            Text(text)
                .lineLimit(1)
                .font(.system(size: 16))
                .foregroundStyle(style)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(style.opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        LibraryTabView()
    }
}
