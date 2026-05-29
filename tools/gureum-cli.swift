#!/usr/bin/env swift
import Foundation

func printUsage() {
    print("""
    Gureum CLI Layout Controller
    Usage:
      gureum-cli [command]

    Commands:
      toggle   Toggle layout between Hangul and Roman (default)
      hangul   Force switch to Hangul layout
      roman    Force switch to Roman layout
      hanja    Switch to Hanja (Search) layout
      help     Show this help message
      --silent Suppress success output
    """)
}

let args = CommandLine.arguments
var command = "toggle"
var silent = false
if args.count > 1 {
    var idx = 1
    while idx < args.count {
        let arg = args[idx]
        if arg == "--silent" {
            silent = true
        } else if arg.hasPrefix("-") {
            // Ignore other flags for now
        } else {
            command = arg.lowercased()
        }
        idx += 1
    }
}

let action: String
switch command {
case "toggle":
    action = "toggle"
case "hangul":
    action = "hangul"
case "roman":
    action = "roman"
case "hanja":
    action = "hanja"
case "help", "-h", "--help":
    printUsage()
    exit(0)
default:
    print("Unknown command: \(command)")
    printUsage()
    exit(1)
}

let notificationName = NSNotification.Name("org.youknowone.gureum.layoutEvent")
let userInfo = ["action": action]

DistributedNotificationCenter.default().postNotificationName(
    notificationName,
    object: nil,
    userInfo: userInfo,
    deliverImmediately: true
)

if !silent {
    print("Successfully sent '\(action)' event to Gureum.")
}
