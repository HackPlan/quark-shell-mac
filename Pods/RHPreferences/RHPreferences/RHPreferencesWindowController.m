//
//  RHPreferencesWindowController.m
//  RHPreferences
//
//  Created by Richard Heard on 10/04/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import "RHPreferencesWindowController.h"

static NSString * const RHPreferencesWindowControllerSelectedItemIdentifier = @"RHPreferencesWindowControllerSelectedItemIdentifier";
static const CGFloat RHPreferencesWindowControllerResizeAnimationDurationPer100Pixels = 0.05f;

#pragma mark - Custom Item Placeholder Controller
@interface RHPreferencesCustomPlaceholderController : NSObject <RHPreferencesViewControllerProtocol> {
    NSString *_identifier;
}
+(id)controllerWithIdentifier:(NSString*)identifier;
@property (readwrite, nonatomic, retain) NSString *identifier;
@end

@implementation RHPreferencesCustomPlaceholderController
@synthesize identifier=_identifier;
+(id)controllerWithIdentifier:(NSString*)identifier{
    RHPreferencesCustomPlaceholderController * placeholder = [[[RHPreferencesCustomPlaceholderController alloc] init] autorelease];
    placeholder.identifier = identifier;
    return placeholder;
}
-(NSToolbarItem*)toolbarItem{
    NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:_identifier] autorelease];
    return item;
}
-(NSString*)identifier{
    return _identifier;
}
-(NSImage*)toolbarItemImage{
    return nil;
}
-(NSString*)toolbarItemLabel{
    return nil;
}
@end


#pragma mark - RHPreferencesWindowController

@interface RHPreferencesWindowController ()

//items
-(NSToolbarItem*)toolbarItemWithItemIdentifier:(NSString*)identifier;
-(NSToolbarItem*)newToolbarItemForViewController:(NSViewController<RHPreferencesViewControllerProtocol>*)controller;
-(void)reloadToolbarItems;
-(IBAction)selectToolbarItem:(NSToolbarItem*)itemToBeSelected;
-(NSArray*)toolbarItemIdentifiers;

//NSWindowController methods
-(void)resizeWindowForContentSize:(NSSize)size duration:(CGFloat)duration;

@end

@implementation RHPreferencesWindowController 

@synthesize toolbar=_toolbar;
@synthesize viewControllers=_viewControllers;
@synthesize windowTitleShouldAutomaticlyUpdateToReflectSelectedViewController=_windowTitleShouldAutomaticlyUpdateToReflectSelectedViewController;

#pragma mark - setup
-(id)initWithViewControllers:(NSArray*)controllers {
    return [self initWithViewControllers:controllers andTitle:nil];
}

-(id)initWithViewControllers:(NSArray*)controllers andTitle:(NSString*)title{
    self = [super initWithWindowNibName:@"RHPreferencesWindow"];
    if (self){
        
        //default settings
        _windowTitleShouldAutomaticlyUpdateToReflectSelectedViewController = YES;

        //store the controllers
        [self setViewControllers:controllers];
        _unloadedWindowTitle = [title copy];
        
    }
    
    return self;
}

#pragma mark - properties

-(NSString*)windowTitle{
    return [self isWindowLoaded] ? self.window.title : _unloadedWindowTitle;
}
-(void)setWindowTitle:(NSString *)windowTitle{
    if ([self isWindowLoaded]){
        self.window.title = windowTitle;
    } else {
        [_unloadedWindowTitle release];
        _unloadedWindowTitle = [windowTitle copy];
    }
}

-(NSArray*)viewControllers{
    return [[_viewControllers retain] autorelease];
}

