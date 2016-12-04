//
//  MapperTests.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 04.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import XCTest

class MapperTests: XCTestCase {
    let json = ["user": ["name" : "Test",
                         "age": 21,
                         "male": true,
                         "chair": ["id": "123",
                                   "testIntArray": [1, 2, 3, 4],
                                   "testStringArray": ["1", "2", "3", "4"],
                                   "testBoolArray": [true, false, true, false]
                                    ]
                        ]
                ]
    
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func testRecursiveSearchForProperty() {
        let intValue = Mapper.findRecursively(propertyKey: "age", mappingType: .number, json: json as AnyObject)
        if let aValue = intValue as? Int {
            XCTAssert(aValue == 21, "Wrong int found")
        } else {
            XCTFail()
        }
        let stringValue = Mapper.findRecursively(propertyKey:"name", mappingType: .string, json: json as AnyObject)
        if let aValue = stringValue as? String {
            XCTAssert(aValue == "Test", "Wrong string found")
        } else {
            XCTFail()
        }
        let boolValue = Mapper.findRecursively(propertyKey: "male", mappingType: .bool, json: json as AnyObject)
        if let aValue = boolValue as? Bool {
            XCTAssert(aValue == true, "Wrong bool found")
        } else {
            XCTFail()
        }

    }
    func testRecursiveSearchForArray() {
        let anyArray = Mapper.findRecursively(arrayKey: "testIntArray", valuesType: .anyObject, json: json as AnyObject)
        if let aArray = anyArray as? [Int] {
            XCTAssert(aArray.count == 4, "Wrong any array found")
        } else {
            XCTFail()
        }
        let intArray = Mapper.findRecursively(arrayKey: "testIntArray", valuesType: .number, json: json as AnyObject)
        if let aArray = intArray as? [Int] {
            XCTAssert(aArray.count == 4, "Wrong int array found")
        } else {
            XCTFail()
        }
        let stringArray = Mapper.findRecursively(arrayKey: "testStringArray", valuesType: .string, json: json as AnyObject)
        if let aArray = stringArray as? [String] {
            XCTAssert(aArray.count == 4, "Wrong string array found")
        } else {
            XCTFail()
        }
        let boolArray = Mapper.findRecursively(arrayKey: "testBoolArray", valuesType: .bool, json: json as AnyObject)
        if let aArray = boolArray as? [Bool] {
            XCTAssert(aArray.count == 4, "Wrong bool array found")
        } else {
            XCTFail()
        }
    }
    func testMapping() {
        do {
            let user: User = try Mapper.map(json as AnyObject)
            XCTAssert(user.age == 21, "Wrong age")
            XCTAssert(user.isMale == true, "Wrong isMale")
            XCTAssert(user.name == "Test", "Wrong name")
            XCTAssert(user.chair?.id == "123", "Wrong chair")
            let chair: Chair = try Mapper.map(json as AnyObject)
            XCTAssert(chair.id == "123", "Wrong chair id")
        } catch {
            XCTFail()
        }
    }
    
    func testPerformanceExample() {
        self.measure {
            do {
                for _ in 0...50 {
                    let user: User = try Mapper.map(self.json as AnyObject)
                    XCTAssert(user.age == 21, "Wrong age")
                    XCTAssert(user.isMale == true, "Wrong isMale")
                    XCTAssert(user.name == "Test", "Wrong name")
                    
                    let chair: Chair = try Mapper.map(self.json as AnyObject)
                    XCTAssert(chair.id == "123", "Wrong chair id")
                }
            } catch {
                XCTFail()
            }
        }
    }
    
}
