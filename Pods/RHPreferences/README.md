## RHPreferences
An OS X Window Controller that makes it easy to provide a standard Preferences window with multiple tabs in your application.

It also provides:
* Auto resizing between different sized tab views (With animation)
* Custom NSToolbarItem support
* Persistance of the last used tab
* Support for placeholder NSToolbarItems (eg NSToolbarFlexibleSpaceItemIdentifier & NSToolbarShowFontsItemIdentifier)

![Example Preferences Window.](https://github.com/heardrwt/RHPreferences/raw/master/Preferences.png )


## RHPreferencesWindowController Interface
<pre>

@interface RHPreferencesWindowController : NSWindowController <NSToolbarDelegate>

//init
-(id)initWithViewControllers:(NSArray*)controllers;
-(id)initWithViewControllers:(NSArray*)controllers andTitle:(NSString*)title;

//properties
@property (copy) NSString *windowTitle;
@property (assign) BOOL windowTitleShouldAutomaticlyUpdateToReflectSelectedViewController; //defaults to YES

@property (retain) IBOutlet NSToolbar *toolbar;
@property (retain) IBOutlet NSArray *viewControllers; //controllers should implement RHPreferencesViewControllerProtocol

@property (assign) NSUInteger selectedIndex;
@property (assign) NSViewController <RHPreferencesViewControllerProtocol> *selectedViewController;

-(NSViewController <RHPreferencesViewControllerProtocol>*)viewControllerWithIdentifier:(NSString*)identifier;

//you can include these placeholder controllers amongst your array of view controllers to show their respective items in the toolbar
+(id)separatorPlaceholderController;        // NSToolbarSeparatorItemIdentifier
+(id)flexibleSpacePlaceholderController;    // NSToolbarFlexibleSpaceItemIdentifier
+(id)spacePlaceholderController;            // NSToolbarSpaceItemIdentifier

+(id)showColorsPlaceholderController;       // NSToolbarShowColorsItemIdentifier
+(id)showFontsPlaceholderController;        // NSToolbarShowFontsItemIdentifier
+(id)customizeToolbarPlaceholderController; // NSToolbarCustomizeToolbarItemIdentifier
+(id)printPlaceholderController;            // NSToolbarPrintItemIdentifier

@end

</pre>

## NSViewController Preferences Protocol
<pre>

// Implement this protocol on your view controller so that RHPreferencesWindow knows what to show in the tabbar. Label, image etc.
@protocol RHPreferencesViewControllerProtocol <NSObject>
@required

@property (nonatomic, readonly, retain) NSString *identifier;
@property (nonatomic, readonly, retain) NSImage *toolbarItemImage;
@property (nonatomic, readonly, retain) NSString *toolbarItemLabel;

@optional

@property (nonatomic, readonly, retain) NSToolbarItem *toolbarItem; //optional, overrides the above 3 properties. allows for custom tabbar items.

//methods called when switching between tabs
-(void)viewWillAppear;
-(void)viewDidAppear;
-(void)viewWillDisappear;
-(void)viewDidDisappear;

-(NSView*)initialKeyView;   // keyboard focus view on tab switch...

@end

</pre>

## Licence
Released under the Modified BSD License. 
(Attribution Required)
<pre>
RHPreferences

Copyright (c) 2012 Richard Heard. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
</pre>


### Version Support
This Framework code compiles and has been tested on OS X 10.6 - 10.8

