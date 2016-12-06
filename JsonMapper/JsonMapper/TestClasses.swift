//
//  TestClasses.swift
//  JsonMapper
//
//  Created by Gleb Radchenko on 05.12.16.
//  Copyright © 2016 Gleb Radchenko. All rights reserved.
//

import Foundation

class Chair: Mapable {
    var id: String
    var stickCount: Int
    
    var helpingPath: [MapPathable] = [.none]
    var relations: [String: MappingProperty] = ["id": .property(type: .string, key: "id", optional: false),
                                                "stickCount": .property(type: .number, key: "stickCount", optional: false)]
    
    func map(with wrapping: Wrapping) {
        do {
            id = try wrapping.get("id")!
            stickCount = try wrapping.get("stickCount")!
        } catch {
            print(error)
        }
    }
    
    required init() {
        self.id = "-1"
        self.stickCount = 0
    }
}

class User: Mapable {
    var name: String
    var age: Int
    var isMale: Bool
    var chairs: [Chair]?
    
    init(name: String, age: Int, isMale: Bool) {
        self.name = name
        self.age = age
        self.isMale = isMale
    }
    
    //Mapable protocol implementation
    required init() {
        name = ""
        age = 1
        isMale = false
    }
    
    func map(with wrapping: Wrapping) {
        do {
            name = try wrapping.get("name")!
            age = try wrapping.get("age")!
            isMale = try wrapping.get("isMale")!
            chairs = try wrapping.get("chairs")
        } catch {
            print(error)
        }
    }
    
    var helpingPath: [MapPathable] = [.destination(nodeType: .dictionary(key: "user", index: nil))]
    
    var relations: [String: MappingProperty] {
        return ["name": .property(type: .string, key: "name", optional: false),
                "age": .property(type: .number, key: "age", optional: false),
                "isMale": .property(type: .bool, key: "male", optional: false),
                "chairs": .mappingObjectsArray(key: "chairs", types: Chair.self, optional: true)]
    }
}
