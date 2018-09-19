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
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    
    
    return true
  }
}

private func create() {
  //TODO: create Person record
  //TODO: convenience API's save
  //TODO: operation API CKModifyRecordsOperation
  //TODO: implement & talk about different completion blocks
  //TODO: Talk about Cursor
}

//private func fetch(completion: (CKRecord)->()) {
//  //TODO: convenience API fetch /w sort
//  //TODO: operation API CKQueryOperation
//}

private func createWithReference() {
  //TODO: Create a Dog, save it.
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
  //TODO: make CKQuerySubscription
  //TODO: create CKNotificationInfo and add to subscription
  //TODO: implement completionBlock
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
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print(#line, "failed to register reason:", error.localizedDescription)
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
    print(#line, notification.alertBody  ?? "no body")
    
  }
}

