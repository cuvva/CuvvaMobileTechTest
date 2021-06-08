import Foundation

struct LivePolicyTermFormatter: PolicyTermFormatter {
    private let dateFormatter: DateFormatter
    private let dateComponentsFormatter: DateComponentsFormatter
    
    init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "E, d MMM yyyy h:mm a"
        
        self.dateComponentsFormatter = DateComponentsFormatter()
        self.dateComponentsFormatter.allowedUnits = [.month, .weekOfMonth, .day, .hour, .minute, .second]
        self.dateComponentsFormatter.maximumUnitCount = 1
        self.dateComponentsFormatter.unitsStyle = .full
        self.dateComponentsFormatter.zeroFormattingBehavior = .dropAll
    }
    
    func durationString(for: TimeInterval) -> String {
        guard let resultString = self.dateComponentsFormatter.string(from: `for`) else {
            return "Duration unknown"
        }
        return resultString + " Policy"
    }
    
    func durationRemainingString(for: PolicyTerm, relativeTo: Date) -> String {
        let duration = `for`.duration
        let passedTime = relativeTo.timeIntervalSince(`for`.startDate)
        let remainingTime = duration - passedTime
        return self.dateComponentsFormatter.string(from: remainingTime) ?? "Unknown time left"
    }
    
    func durationRemainingPercent(for: PolicyTerm, relativeTo: Date) -> Double {
        let progress = Double(relativeTo.timeIntervalSince(`for`.startDate)) / Double(`for`.duration)
        return min(max(progress, 0), 1)
    }
    
    func policyDateString(for: Date) -> String {
        return self.dateFormatter.string(from: `for`)
    }
}

