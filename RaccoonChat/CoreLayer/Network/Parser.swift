//
//  Parser.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 17/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

protocol IParser {
  associatedtype Model
  func parse(data: Data) -> Model?
}

struct PhotoModel {
  let identifier: Int
  let imageURL: String
  var image: UIImage?
}

class Parser: IParser {
  typealias Model = [PhotoModel]

  func parse(data: Data) -> [PhotoModel]? {
    do {
      guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
        return nil
      }

      guard let photos = json["hits"] as? [[String: Any]] else {
          return nil
      }
      Logger.write("Number of parsed objects: \(photos.count)")

      var images: [PhotoModel] = []

      for appObject in photos {
        guard let identifier = appObject["id"] as? Int,
          let imageURL = appObject["webformatURL"] as? String
          else { continue }
        images.append(PhotoModel(identifier: identifier, imageURL: imageURL, image: nil))
      }
      return images

    } catch {
      print("Error trying to convert data to JSON")
      return nil
    }
  }
}
