//
//  TestViewController.swift
//  PreferencesApp
//
//  Created by Jeong YunWon on 2018. 9. 20..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Cocoa
@testable import GureumCore

class PreferenceViewController: NSViewController {
    private let _isAtLeast10_15 = ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 10, minorVersion: 15, patchVersion: 0))

    override func loadView() {
        let path = Bundle.main.path(forResource: "Preferences", ofType: "prefPane")
        let bundle = NSPrefPaneBundle(path: path)!
        assert(bundle.bundle != nil)
        assert(bundle.bundle.principalClass != nil)
        if _isAtLeast10_15 {
            let pane = NSPreferencePane(bundle: bundle.bundle)
            pane.loadMainView()
            view = pane.mainView
        } else {
            let loaded = bundle.instantiatePrefPaneObject()
            assert(loaded)
            let pane = bundle.prefPaneObject()!
            view = pane.mainView
        }
    }
}

class TestViewController: NSViewController {
    @IBOutlet var textField: NSTextField!
    @IBOutlet var inputClient: MockInputClient!
    var inputController: InputController!

    override func viewDidLoad() {
        assert(inputClient != nil)
        inputController = MockInputController(server: InputMethodServer.shared.server, delegate: self, client: inputClient!)
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged], handler: {
            event in
            // print(event)
            assert(self.inputController != nil)
            assert(self.inputClient != nil)
            guard event.type == .keyDown else {
                _ = self.inputController.handle(event, client: self.inputClient)
                return nil
            }
            guard let keyCode = KeyCode(rawValue: Int(event.keyCode)) else { return nil }
            let selected = self.inputClient.selectedRange()
            let marked = self.inputClient.markedRange()
            if keyCode == .delete, selected.length > 0, selected != marked {
                self.inputController.cancelComposition()
                self.inputClient.insertText("", replacementRange: selected)
                self.inputClient.setMarkedText("", selectionRange: NSRange(location: 0, length: 0), replacementRange: NSRange(location: selected.location, length: 0))
                return nil
            }
            let processed = self.inputController.handle(event, client: self.inputClient)
            if processed {
                // self.inputController.updateComposition()
                return nil
            }
            let specialFlags = event.modifierFlags.intersection([.command, .control])
            if !specialFlags.isEmpty {
                return event
            }
            self.inputController.cancelComposition()
            self.inputController.commitComposition(self.inputClient)
            if keyCode == .delete {
                NSLog("\(self.inputClient.selectedRange())")
                // let marked = self.inputClient.markedRange()
                if self.inputClient.hasMarkedText() {
                    self.inputClient.insertText("", replacementRange: marked)
                } else if selected.location > 0 {
                    let deleted = NSRange(location: selected.location - 1, length: 1)
                    self.inputClient.insertText("", replacementRange: deleted)
                    let marking = NSRange(location: deleted.location, length: 0)
                    self.inputClient.setMarkedText("", selectionRange: NSRange(location: 0, length: 0), replacementRange: marking)
                }
            } else if keyCode.isKeyMappable {
                self.inputClient.insertText(event.characters, replacementRange: self.inputClient.markedRange())
            } else {
                return event
            }
            return nil
        })
    }
}
