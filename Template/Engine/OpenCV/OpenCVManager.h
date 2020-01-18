//
//  OpenCVManager.h
//  GrabCut
//
//  Created by Endless Summer on 2019/12/30.
//  Copyright © 2019 flow. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVManager : NSObject

- (nullable UIImage *)doGrabCut:(UIImage*)sourceImage foregroundRect:(CGRect)rect iterationCount:(int)iterationCount;

@end

NS_ASSUME_NONNULL_END
