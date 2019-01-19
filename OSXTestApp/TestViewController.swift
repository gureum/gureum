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
    override func loadView() {
        let path = Bundle.main.path(forResource: "Preferences", ofType: "prefPane")
        let bundle = NSPrefPaneBundle(path: path)!
        assert(bundle.bundle != nil)
        assert(bundle.bundle.principalClass != nil)
        let loaded = bundle.instantiatePrefPaneObject()
        assert(loaded)
        let pane = bundle.prefPaneObject()!
        // pane.loadMainView()
        view = pane.mainView
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
            if event.keyCode == kVK_Delete, self.inputClient.selectedRange().length > 0 {
                self.inputClient.insertText(event.characters, replacementRange: self.inputClient.selectedRange())
                return nil
            }
            let processed = self.inputController.handle(event, client: self.inputClient)
            if processed {
                return nil
            }
            let specialFlags = event.modifierFlags.intersection([.command, .control])
            if !processed, specialFlags.isEmpty {
                if event.keyCode == kVK_Delete {
                    NSLog("\(self.inputClient.selectedRange())")
                    let marked = self.inputClient.markedRange()
                    if self.inputClient.hasMarkedText() {
                        self.inputClient.insertText(event.characters, replacementRange: marked)
                    } else if marked.location > 0 {
                        let deleted = NSRange(location: marked.location - 1, length: 1)
                        self.inputClient.insertText(event.characters, replacementRange: deleted)
                        let marking = NSRange(location: marked.location - 1, length: 0)
                        self.inputClient.setMarkedText("", selectionRange: marking, replacementRange: deleted)
                    }
                } else if event.keyCode <= 0x33 {
                    self.inputClient.insertText(event.characters, replacementRange: self.inputClient.markedRange())
                } else {
                    return event
                }
                return nil
            }
            return event
        })
    }
}
