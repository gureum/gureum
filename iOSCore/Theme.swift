//
//  Theme.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 12..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class Theme {
    func dataForFilename(name: String) -> Data? {
        assert(false)
        return nil
    }

    func JSONObjectForFilename(name: String, error: NSErrorPointer) -> Any! {
        if let data = self.dataForFilename(name: name) {
            do {
                let result = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                return result
            } catch {
                let dataString = (data as NSData).stringUsingUTF8Encoding
                assert(false, "JSON 파일의 서식이 올바르지 않습니다.\(String(describing: error))\n\(data)\n\(String(describing: dataString))")
            }
        } else {
            assert(false, "지정한 JSON 데이터 파일이 없습니다. \(name)")
        }
        return nil
    }

    func imageForFilename(name: String) -> UIImage? {
        return self.imageForFilename(name: name, withTopMargin: 0)
    }

    func imageForFilename(name: String, withTopMargin margin: CGFloat) -> UIImage? {
        let parts = name.components(separatedBy: "::")
        let filename = parts[0]

        guard let data = self.dataForFilename(name: filename) else {
            return nil
        }
        
        guard var image = UIImage(data: data as Data, scale: 2) else {
            return nil
        }

        if margin != 0 {
            var size = image.size
            size.height += margin
            UIGraphicsBeginImageContextWithOptions(size, false, 2)
            let rect = CGRect(x: 0, y: margin, width: size.width, height: image.size.height)
            image.draw(in: rect)
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        if parts.count > 1 {
            let valueStrings = parts[1].components(separatedBy: " ")
            let (s1, s2, s3, s4) = (valueStrings[0], valueStrings[1], valueStrings[2], valueStrings[3])
            
            let insets = UIEdgeInsetsMake(CGFloat(Int(s1)!) + margin, CGFloat(Int(s2)!), CGFloat(Int(s3)!), CGFloat(Int(s4)!))
            image = image.resizableImage(withCapInsets: insets)
        }

        return image
    }

    lazy var mainConfiguration: NSDictionary = {
        var error: NSError? = nil
        let filename = "config.json"
        let JSONObject = self.JSONObjectForFilename(name: filename, error: &error) as! NSDictionary?
        assert(JSONObject != nil)
        return JSONObject!
    }()

    func traitForName(traitName: String, topMargin: CGFloat) -> ThemeTraitConfiguration {
        if let traits = self.mainConfiguration["trait"] as! NSDictionary? {
            if let traitFilename = traits[traitName] as! String? {
                var error: NSError? = nil
                let traitData: Any! = self.JSONObjectForFilename(name: traitFilename, error: &error)
                assert(error == nil, "trait 설정이 올바르지 않은 JSON파일입니다.")
                return ThemeTraitConfiguration(owner: self, configuration: traitData, topMargin: topMargin)
            } else {
                assert(false, "지정한 trait에 대한 설정이 없습니다.")
            }
        } else {
            assert(false, "주 설정 파일에 trait 키가 없습니다.")
        }
        // asserted
        return ThemeTraitConfiguration(owner: self, configuration: nil, topMargin: 0.0)
    }

    func traitForSize(size: CGSize) -> ThemeTraitConfiguration {
        switch size.width {
        case 320.0:
            return self.phonePortraitConfiguration
        case 480.0:
            return self.phoneLandscape480Configuration
        case 568.0:
            return self.phoneLandscape568Configuration
        case 768.0:
            return self.padPortraitConfiguration
        case 1024.0:
            return self.padLandscapeConfiguration
        default:
            assert(false, "no coverage")
            return self.phonePortraitConfiguration
        }
    }

    lazy var phonePortraitConfiguration: ThemeTraitConfiguration = {
        return self.traitForName(traitName: "phone-portrait", topMargin: 8)
        }()

    lazy var phoneLandscape480Configuration: ThemeTraitConfiguration = {
        return self.traitForName(traitName: "phone-landscape480", topMargin: 4)
        }()

    lazy var phoneLandscape568Configuration: ThemeTraitConfiguration = {
        return self.traitForName(traitName: "phone-landscape568", topMargin: 4)
        }()

    lazy var padPortraitConfiguration: ThemeTraitConfiguration = {
        return self.phonePortraitConfiguration
        }()

    lazy var padLandscapeConfiguration: ThemeTraitConfiguration = {
        return self.phoneLandscape480Configuration
        }()
}

