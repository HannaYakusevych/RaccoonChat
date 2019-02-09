//
//  ViewController.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 09/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    LogMaker.viewStateIsChanging(message: "View is appearing")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    LogMaker.viewStateIsChanging(message: "View appeared")
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    LogMaker.viewStateIsChanging(message: "Layout is changing")
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    LogMaker.viewStateIsChanging(message: "Layout changed")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    LogMaker.viewStateIsChanging(message: "View is disappearing")
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    LogMaker.viewStateIsChanging(message: "View disappeared")
    
  }
  
}

