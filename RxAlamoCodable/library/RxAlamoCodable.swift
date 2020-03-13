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

    public var logger: RxAlamoCodableLogger?
    public var headers: HTTPHeaders? = nil

    public init(_ baseURL: String, manager: Alamofire.SessionManager = Alamofire.SessionManager.default, logger: RxAlamoCodableLogger? = nil) {
        self.baseURL = baseURL
        self.manager = manager
        self.logger = logger
    }

    public func get<T: Decodable>(_ path: String, type: T.Type = T.self) -> Single<T> {
        Single.deferred { [unowned self] in
            self.request(path, method: .get).rxValue(self.logger)
        }
    }

    public func get<T: RxAlamoResult<Z>, Z: Decodable>(_ path: String, type: T.Type = T.self) -> Single<RxAlamoResult<Z>> {
        Single.deferred { [unowned self] in
            self.request(path, method: .get).rxResult(self.logger)
        }
    }

    private func createUrl(_ path: String) -> String {
        "\(self.baseURL)\(path)"
    }

    public func get(_ path: String) -> Completable {
        Completable.deferred { [unowned self] in
            self.request(path, method: .get).rxCompletable(self.logger)
        }
    }

    public func delete(_ path: String) -> Completable {
        Completable.deferred { [unowned self] in
            self.request(path, method: .delete).rxCompletable(self.logger)
        }
    }

    public func post<T: Decodable>(_ path: String, body: Encodable? = nil, type: T.Type = T.self) -> Single<T> {
        jsonValueRequest(path, .post, body)
    }

    public func post<T: RxAlamoResult<Z>, Z: Decodable>(_ path: String, body: Encodable? = nil, type: T.Type = T.self) -> Single<RxAlamoResult<Z>> {
        jsonValueRequest(path, .post, body)
    }

    public func post(_ path: String, body: Encodable? = nil) -> Completable {
        jsonCompletableRequest(path, .post, body)
    }

    public func post<T: Decodable>(_ path: String, parameters: Parameters?, encoding: ParameterEncoding) -> Single<T> {
        Single.deferred { [unowned self] in
            self.request(path, method: .post, parameters: parameters, encoding: encoding).rxValue(self.logger)
        }
    }

    public func post<T: RxAlamoResult<Z>, Z: Decodable>(_ path: String, parameters: Parameters?, encoding: ParameterEncoding) -> Single<RxAlamoResult<Z>> {
        Single.deferred { [unowned self] in
            self.request(path, method: .post, parameters: parameters, encoding: encoding).rxResult(self.logger)
        }
    }

    public func post(_ path: String, parameters: Parameters?, encoding: ParameterEncoding) -> Completable {
        Completable.deferred { [unowned self] in
            self.request(path, method: .post, parameters: parameters, encoding: encoding).rxCompletable(self.logger)
        }
    }

    public func put<T: Decodable>(_ path: String, body: Encodable? = nil, type: T.Type = T.self) -> Single<T> {
        jsonValueRequest(path, .put, body)
    }

    public func put<T: RxAlamoResult<Z>, Z: Decodable>(_ path: String, body: Encodable? = nil, type: T.Type = T.self) -> Single<RxAlamoResult<Z>> {
        jsonValueRequest(path, .put, body)
    }

    public func put(_ path: String, body: Encodable? = nil) -> Completable {
        jsonCompletableRequest(path, .put, body)
    }

    public func put<T: Decodable>(_ path: String, parameters: Parameters?, encoding: ParameterEncoding) -> Single<T> {
        Single.deferred { [unowned self] in
            self.request(path, method: .put, parameters: parameters, encoding: encoding).rxValue(self.logger)
        }
    }

    public func put<T: RxAlamoResult<Z>, Z: Decodable>(_ path: String, parameters: Parameters?, encoding: ParameterEncoding) -> Single<RxAlamoResult<Z>> {
        Single.deferred { [unowned self] in
            self.request(path, method: .put, parameters: parameters, encoding: encoding).rxResult(self.logger)
        }
    }

    public func put(_ path: String, parameters: Parameters?, encoding: ParameterEncoding) -> Completable {
        Completable.deferred { [unowned self] in
            self.request(path, method: .put, parameters: parameters, encoding: encoding).rxCompletable(self.logger)
        }
    }

    public func patch<T: Decodable>(_ path: String, body: Encodable? = nil, type: T.Type = T.self) -> Single<T> {
        jsonValueRequest(path, .patch, body)
    }

    public func patch<T: RxAlamoResult<Z>, Z: Decodable>(_ path: String, body: Encodable? = nil, type: T.Type = T.self) -> Single<RxAlamoResult<Z>> {
        jsonValueRequest(path, .patch, body)
    }

    public func patch(_ path: String, body: Encodable? = nil) -> Completable {
        jsonCompletableRequest(path, .patch, body)
    }

    public func patch<T: RxAlamoResult<Z>, Z: Decodable>(_ path: String, parameters: Parameters?, encoding: ParameterEncoding) -> Single<RxAlamoResult<Z>> {
        Single.deferred { [unowned self] in
            self.request(path, method: .patch, parameters: parameters, encoding: encoding).rxResult(self.logger)
        }
    }

    public func patch(_ path: String, parameters: Parameters?, encoding: ParameterEncoding) -> Completable {
        Completable.deferred { [unowned self] in
            self.request(path, method: .patch, parameters: parameters, encoding: encoding).rxCompletable(self.logger)
        }
    }

    private func jsonValueRequest<T: Decodable>(_ path: String, _ method: HTTPMethod, _ body: Encodable? = nil) -> Single<T> {
        body.asRxData(encoder).flatMap { [unowned self] data in
            let request = self.createJsonBodyRequest(path: path, method: method, data: data)
            self.logger?.logRequest(request)
            return self.manager.request(request).rxValue(self.logger)
        }
    }

    private func jsonValueRequest<T: RxAlamoResult<Z>, Z: Decodable>(_ path: String, _ method: HTTPMethod, _ body: Encodable? = nil) -> Single<RxAlamoResult<Z>> {
        body.asRxData(encoder).flatMap { [unowned self] data in
            let request = self.createJsonBodyRequest(path: path, method: method, data: data)
            self.logger?.logRequest(request)
            return self.manager.request(request).rxResult(self.logger)
        }
    }

    private func jsonCompletableRequest(_ path: String, _ method: HTTPMethod, _ body: Encodable? = nil) -> Completable {
        body.asRxData(encoder).flatMapCompletable { [unowned self] data in
            let request = self.createJsonBodyRequest(path: path, method: method, data: data)
            self.logger?.logRequest(request)
            return self.manager.request(request).rxCompletable(self.logger)
        }
    }

    private func createJsonBodyRequest(path: String, method: HTTPMethod, data: Data?) -> URLRequest {
        var request = URLRequest(url: URL(string: self.createUrl(path))!)
        request.httpMethod = method.rawValue
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.headers?.forEach {
            request.addValue($0.key, forHTTPHeaderField: $0.value)
        }
        return request
    }

    private func request(
        _ path: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default)
            -> DataRequest {
        let request = self.manager.request(self.createUrl(path), method: method, parameters: parameters, encoding: encoding, headers: self.headers)
        if let request = request.request {
            logger?.logRequest(request)
        }
        return request;
    }
}

