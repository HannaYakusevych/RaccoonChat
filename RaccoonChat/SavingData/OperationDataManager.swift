//
//  OperationDataManager.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 13/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

class OperationDataManager: ProfileDataManager {

  let queue = OperationQueue()

  func saveProfileData(name: String?, description: String?, image: UIImage?, completion: @escaping (Bool) -> Void) {
    let saveOperation = SaveOperation()
    saveOperation.profileName = name
    saveOperation.profileDescription = description
    saveOperation.image = image
    saveOperation.qualityOfService = .userInitiated
    saveOperation.completionBlock = {
      OperationQueue.main.addOperation {
        completion(!saveOperation.hasError)
      }
    }
    queue.addOperation(saveOperation)
  }

  func loadProfileData(isDone: @escaping (Bool, (String, String, UIImage)) -> Void) {
    let loadOperation = LoadOperation()
    loadOperation.qualityOfService = .userInitiated
    loadOperation.completionBlock = {
      if loadOperation.isLoaded {
        OperationQueue.main.addOperation {
          isDone(true, (loadOperation.profileName ?? "",
                        loadOperation.profileDescription ?? "Profile information",
                        loadOperation.image ?? UIImage(named: "placeholder-user")!))
        }
      } else {
        Logger.write("Error loading data")
        OperationQueue.main.addOperation {
          isDone(false, ("", "Profile information", UIImage(named: "placeholder-user")!))
        }
      }
    }
    queue.addOperation(loadOperation)
  }

}
