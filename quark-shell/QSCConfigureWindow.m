//
//  QSCConfigureWindow.m
//  quark-shell
//
//  Created by Sun Liang on 2016/11/9.
//  Copyright © 2016年 HackPlan. All rights reserved.
//

#import "QSCConfigureWindow.h"

@interface QSCConfigureWindow()
@property (weak) IBOutlet NSButton *makeButton;
@property (weak) IBOutlet NSButton *loadButton;
@property (weak) IBOutlet NSTextField *pathInput;
@property (weak) IBOutlet NSPathControl *folderPath;
@property (nonatomic) NSURL *folderURL;
@end

@implementation QSCConfigureWindow

- (id) init {
    return [super initWithWindowNibName:@"QSCConfigure" owner:self];
}

- (IBAction)loadButtonTapped:(NSButton *)sender
{
    [self choseFolder];
}

- (IBAction)makeButtonTapped:(NSButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setURL:_folderURL forKey:@"folder"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.appDelegate reloadWebview];
}

- (IBAction)resetButtonTapped:(NSButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setURL:nil forKey:@"folder"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _folderURL = nil;
    
    [_pathInput setStringValue:@""];
    
    [self.appDelegate reloadWebview];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    _folderURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"folder"];
    if (_folderURL){
        [_pathInput setStringValue:[_folderURL absoluteString]];
    }
}

- (void)choseFolder {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSArray* urls = [panel URLs];
            for (NSURL *url in urls) {
                if (url.isFileURL) {
                    BOOL isDir = NO;
                    // Verify that the file exists
                    // and is indeed a directory (isDirectory is an out parameter)
                    if ([[NSFileManager defaultManager] fileExistsAtPath: url.path isDirectory: &isDir]
                        && isDir) {
                        
                        _folderURL = url;
                        [_pathInput setStringValue:[_folderURL absoluteString]];
                    }
                }
            }
        }
    }];
}

@end
