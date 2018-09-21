//
//  AppDelegate.swift
//  CloudKitCRUD0918
//
//  Created by steve on 2018-09-19.
//  Copyright © 2018 steve. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let db = CKContainer.default().database(with: .public)
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    application.registerForRemoteNotifications()
    //    create()
    
    //    fetch { (record) in
    //      guard let p = Person(record) else { return }
    //      print(#line, p)
    //    }
    
//    fetchOperation()
//    createWithReference()
    
    UNUserNotificationCenter.current().requestAuthorization(options:[.alert, .sound]) {(success, error) in
      if let error = error { print(#line, error.localizedDescription); return}
        self.subscription()
    }
    
    return true
  }
}

extension AppDelegate {
  private func create() {
    //TODO: create Person record
    //    let person1 = Person(firstName: "Fred", lastName: "Warbler", age: 31)
    //    guard let person1Record = person1.record else { fatalError() }
    //TODO: convenience API's save
    /*
     func save(_ record: CKRecord, completionHandler: @escaping (CKRecord?, Error?) -> Void)
     */
    //    db.save(person1Record) { (record, error) in
    //      if let error = error {
    //        print(#line, error.localizedDescription)
    //        return
    //      }
    //      person1.record = record
    //      let id = record?.recordID
    //      print(#line, id ?? "")
    //    }
    
    //TODO: operation API CKModifyRecordsOperation
    
    guard let person2 = Person(firstName: "Mark", lastName: "Bunder", age: 24).record,
      let person3 = Person(firstName: "Iggy", lastName: "Pop", age: 80).record else { fatalError() }
    
    let operation = CKModifyRecordsOperation(recordsToSave: [person2, person3], recordIDsToDelete: nil)
    
    var persons = [Person]()
    
    operation.perRecordCompletionBlock = { record, error in
      if let error = error {
        print(#line, error.localizedDescription)
        return
      }
      guard let p = Person(record) else { fatalError() }
      print(#line, p)
      persons.append(p)
    }
    
    /*
     @property (nonatomic, copy, nullable) void (^modifyRecordsCompletionBlock)(NSArray<CKRecord *> * _Nullable savedRecords, NSArray<CKRecordID *> * _Nullable deletedRecordIDs, NSError * _Nullable operationError);
     */
    operation.modifyRecordsCompletionBlock = { records, _, error in
      if let error = error {
        print(#line, error.localizedDescription)
        return
      }
      print(#line, "modify completed", records?.count ?? 0)
    }
    
    db.add(operation)
    
    //TODO: implement & talk about different completion blocks
    //TODO: Talk about Cursor
  }
  
  private func fetch(completion: ((CKRecord)->())?) {
    //TODO: convenience API fetch /w sort
    let predicate = NSPredicate(format: "age >= 80")
    let query = CKQuery(recordType: Person.type, predicate: predicate)
    let ageSort = NSSortDescriptor(key: Person.Key.age.rawValue, ascending: true)
    query.sortDescriptors = [ageSort]
    /*
     func perform(CKQuery, inZoneWith: CKRecordZone.ID?, completionHandler: ([CKRecord]?, Error?) -> Void)
     */
    db.perform(query, inZoneWith: .default) { (records, error) in
      if let error = error {
        print(#line, error.localizedDescription)
        return
      }
      
      guard let records = records, let first = records.first  else { return }
      
      completion?(first)
      for record in records {
        guard let p = Person(record) else { continue }
        print(#line, p)
      }
    }
    
    //TODO: operation API CKQueryOperation
  }
  
  private func fetchOperation() {
    let predicate = NSPredicate(format: "age >= 80")
    let query = CKQuery(recordType: Person.type, predicate: predicate)
    let ageSort = NSSortDescriptor(key: Person.Key.age.rawValue, ascending: true)
    query.sortDescriptors = [ageSort]
    let operation = CKQueryOperation(query: query)
    operation.recordFetchedBlock = { record in
      guard let p = Person(record) else { fatalError() }
      print(p)
    }
    db.add(operation)
  }
  
  
  private func createWithReference() {
    //TODO: Create a Dog, save it.
    let dog = Dog(name: "frank")
    guard let record = dog.record else { fatalError() }
    
    db.save(record) { (record, error) in
      if let error = error {
        print(#line, error.localizedDescription)
        return
      }
      guard let dogRecord = record else { fatalError() }
      dog.record = dogRecord
      print(#line, dogRecord.recordID)
      
      self.fetch(completion: { (r) in
//        guard let person = Person(r) else { fatalError() }
        guard let dogRecord = dog.record else { fatalError() }
        let dogRef = CKRecord.Reference.init(record: dogRecord, action: .none)
        r[Person.Key.dogs.rawValue] = [dogRef] as NSArray
        self.db.save(r, completionHandler: { (personWithDog, _) in
          guard let pwd = personWithDog else { fatalError() }
          let p = Person(pwd)!
          print(#line, p)
        })
      })
      
    }
    //TODO: fetch a person, set the "dogs" array to a CKReference of the dog instance
  }
  
  private func update() {
    //TODO: Update Person
  }
  
  private func delete() {
    //TODO: Delete Person
  }
  
  private func subscription() {
    //TODO: call requestAuthForRemoteNotifications from didFinishLaunching
    //TODO: add CKModifySubscriptionsOperation to db
    let predicate = NSPredicate(value: true)
    let personSubscription = CKQuerySubscription(recordType: Person.type, predicate: predicate, options: [.firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion])
    personSubscription.notificationInfo = CKSubscription.NotificationInfo(alertBody: "alert body", title: "my  title")
    
    let op = CKModifySubscriptionsOperation(subscriptionsToSave: [personSubscription], subscriptionIDsToDelete: nil)
    
    /*
 var modifySubscriptionsCompletionBlock: (([CKSubscription]?, [CKSubscription.ID]?, Error?) -> Void)? { get set }
 */
    op.modifySubscriptionsCompletionBlock = {subs, _, error in
      print(#line, error?.localizedDescription ?? "No error")
      guard let sub = subs?.first else { return }
      print(#line, sub.subscriptionID)
      }
    db.add(op)
    
    //TODO: make CKQuerySubscription
    //TODO: create CKNotificationInfo and add to subscription
    //TODO: implement completionBlock
    
  }
}


extension AppDelegate {
  func requestAuthForRemoteNotifications() {
    UIApplication.shared.registerForRemoteNotifications()
    UNUserNotificationCenter.current().requestAuthorization(options:[.alert, .sound]) {(success, error) in
      if let error = error { print(#line, error.localizedDescription); return}
      //      self.subscription()
    }
  }
}

//MARK - Handle Remote Notifications

extension AppDelegate  {
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print(#line, #function)
    self.subscription()
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print(#line, #function, "failed to register reason:", error.localizedDescription)
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
    print(#line, notification.alertBody  ?? "no body")
    
  }
}

