# StartAtLoginController

Easy to use controller that makes use of the [Cocoa ServiceManagement APIs][SM]. This is the required way to do login items for sandboxed applications (required for all Mac App Store apps) and works in non-sandboxed applications as well.

It's been tested on 10.7 and 10.8 (and should work on 10.6.6+). Entries set by this class do not appear in the Accounts Panel of System Preferences.

## HOW-TO

### Helper Bundle

You must create an instance of the controller and set its bundle identifier to use to your helper bundle. (It must point to a helper bundle that has LSBackgroundOnly or LSUIElement set to YES in its Info.plist and put this bundle in Contents/Library/LoginItems).

For sandboxed apps, sign it with the same entitlements and developer id. Also, your can only be launched at login if it has been copied to `/Applications`.

Here is an example of a helper bundle:

	- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
	{
		NSString *appPath = [[[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent]  stringByDeletingLastPathComponent] stringByDeletingLastPathComponent]; 
		// get to the waaay top. Goes through LoginItems, Library, Contents, Applications
		[[NSWorkspace sharedWorkspace] launchApplication:appPath];
		[NSApp terminate:nil];
	}
	
You can find a decent tutorial about this at [Tim Schröder's blog post "The Launch At Login Sandbox Project"][Tutorial].
	
### Main Application

Then in your application

 * add the framework `ServiceManagement` and 
 * add the files `StartAtLoginController.{h,m}`
 
to your main app's target. You can use the controller either in code or with the interface builder.

#### Programmatically

When using in code, create an instance of `StartAtLoginController` by providing the helper app's bundle identifier:

	StartAtLoginController *loginController = [[StartAtLoginController alloc] initWithIdentifier:@"your.app.helpers.bundle.id"];
	
Now, you can manipulate the Services Entry:

	loginController.startAtLogin = YES; // adds the entry into LaunchServices and activates it
	//
	loginController.enabled = NO; // disables the entry on the services list
	//
	BOOL startsAtLogin = [loginController startAtLogin]; // gets the current enabled state
	
#### Interface Builder

If you want to use the interface builder

 * Place a NSObject (the blue box) into the nib window
 * From the Inspector - **Identity Tab**
   * Set the Class to `StartAtLoginController`
   * Add the user defined runtime attribute `identifier` of type `String` and set it to your helper app's bundle identifier
 * Place a Checkbox on your Window/View
 * From the Inspector - **Bindings Tab**
   * Unroll the > Value item
   * Bind to `StartAtLoginController` with the Model Key Path `startAtLogin`

## REQUIREMENTS

Works only on 10.6.6 or later.

## LICENSE

This is licensed under MIT. Here is some legal jargon:

Copyright (c) 2011 Alex Zielenski
Copyright (c) 2012 Travis Tilley

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[SM]: http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLoginItems.html
[Tutorial]: http://blog.timschroeder.net/2012/07/03/the-launch-at-login-sandbox-project/