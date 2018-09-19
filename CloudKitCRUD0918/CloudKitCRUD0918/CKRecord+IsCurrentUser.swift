//
//  CKRecord+IsCurrentUser.swift
//  CloudKitCRUD0918
//
//  Created by steve on 2018-09-19.
//  Copyright © 2018 steve. All rights reserved.
//

import Foundation
import CloudKit

extension CKRecord{
  var wasCreatedByThisUser: Bool{
    return (creatorUserRecordID == nil) || (creatorUserRecordID?.recordName == "__defaultOwner__")
  }
}
