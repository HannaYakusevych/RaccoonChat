//
//  loadOperation.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 13/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

class LoadOperation: Operation {
  
  let imagePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/profilePhoto.jpg"
  let namePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/nameData.txt"
  let aboutMePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/aboutMeData.txt"
  
  var profileName: String?
  var profileDescription: String?
  var image: UIImage?
  
  var isLoaded = false
  
  override func main() {
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
        return
    }
    self.isLoaded = true
    self.profileName = name
    self.profileDescription = description
    self.image = image
  }
}
