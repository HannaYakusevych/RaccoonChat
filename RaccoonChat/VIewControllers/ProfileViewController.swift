//
//  ProfileViewController.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 16/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    // The app crashed
    // The reason is that editButton isn't initialized yet (it is nil),
    // so forced unwrapping causes crash
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
    
    showAlertController()
  }
  @IBAction func goBack(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  
  // MARK: View Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = ThemeManager.currentTheme().mainColor
    editButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    
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
    
    // 1.75 - empirical multiplier (looks better)
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
  
  // MARK: Setting new profile photo functions
  
  /**
   Show the AlertController to allow the user to choose a new photo for the profile
   */
  private func showAlertController() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    // Make actions
    
    // Choose the photo from the library
    let choosePhotoAction = UIAlertAction(title: "Установить из галереи", style: .default, handler: { (alert: UIAlertAction!) -> Void in
      // Check if Photo Library is available
      if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
        // Check if the app is allowed to use the Photo Library
        let photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()

        switch photoLibraryAuthorizationStatus {
        case .notDetermined: self.requestPhotoLibraryPermission()
        case .authorized: self.presentChoosingPhotoController(ofType: .photoLibrary)
        case .restricted, .denied: self.alertAccessNeeded(for: "Photo Library")
        }
      }
    })
    
    // Make a new photo
    let makePhotoAction = UIAlertAction(title: "Сделать фото", style: .default, handler: { (alert: UIAlertAction!) -> Void in
      // Check if camera is available
      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        // Check if the app is allowed to use the camera
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined: self.requestCameraPermission()
        case .authorized: self.presentChoosingPhotoController(ofType: .camera)
        case .restricted, .denied: self.alertAccessNeeded(for: "Camera")
        }
      } else {
        self.alertCameraIsUnavailable()
      }
    })
    
    let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
    
    // Add actions to the controller
    alertController.addAction(choosePhotoAction)
    alertController.addAction(makePhotoAction)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  /**
   Ask the user if an access to the camera is allowed (for now it isn't specified)
   */
  private func requestCameraPermission() {
    AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
      guard accessGranted == true else { return }
      self.presentChoosingPhotoController(ofType: .camera)
    })
  }
  
  /**
   Ask the user if an access to the Photo Library is allowed (for now it isn't specified)
   */
  private func requestPhotoLibraryPermission() {
    PHPhotoLibrary.requestAuthorization() {accessGranted in
      guard accessGranted == PHAuthorizationStatus.authorized else { return }
      self.presentChoosingPhotoController(ofType: .photoLibrary)
    }
  }
  
  private func presentChoosingPhotoController(ofType: UIImagePickerController.SourceType) {
    let photoPicker = UIImagePickerController()
    photoPicker.sourceType = ofType
    photoPicker.delegate = self
    self.present(photoPicker, animated: true, completion: nil)
  }
  
  /**
   Ask the user if an access to the app would be allowed (for now it isn't)
   */
  private func alertAccessNeeded(for app: String) {
    let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
    
    let title = app == "Camera" ? "Необходим доступ к камере" : "Необходим доступ к фотографиям"
    let message = app == "Camera" ? "Доступ к камере необходим для полноценного функционирования приложения" : "Доступ к фотографиям необходим для полноценного функционирования приложения"
    
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertController.Style.alert
    )
    
    alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
    alert.addAction(UIAlertAction(title: "Разрешить", style: .cancel, handler: { (alert) -> Void in
      UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
    }))
    
    present(alert, animated: true, completion: nil)
  }
  
  /**
   Tell the user if camera isn't available on device
 */
  private func alertCameraIsUnavailable() {
    let alert = UIAlertController(
      title: "Камера не доступна на данном устройстве",
      message: nil,
      preferredStyle: UIAlertController.Style.alert
    )
    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
    
    present(alert, animated: true, completion: nil)
  }

  // Setting a new photo as profile photo
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
    profileImageView.image = image
  }
}
