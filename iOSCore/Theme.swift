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

    func pathForResource(name: String?) -> String? {
        return NSBundle.mainBundle().pathForResource(name, ofType: nil, inDirectory: self.name)
    }

    func pathForResource(name: String?, ofType: String?) -> String? {
        return NSBundle.mainBundle().pathForResource(name, ofType: ofType, inDirectory: self.name)
    }

    lazy var configuration: [String: AnyObject?] = {
        let path = self.pathForResource("config", ofType: "json")
        var error: NSError? = nil
        let data = NSData.dataWithContentsOfFile(path, options: NSDataReadingOptions(0), error: &error)
        assert(error == nil, "설정 파일을 찾을 수 없습니다.")
        assert(data != nil, "설정 파일을 읽을 수 없습니다.")
        let JSONObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error:&error) as Dictionary<String, AnyObject>?
        assert(error == nil, "설정 파일에 오류가 있습니다.")
        assert(JSONObject != nil, "설정 파일을 해석할 수 없습니다.")
        return JSONObject!
    }()

    func imageForFilename(name: String) -> UIImage? {
        let path = self.pathForResource(name as String?)
        if path == nil{
            return nil
        } else {
            return UIImage(contentsOfFile: path)
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

    lazy var defaultCaption: ThemeCaptionConfiguration = ThemeCaptionConfiguration(owner: self, configuration: nil, fallback: nil)

    func captionForKey(key: String, fallback: ThemeCaptionConfiguration?) -> ThemeCaptionConfiguration {
        let sub = self.configuration[key]
        if sub == nil {
            return fallback!
        } else {
            return ThemeCaptionConfiguration(owner: self, configuration: sub!, fallback: nil)
        }
    }

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

    lazy var images: (UIImage?, UIImage?, UIImage?) = {
        let sub = self.configuration["image"]
        let imageConfiguration = sub as Array<String!>?
        if imageConfiguration == nil || imageConfiguration!.count == 0 {
            return self.fallback.images
        }
        var images: [UIImage?] = []
        for imageName in imageConfiguration! {
            let path = self.owner.pathForResource(imageName)
            let image = UIImage(contentsOfFile: path) as UIImage!
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

    lazy var font: UIFont = {
        func fallback() -> UIFont {
            if self.fallback != nil {
                let font = self.fallback.font
                if font != nil {
                    return font
                }
            }
            return UIFont.systemFontOfSize(UIFont.systemFontSize())
        }

        let sub = self.configuration["label"]
        let labelConfiguration = sub as Dictionary<String, AnyObject>
        let fontName = labelConfiguration["font"]
        var font: UIFont?
        if fontName == nil {
            return fallback()
        } else {
            font = UIFont(name: fontName as String, size: UIFont.systemFontSize())
            assert(font != nil, "올바른 폰트 이름이 아닙니다")
        }
        if font == nil {
            font = fallback()
        }
        return font!
    }()
}
