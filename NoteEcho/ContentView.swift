//
//  ContentView.swift
//  NoteEcho
//
//  Created by Vera Ren on 2025-08-05.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // SwiftData environment - this gives us access to the database context
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData queries - these automatically fetch and update data from the database
    @Query private var books: [Book]
    @Query private var allHighlights: [Highlight]
    
    // State variables - these hold the current UI state and trigger view updates when changed
    @State private var selectedBook: Book?     // Currently selected book for filtering (nil = all books)
    @State private var sortByNewest = true     // Sort direction: true = newest first, false = oldest first
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool // Track search field focus state
    
    // Computed property that filters and sorts highlights based on current UI state
    // This automatically recalculates whenever any of the state variables change
    private var filteredHighlights: [Highlight] {
        var highlights = allHighlights
        
        // Step 1: Filter by selected book (if any)
        if let selectedBook = selectedBook {
            // $0.book?.id - Gets the ID of the book that this highlight belongs to
            highlights = highlights.filter { $0.book?.id == selectedBook.id }
        }
        
        // Step 2: Filter by search text (searches in content, notes, and book titles)
        if !searchText.isEmpty {
            highlights = highlights.filter { highlight in
                highlight.content.localizedCaseInsensitiveContains(searchText) ||
                highlight.note?.localizedCaseInsensitiveContains(searchText) == true ||
                highlight.book?.title.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Step 3: Sort by creation date
        return highlights.sorted { 
            sortByNewest ? $0.createdDate > $1.createdDate : $0.createdDate < $1.createdDate
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Filter and Sort Controls
                VStack(spacing: 12) {
                    // Search bar - enhanced styling with focus states and colors
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(isSearchFocused ? .blue : .secondary)
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("Search highlights...", text: $searchText)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .focused($isSearchFocused) // Bind to focus state
                        
                        // Clear button when there's text
                        if !searchText.isEmpty {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    searchText = ""
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 14))
                            }
                            .buttonStyle(.plain)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.regularMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isSearchFocused ? .blue : .gray.opacity(0.3), lineWidth: isSearchFocused ? 2 : 1)
                            )
                    )
                    .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
                    .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
                    
                    // Filter and sort controls row
                    HStack {
                        // Book filter dropdown menu - enhanced with colors and modern styling
                        Menu {
                            Button("All Books") {
                                selectedBook = nil  // Setting to nil shows all books
                            }
                            Divider()
                            // Create a button for each book
                            ForEach(books, id: \.id) { book in
                                Button(book.title) {
                                    selectedBook = book  // Filter to this specific book
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: selectedBook != nil ? "book.closed.fill" : "book.closed")
                                    .foregroundStyle(selectedBook != nil ? .blue : .secondary)
                                    .font(.system(size: 14, weight: .medium))
                                
                                Text(selectedBook?.title ?? "All Books")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(selectedBook != nil ? .blue : .primary)
                                
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedBook != nil ? .blue.opacity(0.1) : .gray.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedBook != nil ? .blue.opacity(0.3) : .gray.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        Spacer()  // Push the sort button to the right
                        
                        // Sort direction toggle button - enhanced with colors and modern styling
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                sortByNewest.toggle()  // Flip between newest/oldest first
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: sortByNewest ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                    .foregroundStyle(sortByNewest ? .orange : .green)
                                    .font(.system(size: 14, weight: .medium))
                                
                                Text(sortByNewest ? "Newest" : "Oldest")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill((sortByNewest ? Color.orange : Color.green).opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke((sortByNewest ? Color.orange : Color.green).opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12) // Add space from window title bar
                .padding(.bottom, 8)
                
                // MARK: - Highlights Display Area
                // Show either the highlights list or an empty state message
                if filteredHighlights.isEmpty {
                    // Empty state - shown when no highlights match the current filters
                    VStack(spacing: 16) {
                        Image(systemName: "highlighter")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No highlights found")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        // Show different message if user is searching vs. no highlights at all
                        if !searchText.isEmpty {
                            Text("Try adjusting your search")
                                .font(.body)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)  // Center the empty state
                } else {
                    // Highlights list - scrollable list of highlight cards
                    ScrollView {
                        // LazyVStack only creates views as needed (good for performance)
                        LazyVStack(spacing: 20) {
                            ForEach(filteredHighlights, id: \.id) { highlight in
                                HighlightCard(highlight: highlight)
                                    .padding(.horizontal)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                                        removal: .scale(scale: 0.9).combined(with: .opacity)
                                    ))
                            }
                        }
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: filteredHighlights)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Highlights")  // Sets the title in the navigation bar
            .onAppear {
                // Populate with sample data when the view first appears
                // This only runs once since MockDataService checks if data already exists
                MockDataService.populateWithSampleData(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Book.self, Highlight.self], inMemory: true)
}