class ThemeTraitConfiguration {
    let configuration: NSDictionary!
    let owner: Theme
    let topMargin: CGFloat
    var _captions: Dictionary<String, ThemeCaptionConfiguration> = [:]

    init(owner: Theme, configuration: Any?, topMargin: CGFloat) {
        self.owner = owner
        self.topMargin = topMargin
        self.configuration = configuration as! NSDictionary?
    }

    lazy var backgroundImage: UIImage? = {
        let configFilename = self.configuration["background"] as! String?
        let filename = configFilename ?? "background.png"
        return self.owner.imageForFilename(name: filename)
    }()

    lazy var foregroundImage: UIImage? = {
        let configFilename = self.configuration["foreground"] as! String?
        let filename = configFilename ?? "foreground.png"
        return self.owner.imageForFilename(name: filename)
    }()

    func captionForKey(key: String, fallback: ThemeCaptionConfiguration) -> ThemeCaptionConfiguration {
        if let theme = self._captions[key] {
            return theme
        } else {
            let theme: ThemeCaptionConfiguration = {
                if let sub: Any = self.configuration[key] {
                    return ThemeCaptionConfiguration(trait: self, configuration: sub, fallback: fallback)
                } else {
                    return fallback
                }
            }()
            self._captions[key] = theme
            return theme
        }
    }

    lazy var defaultCaption: ThemeCaptionConfiguration = ThemeDefaultCaptionConfiguration(trait: self)

    lazy var qwertyCaption: ThemeCaptionConfiguration = self.captionForKey(key: "qwerty", fallback: self.defaultCaption)
    func qwertyCaptionForRow(row: Int) -> ThemeCaptionConfiguration {
        return self.captionForKey(key: "qwerty-row\(row)", fallback: self.qwertyCaption)
    }
    lazy var qwerty32pxCaption: ThemeCaptionConfiguration = self.captionForKey(key: "qwerty-32px", fallback: self.qwertyCaption)
    lazy var qwerty40pxCaption: ThemeCaptionConfiguration = self.captionForKey(key: "qwerty-40px", fallback: self.qwertyCaption)
    lazy var qwerty48pxCaption: ThemeCaptionConfiguration = self.captionForKey(key: "qwerty-48px", fallback: self.qwertyCaption)
    lazy var qwerty80pxCaption: ThemeCaptionConfiguration = self.captionForKey(key: "qwerty-80px", fallback: self.qwertyCaption)
    lazy var qwerty160pxCaption: ThemeCaptionConfiguration = self.captionForKey(key: "qwerty-160px", fallback: self.qwertyCaption)

    lazy var qwertyKeyCaption: ThemeCaptionConfiguration = self.captionForKey(key: "qwerty-key", fallback: self.qwerty32pxCaption)
    lazy var qwertyShiftCaption: ThemeCaptionConfiguration = self.captionForKey(key: "qwerty-shift", fallback: self.qwerty48pxCaption)
    lazy var qwertyDeleteCaption: ThemeCaptionConfiguration = self.captionForKey(key: "qwerty-delete", fallback: self.qwerty48pxCaption)
    lazy var qwerty123Caption: ThemeCaptionConfiguration = self.captionForKey(key: "qwerty-123", fallback: self.qwerty40pxCaption)
    lazy var qwertyGlobeCaption: ThemeCaptionConfiguration = self.captionForKey(key: "qwerty-globe", fallback: self.qwerty40pxCaption)
    lazy var qwertySpaceCaption: ThemeCaptionConfiguration = self.captionForKey(key: "qwerty-space", fallback: self.qwerty160pxCaption)
    lazy var qwertyDoneCaption: ThemeCaptionConfiguration = self.captionForKey(key: "qwerty-done", fallback: self.qwerty80pxCaption)

