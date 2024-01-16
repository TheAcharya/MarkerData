//
//  ApplicationDelegate.swift
//  Marker Data
//
//  Created by Milán Várady on 13/01/2024.
//

import Foundation
import Cocoa
import OSLog

// Replaced by OpenEventHander

//class ApplicationDelegate: NSObject, NSApplicationDelegate {
//    func applicationDidFinishLaunching(_ notification: Notification) {
//        // Do not under any circumstances remove the "DispatchQueque.main.async"
//        // If it's not here the events are not set up correctly for some reason
//        // and the file URL is not recieved.
//        DispatchQueue.main.async {
//            // Setup an Apple Event hander for the "Open" event
//            NSAppleEventManager.shared().setEventHandler(self,
//                                                         andSelector: #selector(self.handleOpen(event:replyEvent:)),
//                                                         forEventClass: AEEventClass(kCoreEventClass),
//                                                         andEventID: AEEventID(kAEOpen))
//        }
//    }
//    
//    @objc func handleOpen(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
//        guard let descriptorList = event.paramDescriptor(forKeyword: keyDirectObject) else { return }
//        
//        for index in 1...descriptorList.numberOfItems {
//            if let fileDescriptor = descriptorList.atIndex(index),
//               let urlString = fileDescriptor.stringValue,
//               let url = URL(string: urlString) {
//                
//                let logger = Logger()
//                logger.notice("Open event has received file at URL: \(url)")
//                
//                NotificationCenter.default.post(name: Notification.Name("OpenFile"), object: nil, userInfo: ["url": url])
//            }
//        }
//    }
//}
