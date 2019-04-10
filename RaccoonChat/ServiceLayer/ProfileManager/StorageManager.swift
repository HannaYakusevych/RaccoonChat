//
//  StorageManager.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 26/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation
import CoreData

class StorageManager: ProfileDataManagerProtocol {

  let coreDataStack: CoreDataStack!

  init() {
    self.coreDataStack = CoreDataStack()
  }

  func saveProfileData(name: String?, description: String?, image: UIImage?, completion: @escaping (Bool) -> Void) {

    let saveContext = self.coreDataStack.saveContext

    saveContext.performAndWait {
      let appUser = AppUser.findOrInsertAppUser(in: saveContext)

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

      self.coreDataStack.performSave(with: saveContext) { isSaved in
        // Perform UI task
        DispatchQueue.main.async {
          completion(isSaved)
        }
      }
    }
  }

  func loadProfileData(isDone: @escaping (Bool, [String: Any]) -> Void) {
    //let appUser = AppUser.findOrInsertAppUser(in: coreDataStack.mainContext)
    self.coreDataStack.saveContext.performAndWait {
      let appUser = AppUser.findOrInsertAppUser(in: self.coreDataStack.saveContext)
      let imageData = appUser?.image
      let image = imageData != nil ? UIImage(data: imageData!) : UIImage(named: "placeholder-user")
      isDone(true, ["name": appUser?.name ?? "",
                      "description": appUser?.myDescription ?? "Profile information",
                      "image": image!])
    }
  }
}
