//
//  GRInputButton.m
//  Gureum
//
//  Created by Jeong YunWon on 2014. 8. 20..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#import <UIKitExtension/UIKitExtension.h>
#import "GRInputButton.h"

@interface GRInputButton () {
    GRInputEffectView *_effectView;
    UIImageView *_glyphView;
    UILabel *_captionLabel;
}

@end


@interface GRInputEffectView () {

}

- (void)arrange;

@end


@implementation GRInputButton

- (id)_initGRInputButton {
    self.titleLabel.textColor = [UIColor clearColor];
//    self.layer.borderWidth = 1.0f;
//    self.layer.borderColor = [UIColor redColor].CGColor;
//    self.layer.cornerRadius = 5.0f;
    return self;
}

- (UIImageView *)glyphView {
    if (self->_glyphView == nil) {
        UIImageView *view = [[UIImageView alloc] init];
        view.autoresizingMask = 0;
        [self addSubview:view];
        self->_glyphView = view;
    }
    return self->_glyphView;
}

- (UILabel *)captionLabel {
    if (self->_captionLabel == nil) {
        UILabel *view = [[UILabel alloc] init];
        view.textAlignment = NSTextAlignmentCenter;
        view.autoresizingMask = 0;
        [self addSubview:view];
        self->_captionLabel = view;
    }
    return self->_captionLabel;
}

- (GRInputEffectView *)effectView {
    if (self->_effectView == nil) {
        GRInputEffectView *view = [[GRInputEffectView alloc] init];
        self->_effectView = view;
        self.effectView.hidden = YES;
        self.effectView.textLabel.text = self.captionLabel.text;
    }
    return self->_effectView;
}

- (instancetype)init {
    self = [super init];
    return [self _initGRInputButton];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return [self _initGRInputButton];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return [self _initGRInputButton];
}

- (void)showEffect {
    if (self.enabled) {
        [self.effectView setHidden:NO animated:YES];
    }
}

- (void)hideEffect {
    [self->_effectView setHidden:YES animated:YES];
}

- (void)arrange {
    if (self->_effectView) {
        [self.effectView arrange];
    }
}

- (NSString *)title {
    return self.captionLabel.text;
}

- (void)setTitle:(NSString *)title {
    self.captionLabel.text = title;
    self->_effectView.textLabel.text = title;
}

- (UIImage *)effectBackgroundImage {
    return self->_effectView.backgroundImageView.image;
}

- (void)setEffectBackgroundImage:(UIImage *)image {
    if (image) {
        self.effectView.backgroundImageView.image = image;
    } else {
        self->_effectView.backgroundImageView.image = image;
    }
}

- (UInt32)keycode {
    if (self.keycodes.count == 0) {
        return 0;
    }
    return [self.keycodes[0] unsignedIntValue];
}

- (void)setKeycode:(UInt32)keycode {
    self.keycodes = @[@(keycode)];
}

- (UInt32)keycodeAtIndex:(NSUInteger)index {
    if (self.keycodes.count > index) {
        return [self.keycodes[index] unsignedIntValue];
    }
    return self.keycode;
}

@end


@implementation GRInputEffectView

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 32, 46)];

    //UIViewAutoresizing autoresizing = UIViewAutoresizingFlexibleAll;

    self->_backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self->_backgroundImageView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.75];
    self->_backgroundImageView.layer.cornerRadius = 12.0;
    self->_backgroundImageView.clipsToBounds = true;
    //self->_backgroundImageView.autoresizingMask = autoresizing;
    [self addSubview:self.backgroundImageView];

    self->_textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    //self->_textLabel.backgroundColor = [UIColor blueColor];
    self->_textLabel.textAlignment = NSTextAlignmentCenter;
    //self->_textLabel.autoresizingMask = autoresizing;
    [self addSubview:self.textLabel];

    return self;
}

- (void)arrange {
    self.backgroundImageView.frame = self.bounds;
    self.textLabel.frame = self.bounds;
}

@end
