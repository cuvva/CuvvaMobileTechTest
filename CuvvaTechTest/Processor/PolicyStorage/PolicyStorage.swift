//
//  PolicyStorage.swift
//  CuvvaTechTest
//
//  Created by Anton on 06/06/2021.
//

import Foundation

protocol PolicyStorageProtocol {
    func store(json: JSONResponse)
    
    var policies: [Policy] { get }
    var vehicles: [Vehicle] { get }
}

class PolicyStorage: PolicyStorageProtocol {
    private(set) var policies: [Policy] = []
    private(set) var vehicles: [Vehicle] = []
    
    func store(json: JSONResponse) {
        var policies: [Policy] = []
        var vehicles: [Vehicle] = []
        
        // Chebotov. Sorting may be costly if there are lots of events. On the other hand, it allows us to be sure we process events in the right order, so we can avoid conflicts with policies cancelled before creation
        json.sorted(by: { $0.payload.timestamp < $1.payload.timestamp })
            .forEach { event in
            switch event.type {
            case .created:
                if let policy = self.createNewPolicy(event: event, vehicles: &vehicles) {
                    policies.append(policy)
                }
            case .extended:
                self.extendPolicy(policies: &policies, event: event)
            case .cancelled:
                self.cancelPolicy(policies: &policies, event: event)
            default:
                return
            }
        }
        self.policies = policies
        self.vehicles = vehicles
    }
        
    private func createNewPolicy(event: JSONEvent, vehicles: inout [Vehicle]) -> Policy? {
        guard let startDate = event.payload.startDate,
              let endDate = event.payload.endDate,
              let jsonVehicle = event.payload.vehicle else {
            return nil
        }
        let vehicleId = self.generateId(for: jsonVehicle)
        
        let vehicle: Vehicle
        if let existingVehicle = vehicles.first(where: { $0.id == vehicleId }) {
            vehicle = existingVehicle
        } else {
            vehicle = Vehicle(
                id: vehicleId,
                displayVRM: jsonVehicle.prettyVrm,
                makeModel: "\(jsonVehicle.make) \(jsonVehicle.model)"
            )
            vehicles.append(vehicle)
        }

        return Policy(
            id: event.payload.policyId,
            term: PolicyTerm(startDate: startDate, duration: endDate.timeIntervalSince(startDate)),
            vehicle: vehicle
        )
    }

    private func extendPolicy(policies: inout [Policy], event: JSONEvent) {
        // Chebotov. It is not very clear how the extension works.
        // According to the README description, an extension can start only when the original term ends.
        // If that's not the case and we need to support policies active from 1pm to 2 pm and then from 3pm to 4pm,
        // then we need to store an array of terms for each policy. And I think that would be a better soultion
        guard let policyToExtendIndex = policies.firstIndex(where: { $0.id == event.payload.policyId }),
              let endDate = event.payload.endDate else { return }
        let policyToExtend = policies[policyToExtendIndex]
        var newTerm = policyToExtend.term
        newTerm.duration = endDate.timeIntervalSince(policyToExtend.term.startDate)
        let extendedPolicy = Policy(
            id: policyToExtend.id,
            term: newTerm,
            vehicle: policyToExtend.vehicle)
        policies[policyToExtendIndex] = extendedPolicy
    }
    
    private func cancelPolicy(policies: inout [Policy], event: JSONEvent) {
        guard let policyToCancelIndex = policies.firstIndex(where: { $0.id == event.payload.policyId }) else { return }
        let policyToExtend = policies[policyToCancelIndex]
        var newTerm = policyToExtend.term
        newTerm.duration = 0
        let cancelledPolicy = Policy(
            id: policyToExtend.id,
            term: newTerm,
            vehicle: policyToExtend.vehicle)
        policies[policyToCancelIndex] = cancelledPolicy
    }
    
    private func generateId(for vehicle: JSONVehicle) -> String {
        // Chebotov. It would be nice to get an id from the server
        return vehicle.make + vehicle.model + vehicle.prettyVrm
    }
}
