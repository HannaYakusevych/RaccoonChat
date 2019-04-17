//
//  ImageService.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 17/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

protocol IImageService {
  func fetchData(completionHandler: @escaping ([PhotoModel]?, String?) -> Void)
  func loadImage(urlString: String, completionHandler: @escaping (UIImage?, String?) -> Void)
}

class ImageService: IImageService {

  let apiKey = "12222718-0505ac5371021a44e10d9cbd8"

  let requestSender: IRequestSender

  init() {
    self.requestSender = RequestSender()
  }

  func fetchData(completionHandler: @escaping ([PhotoModel]?, String?) -> Void) {
    let urlString = "https://pixabay.com/api/?key=\(self.apiKey)&image_type=photo&pretty=true&per_page=150"
    guard let url = URL(string: urlString) else { return }
    let urlRequest = URLRequest(url: url)

    let requestConfig = RequestConfig<Parser>(request: urlRequest, parser: Parser())

    self.load(requestConfig: requestConfig, completionHandler: completionHandler)
  }

  func loadImage(urlString: String, completionHandler: @escaping (UIImage?, String?) -> Void) {
    guard let url = URL(string: urlString) else { return }
    let urlRequest = URLRequest(url: url)

    requestSender.sendForImage(urlRequest: urlRequest) { (imageData: Data?, error: Error?) in
      guard imageData != nil else {
        completionHandler(nil, error?.localizedDescription)
        return
      }

      guard let data = imageData,
        let image = UIImage(data: data) else {
        Logger.write("Error: can't convert data to image")
        completionHandler(nil, error?.localizedDescription)
        return
      }

      completionHandler(image, error?.localizedDescription)
    }
  }

  func load(requestConfig: RequestConfig<Parser>, completionHandler: @escaping ([PhotoModel]?, String?) -> Void) {
    requestSender.send(requestConfig: requestConfig) { (result: Result<[PhotoModel]>) in
      switch result {
      case .success(let apps):
        completionHandler(apps, nil)
      case .error(let error):
        completionHandler(nil, error)
      }
    }
  }
}
