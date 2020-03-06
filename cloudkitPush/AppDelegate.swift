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
        
        // forTrackingAllSinceLast()  I don't think I need this just doing if traking all changes
        
        prepareForRemoteNotification(application, launchOptions)
        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        refreshSubscriptions()
    }
    
    
    // MARK: - Helper Functions to Prepare For Remote Notifications
    
    
    /// Setup Needed Items for Remote Notifications
    fileprivate func prepareForRemoteNotification(_ application: UIApplication, _ launchOptions: [UIApplicationLaunchOptionsKey : Any]?) {

        // not sure if need it at all, I took out and it worked  -- UNUserNotificationCenter.current().delegate = self.window?.rootViewController as! ViewController
        
        // if authorized, register for remote notification, whick kicks of the whole process
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { authorized, error in
            if authorized { DispatchQueue.main.async { application.registerForRemoteNotifications() }  }
        }
        
        // TODO: Look if I need it
        // A key indicating that a remote notification is available for the app to process.
        if(launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil){
            print("* * * * *  In the if UIApplicationLaunchOptionsKey")
        }

    }

    fileprivate func refreshSubscriptions() {
        
        let db = CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase
        
         // self.registerNotificationNotification()
         self.registeriPadNotification()
         // self.registerLoginNotification()

    }

    
    fileprivate func registeriPadNotification() {
    
        
        let alreadyCreatedSubscription = UserDefaults.standard.bool(forKey: "ipadSubscriptionDone")
        guard  alreadyCreatedSubscription == false else { return }

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
                if error != nil {
                    print("* * * * There was an error creating subscription")
                } else  {
                    print("- - - -  - - -This is the id of the Ipad subscription", savedSubscriptions?.first?.subscriptionID)
                    UserDefaults.standard.set(true, forKey: "ipadSubscriptionDone")
                    if let iPadSubscriptionID = savedSubscriptions?.first?.subscriptionID {
                        self.iPadSubscriptionID = iPadSubscriptionID
                    }
                }
            }
            modifySubscriptionOperation.qualityOfService = .utility
            return modifySubscriptionOperation
        }()
        
        CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase.add(modifySubscriptionOperation)
    }    
}


extension AppDelegate: UNUserNotificationCenterDelegate{

   
    fileprivate func debugUserInfo(_ userInfo: [AnyHashable : Any]) {
    /// This is just to be avle to debug and see what is in userInfo
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
    }
    
    
    fileprivate func debugQueryNotification(_ queryNotification: CKQueryNotification) {
        print("Container Identifier: \(String(describing: queryNotification.containerIdentifier))")
        print("Record ID Name: \(String(describing: queryNotification.recordID?.recordName))")
        print("Record ID Name: \(String(describing: queryNotification.recordID?.zoneID.zoneName))")
        print("QueryNotificationReason: \(queryNotification.queryNotificationReason)")
        
        switch queryNotification.queryNotificationReason {
        case .recordCreated:
            print(" * * * Record Created")
        case .recordDeleted:
            print(" * * * Record Deleted")
        case .recordUpdated:
            print(" * * * Record Updated")
        }
        
        
        dump(queryNotification.recordFields)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("* * * * * didReceiveRemoteNotification - We received a remote notification")
        debugUserInfo(userInfo)

        guard let queryNotification = CKNotification(fromRemoteNotificationDictionary: userInfo) as? CKQueryNotification else { return }
        
        debugQueryNotification(queryNotification)
        
//        let theCurrentU =  queryNotif.recordFields?["currentUser"] as! String
//        print("* * * * * - The current user", theCurrentU)
        
        dump(queryNotification)
        
        // this detrmines that it came back from the iPad subscription
//        guard iPadSubscriptionID == queryNotif.subscriptionID else {
//            DispatchQueue.global().async {
//                print(" not ipad sub ")
//                completionHandler(.noData)
//            }
//            //return
//        }
        
        
        guard let recID =  queryNotification.recordID as? CKRecordID else {
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
                let navvc = self.window?.rootViewController as! UINavigationController
                let vc = navvc.topViewController  as! DeviceCollectionViewController
                // let vc = self.window?.rootViewController as! ViewController
                // vc.titlelabel.text = currentU
                // vc.titlelabel.setNeedsDisplay()
                // vc.view.setNeedsDisplay()
                // vc.view.setNeedsLayout()
                }
            
            let theCurrentU =  queryNotification.recordFields?["currentUser"] as! String
            print("about to fireup the timer")
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                let myRequestController = MyRequestController()
                myRequestController.sendRequest(putInNotes: theCurrentU)

                print("Timer fired!")
            }

        }
        
        
        
        
//        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
//        if cloudKitNotification.notificationType == .Query {
//            let queryNotificationOBJ = cloudKitNotification as! CKQueryNotification
//            if queryNotificationOBJ.queryNotificationReason == .RecordDeleted {
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

