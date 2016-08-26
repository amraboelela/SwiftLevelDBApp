//
//  BaseTestClass.swift
//  SwiftLevelDBAppTests
//
//  Created by Mathieu D'Amours on 11/14/13
//  Modified by: Amr Aboelela on 8/23/16.
//

import XCTest
import SwiftLevelDB

@testable import SwiftLevelDBApp

class BaseTestClass: XCTestCase {
    
    var db : LevelDB?
    static var db_i = 0
    var lvldb_test_queue : dispatch_queue_t = dispatch_queue_create("Create DB", DISPATCH_QUEUE_SERIAL)
    
    override func setUp() {
        super.setUp()
        
        db = LevelDB.databaseInLibraryWithName("TestDB\(BaseTestClass.db_i)")
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        BaseTestClass.db_i += 1
        db.removeAllObjects()
        db.encoder = {(key: String, value: NSObject) -> NSData? in
            do {
                return try NSJSONSerialization.dataWithJSONObject(value, options: [])
            }
            catch let error {
                print("Problem encoding data: \(error)")
                return nil
            }
        }
        db.decoder = {(key: String, data: NSData) -> NSObject? in
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSObject
            }
            catch let error {
                print("Problem decoding data: \(error)")
                return nil
            }
        }
    }
    
    override func tearDown() {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        db.close()
        db.deleteDatabaseFromDisk()
        super.tearDown()
    }
}
