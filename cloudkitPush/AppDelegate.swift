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

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
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
                        self.registerLoginNotification()
                        
                    }
                } else {
                    // do your error handling here!
                    print(error!.localizedDescription)
                }
                
            }
        }
    }

    
    fileprivate func registerNotificationNotification() {
        //      let subscription = CKQuerySubscription(recordType: "Notifications", predicate: NSPredicate(format: "title = 'st01'"), options: .firesOnRecordCreation)
        let subscription = CKQuerySubscription(recordType: "Notifications", predicate: NSPredicate(format: "TRUEPREDICATE"), options: [.firesOnRecordCreation, .firesOnRecordDeletion] )
        
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
        
        
        CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase.save(subscription, completionHandler: { subscription, error in
            if error == nil
            { print(" Subscription saved successfully") }
            else
            { print("error saving subscription", error?.localizedDescription) }
        }
        )

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
        
        guard let _ = CKNotification(fromRemoteNotificationDictionary: userInfo) as? CKDatabaseNotification else { return }
        
        completionHandler(.newData)
        
//        appData.checkUpdates(finishClosure: { (result) in
//            let mainQueue = OperationQueue.main
//            mainQueue.addOperation({
//                completionHandler(result)
//            })
//        })
//

    }
    

}

