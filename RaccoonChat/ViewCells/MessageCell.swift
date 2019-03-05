//
//  inputMessageCell.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 25/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

protocol MessageCellConfiguration: class {
  var textMessage: String? {get set}
}

class MessageCell: UITableViewCell, MessageCellConfiguration {
  
  // MARK: - Outlets
  @IBOutlet var inputMessageLabel: MyLabel!
  @IBOutlet var outputMessageLabel: MyLabel!
  
  
  var textMessage: String? {
    get {
      return inputMessageLabel?.text ?? outputMessageLabel.text
    }
    set {

      if inputMessageLabel != nil {
        inputMessageLabel.text = newValue
      }
      else {
        outputMessageLabel.text = newValue
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    let label = inputMessageLabel ?? outputMessageLabel!
    label.layer.borderWidth = 1
    label.layer.borderColor = UIColor.black.cgColor
    label.layer.cornerRadius = label.bounds.width / 2
    label.layer.backgroundColor = label == inputMessageLabel ? ThemeManager.currentTheme().mainColor.withAlphaComponent(0.8).cgColor : ThemeManager.currentTheme().mainColor.withAlphaComponent(0.2).cgColor
  }
  

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
  }

}

// MARK: - Customizing margins in labels
@IBDesignable
class MyLabel: UILabel {
  var textInsets = UIEdgeInsets.zero {
    didSet { invalidateIntrinsicContentSize() }
  }
  
  override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
    let insetRect = bounds.inset(by: textInsets)
    let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
    let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                      left: -textInsets.left,
                                      bottom: -textInsets.bottom,
                                      right: -textInsets.right)
    return textRect.inset(by: invertedInsets)
  }
  
  override func drawText(in rect: CGRect) {
    super.drawText(in: rect.inset(by: textInsets))
  }
}

extension MyLabel {
  @IBInspectable
  var leftTextInset: CGFloat {
    set { textInsets.left = newValue }
    get { return textInsets.left }
  }
  
  @IBInspectable
  var rightTextInset: CGFloat {
    set { textInsets.right = newValue }
    get { return textInsets.right }
  }
  
  @IBInspectable
  var topTextInset: CGFloat {
    set { textInsets.top = newValue }
    get { return textInsets.top }
  }
  
  @IBInspectable
  var bottomTextInset: CGFloat {
    set { textInsets.bottom = newValue }
    get { return textInsets.bottom }
  }
}


