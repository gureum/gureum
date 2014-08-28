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
        let data = self.dataForFilename(name)
        assert(data != nil, "지정한 데이터 파일이 없습니다.")
        return NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(0), error: error)
    }

    func imageForFilename(name: String) -> UIImage? {
        let parts = name.componentsSeparatedByString("::")
        let filename = parts[0]
        //println("parts: \(parts) \(parts[0]) \(filename)")
        if let data = self.dataForFilename(filename) {
            var image = UIImage(data: data, scale: 2)
            if parts.count > 1 {
                let valueStrings = parts[1].componentsSeparatedByString(" ")
                let (s1, s2, s3, s4) = (valueStrings[0], valueStrings[1], valueStrings[2], valueStrings[3])
                let insets = UIEdgeInsetsMake(CGFloat(s1.toInt()!), CGFloat(s2.toInt()!), CGFloat(s3.toInt()!), CGFloat(s4.toInt()!))
                image = image.resizableImageWithCapInsets(insets)
            }
            return image
        } else {
            return nil
        }
    }

    func imageForFilename(name: String, withTopMargin margin: CGFloat) -> UIImage? {
        let parts = name.componentsSeparatedByString("::")
        let filename = parts[0]
        if let image = self.imageForFilename(filename) {
            var size = image.size
            size.height += margin
            UIGraphicsBeginImageContextWithOptions(size, false, 2)
            var rect = CGRectMake(0, margin, image.size.width, image.size.height)
            image.drawInRect(rect)
            var newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            if parts.count > 1 {
                let valueStrings = parts[1].componentsSeparatedByString(" ")
                let (s1, s2, s3, s4) = (valueStrings[0], valueStrings[1], valueStrings[2], valueStrings[3])
                let insets = UIEdgeInsetsMake(CGFloat(s1.toInt()!) + margin, CGFloat(s2.toInt()!), CGFloat(s3.toInt()!), CGFloat(s4.toInt()!))
                newImage = newImage.resizableImageWithCapInsets(insets)
            }

            return newImage
        } else {
            return nil
        }
    }

    lazy var mainConfiguration: Dictionary<String, AnyObject> = {
        var error: NSError? = nil
        let JSONObject = self.JSONObjectForFilename("config.json", error: &error) as Dictionary<String, AnyObject>!
        assert(error == nil, "설정 파일의 서식이 올바르지 않습니다.")
        assert(JSONObject != nil)
        return JSONObject!
    }()

    func traitForName(traitName: String, topMargin: CGFloat) -> ThemeTraitConfiguration {
        let sub: AnyObject? = self.mainConfiguration["trait"]
        if let traits = sub as Dictionary<String, String>? {
            if let traitFilename = traits[traitName] {
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
    }

    func traitForCoordinator(coordinator: UIViewControllerTransitionCoordinator!) -> ThemeTraitConfiguration {
        assert(false)
        //println("coordinator: \(coordinator)")
        return self.phonePortraitConfiguration
    }

    func traitForSize(size: CGSize) -> ThemeTraitConfiguration {
        switch size.width {
        case 320.0:
            return self.phonePortraitConfiguration
        case 480.0:
            return self.phoneLandscape480Configuration
        case 568.0:
            return self.phoneLandscape568Configuration
        default:
            assert(false, "no coverage")
        }
    }

    lazy var phonePortraitConfiguration: ThemeTraitConfiguration = {
        return self.traitForName("phone-portrait", topMargin: 8)
    }()

    lazy var phoneLandscape480Configuration: ThemeTraitConfiguration = {
        return self.traitForName("phone-landscape480", topMargin: 4)
    }()

    lazy var phoneLandscape568Configuration: ThemeTraitConfiguration = {
        return self.traitForName("phone-landscape568", topMargin: 4)
    }()
}

class ThemeTraitConfiguration {
    let configuration: Dictionary<String, AnyObject>
    let owner: Theme
    let topMargin: CGFloat
    var _captions: Dictionary<String, ThemeCaptionConfiguration> = [:]

    init(owner: Theme, configuration: AnyObject?, topMargin: CGFloat) {
        self.owner = owner
        self.topMargin = topMargin
        self.configuration = configuration as Dictionary<String, AnyObject>
    }

    lazy var backgroundImage: UIImage? = {
        let configFilename: AnyObject? = self.configuration["background"]
        let filename = configFilename as String? ?? "background.png"
        return self.owner.imageForFilename(filename)
    }()

    lazy var foregroundImage: UIImage? = {
        let configFilename: AnyObject? = self.configuration["foreground"]
        let filename = configFilename as String? ?? "foreground.png"
        return self.owner.imageForFilename(filename)
    }()

    func captionForKey(key: String, fallback: ThemeCaptionConfiguration?) -> ThemeCaptionConfiguration {
        if let theme = self._captions[key] {
            return theme
        } else {
            let theme: ThemeCaptionConfiguration = {
                if let sub: AnyObject = self.configuration[key] {
                    return ThemeCaptionConfiguration(trait: self, configuration: sub, fallback: fallback)
                } else {
                    return fallback!
                }
            }()
            self._captions[key] = theme
            return theme
        }
    }

    lazy var defaultCaption: ThemeCaptionConfiguration = ThemeCaptionConfiguration(trait: self, configuration: nil, fallback: nil)

    lazy var qwertyCaption: ThemeCaptionConfiguration = self.captionForKey("qwerty", fallback: self.defaultCaption)

    lazy var qwerty32pxCaption: ThemeCaptionConfiguration = self.captionForKey("qwerty-32px", fallback: self.qwertyCaption)
    lazy var qwerty40pxCaption: ThemeCaptionConfiguration = self.captionForKey("qwerty-40px", fallback: self.qwertyCaption)
    lazy var qwerty48pxCaption: ThemeCaptionConfiguration = self.captionForKey("qwerty-48px", fallback: self.qwertyCaption)
    lazy var qwerty80pxCaption: ThemeCaptionConfiguration = self.captionForKey("qwerty-80px", fallback: self.qwertyCaption)
    lazy var qwerty160pxCaption: ThemeCaptionConfiguration = self.captionForKey("qwerty-160px", fallback: self.qwertyCaption)

    lazy var qwertyKeyCaption: ThemeCaptionConfiguration = self.captionForKey("qwerty-key", fallback: self.qwerty32pxCaption)
    lazy var qwertyShiftCaption: ThemeCaptionConfiguration = self.captionForKey("qwerty-shift", fallback: self.qwerty48pxCaption)
    lazy var qwertyDeleteCaption: ThemeCaptionConfiguration = self.captionForKey("qwerty-delete", fallback: self.qwerty48pxCaption)
    lazy var qwerty123Caption: ThemeCaptionConfiguration = self.captionForKey("qwerty-123", fallback: self.qwerty40pxCaption)
    lazy var qwertyGlobeCaption: ThemeCaptionConfiguration = self.captionForKey("qwerty-globe", fallback: self.qwerty40pxCaption)
    lazy var qwertySpaceCaption: ThemeCaptionConfiguration = self.captionForKey("qwerty-space", fallback: self.qwerty160pxCaption)
    lazy var qwertyDoneCaption: ThemeCaptionConfiguration = self.captionForKey("qwerty-done", fallback: self.qwerty80pxCaption)
}


class PreferencedTheme: Theme {
    override func dataForFilename(name: String) -> NSData? {
        if let rawData = preferences.themeResources[name] {
            let data = NSData(base64EncodedString: rawData, options: NSDataBase64DecodingOptions(0))
            return data
        } else {
            return nil
        }
    }
}


class ThemeCaptionConfiguration {
    let configuration: [String: AnyObject?]
    let fallback: ThemeCaptionConfiguration!
    let trait: ThemeTraitConfiguration

    init(trait: ThemeTraitConfiguration, configuration: AnyObject?, fallback: ThemeCaptionConfiguration?) {
        self.trait = trait

        var given: AnyObject = configuration ?? Dictionary<String, AnyObject>()

        var full: [String: AnyObject?] = [
            "image": Array<String>(),
            "label": Dictionary<String, AnyObject>(),
        ]

        if given is String {
            var sub = full["image"]
            var image = sub as Array<NSString>
            image.append(given as String)
        }
        else if given is Array<String!> {
            full["image"] = configuration
            var sub = full["image"]
            var image = sub as Array<NSString>
        }
        else {
            full = given as Dictionary<String, AnyObject>
        }

        self.configuration = full
        self.fallback = fallback
    }

    func appeal(button: GRInputButton) {
        let (image1, image2, image3) = self.images
        //assert(image1 != nil)
        button.tintColor = UIColor.clearColor()
        button.setBackgroundImage(image1, forState: .Normal)
        button.setBackgroundImage(image2, forState: .Highlighted)
        button.setBackgroundImage(image3, forState: .Selected)

        if let glyph = self.glyph {
            assert(button.glyphView.superview == button)
            button.glyphView.image = glyph
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
    }

    func arrange(button: GRInputButton) {
        let position = self.position
        //println("pos: \(position)")
        let center = CGPointMake(button.frame.width / 2 + position.x, button.frame.height / 2 + position.y)

        button.glyphView.sizeToFit()
        button.glyphView.center = center
        //println("glyphView: \(button.glyphView.frame)")

        button.captionLabel.sizeToFit()
        button.captionLabel.center = center
        //println("captionlabel: \(button.captionLabel.frame)")
    }

    lazy var images: (UIImage?, UIImage?, UIImage?) = {
        let sub = self.configuration["image"]
        let imageConfiguration = sub as Array<String!>?
        if imageConfiguration == nil || imageConfiguration!.count == 0 {
            return self.fallback.images
        }
        var images: [UIImage?] = []
        for imageName in imageConfiguration! {
            let image = self.trait.owner.imageForFilename(imageName, withTopMargin: self.trait.topMargin)
            //assert(image != nil, "캡션 이미지를 찾을 수 없습니다. \(imageName)")
            images.append(image)
        }
        while images.count < 3 {
            let lastImage = images.last!
            //assert(lastImage != nil)
            images.append(lastImage)
        }
        return (images[0], images[1], images[2])
    }()

    lazy var labelConfiguration: Dictionary<String, AnyObject>? = {
        let sub = self.configuration["label"]
        //println("label: \(sub)")
        assert(sub is Dictionary<String, AnyObject>, "'label' 설정 값의 서식이 맞지 않습니다. 딕셔너리가 필요합니다.")
        return sub as Dictionary<String, AnyObject>?
    }()

    lazy var text: String? = {
        if let config = self.labelConfiguration {
            let subText: AnyObject? = config["text"]
            if subText is String {
                return subText as? String
            } else {
                return nil
            }
        } else {
            return nil
        }
    }()

    lazy var glyph: UIImage? = {
        if let config = self.labelConfiguration {
            let subText: AnyObject? = config["glyph"]
            //println("glyph: \(subText)")
            if subText is String {
                let image = self.trait.owner.imageForFilename(subText as String)
                //println("glyph image: \(image)")
                return image
            }
        }
        return nil
    }()

    lazy var position: CGPoint = {
        if let config = self.labelConfiguration {
            let sub: AnyObject? = config["position"]
            if sub is Array<CGFloat> {
                let rawPosition = sub as Array<CGFloat>
                let position = CGPointMake(rawPosition[0], rawPosition[1])
                return position
            } else {
                return self.fallback.position
            }
        } else {
            return CGPointMake(0, 0)
        }
    }()

    lazy var font: (UIFont, UIColor) = {
        func fallback() -> (UIFont, UIColor) {
            return self.fallback?.font ?? (UIFont.systemFontOfSize(UIFont.systemFontSize()), UIColor.blackColor())
        }

        if let config = self.labelConfiguration {
            let subFont: AnyObject? = config["font"]
            if subFont == nil {
                return fallback()
            }

//        println("font1: \(subFont)")
//        println("font2: \(subFont!)")

            assert(subFont is Dictionary<String, AnyObject>, "'font' 설정 값의 서식이 맞지 않습니다. 딕셔너리가 필요합니다.")

            let fontConfiguration = subFont as Dictionary<String, AnyObject>?
            var font: UIFont?

            let subFontName: AnyObject? = fontConfiguration!["name"]
            let subFontSize: AnyObject? = fontConfiguration!["size"]
            let fontSize = subFontSize as CGFloat? ?? UIFont.systemFontSize()
            if subFontName != nil {
                font = UIFont(name: subFontName as String, size: fontSize)
            } else {
                font = UIFont.systemFontOfSize(fontSize)
            }
            assert(font != nil, "올바른 폰트 이름이 아닙니다")

            let subFontColorCode: AnyObject? = fontConfiguration!["color"]
            var fontColor: UIColor
            if subFontColorCode == nil {
                let (_, color) = fallback()
                fontColor = color
            } else {
                fontColor = UIColor.colorWithHTMLExpression(subFontColorCode as String)
            }
            return (font!, fontColor)
        } else {
            return fallback()
        }
    }()
}

class ThemeResourceCoder {
    func encodeFromData(data: NSData) -> String {
        return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
    }

    func decodeToData(data: String) -> NSData {
        return NSData(base64EncodedString: data, options: NSDataBase64DecodingOptions(0))
    }
}

let themeResourceCoder = ThemeResourceCoder()

