//
//  InputController.swift
//  Gureum
//
//  Created by KMLee on 2018. 9. 12..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Foundation
import InputMethodKit

let debugLogging = false
let debugInputController = false
let debugSpying = true

//! @enum
//! @brief  최종적으로 InputController가 처리할 결과

public enum InputAction: Equatable {
  case none
  case commit
  case cancel
  case layout(String)
  case candidatesEvent(KeyCode)  // keyCode
}

struct InputResult: Equatable {
  let processed: Bool
  let action: InputAction

  static let processed = InputResult(processed: true, action: .none)
  static let notProcessed = InputResult(processed: false, action: .none)
}

enum ChangeLayout {
  case toggle
  case toggleByCapsLock
  case toggleByRightKey
  case hangul
  case roman
  case search
}

enum InputEvent {
  case changeLayout(ChangeLayout, Bool)
}

@objc(GureumInputController)
public class InputController: IMKInputController {
  var receiver: InputReceiver!
  var lastFlags = NSEvent.ModifierFlags(rawValue: 0)
  var updating = false

  override init!(server: IMKServer, delegate: Any!, client inputClient: Any) {
    super.init(server: server, delegate: delegate, client: inputClient)
    guard let inputClient = inputClient as? (IMKTextInput & IMKUnicodeTextInput) else {
      return nil
    }
    dlog(
      debugInputController,
      "**** NEW INPUT CONTROLLER INIT **** WITH SERVER: \(server) / DELEGATE: \(String(describing: delegate)) / CLIENT: \(inputClient) \(inputClient.bundleIdentifier() ?? "nil")"
    )
    assert(InputMethodServer.shared.server === server)
    receiver = InputReceiver(
      server: server, delegate: delegate, client: inputClient, controller: self)
  }

  override init() {
    super.init()
  }

  override public func inputControllerWillClose() {
    super.inputControllerWillClose()
  }

  func asClient(_ sender: Any!) -> IMKTextInput & IMKUnicodeTextInput {
    #if DEBUG
      return sender as! (IMKTextInput & IMKUnicodeTextInput)
    #else
      guard let sender = sender as? (IMKTextInput & IMKUnicodeTextInput) else {
        return client() as! (IMKTextInput & IMKUnicodeTextInput)
      }
      return sender
    #endif
  }

  #if DEBUG
    override public func responds(to aSelector: Selector) -> Bool {
      let r = super.responds(to: aSelector)
      dlog(debugSpying, "controller responds to: \(aSelector) \(r)")
      return r
    }

    override public func modes(_ sender: Any!) -> [AnyHashable: Any]! {
      let modes = super.modes(sender)
      dlog(debugSpying, "modes: \(String(describing: modes))")
      return modes
    }

    override public func value(forTag tag: Int, client _: Any!) -> Any! {
      let v = super.value(forTag: tag, client: client)
      dlog(debugSpying, "value: \(String(describing: v)) for tag: \(tag)")
      return v
    }
  #endif
}

// IMKServerInputTextData, IMKServerInputHandleEvent, IMKServerInputKeyBinding 중 하나를 구현하여 입력 구현
extension InputController {  // IMKServerInputHandleEvent
  // Receiving Events Directly from the Text Services Manager

