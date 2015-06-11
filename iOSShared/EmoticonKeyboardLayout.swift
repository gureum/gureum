//
//  EmoticonKeyboardLayout.swift
//  Gureum
//
//  Created by Jeong YunWon on 2015. 6. 9..
//  Copyright (c) 2015년 youknowone.org. All rights reserved.
//

import UIKit

class EmoticonKeyboardView: KeyboardView {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var footerBlurView: UIVisualEffectView!

    override var visibleButtons: [GRInputButton] {
        get {
            return [self.nextKeyboardButton, self.spaceButton, self.deleteButton]
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let opaqueColor = UIColor(white: 0.0, alpha: 0.90).CGColor
        let medianColor = UIColor(white: 0.0, alpha: 0.60).CGColor
        let transparentColor = UIColor(white: 0.0, alpha: 0.0).CGColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.footerBlurView.bounds
        gradientLayer.colors = [transparentColor, medianColor, opaqueColor]
        gradientLayer.locations = [0.0, 0.15, 0.3, 1.0]
        gradientLayer.startPoint = CGPointMake(0.5, 0.0)
        gradientLayer.endPoint = CGPointMake(0.5, 1.0)
        self.footerBlurView.layer.mask = gradientLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.foregroundEventView.removeFromSuperview()
    }
}

class EmoticonKeyboardLayout: KeyboardLayout, UITableViewDataSource, UITableViewDelegate {
    static let table = NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: "res://emoticon.json".smartURL())!, options: NSJSONReadingOptions(0), error: nil) as! [[String]]
    static let titles = [
        "사람", "자연", "음식 및 음료", "축하", "활동", "여행 및 장소", "사물 및 기호", "텍스트",
    ]
    static let numbersOfColumns = [
        10, 10, 10, 10, 10, 10, 10, 5,
    ]

    var emoticonButtons = [:]
    var headerBackgroundViews: [Int:UIView] = [:]

    var emoticonView: EmoticonKeyboardView {
        get {
            return self.view as! EmoticonKeyboardView
        }
    }

    override class var toggleCaption: String {
        get { return "😀" }
    }

    override func themesForTrait(trait: ThemeTraitConfiguration) -> [GRInputButton : ThemeCaptionConfiguration] {
        return [
            self.view.nextKeyboardButton!: trait.tenkeySpecialKeyCaption,
            self.view.spaceButton!: trait.tenkeySpecialKeyCaption,
            self.view.deleteButton!: trait.tenkeySpecialKeyCaption,
        ]
    }

    override class func loadContext() -> UnsafeMutablePointer<()> {
        return context_create(bypass_phase(), bypass_phase(), bypass_decoder())
    }

    override class func loadView() -> EmoticonKeyboardView {
        let view = EmoticonKeyboardView(nibName: "EmoticonLayout", bundle: nil)
        return view
    }


    func keyForPosition(position: GRKeyboardLayoutHelper.Position, shift: Bool) -> UnicodeScalar {
        return UnicodeScalar(0)
    }

    override func adjustTraits(traits: UITextInputTraits) {

    }

    override func captionThemeForTrait(trait: ThemeTraitConfiguration, position: GRKeyboardLayoutHelper.Position) -> ThemeCaptionConfiguration {
        return trait.defaultCaption
    }

    override func layoutDidLoadForHelper(helper: GRKeyboardLayoutHelper) {
        super.layoutDidLoadForHelper(helper)
        self.emoticonView.tableView.dataSource = self
        self.emoticonView.tableView.delegate = self
    }

    override func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int {
        return 2
    }

    override func helper(helper: GRKeyboardLayoutHelper, heightOfRow row: Int, forSize size: CGSize) -> CGFloat {
        if row == 0 {
            return size.height - (size.height / 5.4)
        } else {
            return size.height / 5.4
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow row: Int) -> Array<UIButton> {
        if row == 0 {
            return []
        } else {
            return self.view.visibleButtons
        }
    }

    override func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow row: Int) -> Array<UIButton> {
        return []
    }

    override func helper(helper: GRKeyboardLayoutHelper, buttonForPosition position: GRKeyboardLayoutHelper.Position) -> GRInputButton {
        let button = GRInputButton.buttonWithType(.System) as! GRInputButton
        return button
    }

    override func helper(helper: GRKeyboardLayoutHelper, titleForPosition position: GRKeyboardLayoutHelper.Position) -> String {
        return ""
    }

    override func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow row: Int) -> Int {
        return 0
    }

    override func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow: Int, forSize: CGSize) -> CGFloat {
        return 0
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dynamicType.table.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let emoticons = self.dynamicType.table[section]
        let length = count(emoticons)
        let numberOfRow  = (length - 1) / self.dynamicType.numbersOfColumns[section] + 1
        return numberOfRow
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell?) ?? {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }()

        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }

        let emoticons = self.dynamicType.table[indexPath.section]
        let length = count(emoticons)

        let numberOfcolumns = self.dynamicType.numbersOfColumns[indexPath.section]
        let margin: CGFloat = 8.0
        let buttonWidth = (tableView.frame.size.width - 2 * margin) / CGFloat(numberOfcolumns)

        for column in 0..<numberOfcolumns {
            let position = indexPath.row * numberOfcolumns + column
            if position >= length {
                break
            }
            let button = GRInputButton(frame: CGRectMake(buttonWidth * CGFloat(column) + margin, 0, 28, buttonWidth))
            let emoticon = emoticons[position]
            button.sequence = emoticon
            button.setTitle(emoticon, forState: UIControlState.Normal)
            let font = button.titleLabel?.font.fontWithSize(30.0)
            let fontSize = (emoticon as NSString).boundingRectWithSize(CGSizeMake(30, 30), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font] as! [NSObject: AnyObject!], context: nil)
            button.titleLabel?.font = button.titleLabel?.font.fontWithSize(30.0)
            cell.contentView.addSubview(button)
            button.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)
        }

        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dynamicType.titles[section]
    }

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView

        let backgroundView = self.headerBackgroundViews[section] ?? {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
            let opaqueColor = UIColor(white: 0.0, alpha: 0.90).CGColor
            let medianColor = UIColor(white: 0.0, alpha: 0.60).CGColor
            let transparentColor = UIColor(white: 0.0, alpha: 0.0).CGColor
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [transparentColor, medianColor, opaqueColor, opaqueColor, medianColor, transparentColor]
            gradientLayer.locations = [0.0, 0.1, 0.3, 0.7, 0.9, 1.0]
            gradientLayer.startPoint = CGPointMake(0.5, 0.0)
            gradientLayer.endPoint = CGPointMake(0.5, 1.0)
            blurView.layer.mask = gradientLayer
            self.headerBackgroundViews[section] = blurView
            return blurView
        }()

        headerView.backgroundView = backgroundView
        headerView.textLabel.font = self.view.spaceButton.captionLabel.font
        headerView.textLabel.textColor = self.view.spaceButton.captionLabel.textColor
    }
/*
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return " - "
    }
*/
}
