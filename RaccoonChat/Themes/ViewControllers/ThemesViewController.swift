//
//  ThemesViewController.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 04/03/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

class ThemesViewController: UIViewController {

  var model: Themes!
  var changeColor: ((UIColor) -> Void)?

  @IBOutlet var themeButtons: [UIButton]!

  @IBAction func didSelectTheme(_ sender: UIButton) {
    guard
      let model = model,
      let index = themeButtons.index(of: sender) else { return }

    let backgroundColor: UIColor

    switch index {
    case 0:
      backgroundColor = model.theme1
    case 1:
      backgroundColor = model.theme2
    case 2:
      backgroundColor = model.theme3
    default:
      fatalError("The button index is out of range")
    }
    if let changeColor = changeColor {
      changeColor(backgroundColor)
    } else {
      Logger.write("Error: The closure for changing color wasn't passed")
    }

  }

  @IBAction private func dismiss(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    themeButtons[0].backgroundColor = UIColor.white.withAlphaComponent(0.8)
    themeButtons[1].backgroundColor = UIColor.white.withAlphaComponent(0.8)
    themeButtons[2].backgroundColor = UIColor.white.withAlphaComponent(0.8)
    self.view.backgroundColor = ThemeManager.currentTheme().mainColor
        // Do any additional setup after loading the view.
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
