//
//  SystemConfigurationWatcher.swift
//  OSXCore
//
//  Created by Jeong YunWon on 06/06/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Foundation
import SwiftCoreServices

typealias FSEventStream = SFSEventStream

public class SystemConfigurationWatcher {
    var configuration: Configuration

    static let globalPreferencesPath: String = {
        let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        let fileURL = URL(fileURLWithPath: "Preferences/.GlobalPreferences.plist", relativeTo: libraryURL)
        return fileURL.path
    }()

    init(configuration: inout Configuration) {
        self.configuration = configuration

        let stream = FSEventStream.create(paths: [SystemConfigurationWatcher.globalPreferencesPath], eventId: FSEventStream.EventIdSinceNow, latancy: 5.0, flags: FSEventStream.CreateFlag.fileEvents) {
            [weak self] _, _ in
                NSLog("Reloading system configuration by watcher")
                self?.reloadConfiguration()
        }!
        stream.schedule(runLoop: .current, mode: .default)
        stream.start()
    }

    public func reloadConfiguration() {
        guard let globalPreferences = NSDictionary(contentsOf: URL(fileURLWithPath: SystemConfigurationWatcher.globalPreferencesPath)) else {
            return
        }

        let state: Int = (globalPreferences["TISRomanSwitchState"] as? NSNumber)?.intValue ?? 1
        configuration.enableCapslockToToggleInputMode = state > 0
    }
}

public let watcher = SystemConfigurationWatcher(configuration: &Configuration.shared)
