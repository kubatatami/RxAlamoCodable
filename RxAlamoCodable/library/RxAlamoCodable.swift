//
// Created by Jakub Bogacki on 2019-08-18.
// Copyright (c) 2019 Jakub Bogacki. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift

public class RxAlamoCodable {

    private let baseURL: String;
    private let manager: Alamofire.SessionManager
    private let encoder = JSONEncoder()

    public var headers: HTTPHeaders? = nil

    public init(_ baseURL: String, manager: Alamofire.SessionManager = Alamofire.SessionManager.default) {
        self.baseURL = baseURL
        self.manager = manager
    }

    public func get<T: Decodable>(_ path: String, type: T.Type = T.self) -> Single<T> {
        return Single.deferred { [unowned self] in self.manager.request("\(self.baseURL)\(path)", headers: self.headers).rxValue() }
    }

    public func get(_ path: String) -> Completable {
        return Completable.deferred { [unowned self] in self.manager.request("\(self.baseURL)\(path)", headers: self.headers).rxCompletable() }
    }

    public func delete(_ path: String) -> Completable {
        return Completable.deferred { [unowned self] in self.manager.request("\(self.baseURL)\(path)", method: .delete, headers: self.headers).rxCompletable() }
    }

    public func post<T: Decodable>(_ path: String, body: Encodable? = nil, type: T.Type = T.self) -> Single<T> {
        return jsonValueRequest(path, .post, body)
    }

    public func post(_ path: String, body: Encodable? = nil) -> Completable {
        return jsonCompletableRequest(path, .post, body)
    }

    public func put<T: Decodable>(_ path: String, body: Encodable? = nil, type: T.Type = T.self) -> Single<T> {
        return jsonValueRequest(path, .put, body)
    }

    public func put(_ path: String, body: Encodable? = nil) -> Completable {
        return jsonCompletableRequest(path, .put, body)
    }

    public func patch<T: Decodable>(_ path: String, body: Encodable? = nil, type: T.Type = T.self) -> Single<T> {
        return jsonValueRequest(path, .patch, body)
    }

    public func patch(_ path: String, body: Encodable? = nil) -> Completable {
        return jsonCompletableRequest(path, .patch, body)
    }

    private func jsonValueRequest<T: Decodable>(_ path: String, _ method: HTTPMethod, _ body: Encodable? = nil) -> Single<T> {
        return body.asRxData(encoder).flatMap { [unowned self] data in
            let request = self.createJsonBodyRequest(path: path, method: method, data: data)
            return self.manager.request(request).rxValue()
        }
    }

    private func jsonCompletableRequest(_ path: String, _ method: HTTPMethod, _ body: Encodable? = nil) -> Completable {
        return body.asRxData(encoder).flatMapCompletable { [unowned self] data in
            let request = self.createJsonBodyRequest(path: path, method: method, data: data)
            return self.manager.request(request).rxCompletable()
        }
    }

    private func createJsonBodyRequest(path: String, method: HTTPMethod, data: Data?) -> URLRequest {
        var request = URLRequest(url: URL(string: "\(self.baseURL)\(path)")!)
        request.httpMethod = method.rawValue
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.headers?.forEach { request.addValue($0.key, forHTTPHeaderField: $0.value) }
        return request
    }
}

extension DataRequest {
    func rxValue<T: Decodable>() -> Single<T> {
        return Single<T>.create { [weak self] observer in
            self!.responseJSON { response in
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
                self?.cancel()
            }
        }
    }

    func rxCompletable() -> Completable {
        return Completable.create { [weak self] observer in
            self!.response { response in
                if let _ = response.error {
                    observer(.error(RxAlamoCodableError.networkError))
                } else if let http = response.response, http.statusCode >= 400 {
                    observer(.error(RxAlamoCodableError.httpError(code: http.statusCode, data: response.data)))
                } else {
                    observer(.completed)
                }
            }
            return Disposables.create {
                self?.cancel()
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
    func asData(_ encoder: JSONEncoder) throws -> Data {
        return try encoder.encode(self)
    }
}

extension Optional where Wrapped == Encodable {
    func asRxData(_ encoder: JSONEncoder) -> Single<Data?> {
        return Single.deferred {
            Single.just(try self?.asData(encoder))
        }
    }
}
