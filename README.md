# JsonMapper

 - Simple JsonMapper, which maps JSON data to your models automatically.
 - You don't need to parse your JSON manually.
 - Mapper don't use reflection at all, so it's fast enough.  
 
## Requirements: 
  - iOS 9.1+
  - XCode 8.0+ 
  - Swift 3.0+
  (Actually, I didn't test it for other versions of iOS and macOS so, you can try :) )
  
## Current features: 

- Mapping primitive types;
- Mapping Mapable objects (classes, structs, enums);
- Optional mapping;
- Supporting of arrays mapping;
- Supporting of nested types mapping;
- Supporting speeding up mapping of single object by declaring helpingPath property;
- Untested feature of mapping custom types like Date.

### Future features and plans:

- Map objects by declaring helpingPath directly;
- Unit tests coverage(in process);
- Simplify declaring of helpingPath property;
- Extend all primitive types for AtomaryMapable protocol;
  
 ## Usage:
 
  1. Import library as follows: 
 
  ``` swift
  import JsonMapper
```
  2. Create your Class or Struct and extend it for Mapable protocol: 
   ``` swift
public protocol Mapable {
    static var helpingPath: [MapPathable] { get }
    static var relations: [String: MappingProperty] { get }
    init(_ wrapping: Wrapping) throws
}
```
for example: 
  ``` swift
class User: Mapable {
    
    var name: String?
    var login: String
    var password: String
    
    public static var helpingPath: [MapPathable] = [.none] //or remove it.
    public static var relations: [String : MappingProperty] {
        return ["name": .property(type: .string, key: "name", optional: true),
                "login": .property(type: .string, key: "login", optional: false),
                "password": .property(type: .string, key: "password", optional: false)]
    }
    
    public required init(_ wrapping: Wrapping) throws {
        name = try wrapping.get("name")
        login = try wrapping.get("login")
        password = try wrapping.get("password")
    }
}
  ```
  
  where helpingPath - array of values, which can help Mapper to find destination Object in JSON file.
  For example, you have json file: 
  
  ``` json
  {
    "response" : {
      "user" : {
        "name" : "Test",
        "login" : "Login", 
        "password" : "Password"
      }
    }
  }
  ```
  
  your helpingPath should be as follows: 
  
  ``` swift
  public static var helpingPath: [MapPathable] = [.target(nodeType: .dictionary(key: "response", index: nil)),
                                                    .destination(nodeType: .dictionary(key: "user", index: nil))]                                         
  ``` 
  
  this protperty determine a valid way for "user" object, and Mapper won't search object recursively.
  You can delete this property or stay it like :
  
   ``` swift
  
  public static var helpingPath: [MapPathable] = [.none]
                                                    
  ```
  
  to force recursive search (DFS) of object that you need to be mapped.
  
  MappingProperty supports properties like :
  
  ``` swift
  public enum MappingProperty {
    case property(type: MappingType, key: String, optional: Bool)
    case mappingObject(key: String, type: Mapable.Type, optional: Bool)
    case mappingObjectsArray(key: String?, types: Mapable.Type, optional: Bool)
    case array(key: String, valuesType: MappingType, optional: Bool)
    case dictionary(key: String, optional: Bool)
}                                                 
  ```
  
  3. Then call with Data object:
  
``` swift
  let user: User = try Mapper.map(data)
  ```
  
  or json object (AnyObject):
  
  ``` swift
  let user: User = try Mapper.map(json)                                        
  ```
  
  4. Also you can map arrays, nested types or primitive and custom types by call :
  
  ``` swift
    
    let users: [User] = try Mapper.map([data or json])
    let stringValue: String = try Mapper.map([data or json], for: "[your key for needed String value]")
    let doubles: [Double] = try Mapper.map([data or json], for: "[your key for needed array of Double values]")
    
    //raw value for Date is String
    let date: Date = try Mapper.map(data, for: "[your key for needed Date value]", formatting: { (rawValue: String) -> Data in
      guard let date = DateFormatter().date(from: unformattedString) else {
          throw SomeError
      }
    
      return date
    })
    
    //raw value for CustomStruct is String(it can be any, just conform your struct, class etc to AtomaryMapable protocol)
    let custom: CustomStruct = try Mapper.map(data, for: "[key for needed CustomStruct value]") { return CustomStruct(stringValue: $0) }
  ```
  
  For mapping array of Mapable objects it's recommended not to use helpingPath value (just for now :D), to prevent unexpected behavior.
  
