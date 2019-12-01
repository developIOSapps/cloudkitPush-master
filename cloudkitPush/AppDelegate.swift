//
//  AppDelegate.swift
//  cloudkitPush
//
//  Created by Soulchild on 27/09/2018.
//  Copyright © 2018 fluffy. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var iPadSubscriptionID: String = ""

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        
        
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
                        print("record not created")
                    }
                })
            }
        }
        
        
        // CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").add(fetchNotificationChangesOperation)
        
        
        

        
        prepareForRemoteNotification(application, launchOptions)
        
        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        refreshSubscriptions()
    }
    
    
    // MARK: - Helper Functions to Prepare For Remote Notifications
    
    
    /// Setup Needed Items for Remote Notifications
    fileprivate func prepareForRemoteNotification(_ application: UIApplication, _ launchOptions: [UIApplicationLaunchOptionsKey : Any]?) {

        UNUserNotificationCenter.current().delegate = self.window?.rootViewController as! ViewController
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { authorized, error in
            if authorized {
                DispatchQueue.main.async(execute: { application.registerForRemoteNotifications() })
            }
        }
        
        if(launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil){
            print("* * * * *  In the if UIApplicationLaunchOptionsKey")
        }

    }

    fileprivate func refreshSubscriptions() {
        
        let db = CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase
        
        DispatchQueue.global().sync {
            db.fetchAllSubscriptions { [unowned self] subscriptions, error in
                if error == nil {
                    if let subscriptions = subscriptions {
                        for subscription in subscriptions {
                            db.delete(withSubscriptionID: subscription.subscriptionID) { str, error in
                                if error != nil {
                                    // do your error handling here!
                                    print(error!.localizedDescription)
                                    fatalError("error deleting subscriptions")
                                } else {
                                    print("deleted subscription")
                                }
                            }
                        }
                        
                        self.registerNotificationNotification()
                        
                        self.registeriPadNotification()
                       
                        self.registerLoginNotification()
                        
                    }
                } else {
                    // do your error handling here!
                    print(error!.localizedDescription)
                }
                
            }
        }
    }

    
    fileprivate func registeriPadNotification() {
    
        /// Create a CKQuerySubscription object
        let subscription: CKQuerySubscription = {
            
            let subscription = CKQuerySubscription(recordType: "iPad",
                                                   predicate: NSPredicate(format: "TRUEPREDICATE"),
                                                   options: [.firesOnRecordCreation, .firesOnRecordUpdate] )
            
            let notificationInfoSilent: CKNotificationInfo = {
                let notificationInfoSilent = CKNotificationInfo()
                notificationInfoSilent.shouldSendContentAvailable = true
                notificationInfoSilent.desiredKeys = ["currentUser", "userLevel"]
                return notificationInfoSilent
            }()
            
            subscription.notificationInfo = notificationInfoSilent
            
            return subscription
            
        }()
        
        /// create a CKModifySubscriptionsOperation
        let modifySubscriptionOperation: CKModifySubscriptionsOperation = {
            let modifySubscriptionOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription],  subscriptionIDsToDelete: nil)
            modifySubscriptionOperation.modifySubscriptionsCompletionBlock = { (savedSubscriptions, deletedSubscriptionsIDS, error) in
                 // TODO: cache the subscriptions that were saved so it does not need to be recreated over
                 if error != nil {
                     print("* * * * There was an error creating subscription")
                 }
                print("- - - -  - - -This is the id of the Ipad subscription", savedSubscriptions?.first?.subscriptionID)
                if let iPadSubscriptionID = savedSubscriptions?.first?.subscriptionID {
                    self.iPadSubscriptionID = iPadSubscriptionID
                }
             }
             modifySubscriptionOperation.qualityOfService = .utility
            return modifySubscriptionOperation
        }()
        
