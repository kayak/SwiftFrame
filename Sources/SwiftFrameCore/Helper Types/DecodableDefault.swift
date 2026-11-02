import Foundation

// Copied and pasted together from John Sundell's post
// https://www.swiftbysundell.com/tips/default-decoding-values/

protocol DecodableDefaultSource {

    associatedtype Value: Decodable
    static var defaultValue: Value { get }

}

enum DecodableDefault {}

extension DecodableDefault {

    @propertyWrapper struct Wrapper<Source: DecodableDefaultSource> {
        typealias Value = Source.Value
        var wrappedValue = Source.defaultValue
    }

}

extension DecodableDefault.Wrapper: Decodable {

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }

}

extension KeyedDecodingContainer {

    func decode<T>(
        _ type: DecodableDefault.Wrapper<T>.Type,
        forKey key: Key
    ) throws -> DecodableDefault.Wrapper<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }

}

extension DecodableDefault {

    typealias Source = DecodableDefaultSource
    typealias List = Decodable & ExpressibleByArrayLiteral

    enum Sources {
        enum EmptyList<T: List>: Source {
            static var defaultValue: T { [] }
        }

        enum IntZero: Source {
            static var defaultValue: Swift.Int { 0 }
        }

        enum CGFloatZero: Source {
            static var defaultValue: CGFloat { 0.00 }
        }
    }

}

extension DecodableDefault {

    typealias EmptyList<T: List> = Wrapper<Sources.EmptyList<T>>
    typealias IntZero = Wrapper<Sources.IntZero>
    typealias CGFloatZero = Wrapper<Sources.CGFloatZero>

}

extension DecodableDefault.Wrapper: Equatable where Value: Equatable {}
extension DecodableDefault.Wrapper: Hashable where Value: Hashable {}
