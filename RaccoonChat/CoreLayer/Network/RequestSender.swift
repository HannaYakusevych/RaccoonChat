//
//  RequestSender.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 17/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

struct RequestConfig<Parser> where Parser: IParser {
  let request: URLRequest?
  let parser: Parser
}

enum Result<Model> {
  case success(Model)
  case error(String)
}

protocol IRequestSender {
  func send<Parser>(requestConfig: RequestConfig<Parser>,
                    completionHandler: @escaping(Result<Parser.Model>) -> Void)
  func sendForImage(urlRequest: URLRequest, completionHandler: @escaping(Data?, Error?) -> Void)
}

class RequestSender: IRequestSender {

  let session = URLSession.shared
  let queue = DispatchQueue(label: "com.app.gcdQueue", qos: .userInitiated)

  func send<Parser>(requestConfig config: RequestConfig<Parser>,
                    completionHandler: @escaping (Result<Parser.Model>) -> Void) {
    guard let urlRequest = config.request else {
      completionHandler(Result.error("url string can't be parsed to URL"))
      return
    }

    let task = session.dataTask(with: urlRequest) { (data: Data?, _, error: Error?) in
      if let error = error {
        completionHandler(Result.error(error.localizedDescription))
        return
      }
      guard let data = data,
        let parsedModel: Parser.Model = config.parser.parse(data: data) else {
          completionHandler(Result.error("received data can't be parsed"))
          return
      }

      completionHandler(Result.success(parsedModel))
    }

    queue.async {
      task.resume()
    }
  }

  func sendForImage(urlRequest: URLRequest, completionHandler: @escaping(Data?, Error?) -> Void) {
    let task = session.dataTask(with: urlRequest) { (data: Data?, _, error: Error?) in
      completionHandler(data, error)
    }
    queue.async {
      task.resume()
    }
  }
}
