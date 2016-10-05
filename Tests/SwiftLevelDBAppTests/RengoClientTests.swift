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
    //let data = "data"
    
    func testClientApplicationRun() {
        //XCTAssertNotNil(data, "Database should not be nil")
        ClientApplication(deviceID: "73946915A18B4908BD1E02D427149FC3", name: "Amr", bio: "Funny man has a flu", latitude: 37.764424, longitude: -120.652389).run()
    }

    /*
    func testContentIntegrity() {
        let key = "dict1"
        XCTAssertNotNil(key, "A key that was deleted in batch should return nil")
    }*/

    static var allTests : [(String, (RengoClientTests) -> () throws -> Void)] {
        return [
            ("testClientApplicationRun", testClientApplicationRun),
            //("testContentIntegrity", testContentIntegrity),
        ]
    }
}
