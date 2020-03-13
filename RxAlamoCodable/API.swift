//
// Created by Jakub Bogacki on 2019-08-18.
// Copyright (c) 2019 Jakub Bogacki. All rights reserved.
//

import Foundation
import RxSwift

class API {

    private let api = RxAlamoCodable(
        "https://jsonplaceholder.typicode.com/", 
        logger: DefaultRxAlamoCodableLogger(logHeaders: false, logBody: true, logNetworkErrors: true)
    )

    func todo() -> Single<TODO> {
        api.get("todos/1")
    }

    func todoFullResponse() -> Single<RxAlamoResult<TODO>> {
        api.get("todos/1")
    }

    func todoTitle() -> Single<String> {
        api.get("todos/1", type: TODO.self).map { $0.title }
    }

    func posts() -> Single<Array<JSONAny>> {
        api.get("posts")
    }

    func createTodo(_ todo: TODO) -> Completable {
        api.post("todos", body: todo)
    }
}

struct TODO: Codable {
    let userId: Int
    let id: Int = 0
    let title: String
    let completed: Bool
}