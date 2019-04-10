//
//  Utils.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 10/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

func generateMessageId() -> String {
  let date = Date.timeIntervalSinceReferenceDate
  let string = "\(arc4random_uniform(UINT32_MAX))+\(date)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
  return string!
}
