//
//  Date+Extension.swift
//  Motif
//
//  Created by 市東 on 2026/05/10.
//

import Foundation

extension Date {
    
    func dateToString(formatter: DateFormatter) -> String {
        return formatter.string(from: self)
    }
}

extension DateFormatter {
    static let defaultFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter
    }()
}