//        let modifySubscriptionOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription],
//                                                                         subscriptionIDsToDelete: nil)
//        modifySubscriptionOperation.modifySubscriptionsCompletionBlock = { (savedSubscriptions, deletedSubscriptionsIDS, error) in
//            // TODO: cache the subscriptions that were saved so it does not need to be recreated over
//            if error != nil {
//                print("* * * * There was an error creating subscription")
//            }
//        }
//
//        modifySubscriptionOperation.qualityOfService = .utility
        

        CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase.add(modifySubscriptionOperation)
    }
    

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
        
        
//        db.save(subscription, completionHandler: { subscription, error in
//            if error == nil
//            { print(" Subscription saved successfully") }
//            else
//            { print("error saving subscription", error?.localizedDescription) }
//        }
//        )

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


extension AppDelegate: UNUserNotificationCenterDelegate{

   
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("* * * * * didReceiveRemoteNotification - We received a remote notification")

        if let ckDict = userInfo["ck"] as? [AnyHashable : Any] {
            if let qryDict = ckDict["qry"] as? [AnyHashable : Any] {
                for (key, value) in qryDict {
                    print(key as! NSString)
                    if let item = value as? NSNumber {
                        print(item)
                    }
                    if let item = value as? NSString {
                        print(item)
                    }
                }
            }
        }
        dump(userInfo)
//          NSLog("Save error: %@", "hello")


        guard let queryNotif = CKNotification(fromRemoteNotificationDictionary: userInfo) as? CKQueryNotification else { return }
        
        print("Container Identifier: \(String(describing: queryNotif.containerIdentifier))") 
        print("Record ID Name: \(String(describing: queryNotif.recordID?.recordName))")
        print("Record ID Name: \(String(describing: queryNotif.recordID?.zoneID.zoneName))")
        print("QueryNotificationReason: \(queryNotif.queryNotificationReason)")
        
        switch queryNotif.queryNotificationReason {
        case .recordCreated:
            print(" * * * Record Created")
        case .recordDeleted:
            print(" * * * Record Deleted")
        case .recordUpdated:
            print(" * * * Record Updated")
        }
        

        dump(queryNotif.recordFields)
        
//        let theCurrentU =  queryNotif.recordFields?["currentUser"] as! String
//        print("* * * * * - The current user", theCurrentU)
        
        dump(queryNotif)
        
        // this detrmines that it came back from the iPad subscription
        guard iPadSubscriptionID == queryNotif.subscriptionID else {
            DispatchQueue.global().async {
                completionHandler(.noData)
            }
            return
        }
        
        guard let recID =  queryNotif.recordID as? CKRecordID   else {
            fatalError("Error - could not use the record id")
        }
        
        CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase.fetch(withRecordID: recID) { (record, error) in
            guard let rec = record, error == nil else {fatalError("error - getting record")}
            // print(rec["title"] as! String)
            
            //let titl = rec["title"] as! String
            let currentU = rec["currentUser"] as! String
            print(currentU)
            
            let recordDidChangeRemotely = Notification.Name("com.pluralsight.cloudKitFundamentals.remoteChangeKey")
            NotificationCenter.default.post(name: recordDidChangeRemotely,
                                            object: self,
                                            userInfo: userInfo)

            
            
            DispatchQueue.main.async {
                let vc = self.window?.rootViewController as! ViewController
                vc.titlelabel.text = currentU
                vc.titlelabel.setNeedsDisplay()
                vc.view.setNeedsDisplay()
                vc.view.setNeedsLayout()
                }
        }
        
        
        
        
//        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
//        if cloudKitNotification.notificationType == .Query {
//            let queryNotification = cloudKitNotification as! CKQueryNotification
//            if queryNotification.queryNotificationReason == .RecordDeleted {
//
        
        
        
        
        
        
        
        
        
        DispatchQueue.global().async {
            completionHandler(.noData)
        }
        
        // completionHandler(.newData)
        
//        appData.checkUpdates(finishClosure: { (result) in
//            let mainQueue = OperationQueue.main
//            mainQueue.addOperation({
//                completionHandler(result)
//            })
//        })
//

    }
    

}