-(void)setViewControllers:(NSArray *)viewControllers{
    if (_viewControllers != viewControllers){
        NSUInteger oldSelectedIndex = [self selectedIndex];
        
        [_viewControllers autorelease];
        _viewControllers = [viewControllers retain];
        
        //update the selected controller if we had one previously.
        if (_selectedViewController){
            if ([_viewControllers containsObject:_selectedViewController]){
                //cool, nothing to do
            } else {
                [self setSelectedIndex:oldSelectedIndex]; //reset the currently selected view controller
            }
        } else {
            //initial launch state (need to select previously selected tab)
            
            //set the selected controller 
            NSViewController *selectedController = [self viewControllerWithIdentifier:[[NSUserDefaults standardUserDefaults] stringForKey:RHPreferencesWindowControllerSelectedItemIdentifier]];
            if (selectedController){
                [self setSelectedViewController:(id)selectedController];
            } else {
                [self setSelectedIndex:0]; // unknown, default to zero. 
            }

        }

        [self reloadToolbarItems];
    }
}

-(NSViewController<RHPreferencesViewControllerProtocol>*)selectedViewController{
    return [[_selectedViewController retain] autorelease];
}

-(void)setSelectedViewController:(NSViewController<RHPreferencesViewControllerProtocol> *)new{
    //alias
    NSViewController *old = _selectedViewController;

    //stash
    _selectedViewController = new; //weak because we retain it in our array

    //stash to defaults also
    [[NSUserDefaults standardUserDefaults] setObject:[self toolbarItemIdentifierForViewController:new] forKey:RHPreferencesWindowControllerSelectedItemIdentifier];
    
    //bail if not yet loaded
    if (![self isWindowLoaded]){
        return;
    }    
    
    if (old != new){
                
        //notify the old vc that its going away
        if ([old respondsToSelector:@selector(viewWillDisappear)]){
            [(id)old viewWillDisappear];
        }
        
        [old.view removeFromSuperview];
        
        if ([old respondsToSelector:@selector(viewDidDisappear)]){
            [(id)old viewDidDisappear];
        }
        
        //notify the new vc of its appearance
        if ([new respondsToSelector:@selector(viewWillAppear)]){
            [(id)new viewWillAppear];
        }   
                
        //resize to Preferred window size for given view (duration is determined by difference between current and new sizes)
        float hDifference = fabs(new.view.bounds.size.height - old.view.bounds.size.height);
        float wDifference = fabs(new.view.bounds.size.width - old.view.bounds.size.width);
        float difference = MAX(hDifference, wDifference);
        float duration = MAX(RHPreferencesWindowControllerResizeAnimationDurationPer100Pixels * ( difference / 100), 0.10); // we always want a slight animation        
        [self resizeWindowForContentSize:new.view.bounds.size duration:duration];

        double delayInSeconds = duration + 0.02; // +.02 to give time for resize to finish before appearing
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            //make sure our "new" vc is still the selected vc before we add it as a subview, otherwise it's possible we could add more than one vc to the window. (the user has likely clicked to another tab during resizing.)
            if (_selectedViewController == new){
                [self.window.contentView addSubview:new.view];
                
                if ([new respondsToSelector:@selector(viewDidAppear)]){
                    [(id)new viewDidAppear];
                }

                //if there is a initialKeyView set it as key
                if ([new respondsToSelector:@selector(initialKeyView)]){
                    [[new initialKeyView] becomeFirstResponder];
                }
            }
        });
        

        [new.view setFrameOrigin:NSMakePoint(0, 0)]; // force our view to a 0,0 origin, fixed in the lower right corner.
        [new.view setAutoresizingMask:NSViewMaxXMargin|NSViewMaxYMargin];
        
        //set the currently selected toolbar item
        [_toolbar setSelectedItemIdentifier:[self toolbarItemIdentifierForViewController:new]];
                
        //if we should auto-update window title, do it now 
        if (_windowTitleShouldAutomaticlyUpdateToReflectSelectedViewController){
            NSString *identifier = [self toolbarItemIdentifierForViewController:new];
            NSString *title = [[self toolbarItemWithItemIdentifier:identifier] label];
            if (title)[self setWindowTitle:title];
        }
    }
}