extension DataRequest {
    func rxValue<T: Decodable>(_ logger: RxAlamoCodableLogger?) -> Single<T> {
        Single<T>.create { [weak self] observer in
            self!.responseJSON { response in
                if let httpResponse = response.response {
                    logger?.logResponse(response.request!, httpResponse, response.timeline, response.data)
                }
                if let error = response.error {
                    logger?.logError(error)
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

    func rxResult<T: RxAlamoResult<Z>, Z: Decodable>(_ logger: RxAlamoCodableLogger?) -> Single<RxAlamoResult<Z>> {
        Single<RxAlamoResult<Z>>.create { [weak self] observer in
            self!.responseJSON { response in
                if let httpResponse = response.response {
                    logger?.logResponse(response.request!, httpResponse, response.timeline, response.data)
                }
                if let error = response.error {
                    logger?.logError(error)
                    observer(.error(RxAlamoCodableError.networkError))
                } else if let http = response.response, http.statusCode >= 400 {
                    observer(.error(RxAlamoCodableError.httpError(code: http.statusCode, data: response.data)))
                } else if let data = response.data {
                    do {
                        let object = try JSONDecoder().decode(Z.self, from: data)
                        observer(.success(RxAlamoResult(response, object)))
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

    func rxCompletable(_ logger: RxAlamoCodableLogger?) -> Completable {
        Completable.create { [weak self] observer in
            self!.response { response in
                if let httpResponse = response.response {
                    logger?.logResponse(response.request!, httpResponse, response.timeline, response.data)
                }
                if let error = response.error {
                    logger?.logError(error)
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
        try encoder.encode(self)
    }
}

extension Optional where Wrapped == Encodable {
    func asRxData(_ encoder: JSONEncoder) -> Single<Data?> {
        Single.deferred {
            Single.just(try self?.asData(encoder))
        }
    }
}

public class RxAlamoResult<T: Decodable> {
    public let response: DataResponse<Any>
    public let data: T

    init(_ response: DataResponse<Any>, _ data: T) {
        self.response = response
        self.data = data
    }
}