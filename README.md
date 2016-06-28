![Alembic](https://raw.githubusercontent.com/ra1028/Alembic/master/Assets/Alembic_Logo.png)  

<p align="center">
<a href="https://travis-ci.org/ra1028/Alembic"><img alt="Build Status" src="https://travis-ci.org/ra1028/Alembic.svg?branch=master"/></a>
<a href="https://developer.apple.com/swift"><img alt="Swift2.2" src="https://img.shields.io/badge/swift2.2-compatible-blue.svg?style=flat"/></a>
<a href="https://github.com/ra1028/Alembic/blob/master/LICENSE"><img alt="Lincense" src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat"/></a>
<a href="http://cocoadocs.org/docsets/Alembic"><img alt="Platform" src="https://img.shields.io/cocoapods/p/Alembic.svg?style=flat"/></a><br>
<a href="https://cocoapods.org/pods/Alembic"><img alt="CocoaPods" src="https://img.shields.io/cocoapods/v/Alembic.svg"/></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"/></a>
<a href="https://github.com/apple/swift-package-manager"><img alt="Swift Package Manager" src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg"/></a>
</p>  

<p align="center">
<H4 align="center">Functional JSON parsing, mapping to objects, and serialize to JSON</H4>
</p>  

---

## Contents
- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  + [Initialization](#initialization)
  + [JSON parsing](#json-parsing)
  + [Nested objects parsing](#nested-objects-parsing)
  + [Optional objects parsing](#optional-objects-parsing)
  + [Custom objects parsing](#custom-objects-parsing)
  + [Object mapping](#object-mapping)  
  + [Value transformation](#value-transformation)
  + [Error handling](#error-handling)
  + [Serialize objects to JSON](#serialize-objects-to-json)
- [Playground](#playground)
- [Contribution](#contribution)
- [About](#about)
- [License](#license)

---

## Overview  
```Swift
do {
    let j = JSON(obj)

    let str1: String = try j.distil("str1")
    let str2: String = try j <| "str2"
    let str3: String = try j["str3"].distil()

    let transform: Int = (j <| "transform")
        .filter { $0 > 0 }
        .map { $0 * 2 }
        .recover(0)

    let users: [User] = try j <| "users"

    let userJsonData = JSON.serializeToData(users)
} catch {
    // Do error handling...
}

struct User: Distillable, Serializable {
    let name: String
    let thumbnailUrl: NSURL

    static func distil(j: JSON) throws -> User {
        return try User(
            name: j <| "name",
            thumbnailUrl: (j <| "url").flatMap(NSURL.init(string:))
        )
    }

    func serialize() -> JSONObject {
        return ["name": name, "url": thumbnailUrl.absoluteString]
    }
}
```

---

## Features
- [x] JSON parsing with ease
- [x] Mapping JSON to objects
- [x] Serialize objects to JSON
- [x] Powerful value transformation
- [x] Fail safety
- [x] class, struct, enum support with non-optional `let` properties
- [x] Functional, Protocol-oriented programming
- [x] Flexible syntaxes

---

## Requirements
- Swift 2.2 / Xcode 7.3
- OS X 10.9 or later
- iOS 8.0 or later
- watchOS 2.0 or later
- tvOS 9.0 or later

---

## Installation

### [CocoaPods](https://cocoapods.org/)  
Add the following to your Podfile:
```ruby
use_frameworks!
pod 'Alembic'
```

### [Carthage](https://github.com/Carthage/Carthage)  
Add the following to your Cartfile:
```ruby
github "ra1028/Alembic"
```

### [CocoaSeeds](https://github.com/devxoul/CocoaSeeds)  
Add the following to your Seedfile:
```ruby
github "ra1028/Alembic", :files => "Sources/**/*.swift"
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)
Add the following to your Package.swift:
```Swift
let package = Package(
    name: "ProjectName",
    dependencies: [
        .Package(url: "https://github.com/ra1028/Alembic.git", majorVersion: 1)
    ]
)
```

---

## Usage

### Initialization
```Swift
import Alembic
```
JSON from AnyObject
```Swift
let j = JSON(jsonObject)
```
JSON from NSData
```Swift
let j = try JSON(data: jsonData)
```
```Swift
let j = try JSON(data: jsonData, options: .AllowFragments)
```
JSON from String  
```Swift
let j = try JSON(string: jsonString)
```
```Swift
let j = try JSON(
    string: jsonString,
    encoding: NSUTF8StringEncoding,
    allowLossyConversion: false,
    options: .AllowFragments
)
```

### JSON parsing
To enable parsing, a class, struct, or enum just needs to implement the `Distillable` protocol.  
```Swift
public protocol Distillable {
    static func distil(j: JSON) throws -> Self
}
```

__Default supported types__  
- `JSON`  
- `String`  
- `Int`  
- `Double`   
- `Float`  
- `Bool`  
- `NSNumber`  
- `Int8`  
- `UInt8`  
- `Int16`  
- `UInt16`  
- `Int32`  
- `UInt32`  
- `Int64`  
- `UInt64`  
- `RawRepresentable`  
- `Array<T: Distillable>`  
- `Dictionary<String, T: Distillable>`  

__Example__
```Swift
let jsonObject = ["key": "string"]
let j = JSON(jsonObject)
```
function
```Swift
let string: String = try j.distil("key")  // "string"
```
custom operator  
```Swift
let string: String = try j <| "key"  // "string"
```
subscript
```Swift
let string: String = try j["key"].distil()  // "string"
```

__Tips__  
You can set the generic type as following:  
```Swift
let string = try j.distil("key").to(String)  // "string"
```
It's same if use operator or subscript

### Nested objects parsing
Supports parsing nested objects with keys and indexes.  
Keys and indexes can be summarized in the same array.  

__Example__
```Swift
let jsonObject = [
    "nested": ["array": [1, 2, 3, 4, 5]]
]
let j = JSON(jsonObject)
```
function
```Swift
let int: Int = try j.distil(["nested", "array", 2])  // 3        
```
custom operator
```Swift
let int: Int = try j <| ["nested", "array", 2]  // 3  
```
subscript
```Swift
let int: Int = try j["nested", "array", 2].distil()  // 3  
let int: Int = try j["nested"]["array"][2].distil()  // 3  
```

__Tips__  
Syntax like [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) is here:  
```Swift
let json = try JSON(data: jsonData)
let userName = try json[0]["user"]["name"].to(String)
```


### Optional objects parsing
Has functions to parsing optional objects.  
If the key is missing, returns nil.  

__Example__
```Swift
let jsonObject = [
    "nested": [:] // Nested key is nothing...
]
let j = JSON(jsonObject)
```
function
```Swift
let int: Int? = try j.option(["nested", "key"])  // nil
```
custom operator
```Swift
let int: Int? = try j <|? ["nested", "key"]  // nil
```
subscript
```Swift
let int: Int? = try j["nested", "key"].option()  // nil
let int: Int? = try j["nested"]["key"].option()  // nil
```

### Custom objects parsing
If implement `Distillable` protocol to existing classes like `NSURL`, it be able to parse from JSON.  

__Example__
```Swift
let jsonObject = ["key": "http://example.com"]
let j = JSON(jsonObject)
```
```Swift
extension NSURL: Distillable {
    public static func distil(j: JSON) throws -> Self {
        return try j.distil().flatMap(self.init(string:))
    }
}

let url: NSURL = try j <| "key"  // http://example.com
```

### Object mapping  
To mapping your models, need confirm to the `Distillable` protocol.  
Then, parse the objects from JSON to all your model properties.  

__Example__
```Swift
let jsonObject = [
    "key": [
        "string_key": "string",
        "option_int_key": NSNull()
    ]
]
let j = JSON(jsonObject)
```
```Swift
struct Sample: Distillable {
    let string: String
    let int: Int?

    static func distil(j: JSON) throws -> Sample {
        return try Sample(
            string: j <| "string_key",
            int: j <|? "option_int_key"
        )
    }
}

let sample: Sample = try j <| "key"  // Sample
```

### Value transformation
Alembic supports functional value transformation during the parsing process like `String` -> `NSDate`.  
Functions that extract value from JSON are possible to return `Distillate` object.  
So, you can use 'map' 'flatMap' and other following useful functions.  

<table>

<thead>
<tr>
<th>func</th>
<th>description</th>
<th>returns</th>
<th>throws</th>
</tr>
</thead>

<tbody>

<tr>
<td>map(Value throws -> U)</td>
<td>Transform the current value.</td>
<td>U</td>
<td>throw</td>
</tr>

<tr>
<td>flatMap(Value throws -> (U: DistillateType))</td>
<td>Returns the value containing in U.</td>
<td>U.Value</td>
<td>throw</td>
</tr>

<tr>
<td>flatMap(Value throws -> U?</td>
<td>Returns the non-nil value.<br>
If the transformed value is nil,<br>
throw DistillError.FilteredValue</td>
<td>U.Wrapped</td>
<td>throw</td>
</tr>

<tr>
<td>flatMapError(ErrorType throws -> (U: DistillateType)</td>
<td>If the error thrown, flatMap its error.</td>
<td>U.Value</td>
<td>throw</td>
</tr>

<tr>
<td>filter(Value throws -> Bool)</td>
<td>If the value is filtered by predicates,<br>
throw DistillError.FilteredValue.</td>
<td>Value</td>
<td>throw</td>
</tr>

<tr>
<td>recover(Value)</td>
<td>If the error was thrown, replace it.<br>
Error handling is not required.</td>
<td>Value (might replace)</td>
<td></td>
</tr>

<tr>
<td>recover(ErrorType -> Value)</td>
<td>If the error was thrown, replace it.<br>
Error handling is not required.</td>
<td>Value (might replace)</td>
<td></td>
</tr>

<tr>
<td>replaceNil(Value.Wrapped)</td>
<td>If the value is nil, replace it.</td>
<td>Value.Wrapped (might replace)</td>
<td>throw</td>
</tr>

<tr>
<td>replaceNil(() throws -> Value.Wrapped)</td>
<td>If the value is nil, replace it.</td>
<td>Value.Wrapped (might replace)</td>
<td>throw</td>
</tr>

<tr>
<td>filterNil()</td>
<td>If the value is nil,<br>
throw DistillError.FilteredValue.</td>
<td>Value.Wrapped</td>
<td>throw</td>
</tr>

<tr>
<td>replaceEmpty(Value)</td>
<td>If the value is empty of CollectionType, replace it.</td>
<td>Value (might replace)</td>
<td>throw</td>
</tr>

<tr>
<td>replaceEmpty(() throws -> Value)</td>
<td>If the value is empty of CollectionType, replace it.</td>
<td>Value (might replace)</td>
<td>throw</td>
</tr>

<tr>
<td>filterEmpty()</td>
<td>If the value is empty of CollectionType,<br>
throw DistillError.FilteredValue.</td>
<td>Value</td>
<td>throw</td>
</tr>

</tbody>
</table>

__Example__
```Swift
let jsonObject = ["time_string": "2016-04-01 00:00:00"]
let j = JSON(jsonObject)
```
function
```Swift
let date: NSDate = j.distil("time_string")(String)  // "Apr 1, 2016, 12:00 AM"
    .filter { !$0.isEmpty }
    .flatMap {
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return fmt.dateFromString($0)
    }  
    .recover(NSDate())
```
custom operator
```Swift
let date: NSDate = (j <| "time_string")(String)  // "Apr 1, 2016, 12:00 AM"
    .filter { !$0.isEmpty }
    .flatMap {
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return fmt.dateFromString($0)
    }
    .recover(NSDate())
```
subscript
```Swift
let date: NSDate = j["time_string"].distil(String)  // "Apr 1, 2016, 12:00 AM"
    .filter { !$0.isEmpty }
    .flatMap {
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return fmt.dateFromString($0)
    }    
    .recover(NSDate())
```

__Tips__  
You can create `Distillate` by  `Distillate.just(value)`, `Distillate.filter()` and `Distillate.error(error)`.  
It's provide more convenience to value-transformation.  
Example:  

```Swift
struct FindAppleError: ErrorType {}

let message: String = try j.distil("number_of_apples")(Int)
    .flatMap { count -> Distillate<String> in
        count > 0 ? .just("\(count) apples found!!") : .filter()
    }
    .flatMapError { _ in Distillate.error(FindAppleError()) }
    .recover { "Anything not found... | Error: \($0)" }
```

### Error handling
Alembic has simple error handling designs as following.  

__DistillError__
- case MissingPath(JSONPath)  
- case TypeMismatch(expected: Any.Type, actual: AnyObject)  
- case FilteredValue(type: Any.Type, value: Any)  

<table>
<thead>
<tr>
<th>func</th>
<th>null</th>
<th>missing key</th>
<th>type mismatch</th>
<th>error in sub-objects</th>
</tr>
</thead>

<tbody>

<tr>
<td>
try j.distil(path)<br>
try j <| path<br>
try j[path].distil()<br>
</td>
<td>throw</td>
<td>throw</td>
<td>throw</td>
<td>throw</td>
</tr>

<tr>
<td>
try j.option(path)<br>
try j <|? path<br>
try j[path].option()<br>
</td>
<td>nil</td>
<td>nil</td>
<td>throw</td>
<td>throw</td>
</tr>

<tr>
<td>
try? j.distil(path)<br>
try? j <| path<br>
try? j[path].distil()<br>
</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
</tr>

<tr>
<td>
try? j.option(path)<br>
try? j <|? path<br>
try? j[path].option()<br>
</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
</tr>

</tbody>
</table>

__Don't wanna handling the error?__  
If you don't care about error handling, use `try?` or `(j <| "key").recover(value)`.  
```Swift
let value: String? = try? j <| "key"
```
```Swift
let value: String = (j <| "key").recover("sub-value")
```

### Serialize objects to JSON
To Serialize objects to `NSData` or `String` of JSON, your models should implements the `Serializable` protocol.  
```Swift
public protocol Serializable {
    func serialize() -> JSONObject
}
```
`serialize()` function returns the `JSONObject`.  

- JSONObject  
  `init` with `Array<T: JSONValueConvertible>` or `Dictionary<String, T: JSONValueConvertible>` only.  
  Implemented the `ArrayLiteralConvertible` and `DictionaryLiteralConvertible`.
- JSONValueConvertible  
  The protocol that to be convert to `JSONValue` with ease.
- JSONValue  
  For constraint to the types that allowed as value of JSON.   

__Defaults JSONValueConvertible implemented types__  
- `String`  
- `Int`  
- `Double`  
- `Float`  
- `Bool`  
- `NSNumber`  
- `Int8`  
- `UInt8`  
- `Int16`  
- `UInt16`  
- `Int32`  
- `UInt32`  
- `Int64`  
- `UInt64`  
- `RawRepresentable`  
- `JSONValue`  

__Example__
```Swift
let user: User = ...
let data = JSON.serializeToData(user)
let string = JSON.serializeToString(user)

enum Gender: String, JSONValueConvertible {
    case Male = "male"
    case Female = "female"

    private var jsonValue: JSONValue {
        return JSONValue(rawValue)
    }
}

struct User: Serializable {
    let id: Int
    let name: String    
    let gender: Gender
    let friendIds: [Int]

    func serialize() -> JSONObject {
        return [
            "id": id,
            "name": name,            
            "gender": gender,
            "friend_ids": JSONValue(friendIds)
        ]
    }
}
```

---

### More Example
See the Alembic `Tests` for more examples.  
If you want to try Alembic, use Alembic Playground :)

---

## Playground
1. Open Alembic.xcworkspace.
2. Build the Alembic-iOS.
3. Open Alembic playground in project navigator.
4. Enjoy the Alembic!

---

## Contribution
Welcome to fork and submit pull requests!!  

Before submitting pull request, please ensure you have passed the included tests.  
If your pull request including new function, please write test cases for it.  

(Also, welcome the offer of Alembic logo image :pray:)

---

## About  
Alembic is inspired by great libs
[Argo](https://github.com/thoughtbot/Argo),
[Himotoki](https://github.com/ikesyo/Himotoki),
[RxSwift](https://github.com/ReactiveX/RxSwift).  
Greatly thanks for authors!! :beers:.  

---

## License  
Alembic is released under the MIT License.

---
