//
//  ContentView.swift
//  Expenses
//
//  Created by Abdullah Hafiz on 07/09/1446 AH.
//

import SwiftUI

struct ContentView: View {
    @State private var isDarkMode: Bool = false
    @State private var showingAddExpense = false
    @State private var selectedCategoryFilter: String = "All"
    
    @StateObject private var viewModel = ExpensesViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Dark/Light Mode Toggle
                    Toggle(isDarkMode ? "Light Mode" : "Dark Mode", isOn: $isDarkMode)
                        .padding()
                    
                    // ACTION ROW: includes Filter button and maybe a Sort button
                    HStack {
                        // Example Sort Buttons
                        Button("Sort Asc") {
                            viewModel.sortExpenses(ascending: true)
                        }
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button("Sort Desc") {
                            viewModel.sortExpenses(ascending: false)
                        }
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        // Filter Menu
                        Menu("Filter by Category") {
                            // 'All' means show everything
                            Button("All") {
                                selectedCategoryFilter = "All"
                            }
                            // For each known category, we add a button
                            ForEach(["Food", "Travel", "Shopping", "Other"], id: \.self) { cat in
                                Button(cat) {
                                    selectedCategoryFilter = cat
                                }
                            }
                        }
                        .padding(8)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    // Filter Info Text
                    Text("Filtering by: \(selectedCategoryFilter)")
                        .padding(.top, 5)
                    
                    // List of expenses
                    List {
                        ForEach(filteredExpenses) { expense in
                            HStack {
                                Text(expense.name)
                                Spacer()
                                Text(String(format: "$%.2f", expense.amount))
                            }
                            .padding()
                        }
                        .onDelete(perform: viewModel.deleteExpense)
                    }
                    .listStyle(.plain)
                    
                    // Add Expense Button (opens sheet)
                    Button(action: {
                        showingAddExpense = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 15, height: 15)
                            Text("Add Expense")
                        }
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .padding(.bottom)
                    .sheet(isPresented: $showingAddExpense) {
                        // Present the AddExpenseView as a sheet
                        AddExpenseView(viewModel: viewModel)
                    }
                }
                .padding()
                .navigationBarTitle("Expenses")
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    // Computed Property for Filtered Expenses
    private var filteredExpenses: [Expanse] {
        if selectedCategoryFilter == "All" {
            return viewModel.expenses
        } else {
            // Use the existing filter function or filter in-line
            return viewModel.fliterExpenses(catagory: selectedCategoryFilter)
        }
    }
}

#Preview {
    ContentView()
}

