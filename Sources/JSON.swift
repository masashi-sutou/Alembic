import class Foundation.JSONSerialization
import class Foundation.NSNull
import struct Foundation.Data

public final class JSON {
    public let raw: Any
    
    private let evaluate: () throws -> Any
    private var cached: Any?
    
    public subscript(element: Path.Element...) -> LazyJSON {
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
                throw DecodeError.serializeFailed(with: data)
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
                throw DecodeError.serializeFailed(with: string)
            }
            
            do {
                return try JSONSerialization.jsonObject(with: data, options: options)
            } catch {
                throw DecodeError.serializeFailed(with: string)
            }
        }
    }
    
    private init(raw: Any, evaluate: @escaping () throws -> Any) {
        self.raw = raw
        self.evaluate = evaluate
    }
    
    fileprivate func jsonObject() throws -> Any {
        if let cached = cached { return cached }
        let jsonObject = try evaluate()
        cached = jsonObject
        return jsonObject
    }
}

// MARK: - JSONProtocol

extension JSON: JSONProtocol {
    public func distil<T: Decodable>(_ path: Path, as: T.Type) -> ThrowableDecoded<T> {
        return .init {
            let object: Any = try self.distilRecursive(path: path)
            do {
                return try .value(from: .init(object))
            } catch let DecodeError.missingPath(missing) {
                throw DecodeError.missingPath(path + missing)
            } catch let DecodeError.typeMismatch(expected: expected, actual: actual, path: mismatchPath) {
                throw DecodeError.typeMismatch(expected: expected, actual: actual, path: path + mismatchPath)
            }
        }
    }
    
    public func option<T: Decodable>(_ path: Path, as: T?.Type) -> ThrowableDecoded<T?> {
        return .init {
            do {
                return try *self.distil(path, as: T.self)
            } catch let DecodeError.missingPath(missing) where missing == path {
                return nil
            }
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
        func cast<T>(_ object: Any) throws -> T {
            guard let value = object as? T else {
                throw DecodeError.typeMismatch(expected: T.self, actual: object, path: path)
            }
            return value
        }
        
        func distilRecursive(object: Any, elements: ArraySlice<Path.Element>) throws -> Any {
            guard let first = elements.first else { return object }
            
            switch first {
            case let .key(key):
                let dictionary: [String: Any] = try cast(object)
                
                guard let value = dictionary[key], !(value is NSNull) else {
                    throw DecodeError.missingPath(path)
                }
                
                return try distilRecursive(object: value, elements: elements.dropFirst())
                
            case let .index(index):
                let array: [Any] = try cast(object)
                
                guard array.count > index else {
                    throw DecodeError.missingPath(path)
                }
                
                let value = array[index]
                
                if value is NSNull {
                    throw DecodeError.missingPath(path)
                }
                
                return try distilRecursive(object: value, elements: elements.dropFirst())
            }
        }
        
        let object = try jsonObject()
        let elements = ArraySlice(path.elements)
        return try cast(distilRecursive(object: object, elements: elements))
    }
}
