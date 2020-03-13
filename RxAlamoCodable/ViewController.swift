//
//  ViewController.swift
//  RxAlamoCodable
//
//  Created by Jakub Bogacki on 18/08/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    private let api = API()
    private let formApi = FormAPI()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        api.todo().subscribe(onSuccess: { todo in
//            print(todo)
        }).disposed(by: disposeBag)

        api.todoFullResponse().subscribe(onSuccess: { response in
//            print(response.response.response?.allHeaderFields)
//            print(response.data)
        }).disposed(by: disposeBag)

        api.todoTitle().subscribe(onSuccess: { todo in
//            print(todo)
        }).disposed(by: disposeBag)

        api.posts().subscribe(onSuccess: { todo in
//            todo.forEach {
//                print($0.toJsonString())
//            }
        }).disposed(by: disposeBag)

        api.createTodo(TODO(userId: 1, title: "wewecwe", completed: false))
            .subscribe(onCompleted: {
//                print("onCompleted")
            }).disposed(by: disposeBag)

        formApi.example(parameter1: "wewecwe", parameter2: 1234)
            .subscribe(onSuccess: { response in
//                print(response.message)
            }).disposed(by: disposeBag)
    }
}

