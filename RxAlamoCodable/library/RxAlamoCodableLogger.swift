//
// Created by Jakub Bogacki on 13/03/2020.
// Copyright (c) 2020 Jakub Bogacki. All rights reserved.
//

import Alamofire
import Foundation

public protocol RxAlamoCodableLogger {
    func logRequest(_ request: URLRequest)
    func logResponse(_ request: URLRequest, _ response: HTTPURLResponse, _ timeline: Timeline, _ data: Data?)
    func logError(_ error: Error)
}

public class DefaultRxAlamoCodableLogger: RxAlamoCodableLogger {

    public var logHeaders: Bool
    public var logBody: Bool
    public var logNetworkErrors: Bool

    public init(logHeaders: Bool, logBody: Bool, logNetworkErrors: Bool) {
        self.logHeaders = logHeaders
        self.logBody = logBody
        self.logNetworkErrors = logNetworkErrors
    }

    public func logRequest(_ request: URLRequest) {
        print("--> \(request.httpMethod!) \(request.url!.absoluteString) (\(request.httpBody?.count ?? 0)-byte body)")
        if logHeaders || logBody {
            if logHeaders {
                request.allHTTPHeaderFields?.forEach { key, value in
                    debugPrint("\(key): \(value)")
                }
                if logBody {
                    print("")
                }
            }
            if let body = request.httpBody, logBody {
                print(String(decoding: body, as: UTF8.self))
            }
            if request.httpBody != nil || !(request.allHTTPHeaderFields?.isEmpty ?? true) {
                print("--> END \(request.httpMethod!)")
            }
        }
    }

    public func logResponse(_ request: URLRequest, _ response: HTTPURLResponse, _ timeline: Timeline, _ data: Data?) {
        print("<-- \(response.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode)) (\(Int(timeline.requestDuration * 1000))ms) \(request.httpMethod!) \(request.url!.absoluteString)")
        if logHeaders || logBody {
            if logHeaders {
                response.allHeaderFields.forEach { key, value in
                    debugPrint("\(key): \(value)")
                }
            }
            if let body = data, logBody {
                print("")
                print(String(decoding: body, as: UTF8.self))
            }
            print("<-- END HTTP")
        }
    }

    public func logError(_ error: Error) {
        if logNetworkErrors {
            print(error.localizedDescription)
        }
    }
}