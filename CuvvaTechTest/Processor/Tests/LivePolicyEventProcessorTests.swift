//
//  LivePolicyEventProcessorTests.swift
//  CuvvaTechTestTests
//
//  Created by Anton on 06/06/2021.
//

import XCTest
@testable import CuvvaTechTest

class LivePolicyEventProcessorTests: XCTestCase {
    private var storage: MockTestsPolicyStorage!
    private var sut: LivePolicyEventProcessor!
    
    override func setUp() {
        super.setUp()
        
        self.storage = MockTestsPolicyStorage()
        self.sut = LivePolicyEventProcessor(policyStorage: self.storage)
    }

    override func tearDown() {
        self.storage = nil
        self.sut = nil
        
        super.tearDown()
    }

    func test_GivenAllPoliciesExpired_WhenPoliciesAreRequested_ThenNoActivePoliciesReturned() throws {
        // Given
        let vehicle = Vehicle(id: "id", displayVRM: "vrm", makeModel: "makeModel")
        let policyTerm = PolicyTerm(
            startDate: Date(timeIntervalSince1970: 100),
            duration: 100
        )
        self.storage.policies = [
            Policy(
                id: "",
                term: policyTerm,
                vehicle: vehicle
            )
        ]
        self.storage.vehicles = [vehicle]
        // When
        let result = self.sut.retrieve(for: Date(timeIntervalSince1970: 300))
        // Then
        XCTAssertEqual(result.activePolicies.count, 0)
        XCTAssertEqual(result.historicVehicles, [vehicle])
        XCTAssertEqual(result.historicVehicles[0].historicalPolicies.count, 1)
    }
    
    func test_GivenPolicyDidntStartYet_WhenPoliciesAreRequested_ThenCorrectActivePoliciesReturned() throws {
        // Given
        let vehicle = Vehicle(id: "id", displayVRM: "vrm", makeModel: "makeModel")
        let policyTerm = PolicyTerm(
            startDate: Date(timeIntervalSince1970: 300),
            duration: 100
        )
        self.storage.policies = [
            Policy(
                id: "",
                term: policyTerm,
                vehicle: vehicle
            )
        ]
        // When
        let result = self.sut.retrieve(for: Date(timeIntervalSince1970: 200))
        // Then
        XCTAssertEqual(result.activePolicies.count, 1)
        XCTAssertEqual(result.historicVehicles.count, 0)
        XCTAssertEqual(result.activePolicies[0].vehicle.historicalPolicies.count, 0)
    }
    
    func test_GivenSomePoliciesStartedAndSomeExpired_WhenPoliciesAreRequested_ThenCorrectActivePoliciesReturned() throws {
        // Given
        let vehicle = Vehicle(id: "id", displayVRM: "vrm", makeModel: "makeModel")
        let policyTerm1 = PolicyTerm(
            startDate: Date(timeIntervalSince1970: 100),
            duration: 100
        )
        
        let policyTerm2 = PolicyTerm(
            startDate: Date(timeIntervalSince1970: 300),
            duration: 100
        )
        
        self.storage.policies = [
            Policy(
                id: "",
                term: policyTerm1,
                vehicle: vehicle
            ),
            Policy(
                id: "",
                term: policyTerm2,
                vehicle: vehicle
            )
        ]
        // When
        let result = self.sut.retrieve(for: Date(timeIntervalSince1970: 350))
        // Then
        XCTAssertEqual(result.activePolicies.count, 1)
        XCTAssertEqual(result.historicVehicles.count, 0)
        XCTAssertEqual(result.activePolicies[0].vehicle.historicalPolicies.count, 1)
    }
}
