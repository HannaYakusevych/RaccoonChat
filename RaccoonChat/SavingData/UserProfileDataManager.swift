//
//  UserProfileData.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 11/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

struct ProfileDataManager {

  static var user = AppUser()
  static let imagePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/profilePhoto.png"
  static let dataPath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/profileData.txt"

  static func saveData(name: String, description: String?, image: UIImage?) -> Bool {
    // Image saving
    if let image = image {
      let imageUrl = URL(fileURLWithPath: imagePath)
      do {
        try image.pngData()?.write(to: imageUrl)
      } catch {
        Logger.write("Image saving error")
        return false
      }
    }

    // Data saving
    user = AppUser(name: name, description: description)
    let jsonEncoder = JSONEncoder()
    do {
      let jsonData = try jsonEncoder.encode(user)
      let dataUrl = URL(fileURLWithPath: dataPath)
      do {
        try jsonData.write(to: dataUrl)
      } catch {
        Logger.write("Data saving error: unable to save data")
        return false
      }
    } catch {
      Logger.write("Data saving error: unable to encode the data")
      return false
    }
    return true
  }

  //static func loadData() -> (name: String, description: String?, image: UIImage?) {
  static func loadData() -> [String: Any] {
    let imageUrl = URL(fileURLWithPath: imagePath)

    let jsonDecoder = JSONDecoder()
    let dataUrl = URL(fileURLWithPath: dataPath)
    if let jsonData = try? Data(contentsOf: dataUrl) {
      do {
        user = try jsonDecoder.decode(AppUser.self, from: jsonData)
      } catch {
        Logger.write("Error parsing data: can't read from file")
      }
    } else {
      user = AppUser()
    }

    guard FileManager.default.fileExists(atPath: imagePath), let imageData = try? Data(contentsOf: imageUrl),
      let image = UIImage(data: imageData, scale: UIScreen.main.scale) else {
      print("Hello")
        return ["Name": user.name, "description": user.description, "image": nil]
    }
    return ["Name": user.name, "description": user.description, "image": image]

  }
}

struct AppUser: Codable {
  var name: String = ""
  var description: String?
  //var image: URL?
}
