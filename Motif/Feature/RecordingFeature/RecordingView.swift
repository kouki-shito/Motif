//
//  RecordingView.swift
//  Motif
//
//  Created by 市東 on 2026/05/16.
//

import SwiftUI
import ComposableArchitecture
import SQLiteData

struct RecordingView: View {
    
    @Bindable var store: StoreOf<RecordingReducer>
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("新しいボイスメモ")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    tagChips()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 28)
                .padding(.horizontal, 20)
                
                Spacer()
                
                VStack(spacing: 64) {
                    RecordingWaveformView()
                        .frame(height: 160)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 8) {
                        Text("00:01:28")
                            .font(.system(size: 32))
                            .monospaced()
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.recordingRed)
                                .frame(width: 8, height: 8)
                            Text("録音中...")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.recordingRed)
                        }
                    }
                }
                
                Spacer()
                
                controls()
                    .padding(.horizontal, 34)
                    .padding(.bottom, 30)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .fontWeight(.semibold)
                    }
                    .tint(.primary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func tagChips() -> some View {
        HStack(spacing: 8) {
            
            Button {
                
            } label: {
                Label("タグを追加", systemImage: "plus")
                    .labelStyle(.titleAndIcon)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 8)
                    .frame(height: 32)
                    .background(Color(.systemGray6), in: Capsule())
            }
        }
    }
    
    @ViewBuilder
    private func controls() -> some View {
        HStack(alignment: .center) {
            RecordingControlButton(
                title: "マーク",
                systemImage: "flag.fill"
            ) {}
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "stop.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 68, height: 68)
                    .background(Color.recordingRed, in: Circle())
                    .shadow(color: Color.recordingRed.opacity(0.18), radius: 18, y: 8)
            }
            
            Spacer()
            
            RecordingControlButton(
                title: "一時停止",
                systemImage: "pause.fill"
            ) {
                
            }
        }
    }
}

private struct RecordingTagChip: View {
    
    let title: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
            Image(systemName: "xmark")
                .font(.system(size: 8, weight: .bold))
        }
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 10)
        .frame(height: 28)
        .background(Color(.systemGray6), in: Capsule())
    }
}

private struct RecordingWaveformView: View {
    
    private let levels: [CGFloat] = [
        0.28, 0.50, 0.38, 0.66, 0.26, 0.74, 0.34, 0.58,
        0.82, 0.42, 0.64, 0.32, 0.90, 0.46, 0.70, 0.54,
        0.78, 0.36, 0.62, 0.88, 0.48, 0.74, 0.56, 0.34,
        0.66, 0.52, 0.40, 0.58, 0.30, 0.44, 0.34, 0.48,
        0.26, 0.38, 0.30, 0.42, 0.24, 0.34, 0.28, 0.36
    ]
    
    var body: some View {
        GeometryReader { proxy in
            let barWidth: CGFloat = 3
            let spacing: CGFloat = 4
            let maxHeight = proxy.size.height
            
            HStack(alignment: .center, spacing: spacing) {
                ForEach(levels.indices, id: \.self) { index in
                    Capsule()
                        .fill(index < 24 ? Color.recordAccent : Color(.systemGray4))
                        .frame(
                            width: barWidth,
                            height: max(10, maxHeight * levels[index])
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .accessibilityHidden(true)
    }
}

private struct RecordingControlButton: View {
    
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 42, height: 42)
                    .background(Color(.systemGray6), in: Circle())
                    .overlay {
                        Circle()
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    }
                
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .frame(width: 70)
        }
    }
}

private extension Color {
    static let recordAccent = Color(red: 0.43, green: 0.30, blue: 0.89)
    static let recordingRed = Color(red: 0.94, green: 0.22, blue: 0.24)
}

#Preview {
    let _ = prepareDependencies {
        let db = try! appDatabase()
        $0.defaultDatabase = db
    }
    RecordingView(store: Store(initialState: RecordingReducer.State(), reducer: {
        RecordingReducer()
    }))
}