  public override func handle(_ event: NSEvent, client sender: Any) -> Bool {
    // dlog(debugInputController, "event: \(event)")
    // sender is (IMKTextInput & IMKUnicodeTextInput & IMTSMSupport)
    let client = asClient(sender)

    switch event.type {
    case .keyDown:
      guard let keyCode = KeyCode(rawValue: Int(event.keyCode)) else {
        return false
      }

      dlog(
        debugInputController,
        "** InputController KEYDOWN -handleEvent:client: with event: %@ / key: %d / modifier: %lu / chars: %@ / chars ignoreMod: %@ / client: %@",
        event, event.keyCode, event.modifierFlags.rawValue, event.characters ?? "(empty)",
        event.charactersIgnoringModifiers ?? "(empty)",
        client.bundleIdentifier() ?? "(no client bundle)")

      let imkCandidates = InputMethodServer.shared.candidates
      if imkCandidates.isVisible() {
        let selectionKeys = imkCandidates.selectionKeys() as? [NSNumber] ?? []
        let arrowModifier = NSEvent.ModifierFlags.numericPad.union(.function)
        let emptyModifier = NSEvent.ModifierFlags(rawValue: 0)

        let inputModifier = event.modifierFlags
          .intersection(.deviceIndependentFlagsMask)
          .subtracting(.capsLock)

        if inputModifier == arrowModifier && KeyCode.arrows.contains(keyCode)
          || inputModifier == emptyModifier
            && (keyCode == .return || selectionKeys.contains(NSNumber(value: event.keyCode)))
        {
          // https://github.com/pkamb/NumberInput_IMKit_Sample/issues/1#issuecomment-633264470
          imkCandidates.perform(Selector(("handleKeyboardEvent:")), with: event)
          return true
        }
      }

      let result = receiver.input(
        text: event.characters, key: keyCode, modifiers: event.modifierFlags, client: client)
      dlog(debugLogging, "LOGGING::PROCESSED::\(result)")
      return result.processed
    case .flagsChanged:
      dlog(
        debugInputController,
        "** InputController FLAGCHANGED -handleEvent:client: with event: %@ / key: %d / modifier: %lu / client: %@",
        event, -1, event.modifierFlags.rawValue, client.bundleIdentifier() ?? "(no client bundle)")
      let changed = lastFlags.symmetricDifference(event.modifierFlags)
      lastFlags = event.modifierFlags

      if changed.contains(.capsLock), Configuration.shared.enableCapslockToToggleInputMode {
        if InputMethodServer.shared.io.capsLockTriggered {
          dlog(debugIOKitEvent, "controller detected capslock to change layout")
          let toggle = { [weak self] in
            _ = self?.receiver.input(event: .changeLayout(.toggleByCapsLock, true), client: client)
          }
          toggle()
          InputMethodServer.shared.io.rollback = toggle
        } else {
          dlog(debugIOKitEvent, "controller detected capslock")
          (sender as! IMKTextInput).selectMode(receiver.composer.inputMode)
        }
      }

      if InputMethodServer.shared.io.resolveRightKeyPressed() {
        let result = receiver.input(event: .changeLayout(.toggleByRightKey, true), client: client)
        dlog(debugIOKitEvent, "controller detected right key")
        return result.processed
      }

      dlog(debugLogging, "LOGGING::UNHANDLED::%@/%@", event, sender as! NSObject)
      dlog(
        debugInputController,
        "** InputController -handleEvent:client: with event: %@ / sender: %@", event,
        sender as! NSObject)
      return false
    case .leftMouseDown, .leftMouseUp, .leftMouseDragged, .rightMouseDown, .rightMouseUp,
      .rightMouseDragged:
      commitComposition(sender)
    default:
      dlog(debugSpying, "unhandled event: \(event)")
    }
    return false
  }
}

extension InputController {  // IMKStateSetting
  //! @brief  마우스 이벤트를 잡을 수 있게 한다.
  public override func recognizedEvents(_ sender: Any!) -> Int {
    let client = asClient(sender)
    return Int(receiver.recognizedEvents(client).rawValue)
  }

  //! @brief 자판 전환을 감지한다.
  public override func setValue(_ value: Any, forTag tag: Int, client sender: Any) {
    let client = asClient(sender)
    receiver.setValue(value, forTag: tag, client: client)
  }

  public override func activateServer(_ sender: Any!) {
    dlog(true, "server activated")
    super.activateServer(sender)
  }

  public override func deactivateServer(_ sender: Any!) {
    dlog(true, "server deactivating")
    if responds(to: #selector(commitComposition(_:))) {
      self.commitComposition(sender)
    }
    super.deactivateServer(sender)
  }
}

extension InputController {  // IMKMouseHandling
  //! @brief  마우스 입력 발생을 커서 옮기기로 간주하고 조합 중지. 만일 마우스 입력 발생을 감지하는 대신 커서 옮기기를 직접 알아낼 수 있으면 이 부분은 제거한다.
  public override func mouseDown(
    onCharacterIndex _: Int, coordinate _: NSPoint, withModifier _: Int,
    continueTracking _: UnsafeMutablePointer<ObjCBool>!, client sender: Any
  ) -> Bool {
    dlog(debugLogging, "LOGGING::EVENT::MOUSEDOWN")
    commitComposition(sender)
    return false
  }
}

extension InputController {  // IMKCustomCommands
  public override func menu() -> NSMenu! {
    return (NSApplication.shared.delegate! as! GureumApplicationDelegate).menu
  }
}

extension InputController {  // IMKServerInput
  // Committing a Composition
  // 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
  @objc public override func commitComposition(_ sender: Any!) {
    let client = asClient(sender)
    dlog(debugLogging, "LOGGING::EVENT::COMMIT-RAW?")
    _ = receiver.commitCompositionEvent(client)
    // super.commitComposition(sender)
  }

  @objc public override func updateComposition() {
    dlog(debugLogging, "LOGGING::EVENT::UPDATE-RAW?")
    dlog(debugInputController, "** InputController -updateComposition")
    receiver.updateCompositionEvent()
    super.updateComposition()
    dlog(debugInputController, "** InputController -updateComposition ended")
  }

  @objc public override func cancelComposition() {
    dlog(debugLogging, "LOGGING::EVENT::CANCEL-RAW?")
    receiver.cancelCompositionEvent()
    super.cancelComposition()
  }

  // Getting Input Strings and Candidates
  // 현재 입력 중인 글자를 반환한다. -updateComposition: 이 사용
  @objc public override func composedString(_ sender: Any!) -> Any {
    let client = asClient(sender)
    return receiver.composedString(client)
  }

