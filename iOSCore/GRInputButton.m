//
//  GRInputButton.m
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 20..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#import <UIKitExtension/UIKitExtension.h>
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
        //view.alpha = .0;
        self->_effectView = view;
    }

    [self addTarget:self action:@selector(touchAnimation:) forControlEvents:UIControlEventTouchDown];
    self.effectView.hidden = YES;
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

- (void)arrangeEffectViewWithInsets:(UIEdgeInsets)insets {
    if (self.effectView.superview != self.superview) {
        [self.superview addSubview:self.effectView];
    }
    {
        CGRect frame = self.frame;
        frame.origin.x = insets.left;
        frame.origin.y = insets.top;
        self.effectView.textLabel.frame = frame;
    }

    //* original implementation
    {
//        CGRect frame = self.effectView.textLabel.frame;
//        frame.size.height += insets.top + insets.bottom;
//        frame.size.width += insets.left + insets.right;
//        frame.origin.x = self.frame.origin.x - insets.left;
//        frame.origin.y = self.frame.origin.y - frame.size.height;
//        self.effectView.frame = frame;
    }
    {
        CGRect frame = self.effectView.textLabel.frame;
        frame.size.height += insets.top + insets.bottom;
        frame.size.width += insets.left + insets.right;
        if (self.center.x <= self.superview.frame.size.width / 2) {
            frame.origin.x = self.frame.origin.x + self.frame.size.width;
        } else {
            frame.origin.x = self.frame.origin.x - frame.size.width;
        }
        frame.origin.y = self.frame.origin.y - insets.top;
        self.effectView.frame = frame;
    }
}

- (void)showEffect {
    self.effectView.backgroundColor = [UIColor redColor];
    [self.effectView setHidden:NO animated:YES];
}

- (void)hideEffect {
    [self.effectView setHidden:YES animated:YES];
}

@end
