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
        printViewStateChanges(from: "Disappeared", to: "Appearing")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        printViewStateChanges(from: "Appearing", to: "Appeared")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        printViewStateChanges(from: "-", to: "Changing Layout")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        printViewStateChanges(from: "Changing Layout", to: "-")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        printViewStateChanges(from: "Appeared", to: "Disappearing")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        printViewStateChanges(from: "Disappearing", to: "Disappeared")
    }
    
    // MARK: Lifecycle logging methods
    
    private func printViewStateChanges(in method: String = #function, from state1: String, to state2: String) {
        print("ViewController: Application moved from \"\(state1)\" to \"\(state2)\": \(method)")
    }


}

