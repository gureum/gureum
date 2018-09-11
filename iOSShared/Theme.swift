//
//  Theme.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 8. 12..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

public class Theme {
    public func dataForFilename(name: String) -> Data? {
        assert(false)
        return nil
    }

    public func jsonObjectForFilename(name: String, error: NSErrorPointer) -> Any! {
        guard let data = self.dataForFilename(name: name) else {
            assert(false, "지정한 JSON 데이터 파일이 없습니다. \(name)")
            return nil
        }
        
        do {
            let result = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))
            return result
        } catch {
            let dataString = (data as NSData).stringUsingUTF8Encoding
            assert(false, "JSON 파일의 서식이 올바르지 않습니다.\(String(describing: error))\n\(data)\n\(String(describing: dataString))")
            return nil
        }
    }


    public func imageForFilename(name: String) -> UIImage? {
        return self.imageForFilename(name: name, withTopMargin: 0)
    }

    public func imageForFilename(name: String, withTopMargin margin: CGFloat) -> UIImage? {
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
        let jsonObject = self.jsonObjectForFilename(name: filename, error: &error) as! NSDictionary?
        assert(jsonObject != nil)
        return jsonObject!
    }()

    public func traitForName(traitName: String, topMargin: CGFloat) -> ThemeTrait {
        if let traits = self.mainConfiguration["trait"] as? NSDictionary {
            if let traitFilename = traits[traitName] as? String {
                var error: NSError? = nil
                let traitData: Any! = self.jsonObjectForFilename(name: traitFilename, error: &error)
                assert(error == nil, "trait 설정이 올바르지 않은 JSON파일입니다.")
                return ThemeTrait(owner: self, configuration: traitData, topMargin: topMargin)
            } else {
                assert(false, "지정한 trait에 대한 설정이 없습니다.")
            }
        } else {
            assert(false, "주 설정 파일에 trait 키가 없습니다.")
        }
        // asserted
        return ThemeTrait(owner: self, configuration: nil, topMargin: 0.0)
    }

    public func traitForSize(size: CGSize) -> ThemeTrait {
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
            //globalInputViewController?.log("unknown size: \(size)")
            //assert(false, "no coverage")
            return self.phonePortraitConfiguration
        }
    }

    public lazy var phonePortraitConfiguration: ThemeTrait = self.traitForName(traitName: "phone-portrait", topMargin: 6)
    public lazy var phoneLandscape480Configuration: ThemeTrait = self.traitForName(traitName: "phone-landscape480", topMargin: 3)
    public lazy var phoneLandscape568Configuration: ThemeTrait = self.traitForName(traitName: "phone-landscape568", topMargin: 3)
    public lazy var padPortraitConfiguration: ThemeTrait = self.phonePortraitConfiguration
    public lazy var padLandscapeConfiguration: ThemeTrait = self.phoneLandscape480Configuration
}

public class ThemeTrait {
    let configuration: NSDictionary!
    weak var owner: Theme!
    let topMargin: CGFloat
    var _captions: Dictionary<String, ThemeCaption> = [:]
    var _captionClasses: Dictionary<String, ThemeCaptionClass> = [:]

    init(owner: Theme, configuration: Any?, topMargin: CGFloat) {
        self.owner = owner
        self.topMargin = topMargin
        self.configuration = configuration as? NSDictionary
    }

    public lazy var backgroundImage: UIImage? = {
        let configFilename = self.configuration["background"] as? String
        let filename = configFilename ?? "background.png"
        return self.owner.imageForFilename(name: filename)
    }()

    public lazy var foregroundImage: UIImage? = {
        let configFilename = self.configuration["foreground"] as? String
        let filename = configFilename ?? "foreground.png"
        return self.owner.imageForFilename(name: filename)
    }()

    public func captionClassForKey(key: String) -> ThemeCaptionClass? {
        if let theme = self._captionClasses[key] {
            return theme
        } else {
            let theme: ThemeCaptionClass?
            if let sub: Any = self.configuration[key] {
                theme = ThemeCaptionClass(trait: self, configuration: sub)
            } else {
                theme = nil
            }
            self._captionClasses[key] = theme
            return theme
        }
    }

