//
//  ProfileViewController.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 16/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    // The app crashes
    // The reason is that editButton isn't initialized yet (it is nil)
    //Logger.write("\(editButton.frame)")
  }
  
  // MARK: Outlets
  @IBOutlet weak var setPhotoImageView: UIImageView!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var editButton: UIButton!
  
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
    
    Logger.write("\(editButton.frame)")
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    setViewContentProperties()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // The editButton.frame property is different here because
    // the methods viewWillLayoutSubviews() and viewDidLayoutSubviews()
    // were called and object size has changed according to the screen size
    Logger.write("\(editButton.frame)")
  }
  
  // MARK: Private functions
  
  /**
   Set properties for profilePhotoView, choosePhotoView and editButton
   */
  private func setViewContentProperties() {
    let layer = setPhotoImageView.layer
    
    // choosePhotoView settings
    let image = UIImage(named: "slr-camera-2-xxl")?.cgImage
    layer.contents = image
    layer.contentsGravity = CALayerContentsGravity.center
    
    // 1.75 - empirical multiplier
    let k = CGFloat((image?.height)!) / layer.bounds.height * 1.75
    layer.contentsScale = k
    
    let radius = setPhotoImageView.frame.size.height / 2
    layer.cornerRadius = radius
    
    // profilePhotoView settings
    profileImageView.layer.cornerRadius = radius
    
    // editButton settings
    editButton.layer.cornerRadius = editButton.layer.bounds.height / 4
    editButton.layer.borderColor = UIColor.black.cgColor
    editButton.layer.borderWidth = 1.0
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
