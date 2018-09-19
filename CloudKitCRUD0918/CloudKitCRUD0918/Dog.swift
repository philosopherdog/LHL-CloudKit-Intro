//
//  Dog.swift
//  CloudKitCRUD0918
//
//  Created by steve on 2018-09-19.
//  Copyright © 2018 steve. All rights reserved.
//

import Foundation
import CloudKit

final class Dog {
  
  static let type = "Dog"
  
  let name: String
  
  enum Key: String {
    case name
  }
  
  init?(_ record: CKRecord) {
    guard let name = record[Key.name.rawValue] as? String else { return nil }
    self.name = name
  }
}
