//
//  PhotoCell.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 17/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

  @IBOutlet var photoImageView: UIImageView!

  var image: UIImage? {
    didSet {
      photoImageView.image = image ?? UIImage(named: "placeholder")
    }
  }

}
