//
//  CKContainer + Extension.swift
//  cloudkitPush
//
//  Created by Steven Hertz on 9/16/19.
//  Copyright © 2019 fluffy. All rights reserved.
//

import Foundation
import CloudKit

extension CKContainer {
    func fetchCloudKitRecordChanges(completion: ([RecordChange])) -> () {
        
        /// get latest change id in system
        let existingChangeToken = UserDefaults().serverChangeToken
        
        /// get all the chage records
        let notificationChangesOperation = CKFetchNotificationChangesOperation(previousServerChangeToken: existingChangeToken)

        /// get the reasons for the changes
        var changeReasons = [CKRecordID: CKQueryNotificationReason]()
        notificationChangesOperation.notificationChangedBlock = { notification in
            if let n = notification as? CKQueryNotification, let recordID = n.recordID {
                changeReasons[recordID] = n.queryNotificationReason
            }
        }
        
        /// Implement CKFetchNotificationChangesOperation Completion block
        notificationChangesOperation.fetchNotificationChangesCompletionBlock = { (serverChangeToken, error ) in
            guard error == nil else { return }
            guard changeReasons.count > 0 else { return }
            
            /// Save new change token
            UserDefaults().serverChangeToken = serverChangeToken
            
            var insertedUpdatedRecordIDs = [CKRecordID]()
            var deletedRecordIDs = [CKRecordID]()
            
            for (recordID, reason) in changeReasons {
                switch reason {
                case .recordDeleted:
                    deletedRecordIDs.append(recordID)
                default:
                    insertedUpdatedRecordIDs.append(recordID)
                }
            }
            
//            let fetchRecordsOperation = CKFetchRecordsOperation(recordIDs: [insertedUpdatedRecordIDs])
            
            
        }
        
        
            /// Splitout Record Ids - deleted records from insert/update records
        
            /// Fetch full CKRecords for added or changed CKRecordIDS
        
     
    }
}

public extension UserDefaults {
    // https://gist.github.com/ralcr/ce69a5a496e6619143a639ec55105e98
    var serverChangeToken: CKServerChangeToken? {
        get {
            guard let data = self.value(forKey: "ChangeToken") as? Data else {
                return nil
            }
            guard let token = NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken else {
                return nil
            }
            
            return token
        }
        set {
            if let token = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: token)
                self.set(data, forKey: "ChangeToken")
                self.synchronize()
            } else {
                self.removeObject(forKey: "ChangeToken")
            }
        }
    }
}
