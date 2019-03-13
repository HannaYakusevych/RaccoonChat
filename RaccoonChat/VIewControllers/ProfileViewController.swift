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

class ProfileViewController: UIViewController, UINavigationControllerDelegate  {
  
  // MARK: - Outlets
  @IBOutlet weak var setPhotoImageView: UIImageView!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet var nameTextField: UITextField!
  @IBOutlet var descriptionTextView: UITextView!
  @IBOutlet var gcdButton: UIButton!
  @IBOutlet var operationButton: UIButton!
  @IBOutlet var keyboardToolbar: UIToolbar!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  
  // Default: GCD
  var dataManager: ProfileDataManager = GCDDataManager()
  
  // MARK: - Actions
  
  @IBAction func changePhoto(_ sender: UITapGestureRecognizer) {
    if !tappedInSetPhotoCircle(sender: sender) {
      return
    }
    print("Выбери изображение профиля")
    
    showAlertController()
    setViewContentProperties()
  }
  
  @IBAction func goBack(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func hideKeyboard(_ sender: UIBarButtonItem) {
    view.endEditing(true)
  }
  
  @IBAction func editProfileData(_ sender: UIButton) {
    editingMode(isEnabled: true)
  }
  
  @IBAction func saveData(_ sender: UIButton) {
    showPlaceholderTextIfEmpty(descriptionTextView)
    // Don't allow user to save date while last saving isn't complete
    gcdButton.isUserInteractionEnabled = false
    operationButton.isUserInteractionEnabled = false
    
    if (sender == gcdButton) {
      self.dataManager = GCDDataManager()
    } else {
      //TODO: Save using Operation
    }
    activityIndicator.startAnimating()
    dataManager.saveProfileData(name: self.nameTextField.text, description: self.descriptionTextView.text, image: self.profileImageView.image) { isSaved in
      self.save(isSaved: isSaved)
    }
    
    
  }
  
  
  
  // MARK: - View Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = ThemeManager.currentTheme().mainColor
    
    editingMode(isEnabled: false)
    
    nameTextField.delegate = self
    descriptionTextView.delegate = self
    
    configureTapGesture()
    
    // Listen for keyboard events
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    // Reading the user data from the file
    activityIndicator.startAnimating()
    dataManager.loadProfileData() { isLoaded, data in
      self.load(isLoaded: isLoaded, data: data)
    }
    
  }
  
  deinit {
    // Stop listening for keyboard hide/show events
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    setViewContentProperties()
  }
  
  // MARK: - Private functions
  
