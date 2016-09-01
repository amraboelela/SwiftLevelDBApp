//
//  BaseTestClass.swift
//  SwiftLevelDBAppTests
//
//  Created by Mathieu D'Amours on 11/14/13
//  Modified by: Amr Aboelela on 8/23/16.
//

import XCTest
import Foundation
#if swift(>=3.0)
import Dispatch
#endif
import SwiftLevelDB

#if swift(>=3.0)
#else
    public typealias Any = AnyObject
#endif

@testable import SwiftLevelDBApp

class BaseTestClass: XCTestCase {
    
    var db : LevelDB?
    static var db_i = 0
    #if swift(>=3.0)
    var lvldb_test_queue = DispatchQueue(label: "Create DB")
    #else
    var lvldb_test_queue : dispatch_queue_t = dispatch_queue_create("Create DB", DISPATCH_QUEUE_SERIAL)
    #endif
    
    override func setUp() {
        super.setUp()
        
        db = LevelDB.databaseInLibraryWithName("TestDB\(BaseTestClass.db_i)")
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        BaseTestClass.db_i += 1
        db.removeAllObjects()
        db.encoder = {(key: String, value: Any) -> Data? in
            do {
                #if swift(>=3.0)
                    return JSONSerialization.data(withJSONObject: value)
                #else
                    return try NSJSONSerialization.dataWithJSONObject(value, options: [])
                #endif
            } catch let error {
                print("Problem encoding data: \(error)")
                return nil
            }
        }
        db.decoder = {(key: String, data: Data) -> Any? in
            do {
                #if swift(>=3.0)
                    return try JSONSerialization.jsonObject(with: data)
                #else
                    return try NSJSONSerialization.JSONObjectWithData(data, options: [])
                #endif
            } catch let error {
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