-(NSUInteger)selectedIndex{
    return [_viewControllers indexOfObject:[self selectedViewController]];
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex{
    id newSelection = (selectedIndex >= [_viewControllers count]) ? [_viewControllers lastObject] : [_viewControllers objectAtIndex:selectedIndex];
    [self setSelectedViewController:newSelection];
}

-(NSViewController <RHPreferencesViewControllerProtocol>*)viewControllerWithIdentifier:(NSString*)identifier{
    for (NSViewController <RHPreferencesViewControllerProtocol>* vc in _viewControllers){

        //set the toolbar back to the current controllers selection
        if ([vc respondsToSelector:@selector(toolbarItem)] && [[[vc toolbarItem] itemIdentifier] isEqualToString:identifier]){
            return vc;
        } 
        
        if ([[vc identifier] isEqualToString:identifier]){
            return vc;
        }
    }    
    return nil;
}


#pragma mark - View Controller Methods

-(void)resizeWindowForContentSize:(NSSize)size duration:(CGFloat)duration{
    NSWindow *window = [self window];
    
    NSRect frame = [window contentRectForFrameRect:[window frame]];
    
    CGFloat newX = NSMinX(frame) + (0.5* (NSWidth(frame) - size.width));
    NSRect newFrame = [window frameRectForContentRect:NSMakeRect(newX, NSMaxY(frame) - size.height, size.width, size.height)];
    
    if (duration > 0.0f){
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:duration];
            [[window animator] setFrame:newFrame display:YES];
        [NSAnimationContext endGrouping];
    } else {
        [window setFrame:newFrame display:YES];
    }

}


#pragma mark - Toolbar Items

-(NSToolbarItem*)toolbarItemWithItemIdentifier:(NSString*)identifier{
    for (NSToolbarItem *item in _toolbarItems){
        if ([[item itemIdentifier] isEqualToString:identifier]){
            return item;
        }
    }    
    return nil;
}

-(NSString*)toolbarItemIdentifierForViewController:(NSViewController*)controller{
    if ([controller respondsToSelector:@selector(toolbarItem)]){
        NSToolbarItem *item = [(id)controller toolbarItem];
        if (item){
            return item.itemIdentifier;
        }
    }
    
    if ([controller respondsToSelector:@selector(identifier)]){
        return [(id)controller identifier];
    }
    
    return nil;
}


-(NSToolbarItem*)newToolbarItemForViewController:(NSViewController<RHPreferencesViewControllerProtocol>*)controller{
    //if the controller wants to provide a toolbar item, return that
    if ([controller respondsToSelector:@selector(toolbarItem)]){
        NSToolbarItem *item = [controller toolbarItem];
        if (item){
            item = [item copy]; //we copy the item because it needs to be unique for a specific toolbar
            item.target = self;
            item.action = @selector(selectToolbarItem:);
            return item;
        }
    }

    //otherwise, default to creation of a new item.
    
    NSToolbarItem *new = [[NSToolbarItem alloc] initWithItemIdentifier:controller.identifier];
    new.image = controller.toolbarItemImage;
    new.label = controller.toolbarItemLabel;
    new.target = self;
    new.action = @selector(selectToolbarItem:);    
    return new;
}

-(void)reloadToolbarItems{
    NSMutableArray *newItems = [NSMutableArray arrayWithCapacity:[_viewControllers count]];
    
    for (NSViewController<RHPreferencesViewControllerProtocol>* vc in _viewControllers){

        NSToolbarItem *insertItem = [self toolbarItemWithItemIdentifier:vc.identifier];
        if (!insertItem){
            //create a new one
            insertItem = [[self newToolbarItemForViewController:vc] autorelease];
        }
        [newItems addObject:insertItem];
    }
    
    [_toolbarItems release];
    _toolbarItems = [[NSArray arrayWithArray:newItems] retain];
}


-(IBAction)selectToolbarItem:(NSToolbarItem*)itemToBeSelected{
    if ([_selectedViewController commitEditing] && [[NSUserDefaultsController sharedUserDefaultsController] commitEditing]){
        NSUInteger index = [_toolbarItems indexOfObject:itemToBeSelected];
        if (index != NSNotFound){
            [self setSelectedViewController:[_viewControllers objectAtIndex:index]];
        }
    } else {
        //set the toolbar back to the current controllers selection
        if ([_selectedViewController respondsToSelector:@selector(toolbarItem)] && [[_selectedViewController toolbarItem] itemIdentifier]){
            [_toolbar setSelectedItemIdentifier:[[_selectedViewController toolbarItem] itemIdentifier]];
        } else if ([_selectedViewController respondsToSelector:@selector(identifier)]){
            [_toolbar setSelectedItemIdentifier:[_selectedViewController identifier]];
        }

    }
}

