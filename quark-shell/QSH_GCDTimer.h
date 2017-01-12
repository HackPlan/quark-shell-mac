//
//  QSH_GCDTimer.h
//  Pomotodo
//
//  Created by c4605 on 2017/1/12.
//  Copyright © 2017年 HackPlan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QSH_GCDTimer : NSObject

+ (QSH_GCDTimer *)timerWithTimeInterval:(NSNumber *)interval
                                inQueue:(dispatch_queue_t)queue
                                repeats:(BOOL)repeats
                                  block:(void (^)(QSH_GCDTimer *timer))block;

- (void)invalidate;

@end

typedef void (^QSH_GCDTimerBlock)(QSH_GCDTimer *timer);
