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


@implementation GRInputButton

@synthesize glyphView=_glyphView;
@synthesize captionLabel=_captionLabel;

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

@end
