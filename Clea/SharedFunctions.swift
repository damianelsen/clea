//
//  SharedFunctions.swift
//  Clea
//
//  Created by Damian Elsen on 10/25/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import Foundation

class Shared {
    
    static func formatDate(fromDate date: Date) -> String {
        switch date {
        case Calendar.current.startOfDay(for: Date()):
            return "Today"
        case Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -1, to: Date())!):
            return "Yesterday"
        default:
            let dateFormatter = DateFormatter()
            
            dateFormatter.locale = .current
            dateFormatter.dateStyle = .medium
            
            return dateFormatter.string(from: date)
        }
    }
    
}
