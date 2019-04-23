//
//
//  QSPerformanceMonitor.m
//  QSPerformanceMonitor
//
//  代码千万行，注释第一行！
//  编码不规范，同事泪两行。
//
//  Created by fqs on 2019/4/23.
//  Copyright © 2019 fqs. All rights reserved.
//
    

#import "QSPerformanceMonitor.h"

@interface QSPerformanceMonitor() {
    CFRunLoopObserverRef _observer;
    CFRunLoopActivity _activity;
    int _timeoutCount;
    @public
    dispatch_semaphore_t _semaphore;
}
@end

@implementation QSPerformanceMonitor

+ (instancetype)shareInstance {
    static QSPerformanceMonitor *monitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[QSPerformanceMonitor alloc] init];
    });
    return monitor;
}

void runloopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    QSPerformanceMonitor *monitor = (__bridge QSPerformanceMonitor *)info;
    monitor->_activity = activity;
    dispatch_semaphore_signal(monitor->_semaphore);
    
    if (activity == kCFRunLoopEntry) {
        NSLog(@"kCFRunLoopEntry");
    } else if (activity == kCFRunLoopBeforeTimers) {
        NSLog(@"kCFRunLoopBeforeTimers");
    } else if (activity == kCFRunLoopBeforeSources) {
        NSLog(@"kCFRunLoopBeforeSources");
    } else if (activity == kCFRunLoopBeforeWaiting) {
        NSLog(@"kCFRunLoopBeforeWaiting");
    } else if (activity == kCFRunLoopAfterWaiting) {
        NSLog(@"kCFRunLoopAfterWaiting");
    } else if (activity == kCFRunLoopExit) {
        NSLog(@"kCFRunLoopExit");
    }
}

- (void)startMonitor {
    if (_observer) return;

    _semaphore = dispatch_semaphore_create(0);

    CFRunLoopObserverContext context = {0, (__bridge void *)self, NULL, NULL};
    _observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runloopObserverCallBack, &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (YES) {
            long flag = dispatch_semaphore_wait(self->_semaphore, dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC));

            if (flag == 0) {
                //未超50ms
                self->_timeoutCount = 0;
            } else {
                //可能关闭了监听
                if (!(self->_observer)) {
                    self->_timeoutCount = 0;
                    self->_semaphore = 0;
                    self->_activity = 0;
                    return;
                }
                
                //超时50ms
                if (self->_activity == kCFRunLoopBeforeSources || self->_activity == kCFRunLoopAfterWaiting) {
                    //假定连续5次超时50ms认为卡顿
                    if (++(self->_timeoutCount) >= 5) {
                        self->_timeoutCount = 0;
                        NSLog(@"出现卡顿了============================================");
                        //通过PLCrashReporter, KSCrash获取当前堆栈，然后上传至服务器
                    }
                }
            }
        }
    });
}

- (void)stopMonitor {
    if (!_observer) return;
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
    _observer = NULL;
}


@end
