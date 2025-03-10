//
//  ExpansesView.swift
//  Expenses
//
//  Created by Abdullah Hafiz on 07/09/1446 AH.
//

import Foundation
import SwiftUI

class ExpensesViewModel: ObservableObject {
    @Published var expenses: [Expanse] = []
    
    init() {
        loadExpenses()
    }
    
    func addExpanse(name: String, amount: Double, Catagory: String) {
        let newExpense = Expanse(name: name, amount: amount, Category: Catagory)
        expenses.append(newExpense)
        saveExpenses()
    }
    
    func sortExpenses(ascending: Bool) {
        if ascending {
            expenses.sort { $0.amount < $1.amount }
        } else {
            expenses.sort { $0.amount > $1.amount }
        }
    }
    
    func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
        saveExpenses()
    }
    
    func fliterExpenses(catagory: String?) -> [Expanse] {
        guard let catagory = catagory, !catagory.isEmpty else {
            return expenses
        }
        return expenses.filter { $0.Category == catagory }
    }
    
    
    // MARK: - Saving / Loading
    func saveExpenses() {
        do {
            let data = try JSONEncoder().encode(expenses)
            UserDefaults.standard.set(data, forKey: "expenses")
        } catch {
            print("Unable to encode expenses: \(error.localizedDescription)")
        }
    }
    
    func loadExpenses() {
        guard let data = UserDefaults.standard.data(forKey: "expenses") else { return }
        do {
            let decoded = try JSONDecoder().decode([Expanse].self, from: data)
            expenses = decoded
        } catch {
            print("Unable to decode expenses: \(error.localizedDescription)")
        }
    }
}