-(NSArray*)toolbarItemIdentifiers{
    NSMutableArray *identifiers = [NSMutableArray arrayWithCapacity:[_viewControllers count]];
    
    for (id viewController in _viewControllers){
        [identifiers addObject:[self toolbarItemIdentifierForViewController:viewController]];
    }
    
    return [NSArray arrayWithArray:identifiers];
}

#pragma mark - Custom Placeholder Controller Toolbar Items

+(id)separatorPlaceholderController{
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarSeparatorItemIdentifier];
}
+(id)flexibleSpacePlaceholderController{ 
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarFlexibleSpaceItemIdentifier];
}
+(id)spacePlaceholderController{ 
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarSpaceItemIdentifier]; 
}
+(id)showColorsPlaceholderController{ 
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarShowColorsItemIdentifier]; 
}
+(id)showFontsPlaceholderController{ 
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarShowFontsItemIdentifier]; 
}
+(id)customizeToolbarPlaceholderController{ 
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarCustomizeToolbarItemIdentifier]; 
}
+(id)printPlaceholderController{ 
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarPrintItemIdentifier]; 
}

#pragma mark - NSWindowController

-(void)loadWindow{
    [super loadWindow];
    
    if (_unloadedWindowTitle){
        self.window.title = _unloadedWindowTitle;
        [_unloadedWindowTitle release]; _unloadedWindowTitle = nil;
    }
    
    if (_selectedViewController){
        
        //add the view to the windows content view
        if ([_selectedViewController respondsToSelector:@selector(viewWillAppear)]){
            [_selectedViewController viewWillAppear];
        }        
        
        [self.window.contentView addSubview:[_selectedViewController view]];
        
        if ([_selectedViewController respondsToSelector:@selector(viewDidAppear)]){
            [_selectedViewController viewDidAppear];
        }        
        
        //resize to Preferred window size for given view    
        [self resizeWindowForContentSize:_selectedViewController.view.bounds.size duration:0.0f];
        
        [_selectedViewController.view setFrameOrigin:NSMakePoint(0, 0)];
        [_selectedViewController.view setAutoresizingMask:NSViewMaxXMargin|NSViewMaxYMargin];
        
        
        //set the current controllers tab to selected    
        [_toolbar setSelectedItemIdentifier:[self toolbarItemIdentifierForViewController:_selectedViewController]];
        
        //if there is a initialKeyView set it as key
        if ([_selectedViewController respondsToSelector:@selector(initialKeyView)]){
            [[_selectedViewController initialKeyView] becomeFirstResponder];
        }
        
        //if we should auto-update window title, do it now 
        if (_windowTitleShouldAutomaticlyUpdateToReflectSelectedViewController){
            NSString *identifier = [self toolbarItemIdentifierForViewController:_selectedViewController];
            NSString *title = [[self toolbarItemWithItemIdentifier:identifier] label];
            if (title)[self setWindowTitle:title];
        }
    }
}

-(void)windowDidLoad{
    [super windowDidLoad];
}

#pragma mark - NSWindowDelegate

-(BOOL)windowShouldClose:(id)sender{
    if (_selectedViewController){
        return [_selectedViewController commitEditing];
    }
    
    return YES;
}

-(void)windowWillClose:(NSNotification *)notification{
    // steal firstResponder away from text fields, to commit editing to bindings
    [self.window makeFirstResponder:self];
}

#pragma mark - NSToolbarDelegate

-(NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag{
   return [self toolbarItemWithItemIdentifier:itemIdentifier];
}

-(NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar{
    return [self toolbarItemIdentifiers];
}

-(NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar{
    return [self toolbarItemIdentifiers];
}

-(NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar{
    return [self toolbarItemIdentifiers];
}

@end
