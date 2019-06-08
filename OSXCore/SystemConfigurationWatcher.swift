//
//  SystemConfigurationWatcher.swift
//  OSXCore
//
//  Created by Jeong YunWon on 06/06/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import SwiftCoreServices

typealias FSEventStream = SFSEventStream

public class SystemConfigurationWatcher {
    var configuration: Configuration

    static let globalPreferencesPath: String = {
        let libraryUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        let fileUrl = URL(fileURLWithPath: "Preferences/.GlobalPreferences.plist", relativeTo: libraryUrl)
        return fileUrl.path
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
        let globalPreferences = NSDictionary(contentsOf: URL(fileURLWithPath: SystemConfigurationWatcher.globalPreferencesPath))!
        let state: Int = (globalPreferences["TISRomanSwitchState"] as? NSNumber)?.intValue ?? 1
        configuration.enableCapslockToToggleInputMode = state > 0
    }
}

public let watcher = SystemConfigurationWatcher(configuration: &Configuration.shared)
