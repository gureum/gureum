//
//  CIMInputHandler.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMCommon.h"

@class CIMInputManager;

/*!
    @brief  입력기에 들어온 입력의 처리를 적절히 분배한다.
 
    입력기에서 외부입력을 처리하여 우선순위에 따라 입력을 순서대로 전달한다.
    아직 합성기로 전달하는 역할만 하고 있다.
*/
@interface CIMInputHandler : NSObject<CIMInputTextDelegate> {
@private
    CIMInputManager *manager;
}

@property(nonatomic, readonly) CIMInputManager *manager;
- (void)setManager:(CIMInputManager *)aManager;

//! @brief  입력을 분배할 manager로 초기화
- (id)initWithManager:(CIMInputManager *)manager;

@end
