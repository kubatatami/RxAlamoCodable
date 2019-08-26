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
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        api.todo().subscribe(onSuccess: { todo in
            print(todo)
        }).disposed(by: disposeBag)

        api.posts().subscribe(onSuccess: { todo in
            todo.forEach {
                print($0.toJsonString())
            }
        }).disposed(by: disposeBag)

        api.createTodo(TODO(userId: 1, title: "wewecwe", completed: false))
            .subscribe(onCompleted: {
                print("onCompleted")
            }).disposed(by: disposeBag)
    }
}

