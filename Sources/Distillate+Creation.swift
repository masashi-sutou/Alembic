public extension Distillate {
    static var filter: InsecureDistillate<Value> {
        return error(DistillError.filteredValue(type: Value.self, value: ()))
    }
    
    static func error(_ error: Error) -> InsecureDistillate<Value> {
        return .init { throw error }
    }
    
    static func just(_ element: @autoclosure @escaping () -> Value) -> SecureDistillate<Value> {
        return .init(element)
    }
}