  @objc public override func originalString(_ sender: Any!) -> NSAttributedString {
    let client = asClient(sender)
    return receiver.originalString(client)
  }

  @objc public override func candidates(_ sender: Any!) -> [Any]! {
    let client = asClient(sender)
    return receiver.candidates(client)
  }

  @objc public override func candidateSelected(_ candidateString: NSAttributedString!) {
    receiver.candidateSelected(candidateString)
  }

  @objc public override func candidateSelectionChanged(_ candidateString: NSAttributedString!) {
    receiver.candidateSelectionChanged(candidateString)
  }
}

#if DEBUG
  @objcMembers public class MockInputController: InputController {
    override public init(server: IMKServer, delegate: Any!, client: Any) {
      super.init()
      receiver = InputReceiver(
        server: server, delegate: delegate, client: client as! (IMKTextInput & IMKUnicodeTextInput),
        controller: self)
    }

    func repoduceTextLog(_ text: String) throws {
      for row in text.components(separatedBy: "\n") {
        guard let regex = try? NSRegularExpression(pattern: "LOGGING::([A-Z]+)::(.*)", options: [])
        else {
          throw NSException(
            name: NSExceptionName("MockInputControllerLogParserError"),
            reason: "Log is not readable format", userInfo: nil) as! Error
        }
        let matches = regex.matches(in: row, options: [], range: NSRangeFromString(row))
        let type = matches[1]
        let data = matches[2]
        print("test: \(type) \(data)")
      }
    }

    override public func client() -> (IMKTextInput & NSObjectProtocol)! {
      return receiver.inputClient as? (IMKTextInput & NSObjectProtocol)
    }

    override public func selectionRange() -> NSRange {
      return client().selectedRange()
    }
  }

  extension MockInputController {  // IMKServerInputTextData
    public func inputFlags(_: Int, client sender: Any) -> Bool {
      let client = asClient(sender)
      let result = receiver.input(event: .changeLayout(.toggle, true), client: client)
      if !result.processed {
        // [self cancelComposition]
      }
      return result.processed
    }

    public override func inputText(
      _ string: String!, key keyCode: Int, modifiers flags: Int, client sender: Any
    ) -> Bool {
      let client = asClient(sender)
      print(
        "** InputController -inputText:key:modifiers:client  with string: \(string ?? "(nil)") / keyCode: \(keyCode) / modifier flags: \(flags) / client: \(String(describing: client))"
      )
      guard let key = KeyCode(rawValue: keyCode) else { return false }
      let result = receiver.input(
        text: string, key: key, modifiers: NSEvent.ModifierFlags(rawValue: UInt(flags)),
        client: client)
      if !result.processed {
        // [self cancelComposition]
      }
      return result.processed
    }

    // Committing a Composition
    // 조합을 중단하고 현재까지 조합된 글자를 커밋한다.
    @objc public override func commitComposition(_ sender: Any) {
      let client = asClient(sender)
      receiver.commitCompositionEvent(client)
      // COMMIT triggered
    }

    public override func updateComposition() {
      receiver.updateCompositionEvent()

      let client = receiver.inputClient
      let composed = composedString(client) as! String
      let markedRange = client.markedRange()
      let view = receiver.inputClient as! NSTextView
      view.setMarkedText(
        composed, selectedRange: NSRange(location: 0, length: composed.count),
        replacementRange: markedRange)
    }

    public override func cancelComposition() {
      receiver.cancelCompositionEvent()

      let client = receiver.inputClient
      let view = receiver.inputClient as! NSTextView
      let markedRange = client.markedRange()
      view.setMarkedText(
        "", selectedRange: NSRange(location: markedRange.location, length: 0),
        replacementRange: markedRange)
    }

    // Getting Input Strings and Candidates
    // 현재 입력 중인 글자를 반환한다. -updateComposition: 이 사용
    public override func composedString(_ sender: Any) -> Any {
      let client = asClient(sender)
      return receiver.composedString(client)
    }

    public override func originalString(_ sender: Any) -> NSAttributedString {
      let client = asClient(sender)
      return receiver.originalString(client)
    }

    public override func candidates(_ sender: Any) -> [Any]? {
      let client = asClient(sender)
      return receiver.candidates(client)
    }

    public override func candidateSelected(_ candidateString: NSAttributedString!) {
      receiver.candidateSelected(candidateString)
    }

    public override func candidateSelectionChanged(_ candidateString: NSAttributedString!) {
      receiver.candidateSelectionChanged(candidateString)
    }
  }

  extension MockInputController {  // IMKStateSetting
    //! @brief  마우스 이벤트를 잡을 수 있게 한다.
    public override func recognizedEvents(_ sender: Any) -> Int {
      let client = asClient(sender)
      return Int(receiver.recognizedEvents(client).rawValue)
    }

    //! @brief 자판 전환을 감지한다.
    public override func setValue(_ value: Any, forTag tag: Int, client sender: Any) {
      let client = asClient(sender)
      receiver.setValue(value, forTag: tag, client: client)
    }
  }
#endif
