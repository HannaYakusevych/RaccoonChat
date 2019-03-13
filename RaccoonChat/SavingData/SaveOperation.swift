//
//  SaveOperation.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 13/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

class SaveOperation: Operation {
  
  let imagePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/profilePhoto.jpg"
  let namePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/nameData.txt"
  let aboutMePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/aboutMeData.txt"
  
  var profileName: String?
  var profileDescription: String?
  var image: UIImage?
  
  var hasError = false
  
  override func main() {
    // Image saving
    if let image = self.image {
      do {
        try image.jpegData(compressionQuality: 0.8)?.write(to: URL(fileURLWithPath: imagePath))
      } catch {
        Logger.write("Image saving error")
        hasError = true
      }
    }
    
    // Name saving
    if let name = self.profileName {
      do {
        try name.write(to: URL(fileURLWithPath: namePath), atomically: true, encoding: String.Encoding.utf8)
      } catch {
        Logger.write("Name saving error")
        hasError = true
      }
    }
    
    // Description saving
    if let description = self.profileDescription {
      do {
        try description.write(to: URL(fileURLWithPath: aboutMePath), atomically: true, encoding: String.Encoding.utf8)
      } catch {
        Logger.write("Description saving error")
        hasError = true
      }
    }
  }
}
