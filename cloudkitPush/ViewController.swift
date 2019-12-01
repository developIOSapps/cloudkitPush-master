//
//  ViewController.swift
//  cloudkitPush
//
//  Created by Soulchild on 27/09/2018.
//  Copyright © 2018 fluffy. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var studentsLoggedIn: [String] = ["jack", "harry", "sam", "david"]
    
    let recordDidChangeRemotely = Notification.Name("com.pluralsight.cloudKitFundamentals.remoteChangeKey")
    
    @IBOutlet weak var studentTableView: UITableView!
    
    @IBOutlet weak var studentPicImageView: UIImageView!
    
    @IBOutlet weak var titlelabel: UILabel!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Setup the notification Observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRemoteRecordChange),
                                               name: recordDidChangeRemotely,
                                               object: nil)
        
        /// Setup the TableView
        studentTableView.delegate = self
        studentTableView.dataSource = self
        
   }
    
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        studentsLoggedIn.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseid", for: indexPath)
        cell.textLabel?.text = studentsLoggedIn[indexPath.row]
        return cell
       }
       
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

     @objc func handleRemoteRecordChange(_ notification: Notification) {
        
        guard let queryNotif = CKNotification(fromRemoteNotificationDictionary: notification.userInfo!) as? CKQueryNotification else { return }
        print("Container Identifier: \(String(describing: queryNotif.containerIdentifier))")
        print("Record ID Name: \(String(describing: queryNotif.recordID?.recordName))")
        print("Record ID Name: \(String(describing: queryNotif.recordID?.zoneID.zoneName))")
        print("QueryNotificationReason: \(queryNotif.queryNotificationReason)")

        
        print("*********************** In Remote Record Change")
        
        let theCurrentU =  queryNotif.recordFields?["currentUser"] as! String
        print("* * * * * - The current user", theCurrentU)
        
        DispatchQueue.main.async {
            self.studentsLoggedIn.append(theCurrentU)
            self.studentTableView.reloadData()
        }
        
    }
     


}

extension ViewController: UNUserNotificationCenterDelegate {
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let application = UIApplication.shared
        
        if(application.applicationState == .active){
            print("1  app received notification while in foreground")
        }

        let body = notification.request.content.body
        //let body = response.notification.request.content.body
        
        print("1 this is the content of the notification \(body)")
        studentPicImageView.image = UIImage(named: body)
        
        // show the notification alert (banner), and with sound
        // completionHandler([.alert, .sound])
        completionHandler([])

    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    
        let application = UIApplication.shared
        
        if(application.applicationState == .active){
            print("2 user tapped the notification bar when the app is in foreground")
        }
        
        if(application.applicationState == .inactive)
        {
            print("2 user tapped the notification bar when the app is in background")
        }
        
        let body = response.notification.request.content.body

        
        print("this is the content of the notification \(body)")
        
        /*
        /// remove sent or scheduled to be sent notifications
        center.removeDeliveredNotifications(withIdentifiers: ["nextStudent"])
        center.removePendingNotificationRequests(withIdentifiers: ["nextStudent"])
        
        let body = response.notification.request.content.body
        print("this is the content of the notification \(body)")
        
        let action = response.actionIdentifier
        print(action)
        
        let userInfo = response.notification.request.content.userInfo
        let studentID = userInfo["name"] as! String
        print(studentID)
        let navigationVC = window?.rootViewController as! UINavigationController
        let topVC = navigationVC.topViewController as! DetailViewController
        topVC.theItem = studentID
        topVC.studentImageView.image = UIImage(named: studentID)
        */
        
        // tell the app that we have finished processing the user’s action / response
        completionHandler()
    }
    
}


