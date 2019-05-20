//
//  GRInputButton.h
//  Gureum
//
//  Created by Jeong YunWon on 2014. 8. 20..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

@import UIKit


@class GRInputEffectView;

@interface GRInputButton: UIButton

@property(readonly) UIImageView *glyphView;
@property(readonly) UILabel *captionLabel;
@property(readonly) GRInputEffectView *effectView;

@property(nonatomic,copy) NSString *title;
@property(nonatomic,strong) UIImage *effectBackgroundImage;
@property(nonatomic,copy) NSArray *keycodes;
@property(nonatomic,assign) UInt32 keycode;
@property(nonatomic,copy) NSString *sequence;

- (void)showEffect;
- (void)hideEffect;
- (void)arrange;
- (UInt32)keycodeAtIndex:(NSUInteger)index;

@end


@interface GRInputEffectView: UIView

@property(readonly) UIImageView *backgroundImageView;
@property(readonly) UILabel *textLabel;

@end
