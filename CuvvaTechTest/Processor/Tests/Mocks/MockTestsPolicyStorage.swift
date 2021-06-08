//
//  File.swift
//  CuvvaTechTestTests
//
//  Created by Anton on 06/06/2021.
//

import Foundation
@testable import CuvvaTechTest

// Chebotov. This name is ugly, but MockPolicyStorage is unfortunatelly taken already
final class MockTestsPolicyStorage: PolicyStorageProtocol {
    var policies: [Policy] = []
    var vehicles: [Vehicle] = []
    
    private var storeCallCount = 0
    private var retrieveCallCount = 0
    
    init() {
    }
    
    func store(json: JSONResponse) {
        self.storeCallCount += 1
    }
    
    func retrieve() -> (policies: [Policy], vehicles: [Vehicle]) {
        self.retrieveCallCount += 1
        return (self.policies, self.vehicles)
    }
}
