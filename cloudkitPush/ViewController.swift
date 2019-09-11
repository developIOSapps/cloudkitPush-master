//
//  ViewController.swift
//  cloudkitPush
//
//  Created by Soulchild on 27/09/2018.
//  Copyright © 2018 fluffy. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let application = UIApplication.shared
        
        if(application.applicationState == .active){
            print("1  app received notification while in foreground")
        }
        
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
            print("user tapped the notification bar when the app is in background")
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


