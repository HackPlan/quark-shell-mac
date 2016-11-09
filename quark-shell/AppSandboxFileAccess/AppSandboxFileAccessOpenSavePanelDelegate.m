//
//  AppSandboxFileAccessOpenSavePanelDelegate.m
//  AppSandboxFileAccess
//
//  Created by Leigh McCulloch on 23/11/2013.
//
//  Copyright (c) 2013, Leigh McCulloch
//  All rights reserved.
//
//  BSD-2-Clause License: http://opensource.org/licenses/BSD-2-Clause
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are
//  met:
//
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
//  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
//  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
//  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import "AppSandboxFileAccessOpenSavePanelDelegate.h"

#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

@interface AppSandboxFileAccessOpenSavePanelDelegate ()

@property (readwrite, strong, nonatomic) NSArray *pathComponents;

@end

@implementation AppSandboxFileAccessOpenSavePanelDelegate

- (instancetype)initWithFileURL:(NSURL *)fileURL {
	self = [super init];
	if (self) {
		NSParameterAssert(fileURL);
		self.pathComponents = fileURL.pathComponents;
	}
	return self;
}

#pragma mark -- NSOpenSavePanelDelegate

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
	NSParameterAssert(url);
	
	NSArray *pathComponents = self.pathComponents;
	NSArray *otherPathComponents = url.pathComponents;
	
	// if the url passed in has more components, it could not be a parent path or a exact same path
	if (otherPathComponents.count > pathComponents.count) {
		return NO;
	}
	
	// check that each path component in url, is the same as each corresponding component in self.url
	for (NSUInteger i = 0; i < otherPathComponents.count; ++i) {
		NSString *comp1 = otherPathComponents[i];
		NSString *comp2 = pathComponents[i];
		// not the same, therefore url is not a parent or exact match to self.url
		if (![comp1 isEqualToString:comp2]) {
			return NO;
		}
	}
	
	// there were no mismatches (or no components meaning url is root)
	return YES;
}

@end
