# Expenses Tracker (SwiftUI)

An iOS application built using **SwiftUI** to help users track their personal expenses. Users can add, view, sort, and filter expenses, plus toggle dark/light mode. The app persists data using **UserDefaults** and `Codable`.

---

## Features

1. **Add New Expense**
   - Enter the name, amount, and choose a category (e.g., Food, Travel, Shopping, Other).
   - Automatically saves the expense in `UserDefaults`.

2. **View Expenses List**
   - Displays each expense's name, amount, and category.
   - Dynamically updated using `@ObservedObject` and `@Published`.

3. **Dark/Light Mode Toggle**
   - A simple `Toggle` allows switching between dark and light mode.

4. **Sort Expenses**
   - Two buttons to sort expenses in ascending or descending order by amount.

5. **Filter Expenses**
   - A filter button/menu to display expenses by selected category (or show all).

6. **Persistence**
   - Data is stored using `UserDefaults` so expenses remain after the app restarts.

---

## Code Overview

### Model
```swift
struct Expanse: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Double
    var Category: String
}
```
- Conforms to `Identifiable` for use in SwiftUI lists.
- Conforms to `Codable` to enable easy saving/loading with JSONEncoder and JSONDecoder.

##

### View Model
```swift
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
    
    // MARK: - Persistence
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
```
- `ExpensesViewModel` uses `@Published` to broadcast changes to the `expenses` array.
- `saveExpenses()` and `loadExpenses()` handle data persistence in `UserDefaults`.
- `sortExpenses(ascending:)` sorts the array by amount.
- `fliterExpenses(catagory:)` returns a filtered list of expenses matching the given category.

##

### Main View (`ContentView`)
```swift
struct ContentView: View {
    @State private var isDarkMode: Bool = false
    @State private var showingAddExpense = false
    @State private var selectedCategoryFilter: String = "All"
    
    @StateObject private var viewModel = ExpensesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Dark/Light Mode Toggle
                Toggle(isDarkMode ? "Light Mode" : "Dark Mode", isOn: $isDarkMode)
                    .padding()

                // Action Row (Sort & Filter)
                HStack {
                    // Sort Asc
                    Button("Sort Asc") {
                        viewModel.sortExpenses(ascending: true)
                    }
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    // Sort Desc
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
                
                Text("Filtering by: \(selectedCategoryFilter)")
                
                // List of filtered expenses
                List {
                    ForEach(filteredExpenses) { expense in
                        HStack {
                            Text(expense.name)
                            Spacer()
                            Text(String(format: "$%.2f", expense.amount))
                        }
                    }
                    .onDelete(perform: viewModel.deleteExpense)
                }
                
                // Add Expense Button
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
                }
                .sheet(isPresented: $showingAddExpense) {
                    AddExpenseView(viewModel: viewModel)
                }
            }
            .navigationTitle("Expenses")
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    // Computed property for filtered expenses
    private var filteredExpenses: [Expanse] {
        if selectedCategoryFilter == "All" {
            return viewModel.expenses
        } else {
            return viewModel.fliterExpenses(catagory: selectedCategoryFilter)
        }
    }
}
```
- Uses `@State` to manage the dark mode toggle, the “Add Expense” sheet, and selected filter category.
- Shows a list of expenses (filtered as needed).
- Presents the `AddExpenseView` in a sheet to create new expenses.

##

### AddExpenseView
```swift
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
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
```
- Collects new expense details in a `Form`.
- Passes input back to `ExpensesViewModel` via `viewModel.addExpanse(...)`.
- Automatically dismisses on save or cancel.

##

### Getting Started
1. Clone or Download the project.
2. Open the .xcodeproj or .xcworkspace in Xcode.
3. Build and Run the app (e.g., on a simulator or device running iOS).
4. Add expenses by tapping the “Add Expense” button.
5. Toggle Dark/Light Mode with the switch at the top.
6. Sort ascending or descending by amount using the respective button.
7. Filter by choosing a category in the “Filter by Category” menu.

##

### Requirements
- Xcode 14+ (recommended)
- iOS 16+ (SwiftUI)
- Swift 5.7+ (typical with recent Xcode versions)

##

### Contributing
Feel free to submit pull requests or open issues for improvements, bug fixes, or new features.








