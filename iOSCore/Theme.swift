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
        case 320.0, 375.0:
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
            globalInputViewController?.log("size: \(size)")
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
    lazy var qwerty123Caption: ThemeCaptionConfiguration = self.qwertyCaptionForKey("123", fallback: self.qwertyFunctionCaption)
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
    lazy var tenkey123Caption: ThemeCaptionConfiguration = self.tenkeyCaptionForKey("123", fallback: self.tenkeyCaptionForKeyInRow(1))
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
                case "landscape.json": return "ewogICAgIm5hbWUiOiAiYmx1ZXB1cnBsZSIsCgogICAgImJsdXIiOiBmYWxzZSwKICAgICJiYWNrZ3JvdW5kIjogImJnLnBuZyIsCiAgICAiZm9yZWdyb3VuZCI6ICJmb3JlZ3JvdW5kLnBuZyIsCgogICAgInF3ZXJ0eSI6IHsKICAgICAgICAiaW1hZ2UiOiBbInF3ZXJ0eS85cGF0Y2gucG5nOjoxMCAxMCAxMCAxMCJdLAogICAgICAgICJsYWJlbCI6IHsKICAgICAgICAgICAgImZvbnQiOiB7CiAgICAgICAgICAgICAgICAibmFtZSI6ICJBdmVuaXIgTGlnaHQiLAogICAgICAgICAgICAgICAgInNpemUiOiAxNSwKICAgICAgICAgICAgICAgICJjb2xvciI6ICIjZmZmIiwKICAgICAgICAgICAgfSwKICAgICAgICAgICAgInRleHQiOiBudWxsLAogICAgICAgICAgICAicG9zaXRpb24iOiBbMCwgMl0KICAgICAgICB9LAogICAgfSwKICAgICJ0ZW5rZXkiOiB7CiAgICAgICAgImltYWdlIjogWyJxd2VydHkvOXBhdGNoLnBuZzo6MTAgMTAgMTAgMTAiXSwKICAgICAgICAibGFiZWwiOiB7CiAgICAgICAgICAgICJmb250IjogewogICAgICAgICAgICAgICAgIm5hbWUiOiAiQXZlbmlyIExpZ2h0IiwKICAgICAgICAgICAgICAgICJzaXplIjogMTYsCiAgICAgICAgICAgICAgICAiY29sb3IiOiAiI2ZmZiIsCiAgICAgICAgICAgIH0sCiAgICAgICAgICAgICJ0ZXh0IjogbnVsbCwKICAgICAgICAgICAgInBvc2l0aW9uIjogWzAsIDBdLAogICAgICAgIH0sCiAgICB9LAp9"
                case "qwerty/9patch.png": return "iVBORw0KGgoAAAANSUhEUgAAAEAAAABcCAYAAADefbM+AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3BpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MzU3QzQ0RDc1QUIyMTFFNEEwRjA5ODBGRUJDNkU1MTAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MzU3QzQ0RDY1QUIyMTFFNEEwRjA5ODBGRUJDNkU1MTAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpBRjU1M0U4QjVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpBRjU1M0U4QzVBQUMxMUU0QTBGMDk4MEZFQkM2RTUxMCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PkQfRdkAAAGOSURBVHja7Nw9T8NADIDhpgyhS1lSNkBCLPD/fwsMiIGPiXahGUKXBFtyxOmkEC5FIta9lqxTq/YUP/GlU110XbfIOQoAAAAAAAAAAOA3cSpZSZ5JlvrdmdWihRwkPyR3kp9/BaCFXkhunN3creSbZHsMgBZ/I7m21zvLZmzjf4il5Mq6tLL3aslH645JAJd257W1nqxwD6EQ13ZstRNepgDoJrfWBfeOig+v/87u/sPQ9f8EoOf+3Fr+2elD/sqOw7vk69C5GYp18DDxGtuoliSA0tbGMUAT1ZIEUAS/r16ji2pJAsgiAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADIAWD0f7cO4sTWdgrAwdaVY4AyqiUJYG/rxjFAf+310AcYocEQlbQxOrpZP0ZnboMVlovvYU9h6x81RqdHyHaQUtxWlXXDHEdptXZU66BLR4NhagAAAAAAAACQb3wJMADud5NNwQEygAAAAABJRU5ErkJggg=="
                case "config.json": return "ewogICAgIm5hbWUiOiAiYmx1ZXB1cnBsZSIsCgogICAgImJsdXIiOiBmYWxzZSwKCiAgICAidHJhaXQiOiB7CiAgICAgICAgInBob25lLXBvcnRyYWl0IjogInBvcnRyYWl0Lmpzb24iLAogICAgICAgICJwaG9uZS1sYW5kc2NhcGU0ODAiOiAibGFuZHNjYXBlLmpzb24iLAogICAgICAgICJwaG9uZS1sYW5kc2NhcGU1NjgiOiAibGFuZHNjYXBlLmpzb24iLAogICAgfSwKfQo="
                case "bg.png": return "iVBORw0KGgoAAAANSUhEUgAAAoAAAAGwCAYAAAA5X9QTAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyhpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RDQ1QjdBOEE0MzNBMTFFNEEwMDU5NjBFREUxMzM2MzgiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RDQ1QjdBOEI0MzNBMTFFNEEwMDU5NjBFREUxMzM2MzgiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpENDVCN0E4ODQzM0ExMUU0QTAwNTk2MEVERTEzMzYzOCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpENDVCN0E4OTQzM0ExMUU0QTAwNTk2MEVERTEzMzYzOCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PpT6MkEAAAfBSURBVHja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"
                case "portrait.json": return "ewogICAgIm5hbWUiOiAiYmx1ZXB1cnBsZSIsCgogICAgImJsdXIiOiBmYWxzZSwKICAgICJiYWNrZ3JvdW5kIjogImJnLnBuZyIsCiAgICAiZm9yZWdyb3VuZCI6ICJmb3JlZ3JvdW5kLnBuZyIsCgogICAgInRlbmtleSI6IHsKICAgICAgICAiaW1hZ2UiOiBbInF3ZXJ0eS85cGF0Y2gucG5nOjoxMCAxMCAxMCAxMCJdLAogICAgICAgICJsYWJlbCI6IHsKICAgICAgICAgICAgImZvbnQiOiB7CiAgICAgICAgICAgICAgICAibmFtZSI6ICJBdmVuaXIgTGlnaHQiLAogICAgICAgICAgICAgICAgInNpemUiOiAxNiwKICAgICAgICAgICAgICAgICJjb2xvciI6ICIjZmZmIiwKICAgICAgICAgICAgfSwKICAgICAgICAgICAgInRleHQiOiBudWxsLAogICAgICAgICAgICAicG9zaXRpb24iOiBbMCwgMF0sCiAgICAgICAgfSwKICAgIH0sCiAgICAidGVua2V5LXNoaWZ0IjogewogICAgICAibGFiZWwiOnsiZ2x5cGgiOiJxd2VydHktZ2x5cGgvNDhweC1zaGlmdC5wbmciLH0sfSwKICAgICJ0ZW5rZXktZ2xvYmUiOiB7CiAgICAgICJsYWJlbCI6eyJnbHlwaCI6InF3ZXJ0eS1nbHlwaC80MHB4LWdsb2JlLnBuZyIsfSx9LAogICAgInRlbmtleS1kZWxldGUiOiB7CiAgICAgICJsYWJlbCI6eyJnbHlwaCI6InF3ZXJ0eS1nbHlwaC80OHB4LWRlbGV0ZS5wbmciLH0sfSwKICAgICJxd2VydHkiOiB7CiAgICAgICAgImltYWdlIjogWyJxd2VydHkvOXBhdGNoLnBuZzo6MTAgMTAgMTAgMTAiXSwKICAgICAgICAibGFiZWwiOiB7CiAgICAgICAgICAgICJmb250IjogewogICAgICAgICAgICAgICAgIm5hbWUiOiAiQXZlbmlyIExpZ2h0IiwKICAgICAgICAgICAgICAgICJzaXplIjogMTUsCiAgICAgICAgICAgICAgICAiY29sb3IiOiAiI2ZmZiIsCiAgICAgICAgICAgIH0sCiAgICAgICAgICAgICJ0ZXh0IjogbnVsbCwKICAgICAgICAgICAgInBvc2l0aW9uIjogWzAsIDRdCiAgICAgICAgfSwKICAgIH0sCiAgICAicXdlcnR5LWRvbmUiOiBbInF3ZXJ0eS85cGF0Y2gucG5nOjoxMCAxMCAxMCAxMCJdLAogICAgInF3ZXJ0eS1zaGlmdCI6IHsKICAgICAgImltYWdlIjpbInF3ZXJ0eS85cGF0Y2gucG5nOjoxMCAxMCAxMCAxMCJdLAogICAgICAibGFiZWwiOnsiZ2x5cGgiOiJxd2VydHktZ2x5cGgvNDhweC1zaGlmdC5wbmciLH0sfSwKICAgICJxd2VydHktZ2xvYmUiOiB7CiAgICAgICJpbWFnZSI6WyJxd2VydHkvOXBhdGNoLnBuZzo6MTAgMTAgMTAgMTAiXSwKICAgICAgImxhYmVsIjp7ImdseXBoIjoicXdlcnR5LWdseXBoLzQwcHgtZ2xvYmUucG5nIix9LH0sCiAgICAicXdlcnR5LWRlbGV0ZSI6IHsKICAgICAgImltYWdlIjpbInF3ZXJ0eS85cGF0Y2gucG5nOjoxMCAxMCAxMCAxMCJdLAogICAgICAibGFiZWwiOnsiZ2x5cGgiOiJxd2VydHktZ2x5cGgvNDhweC1kZWxldGUucG5nIix9LH0sCiAgICAicXdlcnR5LXNwYWNlIjogWyJxd2VydHkvOXBhdGNoLnBuZzo6MTAgMTAgMTAgMTAiXQp9"
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
