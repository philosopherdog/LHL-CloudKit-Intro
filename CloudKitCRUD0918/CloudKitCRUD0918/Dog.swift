//
//  Dog.swift
//  CloudKitCRUD0918
//
//  Created by steve on 2018-09-19.
//  Copyright © 2018 steve. All rights reserved.
//

import Foundation
import CloudKit

final class Dog: CustomStringConvertible {
  
  static let type = "Dog"
  
  var name: String = ""
  var record: CKRecord? = nil
  
  enum Key: String {
    case name
  }
  
  convenience init?(_ record: CKRecord) {
    guard let name = record[Key.name.rawValue] as? String else { return nil }
    self.init(name: name, record: record)
  }
  
  init(name: String, record: CKRecord? = nil) {
    self.name = name
    self.record = record
    if self.record == nil {
      createRecord()
    }
  }
  
  private func createRecord() {
    let record  = CKRecord(recordType: Dog.type)
    record[Key.name.rawValue] = self.name
    self.record = record
  }
  
  var description: String {
    return "\(name) is a nice dog"
  }
}
