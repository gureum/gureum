//
//  GRInputButton.m
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 20..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#import <UIKitExtension/UIKitExtension.h>
#import "GRInputButton.h"

@interface GRInputButton () {
    GRInputEffectView *_effectView;
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

    return self;
}

- (GRInputEffectView *)effectView {
    if (self->_effectView == nil) {
        GRInputEffectView *view = [[GRInputEffectView alloc] init];
        self->_effectView = view;
        self.effectView.hidden = YES;
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
    [self.effectView setHidden:NO animated:YES];
}

- (void)hideEffect {
    [self.effectView setHidden:YES animated:YES];
}

@end


@implementation GRInputEffectView

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 20, 20)];

    UIViewAutoresizing autoresizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    self->_backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self->_backgroundImageView.autoresizingMask = autoresizing;
    [self addSubview:self.backgroundImageView];
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = autoresizing;
    [self addSubview:label];
    self->_textLabel = label;
    return self;
}

@end
