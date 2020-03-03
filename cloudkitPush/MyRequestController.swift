//
//  MyRequestController.swift
//  Test Update Shuas Ipads Notes
//
//  Created by Steven Hertz on 3/3/20.
//  Copyright © 2020 DevelopItSolutions. All rights reserved.
//

import Foundation
class MyRequestController {
    func sendRequest(putInNotes name: String) {
        /* Configure session, choose between:
           * defaultSessionConfiguration
           * ephemeralSessionConfiguration
           * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let sessionConfig = URLSessionConfiguration.default

        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        /* Create the Request:
           post Move Device By Updating Note Property (POST https://api.zuludesk.com/devices/01d9c633046fbfba766df508eccb6ed0e6dad548/details)
         */

        guard var URL = URL(string: "https://api.zuludesk.com/devices/01d9c633046fbfba766df508eccb6ed0e6dad548/details") else {return}
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"

        // Headers

        request.addValue("Basic NTM3MjI0NjA6RVBUTlpaVEdYV1U1VEo0Vk5RUDMyWDVZSEpSVjYyMkU=", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "X-Server-Protocol-Version")
        request.addValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")

        // Body

        let bodyStringx = "{\n  \"notes\": \"ZZZ\"\n}"
        let bodyString =  bodyStringx.replacingOccurrences(of: "ZZZ", with: name)
        request.httpBody = bodyString.data(using: .utf8, allowLossyConversion: true)

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
}
