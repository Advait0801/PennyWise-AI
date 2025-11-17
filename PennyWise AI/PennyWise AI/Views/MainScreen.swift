//
//  MainScreen.swift
//  PennyWise AI
//
//  Created by Advait Naik on 11/15/25.
//

import SwiftUI
import Charts

// MARK: - Main Screen
struct MainScreen: View {
    @ObservedObject var authController: AuthController
    @ObservedObject var expenseController: ExpenseController
    @State private var selectedTab = 0
    @State private var showAddExpense = false
    @State private var showEditExpense = false
    @State private var selectedExpense: Expense? = nil
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                headerView(geometry: geometry)
                
                // Tab Selector
                tabSelector(geometry: geometry)
                
                // Content
                TabView(selection: $selectedTab) {
                    // Expenses List Tab
                    expensesListView(geometry: geometry)
                        .tag(0)
                    
                    // Statistics Tab
                    statisticsView(geometry: geometry)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView(
                    expenseController: expenseController,
                    token: authController.accessToken ?? ""
                )
            }
            .sheet(isPresented: $showEditExpense) {
                if let expense = selectedExpense {
                    EditExpenseView(
                        expense: expense,
                        expenseController: expenseController,
                        token: authController.accessToken ?? ""
                    )
                }
            }
            .task {
                if let token = authController.accessToken {
                    await expenseController.loadExpenses(token: token)
                    await expenseController.loadCategoryStats(token: token)
                }
            }
        }
    }
    
    // MARK: - Header View
    private func headerView(geometry: GeometryProxy) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome, \(authController.currentUser?.username ?? "User")")
                    .font(.system(size: dynamicFontSize(geometry, base: 24), weight: .bold))
                    .foregroundColor(.textPrimary)
                Text("Total: $\(String(format: "%.2f", expenseController.totalExpenses))")
                    .font(.system(size: dynamicFontSize(geometry, base: 16)))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Button(action: {
                authController.logout()
            }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: dynamicFontSize(geometry, base: 20)))
                    .foregroundColor(.negativeRed)
            }
        }
        .padding(.horizontal, geometry.size.width * 0.05)
        .padding(.vertical, geometry.size.height * 0.02)
        .background(Color.backgroundCard)
    }
    
    // MARK: - Tab Selector
    private func tabSelector(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = 0 }) {
                Text("Expenses")
                    .font(.system(size: dynamicFontSize(geometry, base: 16), weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: dynamicButtonHeight(geometry))
                    .background(selectedTab == 0 ? Color.primaryMint : Color.backgroundSoft)
                    .foregroundColor(selectedTab == 0 ? .white : .textPrimary)
            }
            
            Button(action: { selectedTab = 1 }) {
                Text("Statistics")
                    .font(.system(size: dynamicFontSize(geometry, base: 16), weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: dynamicButtonHeight(geometry))
                    .background(selectedTab == 1 ? Color.primaryMint : Color.backgroundSoft)
                    .foregroundColor(selectedTab == 1 ? .white : .textPrimary)
            }
        }
        .cornerRadius(0)
    }
    
    // MARK: - Expenses List View
    private func expensesListView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            if expenseController.expenses.isEmpty && !expenseController.isLoading {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: dynamicFontSize(geometry, base: 60)))
                        .foregroundColor(.textSecondary.opacity(0.5))
                    Text("No expenses yet")
                        .font(.system(size: dynamicFontSize(geometry, base: 18)))
                        .foregroundColor(.textSecondary)
                    Text("Tap + to add your first expense")
                        .font(.system(size: dynamicFontSize(geometry, base: 14)))
                        .foregroundColor(.textSecondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: dynamicSpacing(geometry)) {
                        ForEach(expenseController.expenses) { expense in
                            ExpenseRowView(
                                expense: expense,
                                geometry: geometry,
                                onEdit: {
                                    selectedExpense = expense
                                    showEditExpense = true
                                },
                                onDelete: {
                                    Task {
                                        await expenseController.deleteExpense(expenseId: expense.id, token: authController.accessToken ?? "")
                                        await expenseController.loadCategoryStats(token: authController.accessToken ?? "")
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.vertical, geometry.size.height * 0.02)
                }
            }
            
            // Add Button
            Button(action: {
                showAddExpense = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: dynamicFontSize(geometry, base: 24), weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: dynamicButtonHeight(geometry), height: dynamicButtonHeight(geometry))
                    .background(Color.primaryMint)
                    .clipShape(Circle())
                    .shadow(color: Color.primaryMint.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, geometry.size.height * 0.03)
        }
        .background(Color.backgroundSoft)
    }
    
    // MARK: - Statistics View
    private func statisticsView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(spacing: dynamicSpacing(geometry) * 1.5) {
                // Total Summary
                VStack(spacing: 8) {
                    Text("Total Spending")
                        .font(.system(size: dynamicFontSize(geometry, base: 18), weight: .medium))
                        .foregroundColor(.textSecondary)
                    Text("$\(String(format: "%.2f", expenseController.totalExpenses))")
                        .font(.system(size: dynamicFontSize(geometry, base: 36), weight: .bold))
                        .foregroundColor(.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, geometry.size.height * 0.03)
                .background(
                    LinearGradient(
                        colors: [Color.primaryMint.opacity(0.1), Color.accentLime.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .padding(.horizontal, geometry.size.width * 0.05)
                .padding(.top, geometry.size.height * 0.02)
                
                // Category Chart
                if !expenseController.categoryStats.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("By Category")
                            .font(.system(size: dynamicFontSize(geometry, base: 20), weight: .semibold))
                            .padding(.horizontal, geometry.size.width * 0.05)
                        
                        Chart(expenseController.categoryStats) { stat in
                            BarMark(
                                x: .value("Category", stat.category),
                                y: .value("Amount", stat.totalAmount)
                            )
                            .foregroundStyle(Category.color(for: stat.category))
                        }
                        .frame(height: geometry.size.height * 0.3)
                        .padding(.horizontal, geometry.size.width * 0.05)
                    }
                    
                    // Category List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category Breakdown")
                            .font(.system(size: dynamicFontSize(geometry, base: 20), weight: .semibold))
                            .padding(.horizontal, geometry.size.width * 0.05)
                        
                        ForEach(expenseController.categoryStats) { stat in
                            CategoryStatRowView(stat: stat, geometry: geometry)
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: dynamicFontSize(geometry, base: 60)))
                            .foregroundColor(.textSecondary.opacity(0.5))
                        Text("No statistics yet")
                            .font(.system(size: dynamicFontSize(geometry, base: 18)))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, geometry.size.height * 0.1)
                }
            }
        }
        .background(Color.backgroundSoft)
    }
    
    // MARK: - Dynamic Sizing Helpers
    private func dynamicFontSize(_ geometry: GeometryProxy, base: CGFloat) -> CGFloat {
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return base * max(scaleFactor, 0.8)
    }
    
    private func dynamicSpacing(_ geometry: GeometryProxy) -> CGFloat {
        let baseSpacing: CGFloat = 12
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return baseSpacing * max(scaleFactor, 0.8)
    }
    
    private func dynamicButtonHeight(_ geometry: GeometryProxy) -> CGFloat {
        let baseHeight: CGFloat = 44
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return baseHeight * max(scaleFactor, 0.8)
    }
}

