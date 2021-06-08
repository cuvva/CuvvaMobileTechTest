//
//  File.swift
//  CuvvaTechTest
//
//  Created by Anton on 06/06/2021.
//

import Foundation

class MockPolicyStorage: PolicyStorageProtocol {
    func store(json: JSONResponse) { }
    
    var policies: [Policy] = []
    var vehicles: [Vehicle] = []
}
