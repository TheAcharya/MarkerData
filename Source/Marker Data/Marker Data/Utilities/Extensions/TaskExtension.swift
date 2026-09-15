//
//  TaskExtension.swift
//  Marker Data
//
//  Created by Milán Várady on 21/04/2024.
//

import Foundation

extension Task where Failure == Error {
    /// Performs an async task in a sync context.
    ///
    /// - Note: This function blocks the thread until the given operation is finished. The caller is responsible for managing multithreading.
    static func synchronous(priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Success) {
        let semaphore = DispatchSemaphore(value: 0)

        // Explicit non-throwing Task so Xcode 27 does not warn about a discarded
        // throwing unstructured task (#NoUseUnstructuredThrowingTask). Errors
        // cannot be rethrown across the semaphore wait; the only caller is
        // settings migration, which does not throw.
        Task<Void, Never>(priority: priority) {
            defer { semaphore.signal() }

            do {
                _ = try await operation()
            } catch {}
        }

        semaphore.wait()
    }
}
