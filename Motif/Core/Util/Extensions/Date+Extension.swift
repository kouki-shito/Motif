//
//  Date+Extension.swift
//  Motif
//
//  Created by 市東 on 2026/05/10.
//

import Foundation

extension Date {
    func dateToString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
