//
//  ProfileViewController.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 16/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

  // MARK: Outlets
  @IBOutlet weak var setPhotoImageView: UIImageView!
  @IBOutlet weak var profileImageView: UIImageView!
  
  // MARK: Actions
  
  @IBAction func changePhoto(_ sender: UITapGestureRecognizer) {
    if !tappedInSetPhotoCircle(sender: sender) {
      return
    }
    print("Выбери изображение профиля")
  }
  
  
  // MARK: View Lifecycle mathods
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    setImagesProperties()
  }
  
  // MARK: Private functions
  
  /**
   Set properties for profilePhotoView and choosePhotoView
   */
  private func setImagesProperties() {
    let layer = setPhotoImageView.layer
    
    // choosePhotoView settings
    let image = UIImage(named: "slr-camera-2-xxl")?.cgImage
    layer.contents = image
    layer.contentsGravity = CALayerContentsGravity.center
    
    // 1.75 - empirical multiplier
    let k = CGFloat((image?.height)!) / layer.bounds.height * 1.75
    layer.contentsScale = k
    layer.cornerRadius = setPhotoImageView.frame.size.height / 2
    
    // profilePhotoView settings
    profileImageView.layer.cornerRadius = setPhotoImageView.frame.size.height / 2
  }
  
  /**
   Check if user tapped inside the setPhotoImageView circle
   - Parameters:
      - sender: a UITapGestureRecognizer that reacted on tap
   - Returns:
      - true, if user tapped inside the circle
      - false, if user tapped outside the circle
   */
  private func tappedInSetPhotoCircle(sender: UITapGestureRecognizer) -> Bool {
    let point = sender.location(in: setPhotoImageView)
    let radius = setPhotoImageView.bounds.size.width / 2
    let center = CGPoint(x: radius, y: radius)
    if pow(center.x-point.x, 2) + pow(center.y - point.y, 2) >= pow(radius, 2) {
      return false
    }
    return true
  }


}
