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
- Mapping custom types like Date.

### Future features and plans:

- Unit tests coverage(in process);
- Simplify declaring of helpingPath property - done;
- Extend all primitive types for AtomaryMapable protocol - done;
  
 ## Usage:
 
  1. Import library as follows: 
 
  ``` swift
  import JsonMapper
```
  2. Create your Class or Struct and extend it for Mapable protocol: 
   ``` swift
public protocol Mapable {
    init(_ wrapping: Wrapping) throws
    static var properties: [MapableProperty] { get }
    static var mappingPath: [TargetNode] { get }
}
```
for example: 
  ``` swift
class User: Mapable {
    var name: String
    var login: String
    var age: Int
    
    static var mappingPath: [TargetNode] = []
    static var properties: [MapableProperty] = [
        .value(type: String.self, key: "name", optional: false),
        .value(type: String.self, key: "login", optional: false),
        .value(type: Int.self, key: "age", optional: false)
    ]
    
    public required init(_ wrapping: Wrapping) throws {
        name = try wrapping.get("name")
        login = try wrapping.get("login")
        age = try wrapping.get("age")
    }
}
  ```
  
  where mappingPath - array of values, which can help Mapper to find destination Object in JSON file.
  For example, you have json file: 
  
  ``` json
  {
    "response" : {
      "user" : {
        "name" : "Test",
        "login" : "Login", 
        "age" : 33
      }
    }
  }
  ```
  
  your helpingPath should be as follows: 
  
  ``` swift
  public static var mappingPath: [TargetNode] = [.dictionaryNode(key: "response"),
                                                 .dictionaryNode(key: "user", isDestination: true)]                                         
  ```     
  
  this protperty determine a valid way for "user" object, and Mapper won't search object recursively.
  You can delete this property or stay it like :
  
   ``` swift
  public static var helpingPath: [TargetNode] = []                                                    
  ```
  
  to force recursive search (BFS) of object that you need to be mapped.
  
  MapableProperty supports properties like :
  
  ``` swift
public enum MapableProperty {
    
    case value(type: AtomaryMapable.Type, key: String, optional: Bool)
    case array(type: AtomaryMapable.Type, key: String, optional: Bool)
    case dictionary(type: AtomaryMapable.Type, key: String, optional: Bool)
    case object(type: Mapable.Type, key: String, optional: Bool)
    case objectsArray(type: Mapable.Type, key: String, optional: Bool)
    case objectsDictionary(type: Mapable.Type, key: String, optional: Bool)
    
}                                                 
  ```
  
  3. Then call with Data object or json:
  
``` swift
  let dataUser: User = try Mapper.map(data)
  //or
  let jsonUser: User = try Mapper.map(json)  
  ```
  
  4. Also you can map arrays, nested types or primitive and custom types by call :
  
  ``` swift
    let users: [User] = try Mapper.map([data or json])
    let stringValue: String = try Mapper.map([data or json], for: "[your key for needed String value]")
    let doubles: [String: Double] = try Mapper.map([data or json], for: "[your key for needed array of Double values]")
    
    let date: Date = try Mapper.map(for: "data", json, { (rawValue: String) -> Date in
        guard let date = DateFormatter().date(from: rawValue) else {
            throw SomeError
        }
    
        return date
})
  ```
  
  For mapping array of Mapable objects it's recommended not to use mappingPath value (just for now :D), to prevent unexpected behavior.
  
