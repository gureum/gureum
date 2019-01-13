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
    var inputController: CIMInputController!

    override func viewDidLoad() {
        assert(inputClient != nil)
        inputController = CIMMockInputController(server: InputMethodServer.shared.server, delegate: self, client: inputClient!)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: {
            event in
            // print(event)
            assert(self.inputController != nil)
            assert(self.inputClient != nil)
            self.inputController.inputText(event.characters, key: Int(event.keyCode), modifiers: Int(event.modifierFlags.rawValue), client: self.inputClient)
            return event
        })
    }
}
