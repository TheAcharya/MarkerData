//
//  WorkflowExtensionViewController.swift
//  WorkflowExtension
//
//  Created by Milán Várady on 23/01/2024.
//

import Cocoa
import ProExtensionHost

@objc class WorkflowExtensionViewController: NSViewController {
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override var nibName: NSNib.Name? {
		return NSNib.Name("WorkflowExtensionViewController")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
    @objc var hostInfoString: String {
        let host = ProExtensionHostSingleton() as! FCPXHost
        return String(format:"%@ %@", host.name, host.versionString)
    }

}
