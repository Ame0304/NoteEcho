import Foundation
import SwiftData

class MockDataService {
    static func populateWithSampleData(modelContext: ModelContext) {
        // Check if data already exists
        let descriptor = FetchDescriptor<Book>()
        if let existingBooks = try? modelContext.fetch(descriptor), !existingBooks.isEmpty {
            return // Data already exists
        }
        
        // Create sample books
        let books = createSampleBooks()
        
        // Insert books and their highlights
        for book in books {
            modelContext.insert(book)
        }
        
        // Save the context
        try? modelContext.save()
    }
    
    private static func createSampleBooks() -> [Book] {
        var books: [Book] = []
        
        // Book 1: Atomic Habits
        let atomicHabits = Book(title: "Atomic Habits", author: "James Clear", assetId: "atomic-habits-001")
        atomicHabits.highlights = [
            Highlight(content: "You do not rise to the level of your goals. You fall to the level of your systems.", chapter: "Chapter 1: The Surprising Power of Atomic Habits", createdDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()),
            Highlight(content: "Every action you take is a vote for the type of person you wish to become.", note: "This really resonates with identity-based habits", chapter: "Chapter 2: How Your Habits Shape Your Identity", createdDate: Calendar.current.date(byAdding: .day, value: -25, to: Date()) ?? Date()),
            Highlight(content: "The most effective way to change your habits is to focus not on what you want to achieve, but on who you wish to become.", chapter: "Chapter 2: How Your Habits Shape Your Identity", createdDate: Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date()),
            Highlight(content: "Make it obvious, make it attractive, make it easy, make it satisfying.", note: "The four laws of behavior change", chapter: "Chapter 3: How to Build Better Habits", createdDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date()),
            Highlight(content: "Environment is the invisible hand that shapes human behavior.", chapter: "Chapter 6: Motivation Is Overrated", createdDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date())
        ]
        books.append(atomicHabits)
        
        // Book 2: The Psychology of Money
        let psychologyMoney = Book(title: "The Psychology of Money", author: "Morgan Housel", assetId: "psychology-money-002")
        psychologyMoney.highlights = [
            Highlight(content: "Doing well with money has a little to do with how smart you are and a lot to do with how you behave.", chapter: "Introduction", createdDate: Calendar.current.date(byAdding: .day, value: -35, to: Date()) ?? Date()),
            Highlight(content: "Your personal experiences with money make up maybe 0.00000001% of what's happened in the world, but maybe 80% of how you think the world works.", chapter: "Chapter 1: No One's Crazy", createdDate: Calendar.current.date(byAdding: .day, value: -28, to: Date()) ?? Date()),
            Highlight(content: "Getting money and keeping money are two different skills.", note: "Important distinction", chapter: "Chapter 4: Confounding Compounding", createdDate: Calendar.current.date(byAdding: .day, value: -22, to: Date()) ?? Date()),
            Highlight(content: "The hardest financial skill is getting the goalpost to stop moving.", chapter: "Chapter 2: Luck & Risk", createdDate: Calendar.current.date(byAdding: .day, value: -18, to: Date()) ?? Date())
        ]
        books.append(psychologyMoney)
        
        // Book 3: Thinking, Fast and Slow
        let thinkingFastSlow = Book(title: "Thinking, Fast and Slow", author: "Daniel Kahneman", assetId: "thinking-fast-slow-003")
        thinkingFastSlow.highlights = [
            Highlight(content: "A reliable way to make people believe in falsehoods is frequent repetition, because familiarity is not easily distinguished from truth.", chapter: "Chapter 5: Cognitive Ease", createdDate: Calendar.current.date(byAdding: .day, value: -40, to: Date()) ?? Date()),
            Highlight(content: "Nothing in life is as important as you think it is, while you are thinking about it.", chapter: "Chapter 13: Availability and Affect", createdDate: Calendar.current.date(byAdding: .day, value: -32, to: Date()) ?? Date()),
            Highlight(content: "The confidence that individuals have in their beliefs depends mostly on the quality of the story they can tell about what they see.", note: "Narrative fallacy", chapter: "Chapter 7: A Machine for Jumping to Conclusions", createdDate: Calendar.current.date(byAdding: .day, value: -26, to: Date()) ?? Date()),
            Highlight(content: "We can be blind to the obvious, and we are also blind to our blindness.", chapter: "Introduction", createdDate: Calendar.current.date(byAdding: .day, value: -19, to: Date()) ?? Date())
        ]
        books.append(thinkingFastSlow)
        
        // Book 4: Deep Work
        let deepWork = Book(title: "Deep Work", author: "Cal Newport", assetId: "deep-work-004")
        deepWork.highlights = [
            Highlight(content: "Human beings, it seems, are at their best when immersed deeply in something challenging.", chapter: "Introduction", createdDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()),
            Highlight(content: "The ability to perform deep work is becoming increasingly rare at exactly the same time it is becoming increasingly valuable in our economy.", note: "Key insight about modern economy", chapter: "Chapter 1: Deep Work Is Valuable", createdDate: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date()),
            Highlight(content: "Clarity about what matters provides clarity about what does not.", chapter: "Rule #3: Quit Social Media", createdDate: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date()),
            Highlight(content: "The deep life is not just economically lucrative, but also a life well lived.", chapter: "Conclusion", createdDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date())
        ]
        books.append(deepWork)
        
        // Book 5: Sapiens
        let sapiens = Book(title: "Sapiens: A Brief History of Humankind", author: "Yuval Noah Harari", assetId: "sapiens-005")
        sapiens.highlights = [
            Highlight(content: "The real difference between us and chimpanzees is the mysterious glue that enables millions of humans to cooperate effectively.", chapter: "Chapter 1: An Animal of No Significance", createdDate: Calendar.current.date(byAdding: .day, value: -45, to: Date()) ?? Date()),
            Highlight(content: "Culture tends to argue that it forbids only that which is unnatural. But from a biological perspective, nothing is unnatural.", chapter: "Chapter 8: There Is No Justice in History", createdDate: Calendar.current.date(byAdding: .day, value: -38, to: Date()) ?? Date()),
            Highlight(content: "We study history not to predict the future, but to free ourselves of the past and imagine alternative destinies.", note: "Great perspective on learning history", chapter: "Chapter 4: The Flood", createdDate: Calendar.current.date(byAdding: .day, value: -33, to: Date()) ?? Date()),
            Highlight(content: "One of history's few iron laws is that luxuries tend to become necessities and to spawn new obligations.", chapter: "Chapter 5: History's Biggest Fraud", createdDate: Calendar.current.date(byAdding: .day, value: -27, to: Date()) ?? Date())
        ]
        books.append(sapiens)
        
        return books
    }
}