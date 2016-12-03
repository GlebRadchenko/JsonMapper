//: Playground - noun: a place where people can play

import UIKit


/*
class Chair: Mapable {
    var id: String
    
    var helpingPath: [MapPathable] = [.none]
    var relations: [String: MappingProperty] = ["id": .property(type: .string, key: "id", optional: false)]
    
    func map(with dictionary: [String: AnyObject]) {
        if let id = dictionary["id"] as? String {
            self.id = id
        }
    }
    
    required init() {
        self.id = "-1"
    }
}

class User: Mapable {
    var name: String
    var age: Int
    var isMale: Bool
    var chair: Chair?
    
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
    
    func map(with dictionary: [String: AnyObject]) {
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        if let age = dictionary["age"] as? Int {
            self.age = age
        }
        if let isMale = dictionary["isMale"] as? Bool {
            self.isMale = isMale
        }
        if let chair = dictionary["chair"] as? Chair {
            self.chair = chair
        }
    }
    
    var helpingPath: [MapPathable] = [.destination(property: .dictionary(key: "user", valuesType: .string, optional: false))]
    
    var relations: [String: MappingProperty] {
        return ["name": .property(type: .string, key: "name", optional: false),
                "age": .property(type: .number, key: "age", optional: false),
                "isMale": .property(type: .bool, key: "male", optional: false),
                "chair": .mappingObject(key: "chair", type: Chair.self, optional: true)]
    }
}

let json = ["user": ["name" : "Test", "age": 21, "male": true, "chair": ["id": "123"]]]
do {
    let user: User = try Mapper.map(json as AnyObject)
    user.age
    user.name
    user.isMale
    user.chair
    user.chair?.id
} catch {
    print(error)
}*/
//let string = "13135"
//let mirror = Mirror(reflecting: string)
//mirror.subjectType