// MARK: - Expense Row View
struct ExpenseRowView: View {
    let expense: Expense
    let geometry: GeometryProxy
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Color Indicator
            Circle()
                .fill(Category.color(for: expense.category))
                .frame(width: dynamicSize(geometry, base: 12), height: dynamicSize(geometry, base: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.system(size: dynamicFontSize(geometry, base: 16), weight: .medium))
                HStack(spacing: 8) {
                    Text(expense.category)
                        .font(.system(size: dynamicFontSize(geometry, base: 12)))
                        .foregroundColor(.textSecondary)
                    Text("•")
                        .foregroundColor(.textSecondary)
                    Text(expense.formattedDate)
                        .font(.system(size: dynamicFontSize(geometry, base: 12)))
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(expense.formattedAmount)")
                    .font(.system(size: dynamicFontSize(geometry, base: 18), weight: .semibold))
                Text("\(expense.confidencePercentage) confidence")
                    .font(.system(size: dynamicFontSize(geometry, base: 10)))
                    .foregroundColor(.textSecondary)
            }
            
            // Edit Button
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: dynamicFontSize(geometry, base: 16)))
                    .foregroundColor(.primaryMint)
            }
        }
        .padding(.vertical, dynamicSpacing(geometry))
        .padding(.horizontal, geometry.size.width * 0.03)
        .background(Color.backgroundCard)
        .cornerRadius(12)
        .shadow(color: Color.textPrimary.opacity(0.08), radius: 4, x: 0, y: 2)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func dynamicFontSize(_ geometry: GeometryProxy, base: CGFloat) -> CGFloat {
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return base * max(scaleFactor, 0.8)
    }
    
    private func dynamicSpacing(_ geometry: GeometryProxy) -> CGFloat {
        let baseSpacing: CGFloat = 8
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return baseSpacing * max(scaleFactor, 0.8)
    }
    
    private func dynamicSize(_ geometry: GeometryProxy, base: CGFloat) -> CGFloat {
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return base * max(scaleFactor, 0.8)
    }
}

// MARK: - Category Stat Row View
struct CategoryStatRowView: View {
    let stat: CategoryStat
    let geometry: GeometryProxy
    
    var body: some View {
        HStack {
            Circle()
                .fill(Category.color(for: stat.category))
                .frame(width: dynamicSize(geometry, base: 12), height: dynamicSize(geometry, base: 12))
            
            Text(stat.category)
                .font(.system(size: dynamicFontSize(geometry, base: 16)))
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(stat.formattedAmount)")
                    .font(.system(size: dynamicFontSize(geometry, base: 16), weight: .semibold))
                Text("\(stat.count) expense\(stat.count == 1 ? "" : "s")")
                    .font(.system(size: dynamicFontSize(geometry, base: 12)))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.vertical, dynamicSpacing(geometry))
        .padding(.horizontal, geometry.size.width * 0.05)
        .background(Color.backgroundCard)
        .cornerRadius(10)
        .shadow(color: Color.textPrimary.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal, geometry.size.width * 0.05)
    }
    
    private func dynamicFontSize(_ geometry: GeometryProxy, base: CGFloat) -> CGFloat {
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return base * max(scaleFactor, 0.8)
    }
    
    private func dynamicSpacing(_ geometry: GeometryProxy) -> CGFloat {
        let baseSpacing: CGFloat = 8
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return baseSpacing * max(scaleFactor, 0.8)
    }
    
    private func dynamicSize(_ geometry: GeometryProxy, base: CGFloat) -> CGFloat {
        let scaleFactor = min(geometry.size.width / 375, geometry.size.height / 812)
        return base * max(scaleFactor, 0.8)
    }
}
