//
//  Theme.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 12..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class Theme {
    let name: String

    init(name: String) {
        self.name = name
    }

    func dataForFilename(name: String) -> NSData? {
        let rawData = preferences.themeResources[name]
        if rawData == nil {
            return nil
        }
        let data = NSData(base64EncodedString: rawData, options: NSDataBase64DecodingOptions(0))
        return data
    }

    func JSONObjectForFilename(name: String, error: NSErrorPointer) -> AnyObject! {
        let data = self.dataForFilename(name)
        assert(data != nil)
        return NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(0), error: error)
    }

    lazy var configuration: Dictionary<String, AnyObject> = {
        var error: NSError? = nil
        let JSONObject = self.JSONObjectForFilename("config.json", error: &error) as Dictionary<String, AnyObject>!
        assert(error == nil)
        assert(JSONObject != nil)
        return JSONObject!
    }()

    func imageForFilename(name: String) -> UIImage? {
        let data = self.dataForFilename(name)
        if data == nil {
            return nil
        } else {
            return UIImage(data: data)
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

    func appeal(button: UIButton) {
        let (image1, image2, image3) = self.images
        assert(image1 != nil)
        button.setBackgroundImage(image1, forState: .Normal)
        button.setBackgroundImage(image2, forState: .Highlighted)
        button.setBackgroundImage(image3, forState: .Selected)
        let (font, color) = self.font
        button.titleLabel.font = font
        button.setTitleColor(color, forState: .Normal)
        if self.text != nil {
            button.setTitle(self.text, forState: .Normal)
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

    lazy var text: String? = {
        let subLabel = self.configuration["label"]
        if subLabel == nil {
            return nil
        }
        let labelConfiguration = subLabel as Dictionary<String, AnyObject>
        let subText = labelConfiguration["text"]
        if subText is String {
            return subText as String
        } else {
            return nil
        }
    }()

    lazy var font: (UIFont, UIColor) = {
        func fallback() -> (UIFont, UIColor) {
            return self.fallback?.font ?? (UIFont.systemFontOfSize(UIFont.systemFontSize()), UIColor.blackColor())
        }

        let subLabel = self.configuration["label"]
        if subLabel == nil {
            return fallback()
        }
//        println("label1: \(subLabel)")
//        println("label2: \(subLabel!)")
        assert(subLabel is Dictionary<String, AnyObject>, "'label' 설정 값의 서식이 맞지 않습니다. 딕셔너리가 필요합니다.")
        let labelConfiguration = subLabel! as Dictionary<String, AnyObject>
        let subFont = labelConfiguration["font"]
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

