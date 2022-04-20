//
//  AnswersHelper.swift
//  OSX
//
//  Created by Jeong YunWon on 30/05/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import GureumCore

@objc class AnswersHelper: NSObject {
    let configuration = Configuration.shared
    let launchedTime = Date()

    func logLaunch() {
//        let report = configuration.persistentDomain().mapValues { "\($0)" }
//        Answers.logLogin(withMethod: "Launch",
//                         success: true,
//                         customAttributes: report)
    }

    @objc func logUptime() {
//        let uptime = -launchedTime.timeIntervalSinceNow
//        Answers.logContentView(withName: "Uptime",
//                               contentType: "Indicator",
//                               contentId: "uptime",
//                               customAttributes: ["uptime": uptime])
    }

    func logMenu(name _: String) {
//        Answers.logContentView(withName: "Menu",
//                               contentType: "Indicator",
//                               contentId: "menu-\(name)",
//                               customAttributes: ["name": name])
    }

    func logUpdateNotification(updating _: Bool) {
//        Answers.logContentView(withName: "Notification",
//                               contentType: "Indicator",
//                               contentId: "update-\(updating)",
//                               customAttributes: ["updating": updating])
    }
}

let answers = AnswersHelper()
