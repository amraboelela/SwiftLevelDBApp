//
//  MainTests.swift
//  SwiftLevelDBAppTests
//
//  Created by Mathieu D'Amours on 11/13/13.
//  Modified by: Amr Aboelela on 8/23/16.
//

import XCTest
import Foundation

class MainTests: BaseTestClass {

    var numberOfIterations = 2500
    //var pair = pairs[r]
    
    func testDatabaseCreated() {
        XCTAssertNotNil(db, "Database should not be nil")
    }

    func testContentIntegrity() {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        let key = "dict1"
        let value1 = ["foo": "bar"]
        db[key] = value1
        XCTAssertEqual(db[key] as! [String : String], value1, "Saving and retrieving should keep an dictionary intact")
        db.removeObjectForKey("dict1")
        XCTAssertNil(db["dict1"], "A deleted key should return nil")
        let value2 = ["foo", "bar"]
        db[key] = value2
        XCTAssertEqual(db[key] as! [String], value2, "Saving and retrieving should keep an array intact")
        db.removeObjectsForKeys(["array1"])
        XCTAssertNil(db["array1"], "A key that was deleted in batch should return nil")
    }

    func testKeysManipulation() {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        let value = ["foo": "bar"]
        db["dict1"] = value
        db["dict2"] = value
        db["dict3"] = value
        let keys = ["dict1", "dict2", "dict3"]
        let keysFromDB = db.allKeys()
        XCTAssertEqual(keysFromDB, keys, "-[LevelDB allKeys] should return the list of keys used to insert data")
        db.removeAllObjects()
        XCTAssertEqual(db.allKeys(), [], "The list of keys should be empty after removing all objects from the database")
    }

    func testRemovingKeysWithPrefix() {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        let value = ["foo": "bar"]
        db["dict1"] = value
        db["dict2"] = value
        db["dict3"] = value
        db["array1"] = [1, 2, 3]
        db.removeAllObjectsWithPrefix("dict")
        XCTAssertEqual(db.allKeys().count, Int(1), "There should be only 1 key remaining after removing all those prefixed with 'dict'")
    }

    func testDictionaryManipulations() {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        var objects = ["key1": [1, 2], "key2": ["foo": "bar"], "key3": [[:]]]
        db.addEntriesFromDictionary(objects)
        var keys = ["key1", "key2", "key3"]
        for key in keys {
            XCTAssertEqual(db[key], objects[key], "Objects should match between dictionary and db")
        }
        keys = ["key1", "key2", "key9"]
        let extractedObjects = zip(keys, db.objectsForKeys(keys)).reduce([String:NSObject]()){ var d = $0; d[$1.0] = $1.1; return d }
        for key in keys {
            XCTAssertEqual(extractedObjects[key], objects[key], "Objects should match between dictionary and db")
        }
    }
    
    func testPredicateFiltering() {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        let predicate = NSPredicate(format: "price BETWEEN {25, 50}")
        var resultKeys = [String]()
        var price : Int // UInt32
        arc4random_stir()
        for i in 0..<numberOfIterations {
            let numberKey = "\(i)"
            price = Int(arc4random_uniform(100))
            if price >= 25 && price <= 50 {
                resultKeys.append(numberKey)
            }
            db[numberKey] = ["price": price]
        }
        resultKeys = resultKeys.sort{$0 < $1}
        XCTAssertEqual(db.keysByFilteringWithPredicate(predicate), resultKeys, "Filtering db keys with a predicate should return the same list as expected")
        var allObjects = db.dictionaryByFilteringWithPredicate(predicate)
        XCTAssertEqual(allObjects.keys.sort{$0 < $1}, resultKeys, "A dictionary obtained by filtering with a predicate should yield the expected list of keys")
        var i = 0
        db.enumerateKeysWithPredicate(predicate, backward: false, startingAtKey: nil, andPrefix: nil, usingBlock: {key, stop in
            XCTAssertEqual(key, resultKeys[i], "Enumerating by filtering with a predicate should yield the expected keys")
            i += 1
        })
        i = Int(resultKeys.count) - 1
        db.enumerateKeysWithPredicate(predicate, backward:true, startingAtKey: nil, andPrefix: nil, usingBlock: {key, stop in
            XCTAssertEqual(key, resultKeys[i], "Enumerating backwards by filtering with a predicate should yield the expected keys")
            i -= 1
        })
        i = 0
        
        db.enumerateKeysAndObjectsWithPredicate(predicate, backward: false, startingAtKey: nil, andPrefix: nil, usingBlock: {key, value, stop in
            XCTAssertEqual(key, resultKeys[i], "Enumerating keys and objects by filtering with a predicate should yield the expected keys")
            XCTAssertEqual(value, allObjects[resultKeys[i]], "Enumerating keys and objects by filtering with a predicate should yield the expected values")
            i += 1
        })
        i = Int(resultKeys.count) - 1
        db.enumerateKeysAndObjectsWithPredicate(predicate, backward: true, startingAtKey: nil, andPrefix: nil, usingBlock: {key, value, stop in
            XCTAssertEqual(key, resultKeys[i], "Enumerating keys and objects by filtering with a predicate should yield the expected keys")
            XCTAssertEqual(value, allObjects[resultKeys[i]], "Enumerating keys and objects by filtering with a predicate should yield the expected values")
            i -= 1
        })
    }

