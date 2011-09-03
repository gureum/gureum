//
//  CIMComposer.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 2..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMCommon.h"

/*!
    @brief 실제로 문자를 합성하는 합성기의 프로토콜
    @discussion 입력기 전체의 상태에 영향을 끼치는 처리를 마친 후 출력할 글자를 조합하기 위해 CIMComposer로 입력을 전달한다. 기본적으로 자판마다 하나씩 구현하게 된다.
*/

// 한글 합성기 인터페이스에 의존하고 있다. 다듬자...
@protocol CIMComposer<IMKServerInputTextData>
//! @property
@property(nonatomic, readonly) NSString *composedString;
//! @property
@property(nonatomic, readonly) NSString *commitString;
//! @method
- (NSString *)endComposing;
@optional

@end


@interface CIMBaseComposer : NSObject<CIMComposer> {
    NSString *originalString;
}
@property(nonatomic, retain) NSString *originalString;

@end