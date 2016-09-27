//
//  BaseTestClass.swift
//  SwiftLevelDBAppTests
//
//  Created by Mathieu D'Amours on 11/14/13
//  Modified by: Amr Aboelela on 8/23/16.
//

import XCTest
import Foundation
import Dispatch
import RengoFoundation

@testable import RengoFoundation

class BaseTestClass: XCTestCase {
    
    var database : Database?
    var lvldb_test_queue = DispatchQueue(label: "Create DB")
    
    override func setUp() {
        super.setUp()
        database = Database.sharedDatabase()
        database?.removeAllObjects()
    }
    
    override func tearDown() {
        database?.close()
        database = nil
        super.tearDown()
    }
}