    func nPairs(n: Int) -> [[NSObject]] {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return [[]]
        }
        var pairs = [[NSObject]]()
        dispatch_apply(n, lvldb_test_queue, {(i: size_t) -> Void in
            var r: Int
            var key: String
            repeat {
                r = Int(arc4random_uniform(5000))
                key = "\(r)"
            } while db.objectExistsForKey(key)
            let value = [r, i]
            pairs.append([key, value])
            db[key] = value
        })
        pairs.sortInPlace{
            let obj1 = $0[0] as! String
            let obj2 = $1[0] as! String
            return obj1 < obj2
        }
        return pairs
    }

    func testForwardKeyEnumerations() {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        var r: Int
        var pairs = self.nPairs(numberOfIterations)
        // Test that enumerating the whole set yields keys in the correct orders
        r = 0
        db.enumerateKeysUsingBlock({lkey, stop in
            var key: String
            var value: [NSObject]
            var pair = pairs[r]
            key = pair[0] as! String
            //value = pair[1] as! [NSObject]
            XCTAssertEqual(key, lkey, "Keys should be equal, given the ordering worked")
            r += 1
        })
        // Test that enumerating the set by starting at an offset yields keys in the correct orders
        r = 432
        db.enumerateKeys(backward: false, startingAtKey: pairs[r][0] as? String, andPrefix: nil, usingBlock: {lkey, stop in
            var key: String
            var value: [NSObject]
            var pair = pairs[r]
            key = pair[0] as! String
            value = pair[1] as! [NSObject]
            XCTAssertEqual(key, lkey, "Keys should be equal, given the ordering worked")
            r += 1
        })
    }

    /*
    func testBackwardKeyEnumerations() {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        var r: Int
        var key: String
        var value: [NSObject]
        var pairs = self.nPairs(numberOfIterations)
        // Test that enumerating the whole set backwards yields keys in the correct orders
        r = pairs.count - 1
        db.enumerateKeysWithPredicate(true, startingAtKey: nil, filteredByPredicate: nil, andPrefix: nil, usingBlock: {lkey, stop in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqual(key, lkey, "Keys should be equal, given the ordering worked")
            r -= 1
        })
        // Test that enumerating the set backwards at an offset yields keys in the correct orders
        r = 567
        db.enumerateKeysWithPredicate(true, startingAtKey: pairs[r][0], filteredByPredicate: nil, andPrefix: nil, usingBlock: {lkey, stop in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqual(key, lkey, "Keys should be equal, given the ordering worked")
            r -= 1
        })
    }

    func testBackwardPrefixedEnumerationsWithStartingKey() {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        var valueFor = {(i: Int) -> id in
                return ["key": i]
            }
        var pairs = ["tess:0": valueFor(0), "tesa:0": valueFor(0), "test:1": valueFor(1), "test:2": valueFor(2), "test:3": valueFor(3), "test:4": valueFor(4)]
        var i = 3
        db += pairs
        db.enumerateKeysWithPredicate(true, startingAtKey: "test:3", filteredByPredicate: nil, andPrefix: "test", usingBlock: {lkey, stop in
            var key = "test:\(i)"
            XCTAssertEqual(lkey, key, "Keys should be restricted to the prefixed region")
            i -= 1
        })
        XCTAssertEqual(i, 0, "")
    }

    func testPrefixedEnumerations() {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        var valueFor = {(i: Int) -> id in
                return ["key": i]
            }
        var pairs = ["tess:0": valueFor(0), "tesa:0": valueFor(0), "test:1": valueFor(1), "test:2": valueFor(2), "test:3": valueFor(3), "test:4": valueFor(4)]
        var i = 4
        db += pairs
        db.enumerateKeysWithPredicate(true, startingAtKey: nil, filteredByPredicate: nil, andPrefix: "test", usingBlock: {lkey, stop in
            var key = "test:\(i)"
            XCTAssertEqual(lkey, key, "Keys should be restricted to the prefixed region")
            i -= 1
        })
        XCTAssertEqual(i, 0, "")
        db.removeAllObjects()
        db += ["tess:0": valueFor(0), "test:1": valueFor(1), "test:2": valueFor(2), "test:3": valueFor(3), "test:4": valueFor(4), "tesu:5": valueFor(5)]
        i = 4
        db.enumerateKeysAndObjectsBackward(true, lazily: false, startingAtKey: nil, filteredByPredicate: nil, andPrefix: "test", usingBlock: {(lkey: String, value: [NSObject : NSObject], stop: Bool) -> Void in
            var key = "test:\(i)"
            XCTAssertEqual(lkey, key, "Keys should be restricted to the prefixed region")
            XCTAssertEqual(value["key"], i, "Values should be restricted to the prefixed region")
            i -= 1
        })
        XCTAssertEqual(i, 0, "")
        i = 1
        db += pairs
        db.enumerateKeysWithPredicate(false, startingAtKey: nil, filteredByPredicate: nil, andPrefix: "test", usingBlock: {lkey, stop in
            var key = "test:\(i)"
            XCTAssertEqual(lkey, key, "Keys should be restricted to the prefixed region")
            i += 1
        })
        XCTAssertEqual(i, 5, "")
        i = 1
        db.enumerateKeysAndObjectsBackward(false, lazily: false, startingAtKey: nil, filteredByPredicate: nil, andPrefix: "test", usingBlock: {(lkey: String, value: [NSObject : NSObject], stop: Bool) -> Void in
            var key = "test:\(i)"
            XCTAssertEqual(lkey, key, "Keys should be restricted to the prefixed region")
            XCTAssertEqual(value["key"], i, "Values should be restricted to the prefixed region")
            i += 1
        })
        XCTAssertEqual(i, 5, "")
    }

    func testForwardKeyAndValueEnumerations() {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        var r: Int
        var key: String
        var value: [NSObject]
        var pairs = self.nPairs(numberOfIterations)
        // Test that enumerating the whole set yields pairs in the correct orders
        r = 0
        db.enumerateKeysAndObjectsUsingBlock({(lkey: String, value: NSObject, stop: Bool) -> Void in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqual(key, lkey, "Keys should be equal, given the ordering worked")
            XCTAssertEqual(value, value, "Values should be equal, given the ordering worked")
            r += 1
        })
        // Test that enumerating the set by starting at an offset yields pairs in the correct orders
        r = 432
        db.enumerateKeysAndObjectsBackward(false, lazily: false, startingAtKey: pairs[r][0], filteredByPredicate: nil, andPrefix: nil, usingBlock: {(lkey: String, value: NSObject, stop: Bool) -> Void in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqual(key, lkey, "Keys should be equal, given the ordering worked")
            XCTAssertEqual(value, value, "Values should be equal, given the ordering worked")
            r += 1
        })
    }

    func testBackwardKeyAndValueEnumerations() {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        var r: Int
        var key: String
        var value: [NSObject]
        var pairs = self.nPairs(numberOfIterations)
        // Test that enumerating the whole set backwards yields pairs in the correct orders
        r = pairs.count - 1
        db.enumerateKeysAndObjectsBackward(true, lazily: false, startingAtKey: nil, filteredByPredicate: nil, andPrefix: nil, usingBlock: {(lkey: String, value: NSObject, stop: Bool) -> Void in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqual(key, lkey, "Keys should be equal, given the ordering worked")
            XCTAssertEqual(value, value, "Values should be equal, given the ordering worked")
            r -= 1
        })
        // Test that enumerating the set backwards at an offset yields pairs in the correct orders
        r = 567
        db.enumerateKeysAndObjectsBackward(true, lazily: false, startingAtKey: pairs[r][0], filteredByPredicate: nil, andPrefix: nil, usingBlock: {(lkey: String, value: NSObject, stop: Bool) -> Void in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqual(key, lkey, "Keys should be equal, given the ordering worked")
            XCTAssertEqual(value, value, "Values should be equal, given the ordering worked")
            r -= 1
        })
    }

    func testBackwardLazyKeyAndValueEnumerations() {
        guard let db = db else {
            print("Database reference is not existent, failed to open / create database")
            return
        }
        var r: Int
        var key: String
        var value: [NSObject]
        var pairs = self.nPairs(numberOfIterations)
        // Test that enumerating the set backwards and lazily at an offset yields pairs in the correct orders
        r = 567
        var enumerateKeysAndObjectsBackward: db
        var lazily: YES
        var startingAtKey: YES
        pairs[r][0]
        //var andPrefix: nil
        //var usingBlock: nil
    }*/
    /*var = ""
    var LevelDBValueGetterBlock = ""
    var BOOL = ""*/
    
}