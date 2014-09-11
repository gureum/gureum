//
//  GRInputButton.m
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 20..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#import "GRInputButton.h"

@interface GRInputButton (private)

@property(retain) UIImageView *glyphView;
@property(retain) UILabel *captionLabel;

@end


@implementation GRInputEffectView

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 20, 20)];

    UIViewAutoresizing autoresizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    self->_backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self->_backgroundImageView.autoresizingMask = autoresizing;
    self->_textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self->_textLabel.autoresizingMask = autoresizing;
    return self;
}

@end


@implementation GRInputButton

- (id)_initGRInputButton {
    self.titleLabel.textColor = [UIColor clearColor];
    {
        UIImageView *view = [[UIImageView alloc] init];
        view.autoresizingMask = 0;
        [self addSubview:view];
        self->_glyphView = view;
    }
    {
        UILabel *view = [[UILabel alloc] init];
        view.autoresizingMask = 0;
        [self addSubview:view];
        self->_captionLabel = view;
    }
    {
        GRInputEffectView *view = [[GRInputEffectView alloc] init];
        view.alpha = .0;
        [self addSubview:view];
        self->_effectView = view;
    }

    [self addTarget:self action:@selector(touchAnimation:) forControlEvents:UIControlEventTouchDown];

    return self;
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

- (void)showEffectWithInsets:(UIEdgeInsets)insets {
    CGRect labelRect = self.effectView.textLabel.frame;
    labelRect.origin.x = insets.left;
    labelRect.origin.y = insets.top;
    self.effectView.textLabel.frame = labelRect;

    CGRect mainRect = self.effectView.textLabel.frame;
    mainRect.size.height += insets.top + insets.bottom;
    mainRect.size.width += insets.left + insets.right;
    mainRect.origin.x = self.frame.origin.x - insets.left;
    mainRect.origin.y = self.frame.origin.y - mainRect.size.height;
    self.effectView.frame = mainRect;

    [self.superview addSubview:self.effectView];

    [UIView animateWithDuration:0.1 animations:^(void) {
        self.effectView.alpha = 1.0;
    }];
}

- (void)touchAnimation:(UIButton *)button {
    [self showEffectWithInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
}

@end
