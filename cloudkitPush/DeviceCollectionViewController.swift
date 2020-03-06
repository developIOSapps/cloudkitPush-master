//
//  DeviceCollectionViewController.swift
//  Devices View
//
//  Created by Steven Hertz on 3/4/20.
//  Copyright © 2020 DevelopItSolutions. All rights reserved.
//

import UIKit
import CloudKit

private let reuseIdentifier = "Cell"

private let refreshControl = UIRefreshControl()

class DeviceCollectionViewController: UICollectionViewController {

    /// for cloudkit
    var dbs = CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase
    
    var devices =  Array<Device>()
       
    let recordDidChangeRemotely = Notification.Name("com.pluralsight.cloudKitFundamentals.remoteChangeKey")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRemoteRecordChange),
                                               name: recordDidChangeRemotely,
                                               object: nil)

        
        //collectionView.
      
        // Configure Refresh Control
        doRefreshContol()
        
        // Load devices
        loadiPadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    
    @objc func handleRemoteRecordChange(_ notification: Notification) {
        
//        guard let queryNotif = CKNotification(fromRemoteNotificationDictionary: notification.userInfo!) as? CKQueryNotification else { return }
//        print("Container Identifier: \(String(describing: queryNotif.containerIdentifier))")
//        print("Record ID Name: \(String(describing: queryNotif.recordID?.recordName))")
//        print("Record ID Name: \(String(describing: queryNotif.recordID?.zoneID.zoneName))")
//        print("QueryNotificationReason: \(queryNotif.queryNotificationReason)")
//
//
//        print("*********************** In Remote Record Change")
//
//        let theCurrentU =  queryNotif.recordFields?["currentUser"] as! String
//        print("* * * * * - The current user", theCurrentU)
        
        DispatchQueue.main.async {
            self.loadiPadData()
            
            self.collectionView?.reloadData()
        }
        
    }


    fileprivate func loadiPadData() {

        // housekeeping for the refresh
        refreshControl.endRefreshing()
        devices.removeAll()
        
        let predicate = NSPredicate(format: "teacherGroup = %@", "29")
        
        // let query = CKQuery(recordType: "iPad", predicate: NSPredicate(format: "TRUEPREDICATE"))
        let query = CKQuery(recordType: "iPad", predicate: predicate)
        
        dbs.perform(query, inZoneWith: nil) { (records, error) in
            guard let records = records, error == nil else { fatalError("iPads Not found") }
            
            for iPadRecord in records {
                print(iPadRecord["name"] as Any)

                /// get the app
                let theappref = iPadRecord["appID"] as! CKRecord.Reference
                let theApprefid = theappref.recordID
                
                var appIcon: UIImage = UIImage()

                
                self.dbs.fetch(withRecordID: theApprefid) { (appRecord, appError) in
                    guard let appRecord = appRecord, appError == nil else { fatalError("App Not found") }
                    print(appRecord["name"] as Any)
                    
                    
                    if let asset = appRecord["icon"] as? CKAsset {
                        print("in if let asset")
                        if let imageData: NSData = NSData(contentsOf: asset.fileURL) {
                            print("in if let asset image")
                            appIcon = UIImage(data: imageData as Data)!
                            print(appIcon)
                        }
                    }
                    
                    /// get the student
                    let theStudentref = iPadRecord["studentID"] as! CKRecord.Reference
                    let theStudentrefid = theStudentref.recordID
                    
                    var studentImage: UIImage = UIImage()
                    
                    
                    self.dbs.fetch(withRecordID: theStudentrefid) { (studentRecord, studentError) in
                        guard let studentRecord = studentRecord, studentError == nil else { fatalError("Student Not found") }
                        print(studentRecord["lastName"] as Any)
                        
                        /// get the student pic
                        
                        if let asset = studentRecord["photo"] as? CKAsset {
                            if let imageData: NSData = NSData(contentsOf: asset.fileURL) {
                                studentImage = UIImage(data: imageData as Data)!
                            }
                        }
                    
                        self.devices.append(Device(name: studentRecord["lastName"]!, studentImage: studentImage, appIcon: appIcon))
                        self.devices.append(Device(name: studentRecord["lastName"]!, studentImage: studentImage, appIcon: appIcon))
                        
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                    
                    
                }
                

        }
    }
    }

    // MARK: - Side helper functions
    fileprivate func doRefreshContol() {
        collectionView?.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshCollection), for: .valueChanged)
    }
    
   @objc func refreshCollection()  {
        loadiPadData()
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return devices.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("In cell")
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? DeviceCollectionViewCell else {fatalError("Could not cast it")}
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DeviceCollectionViewCell
        cell.setup(device: devices[indexPath.row])
    
       // cell.studentPhotoView.image = theImage
    
        // Configure the cell
    
        return cell
    }
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