    public func hasCaptionForIdentifier(identifier: String) -> Bool {
        return self._captions[identifier] != nil
    }

    public func captionForIdentifier(identifier: String) -> ThemeCaption? {
        return self._captions[identifier]
    }

    public func captionForIdentifier(identifier: String, needsMargin: Bool, classes: () -> [ThemeCaptionClass?]) -> ThemeCaption {
        let theme = self._captions[identifier] ?? {
            let theme: ThemeCaption = {
                return ThemeCaption(trait: self, needsMargin: needsMargin, classes: classes())
                }()
            self._captions[identifier] = theme
            return theme
        }()
        return theme
    }

    public lazy var common: ThemeCaptionGroup = ThemeCaptionGroup(trait: self, group: "common")
    public lazy var qwerty: ThemeCaptionGroup = ThemeCaptionGroup(trait: self, group: "qwerty")
    public lazy var tenkey: ThemeCaptionGroup = ThemeCaptionGroup(trait: self, group: "tenkey")
    public lazy var numpad: ThemeCaptionGroup = ThemeCaptionGroup(trait: self, group: "numpad")
    public lazy var emoticon: ThemeCaptionGroup = ThemeCaptionGroup(trait: self, group: "emoticon")

    lazy var _baseCaption: ThemeCaption = self.captionForIdentifier(identifier: "_base", needsMargin: false, classes: { [self.common.base] })

    func captionClassesForGetters(getters: [(ThemeCaptionGroup) -> ThemeCaptionClass], inGroups groups: [ThemeCaptionGroup]) -> [ThemeCaptionClass?] {
        var classes: [ThemeCaptionClass?] = []
        for group in groups {
            for getter in getters {
                classes.append(getter(group))
            }
        }
        return classes
    }
}

public class ThemeCaptionClass {
    let configuration: [String: Any]
    weak var trait: ThemeTrait!

    init(trait: ThemeTrait, configuration: Any?) {
        self.trait = trait
        var given: Any = configuration ?? Dictionary<String, Any>()
        var full: [String: Any] = [
            "image": Array<String>(),
            "label": Dictionary<String, Any>(),
        ]

        if given is String {
            var sub: Any? = full["image"]
            var image = sub as! Array<NSString>
            image.append(given as! NSString)
        }
        else if given is [String?] {
            full["image"] = configuration
            var sub: Any? = full["image"]
            var image = sub as! Array<NSString>
        }
        else {
            full = given as! [String: Any?]
        }

        self.configuration = full
    }

    func _backgroundImageNames() -> [String] {
        if let sub: Any = self.backgroundConfiguration["image"] {
            return (sub is String ? [sub] : sub) as! [String]
        } else {
            return []
        }
    }

    lazy var backgroundConfiguration: Dictionary<String, Any> = self.configuration["background"] as? Dictionary<String, Any> ?? [:]

    lazy var labelConfiguration: Dictionary<String, Any> = self.configuration["label"] as? Dictionary<String, Any> ?? [:]

    lazy var fontConfiguration: Dictionary<String, Any> = self.labelConfiguration["font"] as? Dictionary<String, Any> ?? [:]

    lazy var effectConfiguration: Dictionary<String, Any> = self.configuration["effect"] as? Dictionary<String, Any> ?? [:]
}

public class ThemeCaptionGroup {
    weak var trait: ThemeTrait!
    let group: String

    init(trait: ThemeTrait, group: String) {
        self.trait = trait
        self.group = group
    }

    func classByName(key: String) -> ThemeCaptionClass {
        return ThemeCaptionClass(trait: self.trait, configuration: self.trait.configuration[self.group + "-" + key])
    }

    public lazy var base: ThemeCaptionClass = ThemeCaptionClass(trait: self.trait, configuration: self.trait.configuration[self.group])

