import Foundation

struct MockPolicyModel: PolicyEventProcessor {
    
    func retrieve(for: Date) -> PolicyData {
        
        let vehicles = [
            Vehicle(id: "UKPL8TE", displayVRM: "UK PL8TE", makeModel: "Volkswagen Polo"),
            Vehicle(id: "D1PLO", displayVRM: "D1 PLO", makeModel: "Mercedes-Benz C350"),
            Vehicle(id: "LB07SEO", displayVRM: "LB07 SEO", makeModel: "MINI Cooper"),
            Vehicle(id: "FX1", displayVRM: "FX 1", makeModel: "Ford Fiesta")
        ].shuffled()
        
        
        let activePolicy = Policy(
            id: UUID().uuidString,
            term: .init(startDate: .distantPast, duration: Date.distantPast.distance(to: .distantFuture)),
            vehicle: vehicles[0]
        )
        
        vehicles[0].activePolicy = activePolicy
        
        vehicles.forEach { vehicle in
            vehicle.historicalPolicies = (0...5).map { _ in
                Policy(
                    id: UUID().uuidString,
                    term: .init(startDate: .distantPast, duration: 1),
                    vehicle: vehicle
                )
            }
        }
        
        return
            .init(
                activePolicies: [activePolicy],
                historicVehicles: Array(vehicles[1...])
        )
    }
    
}
