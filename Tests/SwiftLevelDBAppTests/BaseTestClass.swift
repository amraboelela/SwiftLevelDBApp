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
    
    var database : Database!
    //static var db_i = 0
    var lvldb_test_queue = DispatchQueue(label: "Create DB")
    
    override func setUp() {
        super.setUp()
        
        //database = LevelDB.databaseInLibraryWithName("TestDB\(BaseTestClass.db_i)")
        /*guard let database = database else {
            print("Database reference is not existent, failed to open / create database")
            return
        }*/
        //BaseTestClass.db_i += 1
        //database = Database(name: "TestDB") //\(BaseTestClass.db_i)")
        database = Database.database 
        database.removeAllObjects()
        /*database.encoder = {(key: String, value: Any) -> Data? in
            do {
                return try JSONSerialization.data(withJSONObject: value)
            } catch {
                print("Problem encoding data: \(error)")
                return nil
            }
        }
        database.decoder = {(key: String, data: Data) -> Any? in
            do {
                return try JSONSerialization.jsonObject(with: data)
            } catch {
                print("Problem decoding data: \(error)")
                return nil
            }
        }*/
    }
    
    override func tearDown() {
        /*guard let database = database else {
            print("Database reference is not existent, failed to open / create database")
            return
        }*/
        //database.close()
        //database.deleteDatabaseFromDisk()
        super.tearDown()
    }
}
