//
//  GRInputButton.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 6. 4..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

class GRInputButton: UIButton {
    lazy var glyphView: UIImageView = {
        let imageView = UIImageView()
        self.addSubview(imageView)
        return imageView
    }()

    lazy var captionLabel: UILabel = {
        let label = UILabel()
        self.addSubview(label)
        return label
    }()

    func _init() {
//        self.layer.cornerRadius = 5.0
//        self.layer.masksToBounds = true;

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self._init()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        self._init()
    }

}
