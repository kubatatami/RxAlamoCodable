//
// Created by Jakub Bogacki on 2019-08-18.
// Copyright (c) 2019 Jakub Bogacki. All rights reserved.
//

import Foundation
import RxSwift

class RxAlamoCodableAuth {

    private var logoutSubject: PublishSubject<Void>!
    private(set) var authInterceptor: Observable<Void>
    public var logout: Observable<Void> {
        return logoutSubject.asObservable()
    }
    let isAuthError: (Int, Data?) -> Bool

    public init (authInterceptor: Observable<Void>, isAuthError: @escaping (Int, Data?) -> Bool = { code, _ in code == 401 }) {
        let logoutSubject = PublishSubject<Void>()
        self.authInterceptor = authInterceptor.share().do(onError: {error in
            if case let RxAlamoCodableError.httpError(code, data) = error, isAuthError(code, data) {
                logoutSubject.onNext(())
            }
        })
        self.logoutSubject = logoutSubject
        self.isAuthError = isAuthError
    }
}

extension Single {
    public func auth(_ auth: RxAlamoCodableAuth) -> PrimitiveSequence<Trait, Element> {
        return self.retryWhen { observable in
            observable.flatMap { error -> Observable<Void> in
                if case let RxAlamoCodableError.httpError(code, data) = error, auth.isAuthError(code, data) {
                    return auth.authInterceptor
                } else {
                    return Observable.error(error)
                }
            }
        }
    }
}