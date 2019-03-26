//
//  StorageManager.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 26/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import CoreData

class StorageManager: ProfileDataManager {
  
  let coreDataStack: CoreDataStack!
  
  init() {
    self.coreDataStack = CoreDataStack()
  }
  
  func saveProfileData(name: String?, description: String?, image: UIImage?, completion: @escaping (Bool) -> Void) {
    
    let appUser = AppUser.findOrInsertAppUser(in: coreDataStack.mainContext)
    
    if let name = name {
      appUser?.setValue(name, forKey: "name")
    }
    
    if let description = description {
      appUser?.setValue(description, forKey: "myDescription")
    }
    
    // Save image
    if let image = image {
      let imageData = image.jpegData(compressionQuality: 0.8)
      appUser?.setValue(imageData, forKey: "image")
    }
    
    appUser?.setValue(Date(), forKey: "timestamp")
    
    coreDataStack.performSave(with: coreDataStack.mainContext) { isSaved in
      // Perform UI task
      DispatchQueue.main.async {
        completion(isSaved)
      }
    }
  }
  
  func loadProfileData(isDone: @escaping (Bool, (String, String, UIImage)) -> Void) {
    let appUser = AppUser.findOrInsertAppUser(in: coreDataStack.mainContext)
    let imageData = appUser?.image
    let image = imageData != nil ? UIImage(data: imageData!) : UIImage(named: "placeholder-user")
    // Perform UI task
    DispatchQueue.main.async {
      isDone(true, (appUser?.name ?? "", appUser?.myDescription ?? "Profile information", image!))
    }
  }
  
}