    public lazy var key: ThemeCaptionClass = self.classByName(key: "key")
    public lazy var special: ThemeCaptionClass = self.classByName(key: "special")
    public lazy var function: ThemeCaptionClass = self.classByName(key: "function")
    
    public func row(row: Int) -> ThemeCaptionClass {
        return self.classByName(key: "row-\(row)")
    }
    
    public func key(key: String) -> ThemeCaptionClass {
        return self.classByName(key: "key-\(key)")
    }
    
    public func caption(key: String) -> ThemeCaptionClass {
        return self.classByName(key: "caption-\(key)")
    }
}

public class ThemeCaption {
    weak var trait: ThemeTrait!
    let needsMargin: Bool
    let classes: [ThemeCaptionClass?]
    lazy var topMargin: CGFloat = { return self.needsMargin ? self.trait.topMargin : 0 }()

    init(trait: ThemeTrait, needsMargin: Bool, classes: [ThemeCaptionClass?]) {
        self.trait = trait
        self.needsMargin = needsMargin
        self.classes = classes
    }

    func appealButton(button: GRInputButton) {
        let (image1, image2, image3) = self.backgroundImages
        //assert(image1 != nil)
        button.tintColor = UIColor.clear
        button.setBackgroundImage(image1, for: .normal)
        button.setBackgroundImage(image2, for: .highlighted)
        button.setBackgroundImage(image3, for: .selected)

        let color = self.backgroundColor
        button.backgroundColor = color

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

        button.effectBackgroundImage = self.effectBackgroundImage
    }

    func arrangeButton(button: GRInputButton) {
        let position = self.position
        //println("pos: \(position)")
        let center = CGPoint(x: button.frame.width / 2 + position.x, y: button.frame.height / 2 + position.y)

        button.glyphView.sizeToFit()
        button.glyphView.center = center
        //println("glyphView: \(button.glyphView.frame)")

        button.captionLabel.frame = button.bounds;
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
        frame.size.height -= self.topMargin
        frame.origin = CGPoint(x: insets.left, y: insets.top)
        button.effectView!.textLabel!.frame = frame

        frame.size.width += 12
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

    func attributeByGetter(getter: (ThemeCaptionClass) -> Any?, until: (Any?) -> Bool = { $0 != nil }) -> Any? {
        for cls in self.classes {
            if let cls = cls {
                let value: Any? = getter(cls)
                if until(value) {
                    return value
                }
            }
        }
        return nil
    }

    func _backgroundImages() -> (UIImage?, UIImage?, UIImage?) {
         if let imageNames = self.attributeByGetter(getter: { $0._backgroundImageNames() }, until: { ($0! as AnyObject).count > 0 }) as?  [String] {
            var images: [UIImage?] = []
            for imageName in imageNames {
                let image = self.trait.owner.imageForFilename(name: imageName, withTopMargin: self.topMargin)
                //assert(image != nil, "캡션 이미지를 찾을 수 없습니다. \(imageName)")
                images.append(image)
            }
            while images.count < 3 {
                let lastImage = images.last!
                //assert(lastImage != nil)
                images.append(lastImage)
            }
            return (images[0], images[1], images[2])
        } else {
            return (nil, nil, nil)
        }
    }

    public lazy var backgroundImages: (UIImage?, UIImage?, UIImage?) = self._backgroundImages()

    public lazy var backgroundColor: UIColor? = {
        if let colorExpression = self.attributeByGetter(getter: { $0.backgroundConfiguration["color"] }) as? String {
            return UIColor(htmlExpression: colorExpression)
        } else {
            return nil
        }
    }()

    public lazy var text: String? = {
        if let text = self.attributeByGetter(getter: { $0.labelConfiguration["text"] }) as? String {
            return text
        } else {
            return nil
        }
    }()

    public lazy var glyph: UIImage? = {
        if let text = self.attributeByGetter(getter: { $0.labelConfiguration["glyph"] }) as! String? {
            let image = self.trait.owner.imageForFilename(name: text)
            //println("glyph image: \(image)")
            return image
        } else {
            return nil
        }
    }()

    public lazy var position: CGPoint = {
        if let array = self.attributeByGetter(getter: {
            let value = $0.labelConfiguration["position"]
            print("position: \(value) \($0.labelConfiguration)")
            return value

            }, until: { $0 is [CGFloat] }) as! [Any]? {
            let position = CGPoint(x: array[0] as! CGFloat, y: array[1] as! CGFloat)
            return position
        } else {
            return CGPoint.zero
        }
    }()

    public lazy var font: (UIFont, UIColor) = {
        let name = self.attributeByGetter(getter: { $0.fontConfiguration["name"] }) as! String?
        let size = self.attributeByGetter(getter: { $0.fontConfiguration["size"] }) as? CGFloat ?? UIFont.systemFontSize
        let colorText = self.attributeByGetter(getter: { $0.fontConfiguration["color"] }) as! String?

        let font: UIFont
        if let name = name {
            font = UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
        } else {
            font = UIFont.systemFont(ofSize: size)
        }
        let color = colorText != nil ? UIColor(htmlExpression: colorText) : UIColor.darkText

        return (font, color!)
    }()

    public lazy var effectBackgroundImage: UIImage? = {
        if let name = self.attributeByGetter(getter: { $0.effectConfiguration["background"] }) as! String? {
            if let image = self.trait.owner.imageForFilename(name: name) {
                return image
            }
        }
        return nil
    }()

    public lazy var effectEdgeInsets: UIEdgeInsets = {
        if let rawInsets = self.attributeByGetter(getter: { $0.effectConfiguration["padding"] }) as! [CGFloat]? {
            let insets = UIEdgeInsetsMake(rawInsets[0], rawInsets[1], rawInsets[2], rawInsets[3])
            return insets
        }
        return UIEdgeInsets.zero
    }()

    public lazy var effectPosition: CGPoint = {
        if let rawPosition = self.attributeByGetter(getter: { $0.effectConfiguration["position"] }) as! [CGFloat]? {
            let position = CGPoint(x: rawPosition[0], y: rawPosition[1])
            return position
        }
        return CGPoint.zero
    }()
}

class CachedTheme: Theme {
    let theme: Theme
    var _cache: [String: Any?] = [:]

