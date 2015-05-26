//
//  Theme.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 12..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class Theme {
    func dataForFilename(name: String) -> NSData? {
        assert(false)
        return nil
    }

    func JSONObjectForFilename(name: String, error: NSErrorPointer) -> AnyObject! {
        if let data = self.dataForFilename(name) {
            if let result: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: error) {
                return result
            } else {
                let dataString = data.stringUsingUTF8Encoding
                assert(false, "JSON 파일의 서식이 올바르지 않습니다.\(error)\n\(data)\n\(dataString)")
            }
        } else {
            assert(false, "지정한 JSON 데이터 파일이 없습니다. \(name)")
        }
        return nil
    }

    func imageForFilename(name: String) -> UIImage? {
        return self.imageForFilename(name, withTopMargin: 0)
    }

    func imageForFilename(name: String, withTopMargin margin: CGFloat) -> UIImage? {
        let parts = name.componentsSeparatedByString("::")
        let filename = parts[0]

        let data = self.dataForFilename(filename)
        if data == nil {
            return nil
        }

        var image = UIImage(data: data!, scale: 2)
        if image == nil {
            return nil
        }

        if margin != 0 {
            var size = image!.size
            size.height += margin
            UIGraphicsBeginImageContextWithOptions(size, false, 2)
            var rect = CGRectMake(0, margin, size.width, image!.size.height)
            image!.drawInRect(rect)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        if parts.count > 1 {
            let valueStrings = parts[1].componentsSeparatedByString(" ")
            let (s1, s2, s3, s4) = (valueStrings[0], valueStrings[1], valueStrings[2], valueStrings[3])
            let insets = UIEdgeInsetsMake(CGFloat(s1.toInt()!) + margin, CGFloat(s2.toInt()!), CGFloat(s3.toInt()!), CGFloat(s4.toInt()!))
            image = image!.resizableImageWithCapInsets(insets)
        }

        return image
    }

    lazy var mainConfiguration: NSDictionary = {
        var error: NSError? = nil
        let filename = "config.json"
        let JSONObject = self.JSONObjectForFilename(filename, error: &error) as! NSDictionary
        return JSONObject
    }()

    func traitForName(traitName: String, topMargin: CGFloat) -> ThemeTraitConfiguration {
        if let traits = self.mainConfiguration["trait"] as? NSDictionary {
            if let traitFilename = traits[traitName] as? String {
                var error: NSError? = nil
                let traitData: AnyObject! = self.JSONObjectForFilename(traitFilename, error: &error)
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
        case 320.0, 375.0, 414.0:
            return self.phonePortraitConfiguration
        case 480.0:
            return self.phoneLandscape480Configuration
        case 568.0, 667.0:
            return self.phoneLandscape568Configuration
        case 768.0:
            return self.padPortraitConfiguration
        case 1024.0:
            return self.padLandscapeConfiguration
        default:
            globalInputViewController?.log("unknown size: \(size)")
            //assert(false, "no coverage")
            return self.phonePortraitConfiguration
        }
    }

    lazy var phonePortraitConfiguration: ThemeTraitConfiguration = self.traitForName("phone-portrait", topMargin: 6)
    lazy var phoneLandscape480Configuration: ThemeTraitConfiguration = self.traitForName("phone-landscape480", topMargin: 3)
    lazy var phoneLandscape568Configuration: ThemeTraitConfiguration = self.traitForName("phone-landscape568", topMargin: 3)
    lazy var padPortraitConfiguration: ThemeTraitConfiguration = self.phonePortraitConfiguration
    lazy var padLandscapeConfiguration: ThemeTraitConfiguration = self.phoneLandscape480Configuration
}

class ThemeTraitConfiguration {
    let configuration: NSDictionary!
    let owner: Theme
    let topMargin: CGFloat
    var _captions: Dictionary<String, ThemeCaptionConfiguration> = [:]

    init(owner: Theme, configuration: AnyObject?, topMargin: CGFloat) {
        self.owner = owner
        self.topMargin = topMargin
        self.configuration = configuration as? NSDictionary
    }

    lazy var backgroundImage: UIImage? = {
        let configFilename = self.configuration["background"] as? String
        let filename = configFilename ?? "background.png"
        return self.owner.imageForFilename(filename)
    }()

    lazy var foregroundImage: UIImage? = {
        let configFilename = self.configuration["foreground"] as? String
        let filename = configFilename ?? "foreground.png"
        return self.owner.imageForFilename(filename)
    }()

    func captionForKey(key: String, needsMargin: Bool, fallback: ThemeCaptionConfiguration) -> ThemeCaptionConfiguration {
        if let theme = self._captions[key] {
            return theme
        } else {
            let theme: ThemeCaptionConfiguration = {
                if let sub: AnyObject = self.configuration[key] {
                    return ThemeCaptionConfiguration(trait: self, configuration: sub, needsMargin: needsMargin, fallback: fallback)
                } else {
                    return fallback
                }
            }()
            self._captions[key] = theme
            return theme
        }
    }

    func qwertyCaptionForKey(key: String, fallback: ThemeCaptionConfiguration) -> ThemeCaptionConfiguration {
        let newKey = "qwerty-" + key
        return captionForKey(newKey, needsMargin: true, fallback: fallback)
    }

    lazy var defaultCaption: ThemeCaptionConfiguration = ThemeDefaultCaptionConfiguration(trait: self)
    lazy var qwertyCaption: ThemeCaptionConfiguration = self.captionForKey("qwerty", needsMargin: true, fallback: self.defaultCaption)
    func qwertyCaptionForKeyInRow(row: Int) -> ThemeCaptionConfiguration {
        return self.qwertyCaptionForKey("row\(row)", fallback: self.qwertyCaption)
    }

    lazy var qwertyKeyCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("key", fallback: self.qwertyCaption)
    lazy var qwertySpecialKeyCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("special", fallback: self.qwertyKeyCaption)
    lazy var qwertyFunctionCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("function", fallback: self.qwertyCaption)

    /*
    lazy var qwerty1xCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("1x", fallback: self.qwertyKeyCaption)
    lazy var qwerty1_25xCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("1.25x", fallback: self.qwertyFunctionCaption)
    lazy var qwerty1_5xCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("1.5x", fallback: self.qwertyFunctionCaption)
    lazy var qwerty3xCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("3x", fallback: self.qwertyFunctionCaption)
    lazy var qwerty5xCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("5x", fallback: self.qwertyFunctionCaption)
    */

    lazy var qwertyShiftCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("shift", fallback: self.qwertyFunctionCaption)
    lazy var qwertyDeleteCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("delete", fallback: self.qwertyFunctionCaption)
    lazy var qwertyToggleCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("toggle", fallback: self.qwertyFunctionCaption)
    lazy var qwertyGlobeCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("globe", fallback: self.qwertyFunctionCaption)
    lazy var qwertySpaceCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("space", fallback: self.qwertySpecialKeyCaption)
    lazy var qwertyDoneCaption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("done", fallback: self.qwertyFunctionCaption)

    func tenkeyCaptionForKey(key: String, fallback: ThemeCaptionConfiguration) -> ThemeCaptionConfiguration {
        let newKey = "tenkey-" + key
        return captionForKey(newKey, needsMargin: true, fallback: fallback)
    }

    lazy var tenkeyCaption: ThemeCaptionConfiguration = self.captionForKey("tenkey", needsMargin: false, fallback: self.defaultCaption)
    func tenkeyCaptionForKeyInRow(row: Int) -> ThemeCaptionConfiguration {
        return self.captionForKey("tenkey-row\(row)", needsMargin: false, fallback: self.tenkeyCaption)
    }
    lazy var tenkeyKeyCaption: ThemeCaptionConfiguration = self.tenkeyCaptionForKey("key", fallback: self.tenkeyCaption)
    lazy var tenkeySpecialKeyCaption: ThemeCaptionConfiguration = self.tenkeyCaptionForKey("special", fallback: self.tenkeyKeyCaption)
    lazy var tenkeyFunctionCaption: ThemeCaptionConfiguration = self.tenkeyCaptionForKey("function", fallback: self.tenkeyCaption)

    lazy var tenkeyShiftCaption: ThemeCaptionConfiguration = self.tenkeyCaptionForKey("shift", fallback: self.tenkeyCaptionForKeyInRow(2))
    lazy var tenkeyDeleteCaption: ThemeCaptionConfiguration = self.tenkeyCaptionForKey("delete", fallback: self.tenkeyCaptionForKeyInRow(1))
    lazy var tenkeyToggleCaption: ThemeCaptionConfiguration = self.tenkeyCaptionForKey("toggle", fallback: self.tenkeyCaptionForKeyInRow(1))
    lazy var tenkeyAbcCaption: ThemeCaptionConfiguration = self.tenkeyCaptionForKey("abc", fallback: self.tenkeyCaptionForKeyInRow(2))
    lazy var tenkeyHangeulCaption: ThemeCaptionConfiguration = self.tenkeyCaptionForKey("hangeul", fallback: self.tenkeyCaptionForKeyInRow(3))
    lazy var tenkeyGlobeCaption: ThemeCaptionConfiguration = self.tenkeyCaptionForKey("globe", fallback: self.tenkeyCaptionForKeyInRow(4))
    lazy var tenkeySpaceCaption: ThemeCaptionConfiguration = self.tenkeyCaptionForKey("space", fallback: self.tenkeyCaptionForKeyInRow(4))
    lazy var tenkeyDoneCaption: ThemeCaptionConfiguration = self.tenkeyCaptionForKey("done", fallback: self.tenkeyCaptionForKeyInRow(3))

}


class ThemeCaptionConfiguration {
    let configuration: [String: AnyObject]
    let needsMargin: Bool
    let fallback: ThemeCaptionConfiguration!
    let trait: ThemeTraitConfiguration
    lazy var topMargin: CGFloat = { return self.needsMargin ? self.trait.topMargin : 0 }()

    init(trait: ThemeTraitConfiguration, configuration: AnyObject?, needsMargin: Bool, fallback: ThemeCaptionConfiguration!) {
        self.trait = trait
        self.needsMargin = needsMargin

        var given: AnyObject = configuration ?? Dictionary<String, AnyObject>()

        var full: [String: AnyObject] = [
            "image": Array<String>(),
            "label": Dictionary<String, AnyObject>(),
        ]

        if given is String {
            var sub: AnyObject? = full["image"]
            var image = sub as! Array<NSString>
            image.append(given as! NSString)
        }
        else if given is Array<String!> {
            full["image"] = configuration
            var sub: AnyObject? = full["image"]
            var image = sub as! Array<NSString>
        }
        else {
            full = given as! Dictionary<String, AnyObject>
        }

        self.configuration = full
        self.fallback = fallback
    }

    func appealButton(button: GRInputButton) {
        let (image1, image2, image3) = self.images
        //assert(image1 != nil)
        button.tintColor = UIColor.clearColor()
        button.setBackgroundImage(image1, forState: .Normal)
        button.setBackgroundImage(image2, forState: .Highlighted)
        button.setBackgroundImage(image3, forState: .Selected)

        if let glyph = self.glyph {
            assert(button.glyphView.superview == button)
            button.glyphView.image = glyph
            button.setTitle("", forState: .Normal)
            button.captionLabel.text = ""
            assert(button.glyphView.image != nil)
        } else {
            assert(button.captionLabel.superview == button)
            let (font, color) = self.font
            //println("font: \(font) / color: \(color)")
            if let title = button.titleForState(.Normal) {
                button.captionLabel.text = title
            }
            if let text = self.text {
                button.captionLabel.text = text
            }
            button.captionLabel.textColor = color
            button.captionLabel.font = font
            //println("caption center: \(button.captionLabel.center) / button center: \(center)")
        }

        button.effectBackgroundImage = self.effectBackgroundImage
    }

    func arrangeButton(button: GRInputButton) {
        let position = self.position
        //println("pos: \(position)")
        let center = CGPointMake(button.frame.width / 2 + position.x, button.frame.height / 2 + position.y)

        button.glyphView.sizeToFit()
        button.glyphView.center = center
        //println("glyphView: \(button.glyphView.frame)")

        button.captionLabel.sizeToFit()
        button.captionLabel.center = center
        //println("captionlabel: \(button.captionLabel.frame)")

        self.arrangeEffectView(button)
    }

    func arrangeEffectView(button: GRInputButton) {
        if button.effectView.superview != button.superview {
            button.superview!.addSubview(button.effectView)
        }

        button.effectView.backgroundImageView.image = self.effectBackgroundImage
        let insets = self.effectEdgeInsets
        var frame = button.frame
        frame.size.height -= self.topMargin
        frame.origin = CGPointMake(insets.left, insets.top)
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
        frame.origin.y += position.y + self.topMargin / 2

        button.effectView.frame = frame
        button.arrange()
    }

    func _images() -> (UIImage?, UIImage?, UIImage?) {
        let sub: AnyObject? = self.configuration["image"]
        let imageConfiguration = sub as? Array<String!>
        if imageConfiguration == nil || imageConfiguration!.count == 0 {
            return self.fallback.images
        }
        var images: [UIImage?] = []
        for imageName in imageConfiguration! {
            let image = self.trait.owner.imageForFilename(imageName, withTopMargin: self.topMargin)
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

    lazy var labelConfiguration: Dictionary<String, AnyObject> = {
        if let sub = self.configuration["label"] as? Dictionary<String, AnyObject> {
            return sub
        } else {
            return self.fallback.labelConfiguration
        }
    }()

    lazy var text: String? = {
        let subText: AnyObject? = self.labelConfiguration["text"]
        if subText is String {
            return subText as? String
        } else {
            return nil
        }
    }()

    lazy var glyph: UIImage? = {
        let subText: AnyObject? = self.labelConfiguration["glyph"]
        //println("glyph: \(subText)")
        if subText is String {
            let image = self.trait.owner.imageForFilename(subText as! String)
            //println("glyph image: \(image)")
            return image
        } else {
            return nil
        }
    }()

    lazy var position: CGPoint = {
        let sub: AnyObject? = self.labelConfiguration["position"]
        if sub is Array<CGFloat> {
            let rawPosition = sub as! Array<CGFloat>
            let position = CGPointMake(rawPosition[0], rawPosition[1])
            return position
        } else {
            return self.fallback.position
        }
    }()

    lazy var font: (UIFont, UIColor) = {
        func fallback() -> (UIFont, UIColor) {
            return self.fallback.font
        }

        let subFont: AnyObject? = self.labelConfiguration["font"]
        if subFont == nil {
            return fallback()
        }

//        println("font1: \(subFont)")
//        println("font2: \(subFont!)")

        assert(subFont is Dictionary<String, AnyObject>, "'font' 설정 값의 서식이 맞지 않습니다. 딕셔너리가 필요합니다.")

        let fontConfiguration = subFont as! Dictionary<String, AnyObject>
        var font: UIFont?

        let (fallbackFont, fallbackColor) = fallback()

        let subFontName = fontConfiguration["name"] as? String
        let subFontSize = fontConfiguration["size"] as? CGFloat
        let fontSize = subFontSize ?? fallbackFont.pointSize
        if subFontName != nil {
            font = UIFont(name: subFontName!, size: fontSize)
        } else {
            font = fallbackFont.fontWithSize(fontSize)
        }
        assert(font != nil, "올바른 폰트 이름이 아닙니다")

        var fontColor: UIColor
        if let subFontColorCode = fontConfiguration["color"] as? String {
            fontColor = UIColor(HTMLExpression: subFontColorCode)
        } else {
            fontColor = fallbackColor
        }
        return (font!, fontColor)
    }()

    lazy var effectConfiguration: Dictionary<String, AnyObject> = {
        if let sub: AnyObject = self.configuration["effect"] {
            //println("effect: \(sub)")
            assert(sub is Dictionary<String, AnyObject>, "'effect' 설정 값의 서식이 맞지 않습니다. 딕셔너리가 필요합니다. 현재 값: \(sub)")
            return sub as! Dictionary<String, AnyObject>
        } else {
            return self.fallback.effectConfiguration
        }
    }()

    lazy var effectBackgroundImage: UIImage? = {
        if let sub = self.effectConfiguration["background"] as? String {
            if let image = self.trait.owner.imageForFilename(sub) {
                return image
            }
        }
        return self.fallback.effectBackgroundImage
    }()

    lazy var effectEdgeInsets: UIEdgeInsets = {
        if let rawInsets = self.effectConfiguration["padding"] as? Array<CGFloat> {
            let insets = UIEdgeInsetsMake(rawInsets[0], rawInsets[1], rawInsets[2], rawInsets[3])
            return insets
        }
        return self.fallback.effectEdgeInsets
    }()

    lazy var effectPosition: CGPoint = {
        if let rawPosition = self.effectConfiguration["position"] as? Array<CGFloat> {
            let position = CGPointMake(rawPosition[0], rawPosition[1])
            return position
        }
        return self.fallback.effectPosition
    }()
}

let ThemeDefaultCaptionImage: UIImage? = {
    let URL = NSBundle.mainBundle().URLForResource("9patch", withExtension: "png", subdirectory: "default/qwerty")!
    let image = UIImage(contentsOfFile: URL.absoluteString!)
    return image
}()

class ThemeDefaultCaptionConfiguration: ThemeCaptionConfiguration {
    init(trait: ThemeTraitConfiguration) {
        super.init(trait: trait, configuration: nil, needsMargin: true, fallback: nil)
    }

    override var images: (UIImage?, UIImage?, UIImage?) {
        get {
            return (ThemeDefaultCaptionImage, ThemeDefaultCaptionImage, ThemeDefaultCaptionImage)
        }
        set {

        }
    }

    override var labelConfiguration: Dictionary<String, AnyObject> {
        get {
            return [:]
        }
        set {

        }
    }

    override var position: CGPoint {
        get {
            return CGPointZero
        }
        set {

        }
    }

    override var font: (UIFont, UIColor) {
        get {
            return (UIFont.systemFontOfSize(UIFont.systemFontSize()), UIColor.blackColor())
        }
        set {

        }
    }

    override var effectConfiguration: Dictionary<String, AnyObject> {
        get {
            return [:]
        }
        set {

        }
    }

    override var effectPosition: CGPoint {
        get {
            return CGPointZero
        }
        set {
        }
    }

    override var effectBackgroundImage: UIImage? {
        get {
            let image = self.trait.owner.imageForFilename("effect.png")
            return image
        }
        set {
        }
    }

    override var effectEdgeInsets: UIEdgeInsets {
        get {
            return UIEdgeInsetsZero
        }
        set {
        }
    }
}

class CachedTheme: Theme {
    let theme: Theme
    var _cache: [String: AnyObject?] = [:]

    init(theme: Theme) {
        self.theme = theme
        super.init()
    }

    override func dataForFilename(name: String) -> NSData? {
        let key = name + "_"
        if let data = _cache[key] as? NSData? {
            return data
        }
        let data = self.theme.dataForFilename(name)
        _cache[key] = data
        return data
    }

    override func imageForFilename(name: String, withTopMargin margin: CGFloat) -> UIImage? {
        let key = name + "_\(margin)"
        if let data = _cache[key] as? UIImage? {
            return data
        }
        let data = self.theme.imageForFilename(name, withTopMargin: margin)
        _cache[key] = data
        return data
    }
}

class BuiltInTheme: Theme {
    override func dataForFilename(name: String) -> NSData? {
        if let dataString: String = {
            switch name {
                case "landscape.json": return "ewogICAgIm5hbWUiOiAiYmx1ZXB1cnBsZSIsCgogICAgImJsdXIiOiBmYWxzZSwKICAgICJiYWNrZ3JvdW5kIjogImJnLnBuZyIsCiAgICAiZm9yZWdyb3VuZCI6ICJmb3JlZ3JvdW5kLnBuZyIsCgogICAgInF3ZXJ0eSI6IHsKICAgICAgICAiaW1hZ2UiOiBbInF3ZXJ0eS85cGF0Y2gucG5nOjoxMCAxMCAxMCAxMCIsICJxd2VydHkvc2VsZWN0ZWQucG5nOjoxMCAxMCAxMCAxMCJdLAogICAgICAgICJsYWJlbCI6IHsKICAgICAgICAgICAgImZvbnQiOiB7CiAgICAgICAgICAgICAgICAibmFtZSI6ICJBdmVuaXIgTGlnaHQiLAogICAgICAgICAgICAgICAgInNpemUiOiAxNSwKICAgICAgICAgICAgICAgICJjb2xvciI6ICIjZmZmIiwKICAgICAgICAgICAgfSwKICAgICAgICAgICAgInRleHQiOiBudWxsLAogICAgICAgICAgICAicG9zaXRpb24iOiBbMCwgMl0KICAgICAgICB9LAogICAgfSwKICAgICJxd2VydHktc2hpZnQiOiB7CiAgICAgICJsYWJlbCI6eyJnbHlwaCI6InF3ZXJ0eS1nbHlwaC80OHB4LXNoaWZ0LnBuZyIsfSx9LAogICAgInF3ZXJ0eS1nbG9iZSI6IHsKICAgICAgImxhYmVsIjp7ImdseXBoIjoicXdlcnR5LWdseXBoLzQwcHgtZ2xvYmUucG5nIix9LH0sCiAgICAicXdlcnR5LWRlbGV0ZSI6IHsKICAgICAgImxhYmVsIjp7ImdseXBoIjoicXdlcnR5LWdseXBoLzQ4cHgtZGVsZXRlLnBuZyIsfSx9LAoKICAgICJ0ZW5rZXkiOiB7CiAgICAgICAgImltYWdlIjogWyJxd2VydHkvOXBhdGNoLnBuZzo6MTAgMTAgMTAgMTAiLCAicXdlcnR5L3NlbGVjdGVkLnBuZzo6MTAgMTAgMTAgMTAiXSwKICAgICAgICAibGFiZWwiOiB7CiAgICAgICAgICAgICJmb250IjogewogICAgICAgICAgICAgICAgIm5hbWUiOiAiQXZlbmlyIExpZ2h0IiwKICAgICAgICAgICAgICAgICJzaXplIjogMTYsCiAgICAgICAgICAgICAgICAiY29sb3IiOiAiI2ZmZiIsCiAgICAgICAgICAgIH0sCiAgICAgICAgICAgICJ0ZXh0IjogbnVsbCwKICAgICAgICAgICAgInBvc2l0aW9uIjogWzAsIDBdLAogICAgICAgIH0sCiAgICB9LAogICAgInRlbmtleS1zaGlmdCI6IHsKICAgICAgImxhYmVsIjp7ImdseXBoIjoicXdlcnR5LWdseXBoLzQ4cHgtc2hpZnQucG5nIix9LH0sCiAgICAidGVua2V5LWdsb2JlIjogewogICAgICAibGFiZWwiOnsiZ2x5cGgiOiJxd2VydHktZ2x5cGgvNDBweC1nbG9iZS5wbmciLH0sfSwKICAgICJ0ZW5rZXktZGVsZXRlIjogewogICAgICAibGFiZWwiOnsiZ2x5cGgiOiJxd2VydHktZ2x5cGgvNDhweC1kZWxldGUucG5nIix9LH0KfQ=="
                case "config.json": return "ewogICAgIm5hbWUiOiAiYmx1ZXB1cnBsZSIsCgogICAgImJsdXIiOiBmYWxzZSwKCiAgICAidHJhaXQiOiB7CiAgICAgICAgInBob25lLXBvcnRyYWl0IjogInBvcnRyYWl0Lmpzb24iLAogICAgICAgICJwaG9uZS1sYW5kc2NhcGU0ODAiOiAibGFuZHNjYXBlLmpzb24iLAogICAgICAgICJwaG9uZS1sYW5kc2NhcGU1NjgiOiAibGFuZHNjYXBlLmpzb24iLAogICAgfSwKfQo="
                case "qwerty-glyph/48px-delete.png": return "iVBORw0KGgoAAAANSUhEUgAAAGAAAABcCAYAAACRILDuAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RUU4ODUzMzMzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RUU4ODUzMzIzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDoyMTMxZGQ1ZS1kOTQ1LTRlODUtYTAzZi1iZDlhYzY5OGQwMTQiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6ZDNiNzllZDgtYjJiNi00ZmY0LWIyMzgtZmY1MWU4NjlmNTY5Ii8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+vBAWgAAAA4hJREFUeNrsm1uITVEYx9dx64TpiFKKIcWT5GVcUi55QS4pvKGI4sXtYaKTcRskprwYSbm9iYdBeJHJgzLjhTfjBUme1CAmlzn+X+s7OZ3OZW+z99r7zPr/698+D2f22uf77b2+b317TaZQKBgqOY1gCAiAACgCIACKAAiAIgACoAiAACgCIACKAAiAIgACoAiAACgCIACKAAiAIgACoAiAACgCIAAqGo1K+fWNg7fAi+CJEZ/7F/wB7oHvwl+S+IGZFG9Pl4CfhKc5GOs7fAF+RgBWUzT4k+G38Dn4XcRjZOHZ8Dp4ASyBOOMaQhoBTIeP6xPwGj4Kf4t5zM061cmTsAvu9zUJyx15WoP/Es47CL7oluaCsfB6X6uguTrtNMHP4WPwgMPxu/TY4mMVNB9uhcfATzQh/nF8DX16nOobgKXwPr2WB/AlTYg1c1eA74TVQBIxSXoKWgUf1B8t83BngMDO06ooF2Ic+W47PJMr4X/aCO/Wz9fgm0GqNnirJuv2gBBymlskx+wgAKttarnbL8J3Av5dQZPzey1X60EoBn+GrifO+g4go3e93P2/4fPwo5DnkBr9cAmEU1UglAc/77K+TyOAkfABeDX8UwP39D/PVQqhuQKEhgi+SwCSZA/By+AfurrtHeI5q0FomOC7bEXs1J7LV7gNfhPhuXMa/GaFMTiE4N/T49rh9gSs0OORiINf6UloiDs/qSQc5+M2mNIWSyoAPNbjCXhWxOcun/OrJWavAVw1ttvYpMGaE1Pw83WqI28BSM0vbeZuY1u+sphqiSH4/QFKVG9zgEDogB8a2/WUIC2JOPhB1wleJ2FpPdzWtYE04lZGHPyGgpBUtXBdLa2JPfCGEH/bGqLULIfQpmN6D8DoU9Cpn7cb+042iK7Ar0LU+UUIsv64EXMpnNqVcC1Je2KvTkn34csxBSnIS5xhuxKupW6tkKRBtwbeH9N11Qt+Vo8u30OnZsXYo6WpNOqWG9u4G+34GooLxE8+AjAl87o07BYa2zfKOhy/uB2l11cAoj69+z8b++5Xys3xDsbdZOzuONmY1eVbEq6k8q2JHXqM8mK5NbGOJhnbvOPm3ARV3J6+GJ4Q8bml2vkIv9Bph9vTfRT/Q4YACIAiAAKgCIAAKAIgAIoACIAiAAKgCIAAKAIgAIoACIAiAAKgCIAAKAIgAIoACIAiAAKgItJfAQYAc6veXhys0t0AAAAASUVORK5CYII="
                case "qwerty/selected.png": return "iVBORw0KGgoAAAANSUhEUgAAAEAAAABcCAYAAADefbM+AAAAAXNSR0IArs4c6QAABIJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iCiAgICAgICAgICAgIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIKICAgICAgICAgICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIj4KICAgICAgICAgPHhtcE1NOkRlcml2ZWRGcm9tIHJkZjpwYXJzZVR5cGU9IlJlc291cmNlIj4KICAgICAgICAgICAgPHN0UmVmOmluc3RhbmNlSUQ+eG1wLmlpZDpBRjU1M0U4QjVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMDwvc3RSZWY6aW5zdGFuY2VJRD4KICAgICAgICAgICAgPHN0UmVmOmRvY3VtZW50SUQ+eG1wLmRpZDpBRjU1M0U4QzVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMDwvc3RSZWY6ZG9jdW1lbnRJRD4KICAgICAgICAgPC94bXBNTTpEZXJpdmVkRnJvbT4KICAgICAgICAgPHhtcE1NOkRvY3VtZW50SUQ+eG1wLmRpZDozNTdDNDRENzVBQjIxMUU0QTBGMDk4MEZFQkM2RTUxMDwveG1wTU06RG9jdW1lbnRJRD4KICAgICAgICAgPHhtcE1NOkluc3RhbmNlSUQ+eG1wLmlpZDozNTdDNDRENjVBQjIxMUU0QTBGMDk4MEZFQkM2RTUxMDwveG1wTU06SW5zdGFuY2VJRD4KICAgICAgICAgPHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD54bXAuZGlkOmQzYjc5ZWQ4LWIyYjYtNGZmNC1iMjM4LWZmNTFlODY5ZjU2OTwveG1wTU06T3JpZ2luYWxEb2N1bWVudElEPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICAgICA8eG1wOkNyZWF0b3JUb29sPkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE0IChNYWNpbnRvc2gpPC94bXA6Q3JlYXRvclRvb2w+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgqky3wlAAACp0lEQVR4Ae2czVLCQBCEjWX5c9EL3tQT7/9Qyg0u6kG9iPORDKaAXTJUYZGxp2qTkPQu0z29cMqcnSmkgBSQAlJACkiB/6pAM5T4crm8NuzExp2NKxuD5xr2L2JpX/Jl49XGommazyFfupeEEQfzaON+yIInhJlbLjMT4ruW03ntYUd+ahgnv7DrGxvVebU1j/iMnMiNHAlynnYcVjd2HaoOsMlP3UJY69YG5zEEW5StwLadmwueS0kXK2nkUZM9T4yJPPlSKH6riEnHpf20cSwKwEQbOARLjaXyluo6yJnc4eCFXD/0i5oAVJ14aE+jPHruzmWLRE0A9hExxuq3mf/m7lz8/vpcE8B/IPl/HWt47s5li0dNgC1wxhsSIGNVI5zkgIhaGbFyQMaqRjjJARG1MmLlgIxVjXCSAyJqZcTKARmrGuEkB0TUyoiVAzJWNcJJDoiolRErB2SsaoSTHBBRKyNWDshY1QgnOSCiVkasHJCxqhFOckBErYxYOSBjVSOc5ICIWhmxckDGqkY4yQERtTJi5YCMVY1wkgMiamXEygEZqxrhJAdE1MqIlQMyVjXCSQ6IqJURKwdkrGqEkxwQUSsjVg7IWNUIp4sKmPdu/Z1bfwe3Aj/4kX/HwQtUJuJwWmgU22jUBOCtcTowEIe8QV4i1r/f34L96z6mzaA9lu73Mf3rS/tAM5Vi/jUB3mwiAtCEoNiAwJ6dcswsOXJ/LyXZV30TA3GszwLF9+83J53QZ3ImdzjAZWcUBbDGIx82wyfihjGJQK40USHoKQSXnVEUoEO/2NnJs4/ozcO2iO5Fm3L0gMuqa4yd/fcL68OhGHuJdH140jZS2iuAS9drq0NDEiw2eK6vceQzf3VUnqpXbX/kPLS8FJACUkAKSAEpMBIFfgD3ZVq7JjnsZQAAAABJRU5ErkJggg=="
                case "qwerty-glyph/48px-shift.png": return "iVBORw0KGgoAAAANSUhEUgAAAGAAAABcCAYAAACRILDuAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RUU4ODUzMkYzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RUU4ODUzMkUzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDoyMTMxZGQ1ZS1kOTQ1LTRlODUtYTAzZi1iZDlhYzY5OGQwMTQiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6ZDNiNzllZDgtYjJiNi00ZmY0LWIyMzgtZmY1MWU4NjlmNTY5Ii8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+xI/AxwAAAiFJREFUeNrs2ktKw1AYhuH0IGIVFXWoAy8DLzMX4hbcgeJAkKaIrRV04CrcgvtQN+DEC9oqVvE6i3/IKRyKlDQk5pz0/eDHim0j35MT2iSlIAg8kl8UFQAAAAEAAAIAAAQAAAgAABAAACAAAEAAAIAAAAABAAACAAAEAAAIAAAQAAAg6WTI0f97RGZPZljmWObDVYCSg7enh+XXZdb079cy+zLvHIKyT9kovyVzL7Mk05AZByD78mtG+b6eDsKRiwjK0T2/ItOUedEIdzKLLiK4ADCqy181ym8Zfw8Rqq4iKAfKr/Uo30RwciWoApTfSdtFBFWQ8rsRbg2ECQD6y5hRfrOP8k2EqoHQsBlBWVj+gVG+32f5zq0EVaA9vzuvBsKCRpgEoHf5KzKPuvynFN63G6FhG4KypPy6Ub6fUvlOIChLyl9Oec//C6Fi4+FIWVb+c4bbe9PbuJGZtwVB5Vj+oS7/4R/KNxF8mxDyuh4Qlr8e87kbCbdxHvN54fWEnUFbAV8WfRD5yXPjeV2SPElxD85qBQ3sqYiBCgAAAEAAAIAAAIBt6XxZm07w2ikbvmS5DnClf24ZhcbJjMy2fnxhO4DN94bOyZx60Ym7JPmU2fWiuyQASJhZmU0vOnFXjvmab5lLmTMvum2RFUD4FAQAAQAAAgAABAAACAAAEAAAIAAAAAABAAACAAAEAAAIAAAQAAAgAABAAACAAFD0/AowABgBfyeImBesAAAAAElFTkSuQmCC"
                case "qwerty-glyph/40px-globe.png": return "iVBORw0KGgoAAAANSUhEUgAAAFAAAABcCAYAAAD50zLWAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RUU4ODUzMzczQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RUU4ODUzMzYzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDoyMTMxZGQ1ZS1kOTQ1LTRlODUtYTAzZi1iZDlhYzY5OGQwMTQiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6ZDNiNzllZDgtYjJiNi00ZmY0LWIyMzgtZmY1MWU4NjlmNTY5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"
                case "bg.png": return "iVBORw0KGgoAAAANSUhEUgAAABIAAAGwCAYAAACkbTUGAAAAAXNSR0IArs4c6QAABBdpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iCiAgICAgICAgICAgIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIgogICAgICAgICAgICB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIj4KICAgICAgICAgPHhtcE1NOkRlcml2ZWRGcm9tIHJkZjpwYXJzZVR5cGU9IlJlc291cmNlIj4KICAgICAgICAgICAgPHN0UmVmOmluc3RhbmNlSUQ+eG1wLmlpZDpENDVCN0E4ODQzM0ExMUU0QTAwNTk2MEVERTEzMzYzODwvc3RSZWY6aW5zdGFuY2VJRD4KICAgICAgICAgICAgPHN0UmVmOmRvY3VtZW50SUQ+eG1wLmRpZDpENDVCN0E4OTQzM0ExMUU0QTAwNTk2MEVERTEzMzYzODwvc3RSZWY6ZG9jdW1lbnRJRD4KICAgICAgICAgPC94bXBNTTpEZXJpdmVkRnJvbT4KICAgICAgICAgPHhtcE1NOkRvY3VtZW50SUQ+eG1wLmRpZDpENDVCN0E4QjQzM0ExMUU0QTAwNTk2MEVERTEzMzYzODwveG1wTU06RG9jdW1lbnRJRD4KICAgICAgICAgPHhtcE1NOkluc3RhbmNlSUQ+eG1wLmlpZDpENDVCN0E4QTQzM0ExMUU0QTAwNTk2MEVERTEzMzYzODwveG1wTU06SW5zdGFuY2VJRD4KICAgICAgICAgPHhtcDpDcmVhdG9yVG9vbD5BZG9iZSBQaG90b3Nob3AgQ0MgMjAxNCAoTWFjaW50b3NoKTwveG1wOkNyZWF0b3JUb29sPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KGWPlJAAAAjVJREFUeAHtnMFtxDAMBJ3ABaeh9JJqUsY5QhpYPwbCHj35nkBIs0uK0uny8fX983sAf59AjP8QBsokZZQZncdx5VE3Rgg7Qzoh1oewM2wZbWRkGdkKmynZlpEsmoxuMFrZ/7oxLA+xZmdG52X2J0r6KBE6LGwZ0WHDniENzjW72o3ym2tbYUNXEYOzv29ppkhOEWt2ZlTobA81UTadHREVHmqs2Vk1nZ0ZFdZs6NKvMmltj5Ml+wzZNyMLW3LR6HvIvqt6DflsQ0LbGrdla0gNmQnkEX17vzPaqBp2yl71yKcMQTidHQCtj1frxzzTEHaGPZjRKmz6KDhgsPzY0vRRMNH6GIM9OBB2XsM6tsGw+5aGyY8t7Xwx/brZnwskx6jPR5ghDZSNhDHq85H72qPlB53NnPu4mo0trS/QKiNMF9G4NH2UKlKfan0zcl9LLgIvEPraGsyQ+ij7aLD8+ijLDzKC3ntgM+oL1PdGq5CR/yQoZi2m2uAN0n0t2og7ruujjbCx7DfQRtWsRxthY84+L+aujiy19tnJSZj8fYH6dtpV2Jgc6YPtjFKmrcenUDniKqSqZdUGM8IMacf2aB/1pYjv/DVkJpBHFDrbXx5E2fpUGzwjbO/HupHBsF1aTP7C09FyNvPaS/nfUf7BqmHFH2PkwwFTJBPIIzBDYoH6cg1bmoHe0ZCDVRucayf0HVRhnz3YkC5tY4Vc2e/3tIG3tzUB0PrYpJVRJpBH6KONjAZfIPwBP9pfQqNvDDYAAAAASUVORK5CYII="
                case "qwerty/9patch.png": return "iVBORw0KGgoAAAANSUhEUgAAAEAAAABcCAYAAADefbM+AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3BpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MzU3QzQ0RDc1QUIyMTFFNEEwRjA5ODBGRUJDNkU1MTAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MzU3QzQ0RDY1QUIyMTFFNEEwRjA5ODBGRUJDNkU1MTAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpBRjU1M0U4QjVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpBRjU1M0U4QzVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PkQfRdkAAAGOSURBVHja7Nw9T8NADIDhpgyhS1lSNkBCLPD/fwsMiIGPiXahGUKXBFtyxOmkEC5FIta9lqxTq/YUP/GlU110XbfIOQoAAAAAAAAAAOA3cSpZSZ5JlvrdmdWihRwkPyR3kp9/BaCFXkhunN3creSbZHsMgBZ/I7m21zvLZmzjf4il5Mq6tLL3aslH645JAJd257W1nqxwD6EQ13ZstRNepgDoJrfWBfeOig+v/87u/sPQ9f8EoOf+3Fr+2elD/sqOw7vk69C5GYp18DDxGtuoliSA0tbGMUAT1ZIEUAS/r16ji2pJAsgiAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADIAWD0f7cO4sTWdgrAwdaVY4AyqiUJYG/rxjFAf+310AcYocEQlbQxOrpZP0ZnboMVlovvYU9h6x81RqdHyHaQUtxWlXXDHEdptXZU66BLR4NhagAAAAAAAACQb3wJMADud5NNwQEygAAAAABJRU5ErkJggg=="
                case "portrait.json": return "ewogICAgIm5hbWUiOiAiYmx1ZXB1cnBsZSIsCgogICAgImJsdXIiOiBmYWxzZSwKICAgICJiYWNrZ3JvdW5kIjogImJnLnBuZyIsCiAgICAiZm9yZWdyb3VuZCI6ICJmb3JlZ3JvdW5kLnBuZyIsCgogICAgInF3ZXJ0eSI6IHsKICAgICAgICAiaW1hZ2UiOiBbInF3ZXJ0eS85cGF0Y2gucG5nOjoxMCAxMCAxMCAxMCIsICJxd2VydHkvc2VsZWN0ZWQucG5nOjoxMCAxMCAxMCAxMCJdLAogICAgICAgICJsYWJlbCI6IHsKICAgICAgICAgICAgImZvbnQiOiB7CiAgICAgICAgICAgICAgICAibmFtZSI6ICJBdmVuaXIgTGlnaHQiLAogICAgICAgICAgICAgICAgInNpemUiOiAxNSwKICAgICAgICAgICAgICAgICJjb2xvciI6ICIjZmZmIiwKICAgICAgICAgICAgfSwKICAgICAgICAgICAgInRleHQiOiBudWxsLAogICAgICAgICAgICAicG9zaXRpb24iOiBbMCwgNF0KICAgICAgICB9LAogICAgfSwKICAgICJxd2VydHktc2hpZnQiOiB7CiAgICAgICJsYWJlbCI6eyJnbHlwaCI6InF3ZXJ0eS1nbHlwaC80OHB4LXNoaWZ0LnBuZyIsfSx9LAogICAgInF3ZXJ0eS1nbG9iZSI6IHsKICAgICAgImxhYmVsIjp7ImdseXBoIjoicXdlcnR5LWdseXBoLzQwcHgtZ2xvYmUucG5nIix9LH0sCiAgICAicXdlcnR5LWRlbGV0ZSI6IHsKICAgICAgImxhYmVsIjp7ImdseXBoIjoicXdlcnR5LWdseXBoLzQ4cHgtZGVsZXRlLnBuZyIsfSx9LAoKICAgICJ0ZW5rZXkiOiB7CiAgICAgICAgImltYWdlIjogWyJxd2VydHkvOXBhdGNoLnBuZzo6MTAgMTAgMTAgMTAiLCAicXdlcnR5L3NlbGVjdGVkLnBuZzo6MTAgMTAgMTAgMTAiXSwKICAgICAgICAibGFiZWwiOiB7CiAgICAgICAgICAgICJmb250IjogewogICAgICAgICAgICAgICAgIm5hbWUiOiAiQXZlbmlyIExpZ2h0IiwKICAgICAgICAgICAgICAgICJzaXplIjogMTYsCiAgICAgICAgICAgICAgICAiY29sb3IiOiAiI2ZmZiIsCiAgICAgICAgICAgIH0sCiAgICAgICAgICAgICJ0ZXh0IjogbnVsbCwKICAgICAgICAgICAgInBvc2l0aW9uIjogWzAsIDBdLAogICAgICAgIH0sCiAgICB9LAogICAgInRlbmtleS1zaGlmdCI6IHsKICAgICAgImxhYmVsIjp7ImdseXBoIjoicXdlcnR5LWdseXBoLzQ4cHgtc2hpZnQucG5nIix9LH0sCiAgICAidGVua2V5LWdsb2JlIjogewogICAgICAibGFiZWwiOnsiZ2x5cGgiOiJxd2VydHktZ2x5cGgvNDBweC1nbG9iZS5wbmciLH0sfSwKICAgICJ0ZW5rZXktZGVsZXRlIjogewogICAgICAibGFiZWwiOnsiZ2x5cGgiOiJxd2VydHktZ2x5cGgvNDhweC1kZWxldGUucG5nIix9LH0KfQ=="
                case "config.json": return "ewogICAgIm5hbWUiOiAiYmx1ZXB1cnBsZSIsCgogICAgImJsdXIiOiBmYWxzZSwKCiAgICAidHJhaXQiOiB7CiAgICAgICAgInBob25lLXBvcnRyYWl0IjogInBvcnRyYWl0Lmpzb24iLAogICAgICAgICJwaG9uZS1sYW5kc2NhcGU0ODAiOiAibGFuZHNjYXBlLmpzb24iLAogICAgICAgICJwaG9uZS1sYW5kc2NhcGU1NjgiOiAibGFuZHNjYXBlLmpzb24iLAogICAgfSwKfQo="
                case "qwerty-glyph/48px-delete.png": return "iVBORw0KGgoAAAANSUhEUgAAAGAAAABcCAYAAACRILDuAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RUU4ODUzMzMzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RUU4ODUzMzIzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDoyMTMxZGQ1ZS1kOTQ1LTRlODUtYTAzZi1iZDlhYzY5OGQwMTQiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6ZDNiNzllZDgtYjJiNi00ZmY0LWIyMzgtZmY1MWU4NjlmNTY5Ii8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+vBAWgAAAA4hJREFUeNrsm1uITVEYx9dx64TpiFKKIcWT5GVcUi55QS4pvKGI4sXtYaKTcRskprwYSbm9iYdBeJHJgzLjhTfjBUme1CAmlzn+X+s7OZ3OZW+z99r7zPr/698+D2f22uf77b2+b317TaZQKBgqOY1gCAiAACgCIACKAAiAIgACoAiAACgCIACKAAiAIgACoAiAACgCIACKAAiAIgACoAiAACgCIAAqGo1K+fWNg7fAi+CJEZ/7F/wB7oHvwl+S+IGZFG9Pl4CfhKc5GOs7fAF+RgBWUzT4k+G38Dn4XcRjZOHZ8Dp4ASyBOOMaQhoBTIeP6xPwGj4Kf4t5zM061cmTsAvu9zUJyx15WoP/Es47CL7oluaCsfB6X6uguTrtNMHP4WPwgMPxu/TY4mMVNB9uhcfATzQh/nF8DX16nOobgKXwPr2WB/AlTYg1c1eA74TVQBIxSXoKWgUf1B8t83BngMDO06ooF2Ic+W47PJMr4X/aCO/Wz9fgm0GqNnirJuv2gBBymlskx+wgAKttarnbL8J3Av5dQZPzey1X60EoBn+GrifO+g4go3e93P2/4fPwo5DnkBr9cAmEU1UglAc/77K+TyOAkfABeDX8UwP39D/PVQqhuQKEhgi+SwCSZA/By+AfurrtHeI5q0FomOC7bEXs1J7LV7gNfhPhuXMa/GaFMTiE4N/T49rh9gSs0OORiINf6UloiDs/qSQc5+M2mNIWSyoAPNbjCXhWxOcun/OrJWavAVw1ttvYpMGaE1Pw83WqI28BSM0vbeZuY1u+sphqiSH4/QFKVG9zgEDogB8a2/WUIC2JOPhB1wleJ2FpPdzWtYE04lZGHPyGgpBUtXBdLa2JPfCGEH/bGqLULIfQpmN6D8DoU9Cpn7cb+042iK7Ar0LU+UUIsv64EXMpnNqVcC1Je2KvTkn34csxBSnIS5xhuxKupW6tkKRBtwbeH9N11Qt+Vo8u30OnZsXYo6WpNOqWG9u4G+34GooLxE8+AjAl87o07BYa2zfKOhy/uB2l11cAoj69+z8b++5Xys3xDsbdZOzuONmY1eVbEq6k8q2JHXqM8mK5NbGOJhnbvOPm3ARV3J6+GJ4Q8bml2vkIv9Bph9vTfRT/Q4YACIAiAAKgCIAAKAIgAIoACIAiAAKgCIAAKAIgAIoACIAiAAKgCIAAKAIgAIoACIAiAAKgItJfAQYAc6veXhys0t0AAAAASUVORK5CYII="
                case "qwerty/selected.png": return "iVBORw0KGgoAAAANSUhEUgAAAEAAAABcCAYAAADefbM+AAAAAXNSR0IArs4c6QAABIJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iCiAgICAgICAgICAgIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIKICAgICAgICAgICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIj4KICAgICAgICAgPHhtcE1NOkRlcml2ZWRGcm9tIHJkZjpwYXJzZVR5cGU9IlJlc291cmNlIj4KICAgICAgICAgICAgPHN0UmVmOmluc3RhbmNlSUQ+eG1wLmlpZDpBRjU1M0U4QjVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMDwvc3RSZWY6aW5zdGFuY2VJRD4KICAgICAgICAgICAgPHN0UmVmOmRvY3VtZW50SUQ+eG1wLmRpZDpBRjU1M0U4QzVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMDwvc3RSZWY6ZG9jdW1lbnRJRD4KICAgICAgICAgPC94bXBNTTpEZXJpdmVkRnJvbT4KICAgICAgICAgPHhtcE1NOkRvY3VtZW50SUQ+eG1wLmRpZDozNTdDNDRENzVBQjIxMUU0QTBGMDk4MEZFQkM2RTUxMDwveG1wTU06RG9jdW1lbnRJRD4KICAgICAgICAgPHhtcE1NOkluc3RhbmNlSUQ+eG1wLmlpZDozNTdDNDRENjVBQjIxMUU0QTBGMDk4MEZFQkM2RTUxMDwveG1wTU06SW5zdGFuY2VJRD4KICAgICAgICAgPHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD54bXAuZGlkOmQzYjc5ZWQ4LWIyYjYtNGZmNC1iMjM4LWZmNTFlODY5ZjU2OTwveG1wTU06T3JpZ2luYWxEb2N1bWVudElEPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICAgICA8eG1wOkNyZWF0b3JUb29sPkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE0IChNYWNpbnRvc2gpPC94bXA6Q3JlYXRvclRvb2w+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgqky3wlAAACp0lEQVR4Ae2czVLCQBCEjWX5c9EL3tQT7/9Qyg0u6kG9iPORDKaAXTJUYZGxp2qTkPQu0z29cMqcnSmkgBSQAlJACkiB/6pAM5T4crm8NuzExp2NKxuD5xr2L2JpX/Jl49XGommazyFfupeEEQfzaON+yIInhJlbLjMT4ruW03ntYUd+ahgnv7DrGxvVebU1j/iMnMiNHAlynnYcVjd2HaoOsMlP3UJY69YG5zEEW5StwLadmwueS0kXK2nkUZM9T4yJPPlSKH6riEnHpf20cSwKwEQbOARLjaXyluo6yJnc4eCFXD/0i5oAVJ14aE+jPHruzmWLRE0A9hExxuq3mf/m7lz8/vpcE8B/IPl/HWt47s5li0dNgC1wxhsSIGNVI5zkgIhaGbFyQMaqRjjJARG1MmLlgIxVjXCSAyJqZcTKARmrGuEkB0TUyoiVAzJWNcJJDoiolRErB2SsaoSTHBBRKyNWDshY1QgnOSCiVkasHJCxqhFOckBErYxYOSBjVSOc5ICIWhmxckDGqkY4yQERtTJi5YCMVY1wkgMiamXEygEZqxrhJAdE1MqIlQMyVjXCSQ6IqJURKwdkrGqEkxwQUSsjVg7IWNUIp4sKmPdu/Z1bfwe3Aj/4kX/HwQtUJuJwWmgU22jUBOCtcTowEIe8QV4i1r/f34L96z6mzaA9lu73Mf3rS/tAM5Vi/jUB3mwiAtCEoNiAwJ6dcswsOXJ/LyXZV30TA3GszwLF9+83J53QZ3ImdzjAZWcUBbDGIx82wyfihjGJQK40USHoKQSXnVEUoEO/2NnJs4/ozcO2iO5Fm3L0gMuqa4yd/fcL68OhGHuJdH140jZS2iuAS9drq0NDEiw2eK6vceQzf3VUnqpXbX/kPLS8FJACUkAKSAEpMBIFfgD3ZVq7JjnsZQAAAABJRU5ErkJggg=="
                case "qwerty-glyph/48px-shift.png": return "iVBORw0KGgoAAAANSUhEUgAAAGAAAABcCAYAAACRILDuAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RUU4ODUzMkYzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RUU4ODUzMkUzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDoyMTMxZGQ1ZS1kOTQ1LTRlODUtYTAzZi1iZDlhYzY5OGQwMTQiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6ZDNiNzllZDgtYjJiNi00ZmY0LWIyMzgtZmY1MWU4NjlmNTY5Ii8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+xI/AxwAAAiFJREFUeNrs2ktKw1AYhuH0IGIVFXWoAy8DLzMX4hbcgeJAkKaIrRV04CrcgvtQN+DEC9oqVvE6i3/IKRyKlDQk5pz0/eDHim0j35MT2iSlIAg8kl8UFQAAAAEAAAIAAAQAAAgAABAAACAAAEAAAIAAAAABAAACAAAEAAAIAAAQAAAg6WTI0f97RGZPZljmWObDVYCSg7enh+XXZdb079cy+zLvHIKyT9kovyVzL7Mk05AZByD78mtG+b6eDsKRiwjK0T2/ItOUedEIdzKLLiK4ADCqy181ym8Zfw8Rqq4iKAfKr/Uo30RwciWoApTfSdtFBFWQ8rsRbg2ECQD6y5hRfrOP8k2EqoHQsBlBWVj+gVG+32f5zq0EVaA9vzuvBsKCRpgEoHf5KzKPuvynFN63G6FhG4KypPy6Ub6fUvlOIChLyl9Oec//C6Fi4+FIWVb+c4bbe9PbuJGZtwVB5Vj+oS7/4R/KNxF8mxDyuh4Qlr8e87kbCbdxHvN54fWEnUFbAV8WfRD5yXPjeV2SPElxD85qBQ3sqYiBCgAAAEAAAIAAAIBt6XxZm07w2ikbvmS5DnClf24ZhcbJjMy2fnxhO4DN94bOyZx60Ym7JPmU2fWiuyQASJhZmU0vOnFXjvmab5lLmTMvum2RFUD4FAQAAQAAAgAABAAACAAAEAAAIAAAAAABAAACAAAEAAAIAAAQAAAgAABAAACAAFD0/AowABgBfyeImBesAAAAAElFTkSuQmCC"
                case "qwerty-glyph/40px-globe.png": return "iVBORw0KGgoAAAANSUhEUgAAAFAAAABcCAYAAAD50zLWAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RUU4ODUzMzczQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RUU4ODUzMzYzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDoyMTMxZGQ1ZS1kOTQ1LTRlODUtYTAzZi1iZDlhYzY5OGQwMTQiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6ZDNiNzllZDgtYjJiNi00ZmY0LWIyMzgtZmY1MWU4NjlmNTY5Ii8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+lCmWmAAABYxJREFUeNrsWm9olVUYP9es7X4wy+X+qLPChTURwxVFrPpQmJIlUtosgoHYH2sqRPQls6gPSfkhKVEqMKolaYiosGEhqGTRig11Gsz8s3udyzSW4WZszt/D/b10dnjf3btd7uveu+eBH++97znnec793eec5znP+8b6+/uNyvBljFKgBCqBSqASqKIEKoFKoBKoogQqgUqgEqiiBCqBSqASqKIEKoFKoBKoogTmWMaOkHmUALOBSqAcKAbibOsG/gTagVbgN6BzpBAYu4bPhcX7q4H5wJ0ylwzHyYSPAbuAA8CV0Ujg3cCLwBSftj+AeuBNfn8PWAJM8+mbADYBzaOFwBuAZcBcfu8AdgMLgSLgB+BjoBfYyT5PcKt5FXgEOA9sBx4HytinAfgU+C+fg8h44H2SJz/0C2A5vVDIawLWkzxXetnWxL5TOHYzdc2l7vH5SqD8sLXAHfS614FtwFTgMeBfEjTYfnaFfS5yjIz9jro6qHtt2CSGQWABsBqYzO8ngDP8XMPg8S3wdwa6pM9WjqnhvTPUaWhjNW3mDYEvANOBC0AP8AA9Sfaz+3ivcQj6GjnmfupYT509tDGdNvOCQIm2c7hPvQ2sAo5z819F+0f44zOVbo6JUUcZdcrnNbQ1h7YjHYXlB37CxHgz9yuR6xhBl1p/YBfwC3AYOMXE+Wu2PcfE+lZgBlAFTLD2xc8Zyft47ymglinOK7nOE3NJ4EPWBr/cia6y0X/Je50B+eBgkuDpRdKb5/kH2KerDfTMD4B9UV3C83nd5pOaVNJDJQF+GagDPuPJ4gQjrScXee8A+9RxTDN1VPqkPFudOUTuLFzC41l3gAdMsyKyyElih9XHS6SfDbAhY+8FKoCDTtt+Juwyh1LgbNQ8sIre0RQQILwl256FjXYrdXGlh7ZjLFJEbgnfxWtLQHuplcMNV5KOLldanLlEisCp1tL0k5t4/SsLG+d5vTmg/aQzl0gRONEqFvhJoZXTDVcuObpc6XDmEqk0ZrsZOcXaXlZ7Il+NyUvJlZfI0hzHU8Q/Pu1fMZlePMgytuuBfiL667mUn/Fpv5Gnme5cEpgrDzzHa1ma/SuehY24lbL4SZkzl0gR6OVot6Uh8JYsbHiRPKgM5tk+HUUCW3mdFdDunQwmZWFjkqPLFc/20SgSKI8eJbzfE5BmJHgtz8JGuZNQ21JA2/2cS+SCiHjFMZ4CHgT2OO3Heb3dWm6zeHad7CzteibcSepsYZLsjW0LqATF6X1no0igyC4SuAjY61RkWukdUvTckMYTxxFCWLW1x5ZSx1Gf3/S0NQcTVQKl/LSEhYMFZmBB9WGTKnReT/K6ePg/xE2/0wwsqJbwSDaTxQGP8D56m11QfZL7Y4JzyKnk+rmweNi7JlVmf41XKbJWWH1+ZZ++DPNA2bffYsXHWMtYiqfy3PlD8/+DrOYoe6DhD/geeBR4h/tSnPvSFmClSZXpC6zUJp0Ucoz88x+Z1NO5Cn6+RF17TEhvK4RxlNsI/G5SzzGEvIMkTt5C+ImEzBuCvnkc8zN1iK4feW8CbW0K6ygXBoGXuUSTVsQt5uct9CTxoqIMdBWxr4z5hveKrYicpK3L+USgYZB4g3uVHLHWmdTTMwkYjfSeujTzGcM+hRxzmjrWUWcbbXSFWUwIsxrjkdjAzb7WpB57JpnnSVBYEbAvj2VbFfsmOLaWuhquBXlhROHBovNLxv95RhuXtv16W40TuY21ZDeaUfR6m+v91UxT5HWM2BDGei9Y7jej9AVLV0q4PGcw8Z5oBr7ie47L9gjzRn3FN19ES/pKoBKoBCqBKkqgEqgEKoEqSqASqAQqgSpKoBKoBCqBKkqgEqgEKoEqSqASqAQqgSpKoBKoBCqBKkqgEqgE5p9cFWAAegdJdqiRBH8AAAAASUVORK5CYII="
                case "bg.png": return "iVBORw0KGgoAAAANSUhEUgAAABIAAAGwCAYAAACkbTUGAAAAAXNSR0IArs4c6QAABBdpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iCiAgICAgICAgICAgIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIgogICAgICAgICAgICB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIj4KICAgICAgICAgPHhtcE1NOkRlcml2ZWRGcm9tIHJkZjpwYXJzZVR5cGU9IlJlc291cmNlIj4KICAgICAgICAgICAgPHN0UmVmOmluc3RhbmNlSUQ+eG1wLmlpZDpENDVCN0E4ODQzM0ExMUU0QTAwNTk2MEVERTEzMzYzODwvc3RSZWY6aW5zdGFuY2VJRD4KICAgICAgICAgICAgPHN0UmVmOmRvY3VtZW50SUQ+eG1wLmRpZDpENDVCN0E4OTQzM0ExMUU0QTAwNTk2MEVERTEzMzYzODwvc3RSZWY6ZG9jdW1lbnRJRD4KICAgICAgICAgPC94bXBNTTpEZXJpdmVkRnJvbT4KICAgICAgICAgPHhtcE1NOkRvY3VtZW50SUQ+eG1wLmRpZDpENDVCN0E4QjQzM0ExMUU0QTAwNTk2MEVERTEzMzYzODwveG1wTU06RG9jdW1lbnRJRD4KICAgICAgICAgPHhtcE1NOkluc3RhbmNlSUQ+eG1wLmlpZDpENDVCN0E4QTQzM0ExMUU0QTAwNTk2MEVERTEzMzYzODwveG1wTU06SW5zdGFuY2VJRD4KICAgICAgICAgPHhtcDpDcmVhdG9yVG9vbD5BZG9iZSBQaG90b3Nob3AgQ0MgMjAxNCAoTWFjaW50b3NoKTwveG1wOkNyZWF0b3JUb29sPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KGWPlJAAAAjVJREFUeAHtnMFtxDAMBJ3ABaeh9JJqUsY5QhpYPwbCHj35nkBIs0uK0uny8fX983sAf59AjP8QBsokZZQZncdx5VE3Rgg7Qzoh1oewM2wZbWRkGdkKmynZlpEsmoxuMFrZ/7oxLA+xZmdG52X2J0r6KBE6LGwZ0WHDniENzjW72o3ym2tbYUNXEYOzv29ppkhOEWt2ZlTobA81UTadHREVHmqs2Vk1nZ0ZFdZs6NKvMmltj5Ml+wzZNyMLW3LR6HvIvqt6DflsQ0LbGrdla0gNmQnkEX17vzPaqBp2yl71yKcMQTidHQCtj1frxzzTEHaGPZjRKmz6KDhgsPzY0vRRMNH6GIM9OBB2XsM6tsGw+5aGyY8t7Xwx/brZnwskx6jPR5ghDZSNhDHq85H72qPlB53NnPu4mo0trS/QKiNMF9G4NH2UKlKfan0zcl9LLgIvEPraGsyQ+ij7aLD8+ijLDzKC3ntgM+oL1PdGq5CR/yQoZi2m2uAN0n0t2og7ruujjbCx7DfQRtWsRxthY84+L+aujiy19tnJSZj8fYH6dtpV2Jgc6YPtjFKmrcenUDniKqSqZdUGM8IMacf2aB/1pYjv/DVkJpBHFDrbXx5E2fpUGzwjbO/HupHBsF1aTP7C09FyNvPaS/nfUf7BqmHFH2PkwwFTJBPIIzBDYoH6cg1bmoHe0ZCDVRucayf0HVRhnz3YkC5tY4Vc2e/3tIG3tzUB0PrYpJVRJpBH6KONjAZfIPwBP9pfQqNvDDYAAAAASUVORK5CYII="
                case "qwerty/9patch.png": return "iVBORw0KGgoAAAANSUhEUgAAAEAAAABcCAYAAADefbM+AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3BpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MzU3QzQ0RDc1QUIyMTFFNEEwRjA5ODBGRUJDNkU1MTAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MzU3QzQ0RDY1QUIyMTFFNEEwRjA5ODBGRUJDNkU1MTAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpBRjU1M0U4QjVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpBRjU1M0U4QzVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PkQfRdkAAAGOSURBVHja7Nw9T8NADIDhpgyhS1lSNkBCLPD/fwsMiIGPiXahGUKXBFtyxOmkEC5FIta9lqxTq/YUP/GlU110XbfIOQoAAAAAAAAAAOA3cSpZSZ5JlvrdmdWihRwkPyR3kp9/BaCFXkhunN3creSbZHsMgBZ/I7m21zvLZmzjf4il5Mq6tLL3aslH645JAJd257W1nqxwD6EQ13ZstRNepgDoJrfWBfeOig+v/87u/sPQ9f8EoOf+3Fr+2elD/sqOw7vk69C5GYp18DDxGtuoliSA0tbGMUAT1ZIEUAS/r16ji2pJAsgiAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADIAWD0f7cO4sTWdgrAwdaVY4AyqiUJYG/rxjFAf+310AcYocEQlbQxOrpZP0ZnboMVlovvYU9h6x81RqdHyHaQUtxWlXXDHEdptXZU66BLR4NhagAAAAAAAACQb3wJMADud5NNwQEygAAAAABJRU5ErkJggg=="
                case "landscape.json": return "ewogICAgIm5hbWUiOiAiYmx1ZXB1cnBsZSIsCgogICAgImJsdXIiOiBmYWxzZSwKICAgICJiYWNrZ3JvdW5kIjogImJnLnBuZyIsCiAgICAiZm9yZWdyb3VuZCI6ICJmb3JlZ3JvdW5kLnBuZyIsCgogICAgInF3ZXJ0eSI6IHsKICAgICAgICAiaW1hZ2UiOiBbInF3ZXJ0eS85cGF0Y2gucG5nOjoxMCAxMCAxMCAxMCIsICJxd2VydHkvc2VsZWN0ZWQucG5nOjoxMCAxMCAxMCAxMCJdLAogICAgICAgICJsYWJlbCI6IHsKICAgICAgICAgICAgImZvbnQiOiB7CiAgICAgICAgICAgICAgICAibmFtZSI6ICJBdmVuaXIgTGlnaHQiLAogICAgICAgICAgICAgICAgInNpemUiOiAxNSwKICAgICAgICAgICAgICAgICJjb2xvciI6ICIjZmZmIiwKICAgICAgICAgICAgfSwKICAgICAgICAgICAgInRleHQiOiBudWxsLAogICAgICAgICAgICAicG9zaXRpb24iOiBbMCwgMl0KICAgICAgICB9LAogICAgfSwKICAgICJxd2VydHktc2hpZnQiOiB7CiAgICAgICJsYWJlbCI6eyJnbHlwaCI6InF3ZXJ0eS1nbHlwaC80OHB4LXNoaWZ0LnBuZyIsfSx9LAogICAgInF3ZXJ0eS1nbG9iZSI6IHsKICAgICAgImxhYmVsIjp7ImdseXBoIjoicXdlcnR5LWdseXBoLzQwcHgtZ2xvYmUucG5nIix9LH0sCiAgICAicXdlcnR5LWRlbGV0ZSI6IHsKICAgICAgImxhYmVsIjp7ImdseXBoIjoicXdlcnR5LWdseXBoLzQ4cHgtZGVsZXRlLnBuZyIsfSx9LAoKICAgICJ0ZW5rZXkiOiB7CiAgICAgICAgImltYWdlIjogWyJxd2VydHkvOXBhdGNoLnBuZzo6MTAgMTAgMTAgMTAiLCAicXdlcnR5L3NlbGVjdGVkLnBuZzo6MTAgMTAgMTAgMTAiXSwKICAgICAgICAibGFiZWwiOiB7CiAgICAgICAgICAgICJmb250IjogewogICAgICAgICAgICAgICAgIm5hbWUiOiAiQXZlbmlyIExpZ2h0IiwKICAgICAgICAgICAgICAgICJzaXplIjogMTYsCiAgICAgICAgICAgICAgICAiY29sb3IiOiAiI2ZmZiIsCiAgICAgICAgICAgIH0sCiAgICAgICAgICAgICJ0ZXh0IjogbnVsbCwKICAgICAgICAgICAgInBvc2l0aW9uIjogWzAsIDBdLAogICAgICAgIH0sCiAgICB9LAogICAgInRlbmtleS1zaGlmdCI6IHsKICAgICAgImxhYmVsIjp7ImdseXBoIjoicXdlcnR5LWdseXBoLzQ4cHgtc2hpZnQucG5nIix9LH0sCiAgICAidGVua2V5LWdsb2JlIjogewogICAgICAibGFiZWwiOnsiZ2x5cGgiOiJxd2VydHktZ2x5cGgvNDBweC1nbG9iZS5wbmciLH0sfSwKICAgICJ0ZW5rZXktZGVsZXRlIjogewogICAgICAibGFiZWwiOnsiZ2x5cGgiOiJxd2VydHktZ2x5cGgvNDhweC1kZWxldGUucG5nIix9LH0KfQ=="
                case "config.json": return "ewogICAgIm5hbWUiOiAiYmx1ZXB1cnBsZSIsCgogICAgImJsdXIiOiBmYWxzZSwKCiAgICAidHJhaXQiOiB7CiAgICAgICAgInBob25lLXBvcnRyYWl0IjogInBvcnRyYWl0Lmpzb24iLAogICAgICAgICJwaG9uZS1sYW5kc2NhcGU0ODAiOiAibGFuZHNjYXBlLmpzb24iLAogICAgICAgICJwaG9uZS1sYW5kc2NhcGU1NjgiOiAibGFuZHNjYXBlLmpzb24iLAogICAgfSwKfQo="
                case "qwerty-glyph/48px-delete.png": return "iVBORw0KGgoAAAANSUhEUgAAAGAAAABcCAYAAACRILDuAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RUU4ODUzMzMzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RUU4ODUzMzIzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDoyMTMxZGQ1ZS1kOTQ1LTRlODUtYTAzZi1iZDlhYzY5OGQwMTQiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6ZDNiNzllZDgtYjJiNi00ZmY0LWIyMzgtZmY1MWU4NjlmNTY5Ii8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+vBAWgAAAA4hJREFUeNrsm1uITVEYx9dx64TpiFKKIcWT5GVcUi55QS4pvKGI4sXtYaKTcRskprwYSbm9iYdBeJHJgzLjhTfjBUme1CAmlzn+X+s7OZ3OZW+z99r7zPr/698+D2f22uf77b2+b317TaZQKBgqOY1gCAiAACgCIACKAAiAIgACoAiAACgCIACKAAiAIgACoAiAACgCIACKAAiAIgACoAiAACgCIAAqGo1K+fWNg7fAi+CJEZ/7F/wB7oHvwl+S+IGZFG9Pl4CfhKc5GOs7fAF+RgBWUzT4k+G38Dn4XcRjZOHZ8Dp4ASyBOOMaQhoBTIeP6xPwGj4Kf4t5zM061cmTsAvu9zUJyx15WoP/Es47CL7oluaCsfB6X6uguTrtNMHP4WPwgMPxu/TY4mMVNB9uhcfATzQh/nF8DX16nOobgKXwPr2WB/AlTYg1c1eA74TVQBIxSXoKWgUf1B8t83BngMDO06ooF2Ic+W47PJMr4X/aCO/Wz9fgm0GqNnirJuv2gBBymlskx+wgAKttarnbL8J3Av5dQZPzey1X60EoBn+GrifO+g4go3e93P2/4fPwo5DnkBr9cAmEU1UglAc/77K+TyOAkfABeDX8UwP39D/PVQqhuQKEhgi+SwCSZA/By+AfurrtHeI5q0FomOC7bEXs1J7LV7gNfhPhuXMa/GaFMTiE4N/T49rh9gSs0OORiINf6UloiDs/qSQc5+M2mNIWSyoAPNbjCXhWxOcun/OrJWavAVw1ttvYpMGaE1Pw83WqI28BSM0vbeZuY1u+sphqiSH4/QFKVG9zgEDogB8a2/WUIC2JOPhB1wleJ2FpPdzWtYE04lZGHPyGgpBUtXBdLa2JPfCGEH/bGqLULIfQpmN6D8DoU9Cpn7cb+042iK7Ar0LU+UUIsv64EXMpnNqVcC1Je2KvTkn34csxBSnIS5xhuxKupW6tkKRBtwbeH9N11Qt+Vo8u30OnZsXYo6WpNOqWG9u4G+34GooLxE8+AjAl87o07BYa2zfKOhy/uB2l11cAoj69+z8b++5Xys3xDsbdZOzuONmY1eVbEq6k8q2JHXqM8mK5NbGOJhnbvOPm3ARV3J6+GJ4Q8bml2vkIv9Bph9vTfRT/Q4YACIAiAAKgCIAAKAIgAIoACIAiAAKgCIAAKAIgAIoACIAiAAKgCIAAKAIgAIoACIAiAAKgItJfAQYAc6veXhys0t0AAAAASUVORK5CYII="
                case "qwerty/selected.png": return "iVBORw0KGgoAAAANSUhEUgAAAEAAAABcCAYAAADefbM+AAAAAXNSR0IArs4c6QAABIJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iCiAgICAgICAgICAgIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIKICAgICAgICAgICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIj4KICAgICAgICAgPHhtcE1NOkRlcml2ZWRGcm9tIHJkZjpwYXJzZVR5cGU9IlJlc291cmNlIj4KICAgICAgICAgICAgPHN0UmVmOmluc3RhbmNlSUQ+eG1wLmlpZDpBRjU1M0U4QjVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMDwvc3RSZWY6aW5zdGFuY2VJRD4KICAgICAgICAgICAgPHN0UmVmOmRvY3VtZW50SUQ+eG1wLmRpZDpBRjU1M0U4QzVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMDwvc3RSZWY6ZG9jdW1lbnRJRD4KICAgICAgICAgPC94bXBNTTpEZXJpdmVkRnJvbT4KICAgICAgICAgPHhtcE1NOkRvY3VtZW50SUQ+eG1wLmRpZDozNTdDNDRENzVBQjIxMUU0QTBGMDk4MEZFQkM2RTUxMDwveG1wTU06RG9jdW1lbnRJRD4KICAgICAgICAgPHhtcE1NOkluc3RhbmNlSUQ+eG1wLmlpZDozNTdDNDRENjVBQjIxMUU0QTBGMDk4MEZFQkM2RTUxMDwveG1wTU06SW5zdGFuY2VJRD4KICAgICAgICAgPHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD54bXAuZGlkOmQzYjc5ZWQ4LWIyYjYtNGZmNC1iMjM4LWZmNTFlODY5ZjU2OTwveG1wTU06T3JpZ2luYWxEb2N1bWVudElEPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICAgICA8eG1wOkNyZWF0b3JUb29sPkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE0IChNYWNpbnRvc2gpPC94bXA6Q3JlYXRvclRvb2w+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgqky3wlAAACp0lEQVR4Ae2czVLCQBCEjWX5c9EL3tQT7/9Qyg0u6kG9iPORDKaAXTJUYZGxp2qTkPQu0z29cMqcnSmkgBSQAlJACkiB/6pAM5T4crm8NuzExp2NKxuD5xr2L2JpX/Jl49XGommazyFfupeEEQfzaON+yIInhJlbLjMT4ruW03ntYUd+ahgnv7DrGxvVebU1j/iMnMiNHAlynnYcVjd2HaoOsMlP3UJY69YG5zEEW5StwLadmwueS0kXK2nkUZM9T4yJPPlSKH6riEnHpf20cSwKwEQbOARLjaXyluo6yJnc4eCFXD/0i5oAVJ14aE+jPHruzmWLRE0A9hExxuq3mf/m7lz8/vpcE8B/IPl/HWt47s5li0dNgC1wxhsSIGNVI5zkgIhaGbFyQMaqRjjJARG1MmLlgIxVjXCSAyJqZcTKARmrGuEkB0TUyoiVAzJWNcJJDoiolRErB2SsaoSTHBBRKyNWDshY1QgnOSCiVkasHJCxqhFOckBErYxYOSBjVSOc5ICIWhmxckDGqkY4yQERtTJi5YCMVY1wkgMiamXEygEZqxrhJAdE1MqIlQMyVjXCSQ6IqJURKwdkrGqEkxwQUSsjVg7IWNUIp4sKmPdu/Z1bfwe3Aj/4kX/HwQtUJuJwWmgU22jUBOCtcTowEIe8QV4i1r/f34L96z6mzaA9lu73Mf3rS/tAM5Vi/jUB3mwiAtCEoNiAwJ6dcswsOXJ/LyXZV30TA3GszwLF9+83J53QZ3ImdzjAZWcUBbDGIx82wyfihjGJQK40USHoKQSXnVEUoEO/2NnJs4/ozcO2iO5Fm3L0gMuqa4yd/fcL68OhGHuJdH140jZS2iuAS9drq0NDEiw2eK6vceQzf3VUnqpXbX/kPLS8FJACUkAKSAEpMBIFfgD3ZVq7JjnsZQAAAABJRU5ErkJggg=="
                case "qwerty-glyph/48px-shift.png": return "iVBORw0KGgoAAAANSUhEUgAAAGAAAABcCAYAAACRILDuAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RUU4ODUzMkYzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RUU4ODUzMkUzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDoyMTMxZGQ1ZS1kOTQ1LTRlODUtYTAzZi1iZDlhYzY5OGQwMTQiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6ZDNiNzllZDgtYjJiNi00ZmY0LWIyMzgtZmY1MWU4NjlmNTY5Ii8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+xI/AxwAAAiFJREFUeNrs2ktKw1AYhuH0IGIVFXWoAy8DLzMX4hbcgeJAkKaIrRV04CrcgvtQN+DEC9oqVvE6i3/IKRyKlDQk5pz0/eDHim0j35MT2iSlIAg8kl8UFQAAAAEAAAIAAAQAAAgAABAAACAAAEAAAIAAAAABAAACAAAEAAAIAAAQAAAg6WTI0f97RGZPZljmWObDVYCSg7enh+XXZdb079cy+zLvHIKyT9kovyVzL7Mk05AZByD78mtG+b6eDsKRiwjK0T2/ItOUedEIdzKLLiK4ADCqy181ym8Zfw8Rqq4iKAfKr/Uo30RwciWoApTfSdtFBFWQ8rsRbg2ECQD6y5hRfrOP8k2EqoHQsBlBWVj+gVG+32f5zq0EVaA9vzuvBsKCRpgEoHf5KzKPuvynFN63G6FhG4KypPy6Ub6fUvlOIChLyl9Oec//C6Fi4+FIWVb+c4bbe9PbuJGZtwVB5Vj+oS7/4R/KNxF8mxDyuh4Qlr8e87kbCbdxHvN54fWEnUFbAV8WfRD5yXPjeV2SPElxD85qBQ3sqYiBCgAAAEAAAIAAAIBt6XxZm07w2ikbvmS5DnClf24ZhcbJjMy2fnxhO4DN94bOyZx60Ym7JPmU2fWiuyQASJhZmU0vOnFXjvmab5lLmTMvum2RFUD4FAQAAQAAAgAABAAACAAAEAAAIAAAAAABAAACAAAEAAAIAAAQAAAgAABAAACAAFD0/AowABgBfyeImBesAAAAAElFTkSuQmCC"
                case "qwerty-glyph/40px-globe.png": return "iVBORw0KGgoAAAANSUhEUgAAAFAAAABcCAYAAAD50zLWAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RUU4ODUzMzczQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RUU4ODUzMzYzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDoyMTMxZGQ1ZS1kOTQ1LTRlODUtYTAzZi1iZDlhYzY5OGQwMTQiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6ZDNiNzllZDgtYjJiNi00ZmY0LWIyMzgtZmY1MWU4NjlmNTY5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"
                case "bg.png": return "iVBORw0KGgoAAAANSUhEUgAAABIAAAGwCAYAAACkbTUGAAAAAXNSR0IArs4c6QAABBdpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iCiAgICAgICAgICAgIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIgogICAgICAgICAgICB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIj4KICAgICAgICAgPHhtcE1NOkRlcml2ZWRGcm9tIHJkZjpwYXJzZVR5cGU9IlJlc291cmNlIj4KICAgICAgICAgICAgPHN0UmVmOmluc3RhbmNlSUQ+eG1wLmlpZDpENDVCN0E4ODQzM0ExMUU0QTAwNTk2MEVERTEzMzYzODwvc3RSZWY6aW5zdGFuY2VJRD4KICAgICAgICAgICAgPHN0UmVmOmRvY3VtZW50SUQ+eG1wLmRpZDpENDVCN0E4OTQzM0ExMUU0QTAwNTk2MEVERTEzMzYzODwvc3RSZWY6ZG9jdW1lbnRJRD4KICAgICAgICAgPC94bXBNTTpEZXJpdmVkRnJvbT4KICAgICAgICAgPHhtcE1NOkRvY3VtZW50SUQ+eG1wLmRpZDpENDVCN0E4QjQzM0ExMUU0QTAwNTk2MEVERTEzMzYzODwveG1wTU06RG9jdW1lbnRJRD4KICAgICAgICAgPHhtcE1NOkluc3RhbmNlSUQ+eG1wLmlpZDpENDVCN0E4QTQzM0ExMUU0QTAwNTk2MEVERTEzMzYzODwveG1wTU06SW5zdGFuY2VJRD4KICAgICAgICAgPHhtcDpDcmVhdG9yVG9vbD5BZG9iZSBQaG90b3Nob3AgQ0MgMjAxNCAoTWFjaW50b3NoKTwveG1wOkNyZWF0b3JUb29sPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KGWPlJAAAAjVJREFUeAHtnMFtxDAMBJ3ABaeh9JJqUsY5QhpYPwbCHj35nkBIs0uK0uny8fX983sAf59AjP8QBsokZZQZncdx5VE3Rgg7Qzoh1oewM2wZbWRkGdkKmynZlpEsmoxuMFrZ/7oxLA+xZmdG52X2J0r6KBE6LGwZ0WHDniENzjW72o3ym2tbYUNXEYOzv29ppkhOEWt2ZlTobA81UTadHREVHmqs2Vk1nZ0ZFdZs6NKvMmltj5Ml+wzZNyMLW3LR6HvIvqt6DflsQ0LbGrdla0gNmQnkEX17vzPaqBp2yl71yKcMQTidHQCtj1frxzzTEHaGPZjRKmz6KDhgsPzY0vRRMNH6GIM9OBB2XsM6tsGw+5aGyY8t7Xwx/brZnwskx6jPR5ghDZSNhDHq85H72qPlB53NnPu4mo0trS/QKiNMF9G4NH2UKlKfan0zcl9LLgIvEPraGsyQ+ij7aLD8+ijLDzKC3ntgM+oL1PdGq5CR/yQoZi2m2uAN0n0t2og7ruujjbCx7DfQRtWsRxthY84+L+aujiy19tnJSZj8fYH6dtpV2Jgc6YPtjFKmrcenUDniKqSqZdUGM8IMacf2aB/1pYjv/DVkJpBHFDrbXx5E2fpUGzwjbO/HupHBsF1aTP7C09FyNvPaS/nfUf7BqmHFH2PkwwFTJBPIIzBDYoH6cg1bmoHe0ZCDVRucayf0HVRhnz3YkC5tY4Vc2e/3tIG3tzUB0PrYpJVRJpBH6KONjAZfIPwBP9pfQqNvDDYAAAAASUVORK5CYII="
                case "qwerty/9patch.png": return "iVBORw0KGgoAAAANSUhEUgAAAEAAAABcCAYAAADefbM+AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3BpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MzU3QzQ0RDc1QUIyMTFFNEEwRjA5ODBGRUJDNkU1MTAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MzU3QzQ0RDY1QUIyMTFFNEEwRjA5ODBGRUJDNkU1MTAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpBRjU1M0U4QjVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpBRjU1M0U4QzVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PkQfRdkAAAGOSURBVHja7Nw9T8NADIDhpgyhS1lSNkBCLPD/fwsMiIGPiXahGUKXBFtyxOmkEC5FIta9lqxTq/YUP/GlU110XbfIOQoAAAAAAAAAAOA3cSpZSZ5JlvrdmdWihRwkPyR3kp9/BaCFXkhunN3creSbZHsMgBZ/I7m21zvLZmzjf4il5Mq6tLL3aslH645JAJd257W1nqxwD6EQ13ZstRNepgDoJrfWBfeOig+v/87u/sPQ9f8EoOf+3Fr+2elD/sqOw7vk69C5GYp18DDxGtuoliSA0tbGMUAT1ZIEUAS/r16ji2pJAsgiAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADIAWD0f7cO4sTWdgrAwdaVY4AyqiUJYG/rxjFAf+310AcYocEQlbQxOrpZP0ZnboMVlovvYU9h6x81RqdHyHaQUtxWlXXDHEdptXZU66BLR4NhagAAAAAAAACQb3wJMADud5NNwQEygAAAAABJRU5ErkJggg=="
                default: return nil
            }
        }() {
            return NSData(base64EncodedString: dataString, options: .allZeros)
        } else {
            return nil
        }
    }
}

class ThemeResourceCoder {
    func key() -> NSData {
        let identifier = UIDevice.currentDevice().identifierForVendor
        var UUIDBytes = UnsafeMutablePointer<UInt8>(malloc(16))
        identifier.getUUIDBytes(UUIDBytes as UnsafeMutablePointer<UInt8>)
        let result = NSData(bytes: UUIDBytes, length: 16)
        free(UUIDBytes)
        return result
    }

    func encodeFromData(data: NSData) -> String {
        let encoded = data.encryptedAES256DataWithKey(self.key())
        return encoded.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
    }

    func decodeToData(data: String) -> NSData {
        let encoded = NSData(base64EncodedString: data, options: NSDataBase64DecodingOptions(0))
        return encoded!.decryptedAES256DataWithKey(self.key())
    }

    class func defaultCoder() -> ThemeResourceCoder {
        return ThemeResourceCoderDefaultCoder
    }
}

let ThemeResourceCoderDefaultCoder = ThemeResourceCoder()
