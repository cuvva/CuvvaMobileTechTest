import Foundation

class Vehicle: Identifiable, ObservableObject {
    
    let id: String
    let displayVRM: String
    let makeModel: String
    
    @Published var activePolicy: Policy?
    @Published var historicalPolicies: [Policy]
    
    init(id: String,
         displayVRM: String,
         makeModel: String,
         activePolicy: Policy? = nil,
         historicalPolicies: [Policy] = .init()) {
        self.id = id
        self.displayVRM = displayVRM
        self.makeModel = makeModel
        self._activePolicy = .init(initialValue: activePolicy)
        self._historicalPolicies = .init(wrappedValue: historicalPolicies)
    }
}

extension Vehicle: Equatable {
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.id == rhs.id &&
            lhs.displayVRM == rhs.displayVRM &&
            lhs.makeModel == rhs.makeModel
    }
}