    lazy var numpadCaption: ThemeCaptionConfiguration = self.captionForKey(key: "numpad", fallback: self.defaultCaption)
    func numpadCaptionForRow(row: Int) -> ThemeCaptionConfiguration {
        return self.captionForKey(key: "numpad-row\(row)", fallback: self.numpadCaption)
    }
}


class ThemeCaptionConfiguration {
    let configuration: [String: Any]
    let fallback: ThemeCaptionConfiguration!
    let trait: ThemeTraitConfiguration

    init(trait: ThemeTraitConfiguration, configuration: Any?, fallback: ThemeCaptionConfiguration!) {
        self.trait = trait

        let given = configuration ?? Dictionary<String, Any>() as Any

        var full: [String: Any] = [
            "image": Array<String>() as Any,
            "label": Dictionary<String, Any>() as Any,
        ]

        if given is String {
            var image = full["image"] as! [String]
            image.append((given as? String)!)
        } else if given is [String?] {
            full["image"] = configuration
            var image = configuration as! [String]
        } else {
            full = given as! Dictionary<String, Any>
        }

        self.configuration = full
        self.fallback = fallback
    }

    func appealButton(button: GRInputButton) {
        let (image1, image2, image3) = self.images
        //assert(image1 != nil)
        button.tintColor = UIColor.clear
        button.setBackgroundImage(image1, for: .normal)
        button.setBackgroundImage(image2, for: .highlighted)
        button.setBackgroundImage(image3, for: .selected)

        if let glyph = self.glyph {
            assert(button.glyphView.superview == button)
            button.glyphView.image = glyph
            button.setTitle("", for: .normal)
            button.captionLabel.text = ""
            assert(button.glyphView.image != nil)
        } else {
            assert(button.captionLabel.superview == button)
            let (font, color) = self.font
            //println("font: \(font) / color: \(color)")
            if let title = button.title(for: .normal) {
                button.captionLabel.text = title
            }
            if let text = self.text {
                button.captionLabel.text = text
            }
            button.captionLabel.textColor = color
            button.captionLabel.font = font
            //println("caption center: \(button.captionLabel.center) / button center: \(center)")
        }

        button.effectView.backgroundImageView.image = self.effectBackgroundImage
    }

    func arrangeButton(button: GRInputButton) {
        let position = self.position
        //println("pos: \(position)")
        let center = CGPoint(x: button.frame.width / 2 + position.x, y: button.frame.height / 2 + position.y)

        button.glyphView.sizeToFit()
        button.glyphView.center = center
        //println("glyphView: \(button.glyphView.frame)")

        button.captionLabel.sizeToFit()
        button.captionLabel.center = center
        //println("captionlabel: \(button.captionLabel.frame)")

        self.arrangeEffectView(button: button)
    }

    func arrangeEffectView(button: GRInputButton) {
        if button.effectView.superview != button.superview {
            button.superview!.addSubview(button.effectView)
        }

        button.effectView.backgroundImageView.image = self.effectBackgroundImage
        let insets = self.effectEdgeInsets
        var frame = button.frame
        frame.size.height -= self.trait.topMargin
        frame.origin = CGPoint(x: insets.left, y: insets.top)
        button.effectView!.textLabel!.frame = frame

        frame.size.width *= 1.4
        button.effectView.frame = frame
        button.effectView.center = button.center;
        frame = button.effectView.frame
        //* original implementation
        //        CGRect frame = self.effectView.textLabel.frame;
        //        frame.size.height += insets.top + insets.bottom;
        //        frame.size.width += insets.left + insets.right;
        //        frame.origin.x = self.frame.origin.x - insets.left;
        //        frame.origin.y = self.frame.origin.y - frame.size.height;
        //        self.effectView.frame = frame;
//
//        frame.size.height += insets.top + insets.bottom
//        frame.size.width += insets.left + insets.right
//        if button.center.x <= button.superview!.frame.size.width / 2 {
//            frame.origin.x = button.frame.origin.x + button.frame.size.width
//        } else {
//            frame.origin.x = button.frame.origin.x - frame.size.width
//        }
//        frame.origin.y = button.frame.origin.y - insets.top

        let position = self.effectPosition
        frame.origin.x += position.x
        frame.origin.y += position.y

        button.effectView.frame = frame
        button.effectView.backgroundImageView.frame = button.effectView.bounds
    }

