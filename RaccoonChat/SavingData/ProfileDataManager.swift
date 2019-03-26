//
//  UserProfileData.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 11/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

protocol ProfileDataManager {
  func saveProfileData(name:String?, description: String?, image: UIImage?, completion: @escaping (_ hasError: Bool) -> Void)
  func loadProfileData(isDone: @escaping (Bool, (String, String, UIImage)) -> Void)
}

