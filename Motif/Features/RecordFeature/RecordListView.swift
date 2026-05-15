//
//  RecordListView.swift
//  Motif
//
//  Created by 市東 on 2026/05/14.
//

import SwiftUI

struct RecordListView: View {
    @State private var selectedCategory = "すべて"
    @State var searchText: String = ""
    private let categories = [
        "すべて", "Aメロ", "Bメロ", "サビ", "間奏", "アウトロ"
    ]
    private let records = VoiceMemo.sampleData
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    header()
                    tagFilter()
                    recordList()
                }
                .padding(.horizontal, 12)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(.fixed, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                Button {
                    
                } label: {
                    Circle()
                        .foregroundStyle(.red)
                }
            }
            
        }
    }
    
    @ViewBuilder
    func header() -> some View {
        HStack {
            Button {
                
            } label: {
                Text("すべてのメモ")
                    .font(.title2)
                    .fontWeight(.bold)
                Image(systemName: "chevron.down")
            }
            .tint(.primary)
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .frame(width: 20, height: 28)
                    .contentShape(Circle())
                    .tint(.primary)
            }
            .buttonStyle(.glass)
            
        }
        .padding(.trailing, 8)
        .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    func tagFilter() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(selectedCategory == category ? .white : .primary)
                            .padding(.horizontal, 14)
                            .frame(height: 30)
                            .background(
                                Capsule()
                                    .fill(selectedCategory == category ? Color.recordAccent : Color(.white))
                            )
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    @ViewBuilder
    func recordList() -> some View {
        List {
            ForEach(records) { record in
                recordRow(record: record)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .listRowSpacing(8)
        .listStyle(.plain)
        .buttonStyle(.plain)
        .searchable(text: $searchText)
    }
    
    @ViewBuilder
    func recordRow(record: VoiceMemo) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(record.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(record.category)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .frame(height: 20)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                Text(record.recordedAt)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Button {
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        )
                }
                .tint(Color.recordAccent)
                Text(record.duration)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct VoiceMemo: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let recordedAt: String
    let duration: String
    
    static let sampleData = [
        VoiceMemo(title: "ああああ", category: "Aメロ", recordedAt: "2024/05/20 14:30", duration: "02:45"),
        VoiceMemo(title: "新規メモ", category: "Aメロ", recordedAt: "2024/05/20 14:30", duration: "02:45"),
        VoiceMemo(title: "新規メモ", category: "Aメロ", recordedAt: "2024/05/20 14:30", duration: "02:45"),
        VoiceMemo(title: "新規メモ", category: "Aメロ", recordedAt: "2024/05/20 14:30", duration: "02:45"),
        VoiceMemo(title: "新規メモ", category: "Aメロ", recordedAt: "2024/05/20 14:30", duration: "02:45"),
        VoiceMemo(title: "新規メモ", category: "Aメロ", recordedAt: "2024/05/20 14:30", duration: "02:45"),
        VoiceMemo(title: "新規メモ", category: "Aメロ", recordedAt: "2024/05/20 14:30", duration: "02:45"),
        VoiceMemo(title: "新規メモ", category: "Aメロ", recordedAt: "2024/05/20 14:30", duration: "02:45"),
        VoiceMemo(title: "新規メモ", category: "Aメロ", recordedAt: "2024/05/20 14:30", duration: "02:45"),
        VoiceMemo(title: "新規メモ", category: "Aメロ", recordedAt: "2024/05/20 14:30", duration: "02:45"),
        VoiceMemo(title: "新規メモ", category: "Aメロ", recordedAt: "2024/05/20 14:30", duration: "02:45"),
        VoiceMemo(title: "新規メモ", category: "Aメロ", recordedAt: "2024/05/20 14:30", duration: "02:45"),
    ]
}

private extension Color {
    static let recordAccent = Color(red: 0.43, green: 0.30, blue: 0.89)
}

#Preview {
    NavigationStack {
        RecordListView()
    }
}
