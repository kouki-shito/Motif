//
//  DatabaseError.swift
//  Motif
//
//  Created by 市東 on 2026/05/11.
//

enum DatabaseError: Error {
    enum InsertError: Error {
        case titleIsBlank
    }
    enum UpdateError: Error {
        case titleIsBlank
    }
}
