//
//  Expense.swift
//  Expenses
//
//  Created by Abdullah Hafiz on 10/09/1446 AH.
//

import SwiftUI

struct Expanse: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Double
    var Category: String
}


