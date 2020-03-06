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
    
    var tracker = "" {
        didSet {
            print("just set it")
        }
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Setup the notification Observer
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleRemoteRecordChange),
//                                               name: recordDidChangeRemotely,
//                                               object: nil)
        
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
        
        print("- - - - - - * viewcontroller userNotificationCenter fired")
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

extension AppDelegate {
    
    /*
     
     It seems that this is used when tracking all changes from from a  commit point keep things in sync
     
     */
    
    
    fileprivate func forTrackingAllSinceLast() {
        /// Create an instance of the fetchNotificationChangesCompletionBlock class
        let fetchNotificationChangesOperation = CKFetchNotificationChangesOperation(previousServerChangeToken: nil)
        
        /// set the notificationChangedBlock property
        var recordChanges = [CKRecordID: CKQueryNotificationReason]()
        fetchNotificationChangesOperation.notificationChangedBlock = { notification in
            print("* * * we are in the notificationChangedBlock ")
            let x = notification.subscriptionID
            print("Subscription id is \(String(describing: x))" ,String(describing: x))
            
            guard let n = notification as? CKQueryNotification, let recordID = n.recordID  else { return  }
            
            recordChanges[recordID] = n.queryNotificationReason
        }
        
        /// get the CKServerChangeToken
        fetchNotificationChangesOperation.fetchNotificationChangesCompletionBlock = { (serverChangeToken, error) in
            print("* * * we are in the fetchNotificationChangesCompletionBlock , and this is the change token \(serverChangeToken.debugDescription)")
            print(recordChanges.debugDescription)
            let db = CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase
            for (key, value) in recordChanges {
                db.fetch(withRecordID: key, completionHandler: { (record, error) in
                    guard error == nil else {return}
                    if value == .recordCreated {
                        print(record?["title"] ?? "nothing")
                        print(record?.allKeys() ?? "no keys")
                        print(record?.allTokens() ?? "no tokens")
                    } else {
                        print("record not created ")
                    }
                })
            }
        }
    }

    
}


// Probably not needed
extension AppDelegate {
    fileprivate func registerNotificationNotification() {
        //      let subscription = CKQuerySubscription(recordType: "Notifications", predicate: NSPredicate(format: "title = 'st01'"), options: .firesOnRecordCreation)
        let subscription = CKQuerySubscription(recordType: "Notifications",
                                               predicate: NSPredicate(format: "TRUEPREDICATE"),
                                               options: [.firesOnRecordCreation, .firesOnRecordDeletion] )
        
        let notificationInfoWithAlert: CKNotificationInfo = {
            let notificationInfoWithAlert = CKNotificationInfo()
            notificationInfoWithAlert.titleLocalizationKey = "%1$@"
            notificationInfoWithAlert.titleLocalizationArgs = ["title"]
            notificationInfoWithAlert.alertLocalizationKey = "%1$@"
            notificationInfoWithAlert.alertLocalizationArgs = ["content"]
            notificationInfoWithAlert.shouldBadge = true
            notificationInfoWithAlert.soundName = "default"
            return notificationInfoWithAlert
        }()
        
        let notificationInfoSilent: CKNotificationInfo = {
            let notificationInfoSilent = CKNotificationInfo()
            notificationInfoSilent.shouldSendContentAvailable = true
            return notificationInfoSilent
        }()
        
        subscription.notificationInfo = notificationInfoSilent
        
        let modifySubscriptionOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription],
                                                                         subscriptionIDsToDelete: nil)
        modifySubscriptionOperation.modifySubscriptionsCompletionBlock = { (savedSubscriptions, deletedSubscriptionsIDS, error) in
            // TODO: cache the subscriptions that were saved so it does not need to be recreated over
            if error != nil {
                print("* * * * There was an error creating subscription")
            }
        }
        
        modifySubscriptionOperation.qualityOfService = .utility
        let db = CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase
        db.add(modifySubscriptionOperation)
        
    }
    
    
    fileprivate func registerLoginNotification() {
        
        let subscription = CKQuerySubscription(recordType: "Logins", predicate: NSPredicate(format: "TRUEPREDICATE"), options: .firesOnRecordCreation)
        
        let notificationInfoWithAlert = CKNotificationInfo()
        
        // this will use the 'title' field in the Record type 'notifications' as the title of the push notification
        //        info.titleLocalizationKey = "%1$@"
        //        info.titleLocalizationArgs = ["student"]
        
        // if you want to use multiple field combined for the title of push notification
        // info.titleLocalizationKey = "%1$@ %2$@" // if want to add more, the format will be "%3$@" and so on
        // info.titleLocalizationArgs = ["title", "subtitle"]
        
        // this will use the 'content' field in the Record type 'notifications' as the content of the push notification
        notificationInfoWithAlert.alertLocalizationKey = "%1$@"
        notificationInfoWithAlert.alertLocalizationArgs = ["student"]
        
        // use system default notification sound
        notificationInfoWithAlert.soundName = "default"
        notificationInfoWithAlert.shouldSendMutableContent = true
        
        let inf = CKNotificationInfo()
        inf.shouldSendMutableContent = true
        inf.shouldSendContentAvailable = true
        subscription.notificationInfo = inf
        
        
        CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase.save(subscription, completionHandler: { subscription, error in
            if error == nil {
                print(" Subscription saved successfully")
            } else {
                print("error saving subscription", error?.localizedDescription)
            }
        })
    }
    

}
