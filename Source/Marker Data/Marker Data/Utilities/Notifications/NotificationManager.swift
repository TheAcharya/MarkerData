//
//  NotificationManager.swift
//  Marker Data
//
//  Created by Milán Várady on 21/01/2024.
//

import Foundation
import UserNotifications
import OSLog

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "NotificationManager")

    nonisolated(unsafe) static let shared = NotificationManager()

    private override init() {
        super.init()
    }

    /// Sets up the notification center delegate so notifications can be displayed while the app is in the foreground.
    static func setupDelegate() {
        UNUserNotificationCenter.current().delegate = shared
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    // MARK: - Send Notification

    static func sendNotification(taskFinished: Bool, title: String, body: String = "") async {
        let notificationFrequency: NotificationFrequency
        do {
            let store = try await SettingsStore.loadStaticStoreFromDisk()
            notificationFrequency = store.notificationFrequency
        } catch {
            logger.error("Failed to read notification frequency settings: \(error.localizedDescription)")
            return
        }

        // Check if we should send notification
        // else return
        switch notificationFrequency {
        case .never:
            return
        case .onlyOnCompletion:
            if !taskFinished {
                return
            }
        case .allSteps:
            break
        }

        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        if settings.authorizationStatus != .authorized && settings.authorizationStatus != .provisional {
            // Ask for authorization
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                guard granted else {
                    logger.warning("Notification authorization denied by user")
                    return
                }
            } catch {
                logger.error("Failed to request notification authorization. Error: \(error.localizedDescription)")
                return
            }
        }

        let content = UNMutableNotificationContent()

        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

        do {
            try await center.add(request)
        } catch {
            logger.error("Failed to send notification. Error: \(error.localizedDescription)")
        }
    }
}
