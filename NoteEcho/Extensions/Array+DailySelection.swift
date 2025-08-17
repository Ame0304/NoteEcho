import Foundation

extension Array where Element == Highlight {
    // Get a consistent daily random highlight that changes once per day
    var dailyRandomHighlight: Highlight? {
        guard !isEmpty else { return nil }
        
        // Create a seed based on the current date to ensure the same highlight all day
        let calendar = Calendar.current
        let today = Date()
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        // Combine date components to create a consistent daily seed
        let dateSeed = (dateComponents.year ?? 0) * 10000 + 
                      (dateComponents.month ?? 0) * 100 + 
                      (dateComponents.day ?? 0)
        
        // Add the count of highlights to the seed for more variation
        let seed = dateSeed + count
        
        // Use the seed to get a consistent index
        let index = abs(seed) % count
        return self[index]
    }
}