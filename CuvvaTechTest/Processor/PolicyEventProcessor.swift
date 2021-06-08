import Foundation

protocol PolicyEventProcessor {
    func retrieve(for: Date) -> PolicyData
}

struct PolicyData {
    let activePolicies: [Policy]
    let historicVehicles: [Vehicle]
}
