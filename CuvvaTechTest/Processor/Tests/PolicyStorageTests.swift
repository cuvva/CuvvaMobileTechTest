//
//  file.swift
//  CuvvaTechTestTests
//
//  Created by Anton on 06/06/2021.
//

import XCTest
@testable import CuvvaTechTest

class PolicyStorageTests: XCTestCase {
    
    private var sut: PolicyStorage!

    override func setUp() {
        super.setUp()
        
        self.sut = PolicyStorage()
    }

    override func tearDown() {
        self.sut = nil
        
        super.tearDown()
    }

    func test_WhenPolicyIsCancelledBeforeCreation_ThenValidPolicyIsStored() {
        // Given
        let vehicle = self.createJsonVehicle()
        let events = [
            JSONEvent(
                type: .created,
                payload: JSONPayload(
                    policyId: "policyId1",
                    vehicle: vehicle,
                    timestamp: Date(timeIntervalSince1970: 100),
                    startDate: Date(timeIntervalSince1970: 200),
                    endDate: Date(timeIntervalSince1970: 300)
                )
            ),
            JSONEvent(
                type: .cancelled,
                payload: JSONPayload(
                    policyId: "policyId1",
                    vehicle: vehicle,
                    timestamp: Date(timeIntervalSince1970: 50),
                    startDate: nil,
                    endDate: nil
                )
            )
        ]
        // When
        self.sut.store(json: events)
        // Then
        XCTAssertEqual(self.sut.vehicles.count, 1)
        XCTAssertEqual(self.sut.policies.count, 1)
        XCTAssertEqual(self.sut.policies[0].term.duration, 100)
    }
    
    func test_WhenPolicyIsCancelledAfterCreation_ThenCancelledPolicyIsStored() {
        // Given
        let vehicle = self.createJsonVehicle()
        let events = [
            JSONEvent(
                type: .created,
                payload: JSONPayload(
                    policyId: "policyId1",
                    vehicle: vehicle,
                    timestamp: Date(timeIntervalSince1970: 100),
                    startDate: Date(timeIntervalSince1970: 200),
                    endDate: Date(timeIntervalSince1970: 300)
                )
            ),
            JSONEvent(
                type: .cancelled,
                payload: JSONPayload(
                    policyId: "policyId1",
                    vehicle: vehicle,
                    timestamp: Date(timeIntervalSince1970: 150),
                    startDate: nil,
                    endDate: nil
                )
            )
        ]
        // When
        self.sut.store(json: events)
        // Then
        XCTAssertEqual(self.sut.vehicles.count, 1)
        XCTAssertEqual(self.sut.policies.count, 1)
        XCTAssertEqual(self.sut.policies[0].term.duration, 0)
    }

    func test_WhenPolicyIsExtendedAfterCreation_ThenValidPolicyIsStored() {
        // Given
        let vehicle = self.createJsonVehicle()
        let events = [
            JSONEvent(
                type: .created,
                payload: JSONPayload(
                    policyId: "policyId1",
                    vehicle: vehicle,
                    timestamp: Date(timeIntervalSince1970: 100),
                    startDate: Date(timeIntervalSince1970: 200),
                    endDate: Date(timeIntervalSince1970: 300)
                )
            ),
            JSONEvent(
                type: .extended,
                payload: JSONPayload(
                    policyId: "policyId1",
                    vehicle: vehicle,
                    timestamp: Date(timeIntervalSince1970: 150),
                    startDate: Date(timeIntervalSince1970: 300),
                    endDate: Date(timeIntervalSince1970: 400)
                )
            )
        ]
        // When
        self.sut.store(json: events)
        // Then
        XCTAssertEqual(self.sut.vehicles.count, 1)
        XCTAssertEqual(self.sut.policies.count, 1)
        XCTAssertEqual(self.sut.policies[0].term.duration, 200)
    }
    
    func test_WhenPolicyIsExtendedMultipleTimes_ThenPolicyWithTheCorrectDutationIsStored() {
        // Given
        let vehicle = self.createJsonVehicle()
        let events = [
            JSONEvent(
                type: .created,
                payload: JSONPayload(
                    policyId: "policyId1",
                    vehicle: vehicle,
                    timestamp: Date(timeIntervalSince1970: 100),
                    startDate: Date(timeIntervalSince1970: 200),
                    endDate: Date(timeIntervalSince1970: 300)
                )
            ),
            JSONEvent(
                type: .extended,
                payload: JSONPayload(
                    policyId: "policyId1",
                    vehicle: vehicle,
                    timestamp: Date(timeIntervalSince1970: 150),
                    startDate: Date(timeIntervalSince1970: 300),
                    endDate: Date(timeIntervalSince1970: 400)
                )
            ),
            JSONEvent(
                type: .extended,
                payload: JSONPayload(
                    policyId: "policyId1",
                    vehicle: vehicle,
                    timestamp: Date(timeIntervalSince1970: 250),
                    startDate: Date(timeIntervalSince1970: 400),
                    endDate: Date(timeIntervalSince1970: 500)
                )
            )
        ]
        // When
        self.sut.store(json: events)
        // Then
        XCTAssertEqual(self.sut.vehicles.count, 1)
        XCTAssertEqual(self.sut.policies.count, 1)
        XCTAssertEqual(self.sut.policies[0].term.duration, 300)
    }
    
    // Chebotov. I'd add tests for 'extended after cancellation' and 'extended with a start date not matching the original expiration', but requirements are not very clear here
    
    private func createJsonVehicle() -> JSONVehicle {
        return JSONVehicle(
            prettyVrm: "vrm",
            make: "make",
            model: "model")
    }
}
