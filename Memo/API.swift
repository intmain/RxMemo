//
//  API.swift
//  Memo
//
//  Created by Leonard on 2016. 10. 21..
//  Copyright © 2016년 Leonard. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

enum ApiBuilder {
    case baconipsum
}

extension ApiBuilder {
    
    static let requestManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    static let BaseURL = "https://baconipsum.com"
    
    var path: String {
        switch self {
        case .baconipsum:
            return "/api/"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .baconipsum:
            return .get
        }
    }
    
    var url: String {
        return "\(ApiBuilder.BaseURL)\(self.path)"
    }
    
    func buildRequest(_ parameters: [String: Any]? = nil) -> Observable<Any> {
        return Observable.create { observer in
            let request = ApiBuilder.requestManager.request(self.url, method: self.method, parameters: parameters).responseJSON(completionHandler: { response in
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments)
                    switch (response.result, response.response?.statusCode) {
                    case let (.success(_), statusCode) where statusCode! >= 200 && statusCode! < 300:
                        observer.onNext(json )
                        observer.onCompleted()
                    case let (.success(_), statusCode):
                        observer.onError(NSError(domain: "Error", code: statusCode ?? 500, userInfo: ["":""]))
                    case let (.failure(error) , _ ):
                        observer.onError( error)
                    }
                } catch {
                    observer.onError( error)
                }
                
            })
            return Disposables.create {
                request.cancel()
            }
        }
    }
}


struct API {
    static func Baconipsum() -> Observable<Any> {
        let parameters: [String: Any] = ["type": "meat-and-filler", "paras": 1]
        return ApiBuilder.baconipsum.buildRequest(parameters)
    }
}
