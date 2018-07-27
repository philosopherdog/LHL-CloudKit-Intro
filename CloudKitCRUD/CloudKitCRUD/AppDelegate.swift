//
//  AppDelegate.swift
//  CloudKitCRUD
//
//  Created by steve on 2018-07-26.
//  Copyright © 2018 steve. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

/*
 CRUD
 
 */

extension CKRecord{
  var wasCreatedByThisUser: Bool{
    return (creatorUserRecordID == nil) || (creatorUserRecordID?.recordName == "__defaultOwner__")
  }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  let db = CKContainer.default().publicCloudDatabase
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    //    create()
    //    fetch()
    //    createWithReference()
    //    update()
    //    delete()
    UIApplication.shared.registerForRemoteNotifications()
    UNUserNotificationCenter.current().requestAuthorization(options:[.alert, .sound]) {(success, error) in
      if let error = error { print(#line, error.localizedDescription); return}
//      self.subscription()
    }
    
    return true
  }
  
}

extension AppDelegate {
  
  private func create() {
    let person = CKRecord(recordType: R.Person)
    person[R.firstName] = "james" as NSString
    person[R.lastName] = "wanderer" as NSString
    person[R.age] = 55 as NSNumber
    
    // Convenience API
    /*
     db.save(person) { (record, error) in
     if let error = error { print(#line, error.localizedDescription); return}
     print(#line, (record?[R.firstName] as? NSString) ?? "No first name")
     }
     */
    
    // Inconvenience API
    let operation = CKModifyRecordsOperation(recordsToSave: [person], recordIDsToDelete: nil)
    //    operation.qualityOfService = .userInitiated
    db.add(operation)
    
    // per record completionBlock
    operation.perRecordCompletionBlock = {record, error in
      if let error = error { print(#line, error.localizedDescription); return}
      print(#line, (record[R.firstName] as? NSString) ?? "No first name")
    }
    
    // final completion block
    operation.modifyRecordsCompletionBlock =  { records, _, error in
      if let error = error { print(#line, error.localizedDescription); return}
      guard  let records =  records, let first = records.first else  { return }
      print(#line, (first[R.firstName] as? NSString) ?? "No first name")
    }
  }
  
  private func fetch() {
    /*
     Convenience API
     func perform(CKQuery, inZoneWith: CKRecordZoneID?, completionHandler: ([CKRecord]?, Error?) -> Void)
     */
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: R.Person, predicate: predicate)
    let descriptor = NSSortDescriptor(key: R.age, ascending: true)
    query.sortDescriptors = [descriptor]
    
    /*
     db.perform(query, inZoneWith: nil) { (records, error) in
     if let error = error { print(#line, error.localizedDescription); return}
     guard  let records = records, let first = records.first else  { return }
     print(#line, (first[R.firstName] as? NSString) ?? "No first name")
     }
     */
    
    
    // Inconvenience API
    let queryOperation = CKQueryOperation(query: query)
    db.add(queryOperation)
    
    queryOperation.recordFetchedBlock = { record in
      print(#line, (record[R.firstName] as? NSString) ?? "No first name")
    }
    
  }
  
  private func getPerson(with predicate: NSPredicate, completion: @escaping (CKRecord)->Void ) {
    let query = CKQuery(recordType: R.Person, predicate: predicate)
    db.perform(query, inZoneWith: nil) { (records, error) in
      if let error = error { print(#line, error.localizedDescription); return}
      guard  let records = records, let person = records.first else  { return }
      print(#line, "success")
      completion(person)
    }
  }
  
  
  private func createWithReference() {
    
    // fetch an owner
    
    let predicate = NSPredicate(format: "age > 30")
    getPerson(with: predicate) {[unowned self] (person) in
      
      // create a dog record
      let dog = CKRecord(recordType: R.Dog)
      dog[R.name] = "spot" as NSString
      
      self.db.save(dog, completionHandler: {[weak self] (_, error) in
        if let error = error { print(#line, error.localizedDescription); return}
        
        // create a CKReference from the dog
        let dogReference = CKReference(record: dog, action: .none)
        // Add the record to an array on the fetched owner
        
        person[R.dogs] = [dogReference] as NSArray
        
        self?.db.save(person, completionHandler: { (record, error) in
          if let error = error { print(#line, error.localizedDescription); return}
          guard let record = record, let firstName = record[R.firstName] as? NSString else { print(#line, "problem saving");  return}
          print(#line, "\(firstName) got a dog!")
        })
        
      })
    }
  }
  
  private func update() {
    
    let predicate = NSPredicate(format: "age > 30")
    getPerson(with: predicate) {[unowned self] (person) in
      guard let age = person[R.age] as? NSNumber else { print(#line, "couldn't get age"); return}
      let newAge = age.intValue + 1
      person[R.age] = newAge as NSNumber
      self.db.save(person, completionHandler: { (record, error) in
        if let error = error { print(#line, error.localizedDescription); return}
        guard let firstName = person[R.firstName] as? String else {
          print(#line, "problem with firstName")
          return
        }
        print(#line, "\(firstName) had a birthday")
      })
    }
  }
  
  private func delete() {
    let predicate = NSPredicate(format: "age > 30")
    getPerson(with: predicate) {[unowned self] (person) in
      self.db.delete(withRecordID: person.recordID, completionHandler: { (id, error) in
        if let error = error { print(#line, error.localizedDescription); return}
        guard let id = id else { return }
        print(#line, "\(id) got deleted")
      })
    }
  }
  
  
  private func subscription() {
    let subscription = CKQuerySubscription(recordType: R.Person, predicate: NSPredicate(value: true), options: [.firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion] )
    let info = CKNotificationInfo()
    info.alertBody = "alert body example"
    info.title = "title"
    subscription.notificationInfo = info
    let subscriptionOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
    db.add(subscriptionOperation)
    subscriptionOperation.modifySubscriptionsCompletionBlock = { subscriptions, _, error in
      if let error = error { print(#line, error.localizedDescription); return}
      guard let _ = subscriptions?.first else {  return  }
      print(#line, "saved subscription")
    }
  }
}


//MARK - Handle Remote Notifications

extension AppDelegate  {
  
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
    
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    
    print(#line, "failed to register reason:", error.localizedDescription)
  }
  
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
    print(#line, notification.alertBody  ?? "no body")
    
  }
  
  
}

