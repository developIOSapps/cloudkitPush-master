//
//  MyRequestController.swift
//  Test Update Shuas Ipads Notes
//
//  Created by Steven Hertz on 3/3/20.
//  Copyright © 2020 DevelopItSolutions. All rights reserved.
//

import Foundation
import CloudKit

class MyRequestController {
    
       var dbs : CKDatabase {
           return CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase
       }
    
    var tracker = "" {
        didSet {
            print("just set it")
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                //let myRequestController = MyRequestController()
                self.doNextRequest()

                //print("Timer2 fired!")
            }


        }
    }

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
                self.tracker = "Y"
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
   func doNextRequest()  {

    print("start do next")
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
            let bodyString =  bodyStringx.replacingOccurrences(of: "ZZZ", with: "Profile-App-1Kiosk - Student Login")
            request.httpBody = bodyString.data(using: .utf8, allowLossyConversion: true)
            
            /* Start a new Task */
            let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                print("in completion block")
                if (error == nil) {
                    // Success
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP \(statusCode)")
                    self.upDateRecord(studentID: nil, appID: "Student Login")
                }
                else {
                    // Failure
                    print("URL Session Task Failed: %@", error!.localizedDescription);
                }
            })
            task.resume()
            session.finishTasksAndInvalidate()
        }
    
    fileprivate func upDateRecord(studentID: String?, appID: String)  {
        let recordID = CKRecord.ID(recordName: "01d9c633046fbfba766df508eccb6ed0e6dad548")

        dbs.fetch(withRecordID: recordID) { record, error in

            if let record = record, error == nil {
                
                if let studentID = studentID {
                    let theStudentID = CKRecord.ID(recordName: studentID )
                    let studentRef = CKRecord.Reference(recordID: theStudentID, action: .none)
                    record["studentID"] = studentRef as CKRecord.Reference
                }

                let theAppID = CKRecord.ID(recordName: appID )
                let appRef = CKRecord.Reference(recordID: theAppID, action: .none)
                record["appID"] = appRef as CKRecord.Reference

                
                
//                record["currentUser"] = NSString("zzzz")
//                record["identifier"] =  NSString("oooooo")
//                record["userLevel"] =   NSString("l01")

                self.dbs.save(record) { (savedRecord, error) in
                    if let _ = savedRecord, error == nil{
                        print("Record Saved")
                        
                        let recordDidChangeRemotely = Notification.Name("com.pluralsight.cloudKitFundamentals.remoteChangeKey")
                        NotificationCenter.default.post(name: recordDidChangeRemotely,
                                                        object: self,
                                                        userInfo: nil)


                    } else {
                        print("received error")
                    }
                }
            }
        }
    }

}
