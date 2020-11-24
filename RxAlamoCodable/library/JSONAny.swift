//
// Created by Jakub Bogacki on 2019-08-26.
// Copyright (c) 2019 Jakub Bogacki. All rights reserved.
//

import Foundation

public enum JSONAny: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: JSONAny])
    case array([JSONAny])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try ((try? container.decode(String.self)).map(JSONAny.string))
            .or((try? container.decode(Int.self)).map(JSONAny.int))
            .or((try? container.decode(Double.self)).map(JSONAny.double))
            .or((try? container.decode(Bool.self)).map(JSONAny.bool))
            .or((try? container.decode([String: JSONAny].self)).map(JSONAny.object))
            .or((try? container.decode([JSONAny].self)).map(JSONAny.array))
            .resolve(with: DecodingError.typeMismatch(JSONAny.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a JSON")))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch (self) {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        }
    }

    public func toJson() -> Data {
        return try! JSONEncoder().encode(self)
    }

    public func toJsonString() -> String {
        return String(data: try! JSONEncoder().encode(self), encoding: .utf8)!
    }
}