    init(theme: Theme) {
        //assert(!(theme.dynamicType is CachedTheme.Type))
        self.theme = theme
        super.init()
    }

    override func dataForFilename(name: String) -> Data? {
        let key = name + "_"
        let data: Any? = _cache[key] ?? {
            let data = self.theme.dataForFilename(name: name)
            self._cache[key] = data
            return data
        }()
        return data as? Data
    }

    override func imageForFilename(name: String, withTopMargin margin: CGFloat) -> UIImage? {
        let key = name + "_\(margin)"
        let data: Any? = _cache[key] ?? {
            let data = self.theme.imageForFilename(name: name, withTopMargin: margin)
            self._cache[key] = data
            return data
        }()
        return data as! UIImage?
    }
}

class BuiltInTheme: Theme {
    override func dataForFilename(name: String) -> Data? {
        return nil
        /*
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
                case "qwerty-glyph/40px-globe.png": return "iVBORw0KGgoAAAANSUhEUgAAAFAAAABcCAYAAAD50zLWAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkM2I3OWVkOC1iMmI2LTRmZjQtYjIzOC1mZjUxZTg2OWY1NjkiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RUU4ODUzMzczQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RUU4ODUzMzYzQzhGMTFFNDlGODdCRDlDQjhFMzM2NzAiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDoyMTMxZGQ1ZS1kOTQ1LTRlODUtYTAzZi1iZDlhYzY5OGQwMTQiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6ZDNiNzllZDgtYjJiNi00ZmY0LWIyMzgtZmY1MWU4NjlmNTY5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"
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
        */
    }
}

class ThemeResourceCoder {
    func key() -> NSData {
        let identifier = UIDevice.current.identifierForVendor!
        var UUIDBytes = [UInt8](repeating: 0, count: 16)
        //identifier.getUUIDBytes(UUIDBytes as UnsafeMutablePointer<UInt8>)
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
