//
//
//  QSPerformanceMonitor.h
//  QSPerformanceMonitor
//
//  代码千万行，注释第一行！
//  编码不规范，同事泪两行。
//
//  Created by fqs on 2019/4/23.
//  Copyright © 2019 fqs. All rights reserved.
//
    

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QSPerformanceMonitor : NSObject
+ (instancetype)shareInstance;
- (void)startMonitor;
- (void)stopMonitor;
@end

NS_ASSUME_NONNULL_END
