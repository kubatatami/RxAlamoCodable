import Foundation
import RxSwift
import Alamofire

class FormAPI {

    private let api = RxAlamoCodable("https://rxalamocodable.free.beeceptor.com/")

    func example(parameter1: String, parameter2: Int) -> Single<FormResponse> {
        api.post("example", parameters: ["parameter1": parameter1, "parameter2": parameter2], encoding: URLEncoding.httpBody)
    }

}

struct FormResponse: Codable {
    let message: String
}