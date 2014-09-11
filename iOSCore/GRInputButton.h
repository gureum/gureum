//
//  GRInputButton.h
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 20..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GRInputEffectView: UIView

@property(readonly) UIImageView *backgroundImageView;
@property(readonly) UILabel *textLabel;

@end


@interface GRInputButton: UIButton

@property(readonly) UIImageView *glyphView;
@property(readonly) UILabel *captionLabel;
@property(readonly) GRInputEffectView *effectView;

@end
