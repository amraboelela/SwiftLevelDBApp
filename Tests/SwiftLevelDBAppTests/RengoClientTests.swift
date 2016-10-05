//
//  RengoClientTests.swift
//  SwiftLevelDBAppTests
//
//  Created by: Amr Aboelela on 10/4/16.
//

import XCTest
import Foundation
import Dispatch
import RengoFoundation

@testable import RengoFoundation

class RengoClientTests: XCTestCase {
    
    func testClientApplicationRun() {
        ClientApplication(deviceID: "73946915A18B4908BD1E02D427149FC3", name: "Amr", bio: "Funny man has a flu", latitude: 37.764424, longitude: -120.652389).run()
    }

    static var allTests : [(String, (RengoClientTests) -> () throws -> Void)] {
        return [
            ("testClientApplicationRun", testClientApplicationRun),
        ]
    }
}
