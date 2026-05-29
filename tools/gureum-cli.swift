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
    """)
}

let args = CommandLine.arguments
let command = args.count > 1 ? args[1].lowercased() : "toggle"

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

print("Successfully sent '\(action)' event to Gureum.")
