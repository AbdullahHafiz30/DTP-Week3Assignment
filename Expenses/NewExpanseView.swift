//
//  NewWxpanseView.swift
//  Expenses
//
//  Created by عبدالله حافظ on 09/09/1446 AH.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ExpensesViewModel
    
    @State private var expenseName: String = ""
    @State private var expenseAmount: String = ""
    @State private var selectedCategory: String = "Food"
    
    let categories = ["Food", "Travel", "Shopping", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Expense")) {
                    TextField("Expense Name", text: $expenseName)
                    
                    TextField("Expense Amount", text: $expenseAmount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                }
            }
            .navigationTitle("New Expense")
            .toolbar {
                // Cancel Button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                // Save Button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amount = Double(expenseAmount) {
                            viewModel.addExpanse(name: expenseName, amount: amount, Catagory: selectedCategory)
                            // Optionally save to UserDefaults immediately
                            viewModel.saveExpenses()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddExpenseView(viewModel: ExpensesViewModel())
}

