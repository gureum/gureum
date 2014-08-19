//
//  Theme.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 12..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class Theme {
    init() {

    }

    func dataForFilename(name: String) -> NSData? {
        assert(false)
        return nil
    }

    func JSONObjectForFilename(name: String, error: NSErrorPointer) -> AnyObject! {
        let data = self.dataForFilename(name)
        assert(data != nil)
        return NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(0), error: error)
    }

    lazy var configuration: Dictionary<String, AnyObject> = {
        var error: NSError? = nil
        let JSONObject = self.JSONObjectForFilename("config.json", error: &error) as Dictionary<String, AnyObject>!
        assert(error == nil, "설정 파일의 서식이 올바르지 않습니다.")
        assert(JSONObject != nil)
        return JSONObject!
    }()

    func imageForFilename(name: String) -> UIImage? {
        let data = self.dataForFilename(name)
        if data == nil {
            return nil
        } else {
            return UIImage(data: data, scale: 2)
        }
    }

    lazy var backgroundImage: UIImage? = {
        let configFilename = self.configuration["background" as String]
        let filename = configFilename as String? ?? "background.png"
        return self.imageForFilename(filename)
    }()

    lazy var foregroundImage: UIImage? = {
        let configFilename = self.configuration["foreground" as String]
        let filename = configFilename as String? ?? "foreground.png"
        return self.imageForFilename(filename)
    }()

    func captionForKey(key: String, fallback: ThemeCaptionConfiguration?) -> ThemeCaptionConfiguration {
        //println("\(self.configuration)")
        let sub = self.configuration[key]
        if sub == nil {
            return fallback!
        } else {
            return ThemeCaptionConfiguration(owner: self, configuration: sub!, fallback: fallback)
        }
    }

    lazy var defaultCaption: ThemeCaptionConfiguration = ThemeCaptionConfiguration(owner: self, configuration: nil, fallback: nil)

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
        let rawData = preferences.themeResources[name]
        if rawData == nil {
            return nil
        }
        let data = NSData(base64EncodedString: rawData, options: NSDataBase64DecodingOptions(0))
        return data
    }
}


class ThemeCaptionConfiguration {
    let configuration: [String: AnyObject?]
    let fallback: ThemeCaptionConfiguration!
    let owner: Theme

    init(owner: Theme, configuration: AnyObject?, fallback: ThemeCaptionConfiguration?) {
        self.owner = owner

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
        assert(image1 != nil)
        button.tintColor = UIColor.clearColor()
        button.setBackgroundImage(image1, forState: .Normal)
        button.setBackgroundImage(image2, forState: .Highlighted)
        button.setBackgroundImage(image3, forState: .Selected)

        let position = self.position
        //println("pos: \(position)")
        let center = CGPointMake(button.center.x + position.x, button.center.y + position.y)

        if let glyph = self.glyph {
            assert(button.glyphView != nil)
            assert(button.glyphView.superview == button)
            button.glyphView.image = glyph
            button.glyphView.sizeToFit()
            button.glyphView.center = center
        } else {
            assert(button.captionLabel != nil)
            assert(button.captionLabel.superview == button)
            let (font, color) = self.font
            if let text = self.text {
                button.captionLabel.text = text
            }
            button.captionLabel.textColor = color
            button.captionLabel.font = font
            button.captionLabel.center = center
        }
    }

    lazy var images: (UIImage?, UIImage?, UIImage?) = {
        let sub = self.configuration["image"]
        let imageConfiguration = sub as Array<String!>?
        if imageConfiguration == nil || imageConfiguration!.count == 0 {
            return self.fallback.images
        }
        var images: [UIImage?] = []
        for imageName in imageConfiguration! {
            let image = self.owner.imageForFilename(imageName)
            assert(image != nil, "캡션 이미지를 찾을 수 없습니다.")
            images.append(image)
        }
        while images.count < 3 {
            let lastImage = images.last!
            assert(lastImage != nil)
            images.append(lastImage)
        }
        return (images[0], images[1], images[2])
    }()

    lazy var labelConfiguration: Dictionary<String, AnyObject>? = {
        let sub = self.configuration["label"]
//        println("label: \(sub)")
        assert(sub is Dictionary<String, AnyObject>, "'label' 설정 값의 서식이 맞지 않습니다. 딕셔너리가 필요합니다.")
        return sub as Dictionary<String, AnyObject>?
    }()

    lazy var text: String? = {
        if let config = self.labelConfiguration {
            let subText = config["text"]
            if subText is String {
                return subText as String
            } else {
                return nil
            }
        } else {
            return nil
        }
    }()

    lazy var glyph: UIImage? = {
        if let config = self.labelConfiguration {
            let subText = config["glyph"]
            if subText is String {
                return self.owner.imageForFilename(subText as String)
            }
        }
        return nil
    }()

    lazy var position: CGPoint = {
        if let config = self.labelConfiguration {
            let sub = config["position"]
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
            let subFont = config["font"]
            if subFont == nil {
                return fallback()
            }

//        println("font1: \(subFont)")
//        println("font2: \(subFont!)")

            assert(subFont is Dictionary<String, AnyObject>, "'font' 설정 값의 서식이 맞지 않습니다. 딕셔너리가 필요합니다.")

            let fontConfiguration = subFont as Dictionary<String, AnyObject>?
            var font: UIFont?

            let subFontName = fontConfiguration!["name"]
            let subFontSize = fontConfiguration!["size"]
            let fontSize = subFontSize as CGFloat? ?? UIFont.systemFontSize()
            if subFontName != nil {
                font = UIFont(name: subFontName as String, size: fontSize)
            } else {
                font = UIFont.systemFontOfSize(fontSize)
            }
            assert(font != nil, "올바른 폰트 이름이 아닙니다")

            let subFontColorCode = fontConfiguration!["color"]
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

