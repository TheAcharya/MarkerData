//
//  WorkflowExtensionViewController.swift
//  WorkflowExtension
//
//  Created by Milán Várady on 23/01/2024.
//

import Cocoa
import SwiftUI

@objc class WorkflowExtensionViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swiftuiView = NSHostingView(rootView: WorkflowExtensionView())
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(swiftuiView)
        swiftuiView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        swiftuiView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
}