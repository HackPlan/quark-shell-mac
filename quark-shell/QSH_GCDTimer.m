//
//  QSH_GCDTimer.m
//  Pomotodo
//
//  Created by c4605 on 2017/1/12.
//  Copyright © 2017年 HackPlan. All rights reserved.
//

#import "QSH_GCDTimer.h"

@interface QSH_GCDTimer () {
    dispatch_source_t _timer;
    bool _invalidated;
}

@property (nonatomic) NSNumber *interval;
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) bool repeats;
@property (nonatomic) QSH_GCDTimerBlock block;

@end

@implementation QSH_GCDTimer

#pragma mark - public

+ (QSH_GCDTimer *)timerWithTimeInterval:(NSNumber *)interval
                                inQueue:(dispatch_queue_t)queue
                                repeats:(BOOL)repeats
                                  block:(QSH_GCDTimerBlock)block
{
    QSH_GCDTimer *timer = [[QSH_GCDTimer alloc] init];
    timer.interval = interval;
    timer.queue = queue;
    timer.repeats = repeats;
    timer.block = block;
    [timer start];
    return timer;
}

- (void)invalidate
{
    _invalidated = YES;
    if (self.repeats) {
        dispatch_cancel(_timer);
        _timer = nil;
    }
}

#pragma mark - private

- (void)start
{
    uint64_t interval = [self.interval unsignedLongLongValue] * NSEC_PER_MSEC;
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, interval);
    
    if (self.repeats) {
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
        dispatch_source_set_timer(_timer, startTime, interval, 0);
        dispatch_source_set_event_handler(_timer, ^{
            [self onDispatchTimeout];
        });
        dispatch_resume(_timer);
    } else {
        dispatch_after(startTime, self.queue, ^{
            [self onDispatchTimeout];
        });
    }
}

- (void)onDispatchTimeout
{
    if (!_invalidated) {
        self.block(self);
    }
}

@end
