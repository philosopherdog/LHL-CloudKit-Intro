//
//  Person.swift
//  CloudKitCRUD0918
//
//  Created by steve on 2018-09-19.
//  Copyright © 2018 steve. All rights reserved.
//

import Foundation
import CloudKit

final class Person {
  
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
  
  init?(_ record: CKRecord) {
    guard let fn = record[Key.firstName.rawValue] as? String, let ln = record[Key.lastName.rawValue] as? String, let a = record[Key.age.rawValue] as? Int else { return nil }
    self.firstName = fn
    self.lastName = ln
    self.age = a
    if let d = record[Key.dogs.rawValue] as? [CKRecord.Reference] {
      self.dogs = d
    }
  }
  
}