    func _images() -> (UIImage?, UIImage?, UIImage?) {
        let imageConfiguration = self.configuration["image"] as! [String]?
        if imageConfiguration == nil || imageConfiguration!.count == 0 {
            return self.fallback.images
        }
        var images: [UIImage?] = []
        for imageName in imageConfiguration! {
            let image = self.trait.owner.imageForFilename(name: imageName, withTopMargin: self.trait.topMargin)
            //assert(image != nil, "캡션 이미지를 찾을 수 없습니다. \(imageName)")
            images.append(image)
        }
        while images.count < 3 {
            let lastImage = images.last!
            //assert(lastImage != nil)
            images.append(lastImage)
        }
        return (images[0], images[1], images[2])
    }

    lazy var images: (UIImage?, UIImage?, UIImage?) = self._images()

    lazy var labelConfiguration: Dictionary<String, Any> = {
        if let sub = self.configuration["label"] as! Dictionary<String, Any>? {
            return sub
        } else {
            return self.fallback.labelConfiguration
        }
    }()

    lazy var text: String? = {
        let subText: Any? = self.labelConfiguration["text"]
        if subText is String {
            return subText as? String
        } else {
            return nil
        }
    }()

    lazy var glyph: UIImage? = {
        let subText: Any? = self.labelConfiguration["glyph"]
        //println("glyph: \(subText)")
        if subText is String {
            let image = self.trait.owner.imageForFilename(name: subText as! String)
            //println("glyph image: \(image)")
            return image
        } else {
            return nil
        }
    }()

    lazy var position: CGPoint = {
        let sub: Any? = self.labelConfiguration["position"]
        if sub is Array<CGFloat> {
            let rawPosition = sub as! Array<CGFloat>
            let position = CGPoint(x: rawPosition[0], y: rawPosition[1])
            return position
        } else {
            return self.fallback.position
        }
    }()

    lazy var font: (UIFont, UIColor) = {
        func fallback() -> (UIFont, UIColor) {
            return self.fallback.font
        }

        let subFont: Any? = self.labelConfiguration["font"]
        if subFont == nil {
            return fallback()
        }

//        println("font1: \(subFont)")
//        println("font2: \(subFont!)")

        assert(subFont is Dictionary<String, Any>, "'font' 설정 값의 서식이 맞지 않습니다. 딕셔너리가 필요합니다.")

        let fontConfiguration = subFont! as! Dictionary<String, Any>
        var font: UIFont?

        let (fallbackFont, fallbackColor) = fallback()

        let subFontName: Any? = fontConfiguration["name"]
        let subFontSize: Any? = fontConfiguration["size"]
        let fontSize = subFontSize as! CGFloat? ?? fallbackFont.pointSize
        if subFontName != nil {
            font = UIFont(name: subFontName as! String, size: fontSize)
        } else {
            font = fallbackFont.withSize(fontSize)
        }
        assert(font != nil, "올바른 폰트 이름이 아닙니다")

        let subFontColorCode: Any? = fontConfiguration["color"]
        var fontColor: UIColor
        if subFontColorCode == nil {
            fontColor = fallbackColor
        } else {
            fontColor = UIColor(htmlExpression: subFontColorCode as! String)
        }
        return (font!, fontColor)
    }()

    lazy var effectConfiguration: Dictionary<String, Any> = {
        if let sub: Any = self.configuration["effect"] {
            //println("effect: \(sub)")
            assert(sub is Dictionary<String, Any>, "'effect' 설정 값의 서식이 맞지 않습니다. 딕셔너리가 필요합니다. 현재 값: \(sub)")
            return sub as! Dictionary<String, Any>
        } else {
            return self.fallback.effectConfiguration
        }
    }()

    lazy var effectBackgroundImage: UIImage? = {
        if let sub: Any = self.effectConfiguration["background"] {
            if let image = self.trait.owner.imageForFilename(name: sub as! String) {
                return image
            }
        }
        return self.fallback.effectBackgroundImage
    }()

