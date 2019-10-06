//
//  ChangeNotifications.swift
//  cloudkitPush
//
//  Created by Steven Hertz on 9/16/19.
//  Copyright © 2019 fluffy. All rights reserved.
//

import Foundation
import CloudKit

enum RecordChange {
    case created(CKRecord)
    case updated(CKRecord)
    case deleted(CKRecordID)
}