  /**
   Function for loading data ending (reloading included)
   */
  func load(isLoaded: Bool, data: (String, String, UIImage)) {
    let (name, description, image) = data
    self.profileImageView.image = image
    self.nameTextField.text = name
    self.descriptionTextView.text = description
    if self.descriptionTextView.text != "Profile information" {
      self.descriptionTextView.textColor = UIColor.black
    }
    self.activityIndicator.stopAnimating()
    if !isLoaded {
      print(isLoaded)
      let alertController = UIAlertController(title: "Ошибка загрузки", message: "Не удалось получить данные. Если вы впервые используете приложение, проигнорируйте данное сообщение", preferredStyle: UIAlertController.Style.alert)
      alertController.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
      alertController.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { (alertAction) -> Void in
        self.activityIndicator.startAnimating()
        self.dataManager.loadProfileData() { isLoaded, data in
          self.load(isLoaded: isLoaded, data: data)
        }
      }))
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  /**
   Function for saving data ending (reloading included)
   */
  func save(isSaved: Bool) {
    if isSaved {
      let alertController = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: UIAlertController.Style.alert)
      alertController.addAction(UIAlertAction(title: "ОК", style: .default, handler: {_ in sleep(2)}))
      self.present(alertController, animated: true)
      self.activityIndicator.stopAnimating()
      self.editingMode(isEnabled: false)
    } else {
      let alertController = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные", preferredStyle: UIAlertController.Style.alert)
      alertController.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
      alertController.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
        self.activityIndicator.startAnimating()
        self.dataManager.saveProfileData(name: self.nameTextField.text, description: self.descriptionTextView.text, image: self.profileImageView.image) { isSaved in
          self.save(isSaved: isSaved)
        }
      })
      self.present(alertController, animated: true)
    }
  }
  
  /**
   Set properties for profilePhotoView, choosePhotoView and editButton
   */
  private func setViewContentProperties() {
    let layer = setPhotoImageView.layer
    
    // choosePhotoView settings
    var image: CGImage?
    switch ThemeManager.currentTheme() {
    case Theme.Blue:
      image = UIImage(named: "slr-camera-blue")?.cgImage
    case Theme.Purple:
      image = UIImage(named: "slr-camera-purple")?.cgImage
    case Theme.Orange:
      image = UIImage(named: "slr-camera-orange")?.cgImage
    }
    layer.contents = image
    layer.contentsGravity = CALayerContentsGravity.center
    layer.backgroundColor = UIColor.white.cgColor
    
    // 1.75 - empirical multiplier (looks better)
    let k = CGFloat((image?.height)!) / layer.bounds.height * 1.75
    layer.contentsScale = k
    
    let radius = setPhotoImageView.frame.size.height / 2
    layer.cornerRadius = radius
    
    setPhotoImageView.highlightedImage = UIImage(cgImage: image!)
    
    // profilePhotoView settings
    profileImageView.layer.cornerRadius = radius
    
    // Edit button settings
    editButton.layer.cornerRadius = editButton.layer.bounds.height / 4
    editButton.layer.borderColor = UIColor.black.cgColor
    editButton.layer.borderWidth = 1.0
    editButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    
    // GCD button settings
    gcdButton.layer.cornerRadius = gcdButton.layer.bounds.height / 4
    gcdButton.layer.borderColor = UIColor.black.cgColor
    gcdButton.layer.borderWidth = 1.0
    gcdButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    
    // Operation button settings
    operationButton.layer.cornerRadius = operationButton.layer.bounds.height / 4
    operationButton.layer.borderColor = UIColor.black.cgColor
    operationButton.layer.borderWidth = 1.0
    operationButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    
    nameTextField.layer.cornerRadius = 10
    descriptionTextView.layer.cornerRadius = 10
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
    self.handleTap()
    return true
  }
  
  private func editingMode(isEnabled: Bool) {
    nameTextField.isEnabled = isEnabled
    nameTextField.backgroundColor = isEnabled ? UIColor.white.withAlphaComponent(0.8) : nil
    descriptionTextView.isEditable = isEnabled
    descriptionTextView.backgroundColor = isEnabled ? UIColor.white.withAlphaComponent(0.8) : nil
    
    setPhotoImageView.isHidden = !isEnabled
    setPhotoImageView.isUserInteractionEnabled = isEnabled
    
    // Get rig of editButton
    editButton.isUserInteractionEnabled = !isEnabled
    editButton.isHidden = isEnabled
    
    // Show saving buttons
    gcdButton.isUserInteractionEnabled = isEnabled
    gcdButton.isHidden = !isEnabled
    operationButton.isUserInteractionEnabled = isEnabled
    operationButton.isHidden = !isEnabled
  }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate {
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
    
    let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: {(alert: UIAlertAction!) -> Void in self.setViewContentProperties()})
    
    // Add actions to the controller
    alertController.addAction(choosePhotoAction)
    alertController.addAction(makePhotoAction)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: {self.setViewContentProperties()})
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
    picker.dismiss(animated: true, completion: {self.setViewContentProperties()})
    let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
    profileImageView.image = image
  }
}

// MARK: - UITextFieldDelegate
extension ProfileViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  // Private functions
  private func configureTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
    view.addGestureRecognizer(tapGesture)
  }
  
  @objc func handleTap() {
    view.endEditing(true)
  }
  
  // Handling covering TextField by keyboard
  @objc func keyboardWillChange(notification: Notification) {
    
    guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
      return
    }
    if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
      view.frame.origin.y = -keyboardRect.height
    } else {
      view.frame.origin.y = 0
    }
    
    
  }
}

extension ProfileViewController: UITextViewDelegate {
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    textView.inputAccessoryView = keyboardToolbar
    return true
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    hidePlaceholderText(textView)
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    textView.resignFirstResponder()
    showPlaceholderTextIfEmpty(textView)
  }
  
  private func hidePlaceholderText(_ textView: UITextView) {
    if textView.text == "Profile information" {
      textView.text = ""
      textView.textColor = UIColor.black
    }
  }
  
  private func showPlaceholderTextIfEmpty(_ textView: UITextView) {
    if textView.text == "" {
      textView.text = "Profile information"
      textView.textColor = UIColor.lightGray
    }
  }
}
