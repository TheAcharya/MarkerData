//
//  OpenEventHandler.swift
//  Marker Data
//
//  Created by Milán Várady on 16/01/2024.
//

import Foundation
import OSLog

@MainActor
class OpenEventHandler: NSObject {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "OpenEventHandler")
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupHandler), name: Notification.Name("FCPShareStart"), object: nil)
        self.setupHandler()
    }
    
    @objc func setupHandler() {
        // Do not under any circumstances remove the "DispatchQueque.main.async"
        // If it's not here the events are not set up correctly for some reason
        // and the file URL is not recieved.
        DispatchQueue.main.async {
            // Setup an Apple Event hander for the "Open" event
            NSAppleEventManager.shared().setEventHandler(self,
                                                         andSelector: #selector(self.handleOpen(event:replyEvent:)),
                                                         forEventClass: AEEventClass(kCoreEventClass),
                                                         andEventID: AEEventID(kAEOpen))
            
            Self.logger.notice("Open event handler setup DONE")
        }
    }
    
    @objc func handleOpen(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        guard let descriptorList = event.paramDescriptor(forKeyword: keyDirectObject) else { return }
        
        if descriptorList.numberOfItems == 0 {
            Self.logger.error("Open event triggered but no files received")
            return
        }
        
        for index in 1...descriptorList.numberOfItems {
            if let fileDescriptor = descriptorList.atIndex(index),
               let urlString = fileDescriptor.stringValue,
               let url = URL(string: urlString) {
                
                let logger = Logger()
                logger.notice("Open event has received file at URL: \(url, privacy: .public)")
                
                NotificationCenter.default.post(name: Notification.Name("OpenFile"), object: nil, userInfo: ["url": url])
            }
        }
    }
}
