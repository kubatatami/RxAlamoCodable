//
// Created by Jakub Bogacki on 2019-08-18.
// Copyright (c) 2019 Jakub Bogacki. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift

public class RxAlamoCodable {

    private let baseURL: String;
    public var headers: HTTPHeaders? = nil

    public init(_ baseURL: String) {
        self.baseURL = baseURL
    }

    public func get<T: Decodable>(_ path: String) -> Single<T> {
        return AF.request("\(self.baseURL)\(path)", headers: headers).rxValue()
    }

    public func get(_ path: String) -> Completable {
        return AF.request("\(self.baseURL)\(path)", headers: headers).rxCompletable()
    }

    public func delete(_ path: String) -> Completable {
        return AF.request("\(self.baseURL)\(path)", method: .delete, headers: headers).rxCompletable()
    }

    public func post<T: Decodable>(_ path: String, body: Encodable? = nil) -> Single<T> {
        return jsonValueRequest(path, .post, body)
    }

    public func post(_ path: String, body: Encodable? = nil) -> Completable {
        return jsonCompletableRequest(path, .post, body)
    }

    public func put<T: Decodable>(_ path: String, body: Encodable? = nil) -> Single<T> {
        return jsonValueRequest(path, .put, body)
    }

    public func put(_ path: String, body: Encodable? = nil) -> Completable {
        return jsonCompletableRequest(path, .put, body)
    }

    public func patch<T: Decodable>(_ path: String, body: Encodable? = nil) -> Single<T> {
        return jsonValueRequest(path, .patch, body)
    }

    public func patch(_ path: String, body: Encodable? = nil) -> Completable {
        return jsonCompletableRequest(path, .patch, body)
    }

    private func jsonValueRequest<T: Decodable>(_ path: String, _ method: HTTPMethod, _ body: Encodable? = nil) -> Single<T> {
        return body.asRxDictionary().flatMap { [unowned self] params in
            AF.request("\(self.baseURL)\(path)", method: method, parameters: params, encoding: JSONEncoding.default, headers: self.headers).rxValue()
        }
    }

    private func jsonCompletableRequest(_ path: String, _ method: HTTPMethod, _ body: Encodable? = nil) -> Completable {
        return body.asRxDictionary().flatMapCompletable { [unowned self] params in
            AF.request("\(self.baseURL)\(path)", method: method, parameters: params, encoding: JSONEncoding.default, headers: self.headers).rxCompletable()
        }
    }
}

extension DataRequest {
    func rxValue<T: Decodable>() -> Single<T> {
        return Single<T>.create { observer in
            self.responseJSON { response in
                if let _ = response.error {
                    observer(.error(RxAlamoCodableError.networkError))
                } else if let http = response.response, http.statusCode >= 400 {
                    observer(.error(RxAlamoCodableError.httpError(code: http.statusCode, data: response.data)))
                } else if let data = response.data {
                    do {
                        let object = try JSONDecoder().decode(T.self, from: data)
                        observer(.success(object))
                    } catch {
                        observer(.error(RxAlamoCodableError.parseError(error: error, data: data)))
                    }
                } else {
                    observer(.error(RxAlamoCodableError.emptyResponse))
                }
            }
            return Disposables.create {
                self.cancel()
            }
        }
    }

    func rxCompletable() -> Completable {
        return Completable.create { observer in
            self.response { response in
                if let _ = response.error {
                    observer(.error(RxAlamoCodableError.networkError))
                } else if let http = response.response, http.statusCode >= 400 {
                    observer(.error(RxAlamoCodableError.httpError(code: http.statusCode, data: response.data)))
                } else {
                    observer(.completed)
                }
            }
            return Disposables.create {
                self.cancel()
            }
        }
    }
}

public enum RxAlamoCodableError: Error {
    case httpError(code: Int, data: Data?)
    case networkError
    case parseError(error: Error, data: Data)
    case emptyResponse
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

extension Optional where Wrapped == Encodable {
    func asRxDictionary() -> Single<[String: Any]?> {
        return Single.deferred {
            Single.just(try self?.asDictionary())
        }
    }
}
