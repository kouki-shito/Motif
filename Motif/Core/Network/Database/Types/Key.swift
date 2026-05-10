//
//  Key.swift
//  Motif
//
//  Created by 市東 on 2026/05/08.
//

import SQLiteData
import Foundation

enum Key: Int, QueryBindable, CaseIterable {
    case c, d_flat, d, e_flat, e, f, g_flat, g, a_flat, a, b_flat, b, c_minor, d_flat_minor, d_minor, e_flat_minor, e_minor, f_minor, g_flat_minor, g_minor, a_flat_minor, a_minor, b_flat_minor, b_minor
    
    var description: String {
        switch self {
        case .c:
            "C Major"
        case .d_flat:
            "Db Major"
        case .d:
            "D Major"
        case .e_flat:
            "Eb Major"
        case .e:
            "E Major"
        case .f:
            "F Major"
        case .g_flat:
            "Gb Major"
        case .g:
            "G Major"
        case .a_flat:
            "Ab Major"
        case .a:
            "A Major"
        case .b_flat:
            "Bb Major"
        case .b:
            "B Major"
        case .c_minor:
            "C Minor"
        case .d_flat_minor:
            "Db Minor"
        case .d_minor:
            "D Minor"
        case .e_flat_minor:
            "Eb Minor"
        case .e_minor:
            "E Minor"
        case .f_minor:
            "F Minor"
        case .g_flat_minor:
            "Gb Minor"
        case .g_minor:
            "G Minor"
        case .a_flat_minor:
            "Ab Minor"
        case .a_minor:
            "A Minor"
        case .b_flat_minor:
            "Bb Minor"
        case .b_minor:
            "B Minor"
        }
    }
    
    var shorName: String {
        switch self {
        case .c:
            "C"
        case .d_flat:
            "Db"
        case .d:
            "D"
        case .e_flat:
            "Eb"
        case .e:
            "E"
        case .f:
            "F"
        case .g_flat:
            "Gb"
        case .g:
            "G"
        case .a_flat:
            "Ab"
        case .a:
            "A"
        case .b_flat:
            "Bb"
        case .b:
            "B"
        case .c_minor:
            "Cm"
        case .d_flat_minor:
            "Dbm"
        case .d_minor:
            "Dm"
        case .e_flat_minor:
            "Ebm"
        case .e_minor:
            "Em"
        case .f_minor:
            "Fm"
        case .g_flat_minor:
            "Gbm"
        case .g_minor:
            "Gm"
        case .a_flat_minor:
            "Abm"
        case .a_minor:
            "Am"
        case .b_flat_minor:
            "Bbm"
        case .b_minor:
            "Bm"
        }
    }
}
