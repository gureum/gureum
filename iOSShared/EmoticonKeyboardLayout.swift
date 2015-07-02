//
//  EmoticonKeyboardLayout.swift
//  Gureum
//
//  Created by Jeong YunWon on 2015. 6. 9..
//  Copyright (c) 2015년 youknowone.org. All rights reserved.
//

import UIKit

class EmoticonKeyboardView: KeyboardView {
    static let titleIcons = [
        "🕓", "😀", "🌲", "🍴", "🎉", "🏃", "🚕", "🎵", "^^",
    ]

    @IBOutlet var tableView: UITableView!
    @IBOutlet var footerBlurView: UIView!
    let dummyLabelButton = GRInputButton()

    lazy var sectionButtons: [GRInputButton] = {
        return map(enumerate(self.dynamicType.titleIcons), {
            let (index, title) = $0
            let button = GRInputButton()
            button.captionLabel.text = title
            button.tag = index
            return button
        })
    }()

    override var visibleButtons: [GRInputButton] {
        get {
            return [self.nextKeyboardButton, self.deleteButton, self.dummyLabelButton] + self.sectionButtons
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        /*
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
        */
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
        "자주 사용하는 항목", "사람", "자연", "음식 및 음료", "축하", "활동", "여행 및 장소", "사물 및 기호", "텍스트",
    ]
    static let numbersOfColumns = [
        6, 10, 10, 10, 10, 10, 10, 10, 5,
    ]

    var frequencyMap: [String: UInt] = preferences.emoticonFrequencies as! [String: UInt]
    var frequencyHistory = preferences.emoticonHistory
    lazy var favorites: [String] = self.populateFavorites()
    func populateFavorites() -> [String] {
        let scores = Array(self.frequencyMap.keys.map({ return ($0, self.frequencyMap[$0]!) }))
        let sorted = scores.sorted({
            let (text1, score1) = $0
            let (text2, score2) = $1
            if score1 == score2 {
                return self.frequencyHistory.indexOfObject(text1) < self.frequencyHistory.indexOfObject(text2)
            } else {
                return score1 > score2
            }
        })

        var emoticons: [String] = Array(sorted[0..<min(sorted.count, 24)].map({ (emoticon: String, score: UInt) -> String in return emoticon }))
        for emoticon in self.frequencyHistory as! [String] {
            if contains(emoticons, emoticon) {
                continue
            }
            emoticons.append(emoticon)
            if emoticons.count >= 30 {
                break
            }
        }
        return emoticons
    }


    var headerBackgroundViews: [Int:UIView] = [:]

    var emoticonView: EmoticonKeyboardView {
        get {
            return self.view as! EmoticonKeyboardView
        }
    }

    override class var toggleCaption: String {
        get { return "😀" }
    }

    override func themesForTrait(trait: ThemeTrait) -> [GRInputButton : ThemeCaption] {

        func functionCaption(name: String, row: Int) -> ThemeCaption {
            return trait.captionForIdentifier("emoticon-\(name)", needsMargin: self.dynamicType.needsMargin, classes: {
                trait.captionClassesForGetters([
                    { $0.classByName(name) },
                    { $0.row(row) },
                    { $0.function },
                    { $0.base },
                ], inGroups: [trait.emoticon, trait.common])
            })
        }

        func specialCaption(name: String, row: Int) -> ThemeCaption {
            return trait.captionForIdentifier("emoticon-\(name)", needsMargin: self.dynamicType.needsMargin, classes: {
                trait.captionClassesForGetters([
                    { $0.classByName(name) },
                    { $0.row(row) },
                    { $0.special },
                    { $0.base },
                ], inGroups: [trait.emoticon, trait.common])
            })
        }

        var themeMap = [
            self.view.nextKeyboardButton!: functionCaption("globe", 4),
            self.view.deleteButton!: functionCaption("delete", 4),
            self.emoticonView.dummyLabelButton: trait.captionForIdentifier("emoticon-header", needsMargin: self.dynamicType.needsMargin, classes: {
                trait.captionClassesForGetters([
                    { $0.classByName("header") },
                    { $0.base },
                    ], inGroups: [trait.emoticon, trait.common])
            })
        ]
        for button in self.emoticonView.sectionButtons {
            themeMap[button] = specialCaption("section", 4)
        }
        return themeMap
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

    override func captionThemeForTrait(trait: ThemeTrait, position: GRKeyboardLayoutHelper.Position) -> ThemeCaption {
        return trait._baseCaption
    }

    override func layoutDidLoadForHelper(helper: GRKeyboardLayoutHelper) {
        super.layoutDidLoadForHelper(helper)
        self.emoticonView.tableView.dataSource = self
        self.emoticonView.tableView.delegate = self

        let indexPath = NSIndexPath(forRow: 0, inSection: preferences.emoticonSection) as NSIndexPath
        let position = UITableViewScrollPosition.Top
        self.emoticonView.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: position, animated: false)

        for button in self.emoticonView.sectionButtons {
            button.addTarget(self, action: "selectSection:", forControlEvents: .TouchUpInside)
        }
    }

    override func layoutDidLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        super.layoutDidLayoutForHelper(helper, forRect: rect)

        self.emoticonView.footerBlurView.backgroundColor = self.emoticonView.dummyLabelButton.backgroundColor
        self.emoticonView.footerBlurView.alpha = 0.9
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
            return [self.view.nextKeyboardButton] + self.emoticonView.sectionButtons + [self.view.deleteButton]
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

    override func layoutWillLayoutForHelper(helper: GRKeyboardLayoutHelper, forRect rect: CGRect) {
        super.layoutWillLayoutForHelper(helper, forRect: rect)

        let size = rect.size
        let height = self.helper(self.helper, heightOfRow: 1, forSize: size)
        for button in [self.view.nextKeyboardButton, self.view.deleteButton] {
            let width = size.width / 6
            button.frame.size = CGSizeMake(width, height)
        }
        for button in self.emoticonView.sectionButtons {
            button.frame.size = CGSizeMake(size.width * 4 / 6 / CGFloat(self.dynamicType.titles.count), height)
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dynamicType.table.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            return 10
        } else {
            return tableView.rowHeight
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let emoticons = section == 0 ? self.favorites : self.dynamicType.table[section]
        let length = count(emoticons)
        let numberOfRow  = (length - 1) / self.dynamicType.numbersOfColumns[section] + 1
        return numberOfRow + 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        if indexPath.row == 0 || indexPath.row == self.tableView(tableView, numberOfRowsInSection: section) - 1 {
            let identifier = "margin"
            let cell = (tableView.dequeueReusableCellWithIdentifier(identifier) as! UITableViewCell?) ?? {
                let cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
                cell.backgroundColor = UIColor.clearColor()
                return cell
            }()
            return cell
        }

        let identifier = "cell_\(section)"
        let numberOfColumns = self.dynamicType.numbersOfColumns[indexPath.section]
        let cell = (tableView.dequeueReusableCellWithIdentifier(identifier) as! UITableViewCell?) ?? {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
            cell.backgroundColor = UIColor.clearColor()
            for _ in 0..<numberOfColumns {
                let button = GRInputButton(frame: CGRectMake(0, 0, 60, 28))
                button.addTarget(self, action: "input:", forControlEvents: .TouchUpInside)
                button.addTarget(nil, action: "input:", forControlEvents: .TouchUpInside)

                let font = button.titleLabel?.font.fontWithSize(section == 8 ? 12 : 28)
                button.titleLabel?.font = font
                button.titleLabel?.lineBreakMode = .ByClipping
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.contentView.addSubview(button)
            }
            return cell
        }()

        let emoticons = section == 0 ? self.favorites : self.dynamicType.table[section]
        let length = count(emoticons)

        let margin: CGFloat = 8.0
        let buttonWidth = (tableView.frame.size.width - 2 * margin) / CGFloat(numberOfColumns)

        let row = indexPath.row - 1
        for column in 0..<numberOfColumns {
            let position = row * numberOfColumns + column
            if position >= length {
                break
            }
            let button = cell.contentView.subviews[column] as! GRInputButton
            button.frame = CGRectMake(buttonWidth * CGFloat(column) + margin, 0, buttonWidth, 28)
            let emoticon = emoticons[position]
            button.tag = section
            button.sequence = emoticon
            button.setTitle(emoticon, forState: .Normal)
            if section == 0 {
                let font = button.titleLabel?.font.fontWithSize(contains(self.dynamicType.table[8], emoticon) ? 10 : 28)
                button.titleLabel?.font = font
            }
        }

        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dynamicType.titles[section]
    }

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView

        let backgroundView = self.headerBackgroundViews[section] ?? {
            let blurView = UIView()
            blurView.backgroundColor = self.emoticonView.dummyLabelButton.backgroundColor
            blurView.alpha = 0.9
            return blurView
            /*
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
            */
        }()

        headerView.backgroundView = backgroundView
        let modelLabel = self.emoticonView.sectionButtons[0].captionLabel
        headerView.textLabel.font = modelLabel.font
        headerView.textLabel.textColor = modelLabel.textColor
    }

    func input(sender: GRInputButton) {
        preferences.emoticonSection = sender.tag
        self.frequencyMap[sender.sequence] = (self.frequencyMap[sender.sequence] ?? 0) + 1
        preferences.emoticonFrequencies = self.frequencyMap

        var history = (self.frequencyHistory as NSArray).mutableCopy() as! NSMutableArray
        history.removeObject(sender.sequence)
        history.insertObject(sender.sequence, atIndex: 0)
        self.frequencyHistory = history.copy() as! NSArray as! [String]
        preferences.emoticonHistory = history

        self.favorites = self.populateFavorites()
        self.emoticonView.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }

    func selectSection(sender: GRInputButton) {
        let section = sender.tag
        let indexPath = NSIndexPath(forRow: 0, inSection: section) as NSIndexPath
        let position = UITableViewScrollPosition.Top
        self.emoticonView.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: position, animated: false)
    }
}
