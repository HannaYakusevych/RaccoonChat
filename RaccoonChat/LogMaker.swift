//
//  LogMaker.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 09/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

struct LogMaker {
  
  // Set the default value to 'false' to disable activity logs
  static var isEnabled = true
  
  static func appStateIsChanging(in method: String = #function, from state1: String, to state2: String) {
    if LogMaker.isEnabled {
      print("AppDelegate: Application moved from \"\(state1)\" to \"\(state2)\": \(method)")
    }
  }
  
  static func viewStateIsChanging(in method: String = #function, message: String) {
    if LogMaker.isEnabled {
      print("ViewController: \(message): \(method)")
    }
  }
  
}

