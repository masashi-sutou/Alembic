//
//  Operators.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/25/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

precedencegroup DistillingPrecendence {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator <| : DistillingPrecendence
infix operator <|? : DistillingPrecendence

// MARK: - distil value functions

public func <| <T: Distillable>(j: JSON, path: JSONPath) throws -> T {
    return try j.distil(path)
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> (T.Type) throws -> T {
    return { _ in try j <| path }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> InsecureDistillate<T> {
    return InsecureDistillate { try j <| path }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> (T.Type) -> InsecureDistillate<T> {
    return  { _ in InsecureDistillate { try j <| path } }
}

// MARK: - distil option value functions

public func <|? <T: Distillable>(j: JSON, path: JSONPath) throws -> T? {
    return try j.option(path)
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> (T?.Type) throws -> T? {
    return { _ in try j <|? path }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> InsecureDistillate<T?> {
    return InsecureDistillate { try j <|? path }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> (T?.Type) -> InsecureDistillate<T?> {
    return  { _ in InsecureDistillate { try j <|? path } }
}

// MARK: - distil array functions

public func <| <T: Distillable>(j: JSON, path: JSONPath) throws -> [T] {
    return try j.distil(path)
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> ([T].Type) throws -> [T] {
    return { _ in try j <| path }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> InsecureDistillate<[T]> {
    return InsecureDistillate { try j <| path }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> ([T].Type) -> InsecureDistillate<[T]> {
    return  { _ in InsecureDistillate { try j <| path } }
}

// MARK: - distil option array functions

public func <|? <T: Distillable>(j: JSON, path: JSONPath) throws -> [T]? {
    return try j.option(path)
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> ([T]?.Type) throws -> [T]? {
    return { _ in try j <|? path }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> InsecureDistillate<[T]?> {
    return InsecureDistillate { try j <|? path }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> ([T]?.Type) -> InsecureDistillate<[T]?> {
    return  { _ in InsecureDistillate { try j <|? path } }
}

// MARK: - distil dictionary functions

public func <| <T: Distillable>(j: JSON, path: JSONPath) throws -> [String: T] {
    return try j.distil(path)
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> ([String: T].Type) throws -> [String: T] {
    return { _ in try j <| path }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> InsecureDistillate<[String: T]> {
    return InsecureDistillate { try j <| path }
}

public func <| <T: Distillable>(j: JSON, path: JSONPath) -> ([String: T].Type) -> InsecureDistillate<[String: T]> {
    return  { _ in InsecureDistillate { try j <| path } }
}

// MARK: - distil option dictionary functions

public func <|? <T: Distillable>(j: JSON, path: JSONPath) throws -> [String: T]? {
    return try j.option(path)
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> ([String: T]?.Type) throws -> [String: T]? {
    return { _ in try j <|? path }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> InsecureDistillate<[String: T]?> {
    return InsecureDistillate { try j <|? path }
}

public func <|? <T: Distillable>(j: JSON, path: JSONPath) -> ([String: T]?.Type) -> InsecureDistillate<[String: T]?> {
    return  { _ in InsecureDistillate { try j <|? path } }
}
