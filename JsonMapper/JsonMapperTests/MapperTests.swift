//
//  MapperTests.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 04.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import XCTest

class MapperTests: XCTestCase {
    let json = ["user": ["name" : "Test", "age": 21, "male": true, "chair": ["id": "123"]]]
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func testRecursiveSearch1() {
        let intValue = Mapper.findRecursively("age", mappingType: .number, optional: false, json: json as AnyObject)
        XCTAssertNil(intValue)
        if let aValue = intValue as? Int {
            XCTAssert(aValue == 21, "Wrong int found")
        }
        let stringValue = Mapper.findRecursively("name", mappingType: .string, optional: false, json: json as AnyObject)
        XCTAssertNil(stringValue)
        if let aValue = stringValue as? String {
            XCTAssert(aValue == "Test", "Wrong string found")
        }
        let boolValue = Mapper.findRecursively("male", mappingType: .bool, optional: false, json: json as AnyObject)
        XCTAssertNil(boolValue)
        if let aValue = boolValue as? Bool {
            XCTAssert(aValue == true, "Wrong bool found")
        }
        
        let optionalValue = Mapper.findRecursively("test", mappingType: .number, optional: true, json: json as AnyObject)
        XCTAssert(optionalValue == nil, "Optional unexisting value found")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
