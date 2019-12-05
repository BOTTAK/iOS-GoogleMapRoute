//
//  Request.swift
//  iOS-GoogleMapRoute
//
//  Created by BOTTAK on 12/5/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import Foundation
import Alamofire

class Request {

    static func new(address: String, args: [String : String] = [:], headers: [String : String] = [:], method: String, _ completionHandler: @escaping (_ response:DataResponse<Any>?) -> Void) { UIPageViewController.curView?.startLoading()
               print("request")
        print(address)
        let url = URL(string: address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        var headers0 = headers
        headers0["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers0
        let encoder = JSONEncoder()
        if(args.count != 0) {
            let jsonData = try! encoder.encode(args)
            request.httpBody = jsonData
        }
        Alamofire.request(request).responseJSON { response in
            UIPageViewController.curView?.stopLoading()
            if(response.result.isSuccess) {
                completionHandler(response)
                       print(response)
            } else {
                completionHandler(nil)
            }
        }
    }

}
