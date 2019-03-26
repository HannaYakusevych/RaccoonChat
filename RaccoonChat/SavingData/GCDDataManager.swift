//
//  GCDDataManager.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 12/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

class GCDDataManager: ProfileDataManager {
  
  let queue = DispatchQueue(label: "com.app.gcdQueue", qos: .userInitiated)
  
  let imagePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/profilePhoto.jpg"
  let namePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/nameData.txt"
  let aboutMePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/aboutMeData.txt"
  
  func saveProfileData(name: String?, description: String?, image: UIImage?, completion: @escaping (Bool) -> Void) {
    queue.async() {
      let saved = self.save(name: name, description: description, image: image)
      DispatchQueue.main.async {
        completion(saved)
      }
    }
  }
  
  func loadProfileData(isDone: @escaping (Bool, (String, String, UIImage)) -> Void) {
    queue.async() {
      let data = self.load()
      if let data = data {
        DispatchQueue.main.async {
          isDone(true, (data.name ?? "", data.description ?? "Profile information", data.image ?? UIImage(named: "placeholder-user")!))
        }
      } else {
        Logger.write("Error loading data")
        DispatchQueue.main.async {
          isDone(false, ("", "Profile information", UIImage(named: "placeholder-user")!))
        }
      }
    }
  }
  
  func save(name: String?, description: String?, image: UIImage?) -> Bool {
    // Image saving
    if let image = image {
      do {
        try image.jpegData(compressionQuality: 0.8)?.write(to: URL(fileURLWithPath: imagePath))
      } catch {
        Logger.write("Image saving error")
        return false
      }
    }
    
    // Name saving
    if let name = name {
      do {
        try name.write(to: URL(fileURLWithPath: namePath), atomically: true, encoding: String.Encoding.utf8)
      } catch {
        Logger.write("Name saving error")
        return false
      }
    }
    
    // Description saving
    if let description = description {
      do {
        try description.write(to: URL(fileURLWithPath: aboutMePath), atomically: true, encoding: String.Encoding.utf8)
      } catch {
        Logger.write("Description saving error")
        return false
      }
    }
    return true
  }
  
  func load() -> (name: String?, description: String?, image: UIImage?)? {
    guard FileManager.default.fileExists(atPath: namePath),
      FileManager.default.fileExists(atPath: imagePath),
      FileManager.default.fileExists(atPath: aboutMePath),
      let nameData = try? Data(contentsOf: URL(fileURLWithPath: namePath)),
      let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath)),
      let descriptionData = try? Data(contentsOf: URL(fileURLWithPath: aboutMePath)),
      let name = String(data: nameData, encoding: .utf8),
      let image = UIImage(data: imageData, scale: UIScreen.main.scale),
      let description = String(data: descriptionData, encoding: .utf8) else {
        Logger.write("Error loading data")
        return nil
    }
    return (name, description, image)
  }
  
}