    lazy var effectEdgeInsets: UIEdgeInsets = {
        if let rawInsets: [CGFloat] = self.effectConfiguration["padding"] as? [CGFloat] {
            let insets = UIEdgeInsetsMake(rawInsets[0], rawInsets[1], rawInsets[2], rawInsets[3])
            return insets
        }
        return self.fallback.effectEdgeInsets
    }()

    lazy var effectPosition: CGPoint = {
        if let rawPosition: [CGFloat] = self.effectConfiguration["position"] as? [CGFloat] {
            let position = CGPoint(x: rawPosition[0], y: rawPosition[1])
            return position
        }
        return self.fallback.effectPosition
    }()
}

let ThemeDefaultCaptionImage: UIImage? = {
    let URL = Bundle.main.url(forResource: "9patch", withExtension: "png", subdirectory: "default/qwerty")!
    let image = UIImage(contentsOfFile: URL.absoluteString)
    return image
}()

class ThemeDefaultCaptionConfiguration: ThemeCaptionConfiguration {
    init(trait: ThemeTraitConfiguration) {
        super.init(trait: trait, configuration: nil, fallback: nil)
    }

    override var images: (UIImage?, UIImage?, UIImage?) {
        get {
            return (ThemeDefaultCaptionImage, ThemeDefaultCaptionImage, ThemeDefaultCaptionImage)
        }
        set {

        }
    }

    override var labelConfiguration: Dictionary<String, Any> {
        get {
            return [:]
        }
        set {

        }
    }

    override var position: CGPoint {
        get {
            return CGPoint.zero
        }
        set {

        }
    }

    override var font: (UIFont, UIColor) {
        get {
            return (UIFont.systemFont(ofSize: UIFont.systemFontSize), UIColor.black)
        }
        set {

        }
    }

    override var effectConfiguration: Dictionary<String, Any> {
        get {
            return [:]
        }
        set {

        }
    }

    override var effectPosition: CGPoint {
        get {
            return CGPoint.zero
        }
        set {
        }
    }

    override var effectBackgroundImage: UIImage? {
        get {
            let image = self.trait.owner.imageForFilename(name: "effect.png")
            return image
        }
        set {
        }
    }

    override var effectEdgeInsets: UIEdgeInsets {
        get {
            return UIEdgeInsets.zero
        }
        set {
        }
    }
}

class CachedTheme: Theme {
    let theme: Theme
    var _cache: [String: Any?] = [:]

    init(theme: Theme) {
        self.theme = theme
        super.init()
    }

    override func dataForFilename(name: String) -> Data? {
        let key = name + "_"
        if let data = _cache[key] as! Data?? {
            return data
        }
        let data = self.theme.dataForFilename(name: name)
        _cache[key] = data
        return data
    }

    override func imageForFilename(name: String, withTopMargin margin: CGFloat) -> UIImage? {
        let key = name + "_\(margin)"
        if let data = _cache[key] as! UIImage?? {
            return data
        }
        let data = self.theme.imageForFilename(name: name, withTopMargin: margin)
        _cache[key] = data
        return data
    }
}

class ThemeResourceCoder {
    func key() -> NSData {
        let identifier = UIDevice.current.identifierForVendor!
        var UUIDBytes = [UInt8](repeating: 0, count: 16)
        // identifier.getUUIDBytes(&UUIDBytes)  // FIXME: objc wrapper?
        let result = NSData(bytes: UUIDBytes, length: 16)
        return result
    }

    func encodeFromData(data: NSData) -> String {
        let encoded = data.encryptedAES256Data(withKey: self.key() as Data)!
        return encoded.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }

    func decodeToData(data: String) -> NSData {
        let encoded = NSData(base64Encoded: data, options: NSData.Base64DecodingOptions(rawValue: 0))
        return encoded!.decryptedAES256Data(withKey: self.key() as Data?)! as NSData
    }

    class func defaultCoder() -> ThemeResourceCoder {
        return ThemeResourceCoderDefaultCoder
    }
}

let ThemeResourceCoderDefaultCoder = ThemeResourceCoder()
