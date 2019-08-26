//
// Created by Jakub Bogacki on 2019-08-18.
// Copyright (c) 2019 Jakub Bogacki. All rights reserved.
//

import Foundation
import RxSwift

class API {

    private let api = RxAlamoCodable("https://jsonplaceholder.typicode.com/")

    func todo() -> Single<TODO> {
        return api.get("todos/1")
    }

    func posts() -> Single<Array<JSONAny>> {
        return api.get("posts")
    }

    func createTodo(_ todo: TODO) -> Completable {
        return api.post("todos", body: todo)
    }

}

struct TODO: Codable {
    let userId: Int
    let id: Int = 0
    let title: String
    let completed: Bool
}