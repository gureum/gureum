//
//  ICUtility.h
//  IdealCocoa
//
//  Created by youknowone on 10. 1. 31..
//  Copyright 2010 3rddev.org. All rights reserved.
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//	
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//	
//	You should have received a copy of the GNU General Public License
//	along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/*	IdealCocoa debug mode
 *
 *	To take benefit of this feature, do one of below:
 *	1. define IC_DEBUG
 *	2. define DEBUG (xcode4 default) or CONFIG_Debug or CONFIG_Deployment to define IC_DEBUG
 */

#ifndef IC_DEBUG
	#if defined(DEBUG) || defined(CONFIG_Debug) || defined(CONFIG_Development)
		#define IC_DEBUG 1
	#else
		#define IC_DEBUG 0
	#endif
#endif

/*	Debugtime-only log and assertion
 *
 *	ICLog will call NSLog if TAG is NOT FALSE
 *	ICAssert and ICLogAssert will assert by COND
 */

#if IC_DEBUG
	#define ICLog(TAG, ...) { if ( TAG ) __ICLog([NSString stringWithFormat:__VA_ARGS__], __FILE__, __LINE__); }
	#define ICAssert(COND)	assert(COND)
	#define ICLogAssert(COND, ...) { if ( !COND ) __ICLog([NSString stringWithFormat:__VA_ARGS__], __FILE__, __LINE__); assert(COND); }
#else
	#define ICLog(TAG, ...)
	#define ICAssert(COND)
	#define ICLogAssert(COND, ...)
#endif

#if defined(__cplusplus)
	#define ICEXTERN extern "C"
#else
	#define ICEXTERN extern
#endif

//	__ICUNSTABLE marked features can be removed without notice
#define __ICUNSTABLE __deprecated
//	__ICTESTING marked features can be renamed or reimplemented without notice
#define __ICTESTING
//	__ICDEPRECATED marked featured will be removed on next major update
#define __ICDEPRECATED __deprecated

//	DO NOT CALL THIS DIRECTLY!
//	See 'ICLog' to use this feature
ICEXTERN void __ICLog(NSString *log, char *filename, int line);
