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

    //var numberOfIterations = 2500
    //var pair = pairs[r]
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
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

    /*
    func testKeysManipulation() {
        var value = ["foo": "bar"]
        db["dict1"] = value!
        db["dict2"] = value!
        db["dict3"] = value!
        var keys = ["dict1", "dict2", "dict3"]
        var keysFromDB = db.allKeys()
        XCTAssertEqualObjects(keysFromDB, keys, "-[LevelDB allKeys] should return the list of keys used to insert data")
        db.removeAll()
        XCTAssertEqual(db.allKeys(), [], "The list of keys should be empty after removing all objects from the database")
    }

    func testRemovingKeysWithPrefix() {
        var value = ["foo": "bar"]
        db["dict1"] = value!
        db["dict2"] = value!
        db["dict3"] = value!
        db["array1"] = [1, 2, 3]
        db.removeAllObjectsWithPrefix("dict")
        XCTAssertEqual(db.allKeys().count, Int(1), "There should be only 1 key remaining after removing all those prefixed with 'dict'")
    }

    func testDictionaryManipulations() {
        var objects = ["key1": [1, 2], "key2": ["foo": "bar"], "key3": [[]]]
        db += objects
        var keys = ["key1", "key2", "key3"]
        for key: AnyObject in keys {
            XCTAssertEqualObjects(db[key!], objects[key!], "Objects should match between dictionary and db")
        }
        keys = ["key1", "key2", "key9"]
        var extractedObjects = [NSObject : AnyObject](objects: db.objectsForKeys(keys, notFoundMarker: NSNull()), forKeys: keys)
        for key: AnyObject in keys {
            var val: AnyObject?
            XCTAssertEqualObjects(extractedObjects[key!], (val = (objects[key!] as! String)) ? val : NSNull(), "Objects should match between dictionary and db, or return the noFoundMarker")
        }
    }

    func testPredicateFiltering() {
        var predicate = NSPredicate(format: "price BETWEEN {25, 50}")
        var resultKeys = [AnyObject]()
        var price: Int
        var dataComparator = {(key1: String, key2: String) -> NSComparisonResult in
                return key1.compare(key2)
            }
        arc4random_stir()
        for i in 0..<numberOfIterations {
            var numberKey = "\(i)"
            price = arc4random_uniform(100)
            if price >= 25 && price <= 50 {
                resultKeys.append(numberKey)
            }
            db[numberKey] = ["price": price]
        }
        resultKeys.sortUsingComparator(dataComparator)
        XCTAssertEqualObjects(db.keysByFilteringWithPredicate(predicate!), resultKeys, "Filtering db keys with a predicate should return the same list as expected")
        var allObjects = db.dictionaryByFilteringWithPredicate(predicate!)
        XCTAssertEqualObjects(allObjects.allKeys().sortedArrayUsingComparator(dataComparator), resultKeys, "A dictionary obtained by filtering with a predicate should yield the expected list of keys")
        var i = 0
        db.enumerateKeysBackward(false, startingAtKey: nil, filteredByPredicate: predicate!, andPrefix: nil, usingBlock: {(key: String, stop: Bool) -> Void in
            XCTAssertEqualObjects(key!, resultKeys[i], "Enumerating by filtering with a predicate should yield the expected keys")
            i += 1
        })
        i = Int(resultKeys.count) - 1
        db.enumerateKeysBackward(true, startingAtKey: nil, filteredByPredicate: predicate!, andPrefix: nil, usingBlock: {(key: String, stop: Bool) -> Void in
            XCTAssertEqualObjects(key!, resultKeys[i], "Enumerating backwards by filtering with a predicate should yield the expected keys")
            i -= 1
        })
        i = 0
        db.enumerateKeysAndObjectsBackward(false, lazily: false, startingAtKey: nil, filteredByPredicate: predicate!, andPrefix: nil, usingBlock: {(key: String, value: AnyObject, stop: Bool) -> Void in
            XCTAssertEqualObjects(key!, resultKeys[i], "Enumerating keys and objects by filtering with a predicate should yield the expected keys")
            XCTAssertEqualObjects(value!, allObjects[resultKeys[i]], "Enumerating keys and objects by filtering with a predicate should yield the expected values")
            i += 1
        })
        i = Int(resultKeys.count) - 1
        db.enumerateKeysAndObjectsBackward(true, lazily: false, startingAtKey: nil, filteredByPredicate: predicate!, andPrefix: nil, usingBlock: {(key: String, value: AnyObject, stop: Bool) -> Void in
            XCTAssertEqualObjects(key!, resultKeys[i], "Enumerating keys and objects by filtering with a predicate should yield the expected keys")
            XCTAssertEqualObjects(value!, allObjects[resultKeys[i]], "Enumerating keys and objects by filtering with a predicate should yield the expected values")
            i -= 1
        })
    }

    func nPairs(n: Int) -> [AnyObject] {
        var pairs = [AnyObject]()
        var r: Int
        var key: String
        var value: [AnyObject]
        dispatch_apply(n, lvldb_test_queue, {(i: size_t) -> Void in
            repeat {
                r = arc4random_uniform(5000)
                key = "\(Int(r))"
            } while db.objectExistsForKey(key)
            value = [r, i]
            pairs.append([key, value])
            db[key] = value
        })
        pairs.sortUsingComparator({(obj1: [AnyObject], obj2: [AnyObject]) -> NSComparisonResult in
            return obj1[0].compare(obj2[0])
        })
        return pairs
    }

    func testForwardKeyEnumerations() {
        var r: Int
        var key: String
        var value: [AnyObject]
        var pairs = self.nPairs(numberOfIterations)
        // Test that enumerating the whole set yields keys in the correct orders
        r = 0
        db.enumerateKeysUsingBlock({(lkey: String, stop: Bool) -> Void in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqualObjects(key, lkey, "Keys should be equal, given the ordering worked")
            r += 1
        })
        // Test that enumerating the set by starting at an offset yields keys in the correct orders
        r = 432
        db.enumerateKeysBackward(false, startingAtKey: pairs[r][0], filteredByPredicate: nil, andPrefix: nil, usingBlock: {(lkey: String, stop: Bool) -> Void in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqualObjects(key, lkey, "Keys should be equal, given the ordering worked")
            r += 1
        })
    }

    func testBackwardKeyEnumerations() {
        var r: Int
        var key: String
        var value: [AnyObject]
        var pairs = self.nPairs(numberOfIterations)
        // Test that enumerating the whole set backwards yields keys in the correct orders
        r = pairs.count - 1
        db.enumerateKeysBackward(true, startingAtKey: nil, filteredByPredicate: nil, andPrefix: nil, usingBlock: {(lkey: String, stop: Bool) -> Void in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqualObjects(key, lkey, "Keys should be equal, given the ordering worked")
            r -= 1
        })
        // Test that enumerating the set backwards at an offset yields keys in the correct orders
        r = 567
        db.enumerateKeysBackward(true, startingAtKey: pairs[r][0], filteredByPredicate: nil, andPrefix: nil, usingBlock: {(lkey: String, stop: Bool) -> Void in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqualObjects(key, lkey, "Keys should be equal, given the ordering worked")
            r -= 1
        })
    }

    func testBackwardPrefixedEnumerationsWithStartingKey() {
        var valueFor = {(i: Int) -> id in
                return ["key": i]
            }
        var pairs = ["tess:0": valueFor(0), "tesa:0": valueFor(0), "test:1": valueFor(1), "test:2": valueFor(2), "test:3": valueFor(3), "test:4": valueFor(4)]
        var i = 3
        db += pairs
        db.enumerateKeysBackward(true, startingAtKey: "test:3", filteredByPredicate: nil, andPrefix: "test", usingBlock: {(lkey: String, stop: Bool) -> Void in
            var key = "test:\(i)"
            XCTAssertEqualObjects(lkey, key, "Keys should be restricted to the prefixed region")
            i -= 1
        })
        XCTAssertEqual(i, 0, "")
    }

    func testPrefixedEnumerations() {
        var valueFor = {(i: Int) -> id in
                return ["key": i]
            }
        var pairs = ["tess:0": valueFor(0), "tesa:0": valueFor(0), "test:1": valueFor(1), "test:2": valueFor(2), "test:3": valueFor(3), "test:4": valueFor(4)]
        var i = 4
        db += pairs
        db.enumerateKeysBackward(true, startingAtKey: nil, filteredByPredicate: nil, andPrefix: "test", usingBlock: {(lkey: String, stop: Bool) -> Void in
            var key = "test:\(i)"
            XCTAssertEqualObjects(lkey, key, "Keys should be restricted to the prefixed region")
            i -= 1
        })
        XCTAssertEqual(i, 0, "")
        db.removeAll()
        db += ["tess:0": valueFor(0), "test:1": valueFor(1), "test:2": valueFor(2), "test:3": valueFor(3), "test:4": valueFor(4), "tesu:5": valueFor(5)]
        i = 4
        db.enumerateKeysAndObjectsBackward(true, lazily: false, startingAtKey: nil, filteredByPredicate: nil, andPrefix: "test", usingBlock: {(lkey: String, value: [NSObject : AnyObject], stop: Bool) -> Void in
            var key = "test:\(i)"
            XCTAssertEqualObjects(lkey, key, "Keys should be restricted to the prefixed region")
            XCTAssertEqualObjects(value["key"], i, "Values should be restricted to the prefixed region")
            i -= 1
        })
        XCTAssertEqual(i, 0, "")
        i = 1
        db += pairs
        db.enumerateKeysBackward(false, startingAtKey: nil, filteredByPredicate: nil, andPrefix: "test", usingBlock: {(lkey: String, stop: Bool) -> Void in
            var key = "test:\(i)"
            XCTAssertEqualObjects(lkey, key, "Keys should be restricted to the prefixed region")
            i += 1
        })
        XCTAssertEqual(i, 5, "")
        i = 1
        db.enumerateKeysAndObjectsBackward(false, lazily: false, startingAtKey: nil, filteredByPredicate: nil, andPrefix: "test", usingBlock: {(lkey: String, value: [NSObject : AnyObject], stop: Bool) -> Void in
            var key = "test:\(i)"
            XCTAssertEqualObjects(lkey, key, "Keys should be restricted to the prefixed region")
            XCTAssertEqualObjects(value["key"], i, "Values should be restricted to the prefixed region")
            i += 1
        })
        XCTAssertEqual(i, 5, "")
    }

    func testForwardKeyAndValueEnumerations() {
        var r: Int
        var key: String
        var value: [AnyObject]
        var pairs = self.nPairs(numberOfIterations)
        // Test that enumerating the whole set yields pairs in the correct orders
        r = 0
        db.enumerateKeysAndObjectsUsingBlock({(lkey: String, value: AnyObject, stop: Bool) -> Void in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqualObjects(key, lkey, "Keys should be equal, given the ordering worked")
            XCTAssertEqualObjects(value, value, "Values should be equal, given the ordering worked")
            r += 1
        })
        // Test that enumerating the set by starting at an offset yields pairs in the correct orders
        r = 432
        db.enumerateKeysAndObjectsBackward(false, lazily: false, startingAtKey: pairs[r][0], filteredByPredicate: nil, andPrefix: nil, usingBlock: {(lkey: String, value: AnyObject, stop: Bool) -> Void in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqualObjects(key, lkey, "Keys should be equal, given the ordering worked")
            XCTAssertEqualObjects(value, value, "Values should be equal, given the ordering worked")
            r += 1
        })
    }

    func testBackwardKeyAndValueEnumerations() {
        var r: Int
        var key: String
        var value: [AnyObject]
        var pairs = self.nPairs(numberOfIterations)
        // Test that enumerating the whole set backwards yields pairs in the correct orders
        r = pairs.count - 1
        db.enumerateKeysAndObjectsBackward(true, lazily: false, startingAtKey: nil, filteredByPredicate: nil, andPrefix: nil, usingBlock: {(lkey: String, value: AnyObject, stop: Bool) -> Void in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqualObjects(key, lkey, "Keys should be equal, given the ordering worked")
            XCTAssertEqualObjects(value, value, "Values should be equal, given the ordering worked")
            r -= 1
        })
        // Test that enumerating the set backwards at an offset yields pairs in the correct orders
        r = 567
        db.enumerateKeysAndObjectsBackward(true, lazily: false, startingAtKey: pairs[r][0], filteredByPredicate: nil, andPrefix: nil, usingBlock: {(lkey: String, value: AnyObject, stop: Bool) -> Void in
            var pair = pairs[r]
            key = pair[0]
            value = pair[1]
            XCTAssertEqualObjects(key, lkey, "Keys should be equal, given the ordering worked")
            XCTAssertEqualObjects(value, value, "Values should be equal, given the ordering worked")
            r -= 1
        })
    }

    func testBackwardLazyKeyAndValueEnumerations() {
        var r: Int
        var key: String
        var value: [AnyObject]
        var pairs = self.nPairs(numberOfIterations)
        // Test that enumerating the set backwards and lazily at an offset yields pairs in the correct orders
        r = 567
        var enumerateKeysAndObjectsBackward: db
        var lazily: YES
        var startingAtKey: YES
        pairs[r][0]
        var andPrefix: nil
        var usingBlock: nil
    }
    var = ""
    var LevelDBValueGetterBlock = ""
    var BOOL = ""*/
    
}