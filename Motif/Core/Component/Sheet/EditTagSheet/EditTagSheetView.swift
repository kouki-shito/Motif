//
//  EditTagSheetView.swift
//  Motif
//
//  Created by 市東 on 2026/06/01.
//

import SwiftUI
import SQLiteData
import ComposableArchitecture

struct EditTagSheetView: View {
    @Bindable var store: StoreOf<EditTagReducer>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.baseGray)
                    .ignoresSafeArea()
                List {
                    ForEach(store.tags, id: \.id) { tag in
                        Button {
                            store.send(.view(.tagTapped(tag.id)))
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "tag")
                                    .foregroundStyle(.textBlack)
                                Text(tag.name)
                                Spacer()
                                Image(systemName: store.selectingTags.contains(tag.id) ? "checkmark.square.fill" : "square")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(store.selectingTags.contains(tag.id) ? .primaryBlue : .subGray)
                            }
                        }
                        .tint(.textBlack)
                        .contentShape(Rectangle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                store.send(.view(.deleteTagButtonTapped(tag)))
                            } label: {
                                Image(systemName: "trash.fill")
                                    .foregroundStyle(.baseWhite)
                            }
                            .tint(.dangerRed)
                        }
                    }
                    if store.isShowAddTagButton {
                        Button {
                            store.send(.view(.addTagButtonTapped))
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "plus")
                                    .foregroundStyle(.textBlack)
                                Text("\(store.searchingText)を追加")
                            }
                        }
                        .tint(.textBlack)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .searchable(text: $store.searchingText)
            .navigationTitle("タグ編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        store.send(.view(.cancelButtonTapped))
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                    }
                    .tint(.textBlack)
                    .contentShape(Rectangle())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm) {
                        store.send(.view(.confirmButtonTapped))
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                    .tint(.primaryBlue)
                    .buttonStyle(.glassProminent)
                }
            }
        }
        .onChange(of: store.isDismissed, { _, bool in
            guard bool else { return }
            dismiss()
        })
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}


#Preview {
    let _ = prepareDependencies {
        let db = try! appDatabase()
        $0.defaultDatabase = db
    }
    NavigationStack {
        EditTagSheetView(store: Store(initialState: EditTagReducer.State(selectingTags: []), reducer: {
            EditTagReducer()
        }))
    }
}
