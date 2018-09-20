//
//  Person.swift
//  CloudKitCRUD0918
//
//  Created by steve on 2018-09-19.
//  Copyright © 2018 steve. All rights reserved.
//

import Foundation
import CloudKit

final class Person: CustomStringConvertible {
  
  static let type = "Person"
  
  enum Key: String {
    case firstName
    case lastName
    case age
    case dogs
  }
  
  let firstName: String
  let lastName: String
  let age: Int
  var dogs: [CKRecord.Reference]? = nil
  var record: CKRecord? = nil
  
  init(firstName: String, lastName: String, age: Int, dogs: [CKRecord.Reference]? = nil, record: CKRecord? = nil) {
    self.firstName = firstName
    self.lastName = lastName
    self.age = age
    self.dogs = dogs
    self.record = record
    if self.record == nil {
      createRecord()
    }
  }
  
  private func createRecord() {
    self.record = CKRecord(recordType: Person.type)
    self.record?[Key.firstName.rawValue] = self.firstName as NSString
    self.record?[Key.lastName.rawValue] = self.lastName as NSString
    self.record?[Key.age.rawValue] = self.age as NSNumber
    self.record?[Key.dogs.rawValue] = self.dogs as NSArray?
  }

  convenience init?(_ record: CKRecord) {
    guard let fn = record[Key.firstName.rawValue] as? String, let ln = record[Key.lastName.rawValue] as? String, let a = record[Key.age.rawValue] as? Int else { return nil }
    var d: [CKRecord.Reference]? = nil
    if let dogs = record[Key.dogs.rawValue] as? [CKRecord.Reference] {
      d = dogs
    }
    self.init(firstName: fn, lastName: ln, age: a, dogs: d)
  }
  
  var description: String {
    return "\(firstName) \(lastName) is \(age) years old has \(dogs?.count ?? 0) # of dogs"
  }
  
}
