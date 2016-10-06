//
//  JSON.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import class Foundation.JSONSerialization
import class Foundation.NSNull
import struct Foundation.Data

public final class JSON {
    public let raw: Any
    fileprivate let createObject: () throws -> Any
    
    public subscript(element: PathElement...) -> LazyJSON {
        return .init(rootJSON: self, currentPath: .init(elements: element))
    }
    
    public convenience init(_ raw: Any) {
        self.init(raw: raw) { raw }
    }
    
    public convenience init(data: Data, options: JSONSerialization.ReadingOptions = .allowFragments) {
        self.init(raw: data) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: options)
            } catch {
                throw DistillError.failedToSerialize(with: data)
            }
        }
    }
    
    public convenience init(
        string: String,
        encoding: String.Encoding = .utf8,
        allowLossyConversion: Bool = false,
        options: JSONSerialization.ReadingOptions = .allowFragments) {
        self.init(raw: string) {
            guard let data = string.data(using: encoding, allowLossyConversion: allowLossyConversion) else {
                throw DistillError.failedToSerialize(with: string)
            }
            
            do {
                return try JSONSerialization.jsonObject(with: data, options: options)
            } catch {
                throw DistillError.failedToSerialize(with: string)
            }
        }
    }
    
    private init(raw: Any, createObject: @escaping () throws -> Any) {
        self.raw = raw
        self.createObject = createObject
    }
}

// MARK: - JSONType

extension JSON: JSONType {
    public func distil<T: Distillable>(_ path: Path, as: T.Type) throws -> T {
        let object: Any = try distilRecursive(path: path)
        do {
            return try .distil(json: .init(object))
        } catch let DistillError.missingPath(missing) {
            throw DistillError.missingPath(path + missing)
        } catch let DistillError.typeMismatch(expected: expected, actual: actual, path: mismatchPath) {
            throw DistillError.typeMismatch(expected: expected, actual: actual, path: path + mismatchPath)
        }
    }
    
    public func option<T: Distillable>(_ path: Path, as: T?.Type) throws -> T? {
        do {
            return try distil(path, as: T.self)
        } catch let DistillError.missingPath(missing) where missing == path {
            return nil
        }
    }
}

// MARK: - CustomStringConvertible

extension JSON: CustomStringConvertible {
    public var description: String {
        return "JSON(\(raw))"
    }
}

// MARK: - CustomDebugStringConvertible

extension JSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK: - private functions

private extension JSON {
    func distilRecursive<T>(path: Path) throws -> T {
        var distilledPath: Path = []
        
        func cast<T>(_ object: Any) throws -> T {
            guard let value = object as? T else {
                throw DistillError.typeMismatch(expected: T.self, actual: object, path: distilledPath)
            }
            return value
        }
        
        func distilRecursive(object: Any, elements: ArraySlice<PathElement>) throws -> Any {
            guard let first = elements.first else { return object }
            
            distilledPath = distilledPath + .init(element: first)
            
            switch first {
            case let .key(key):
                let dictionary: [String: Any] = try cast(object)
                
                guard let value = dictionary[key], !(value is NSNull) else {
                    throw DistillError.missingPath(path)
                }
                
                return try distilRecursive(object: value, elements: elements.dropFirst())
                
            case let .index(index):
                let array: [Any] = try cast(object)
                
                guard array.count > index else {
                    throw DistillError.missingPath(path)
                }
                
                let value = array[index]
                
                if value is NSNull {
                    throw DistillError.missingPath(path)
                }
                
                return try distilRecursive(object: value, elements: elements.dropFirst())
            }
        }
        
        let object = try createObject()
        let elements = ArraySlice(path.elements)
        return try cast(distilRecursive(object: object, elements: elements))
    }
}
