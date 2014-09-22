# Menubar WebKit

**menubar-webkit** helps you create Mac menubar app using HTML and JavaScript without writing any Objective-C code. menubar-webkit exposes an JavaScript object called ``mw`` to provide system functions.

<img alt="Screenshot" width="907" src="Assets/screenshot.png">

## API

APIs may change rapidly before 1.0.

```js
mw.platform // returns "mac" or "windows"

// App info (configurable in Xcode)
mw.appVersion
mw.appBundleVersion

// Open/close the popup window
mw.openPopup()
mw.closePopup()

// Quit application
mw.quit()

// Open URL in default browser
mw.openURL("http://pomotodo.com")

// Set menubar icon
mw.setMenubarIcon("data:image/png;base64,iVBORw...SuQmCC")
mw.setMenubarHighlightedIcon("data:image/png;base64,iVBORw...SuQmCC")
mw.resetMenubarIcon()

// Auto start with system
mw.setAutoStart(true) // not implemented yet

// Send system notification
mw.notify({
  title: "Pomotodo",
  content: "Break is over!",
  time: "2038-01-19T03:14:07Z", // (optional) delivery date for scheduled notification, in ISO 8601
  popupOnClick: true // popup when clicking notification
})

// Remove all scheduled notifications
mw.removeAllScheduledNotifications()

// Remove all delivered notifications from notification center
mw.removeAllDeliveredNotifications()

// Open new window
// "url" is relative to "app" folder
// Notice: You can only open one window at the same time,
// or the later window will replace the former window.
mw.newWindow({
  url: "about.html",
  width: 600,
  height: 400,
  x: 100, y: 100 // optional, x and y should both be provided, "center" is also a valid value
})

// Close new window
mw.closeWindow()

// Pin/unpin pop-up window (won’t close when click outside the window)
mw.pin()
mw.unpin()

// Exchange messages between webviews
mw.emit("MessageName", "payload")
mw.on("MessageName", function(message) {
	console.log(message)
})

// Show a context menu
mw.showMenu({
  items: [
    {label: "Test", click: function() { console.log("I am completely operational") } },
    {type: "separator"},
    {label: "Exit", click: function() { console.log("LIFE FUNCTION TERMINATED") } }
  ],
  x: 100,
  y: 200
])
```

### Global Shortcuts

```js
// Set global keyboard shortcut
mw.addKeyboardShortcut({
  keycode: 0x7A, // F1 key
  modifierFlags: 0, // no modifier key
  callback: function suchCallback() {
    console.log("wow")
    mw.openPopup()
  }
})

// Clear global keyboard shortcut
mw.clearKeyboardShortcut()
```

Please follow [NSEvent Class Reference](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSEvent_Class/Reference/Reference.html#//apple_ref/doc/constant_group/Modifier_Flags) for documentation about modifier flags.

Also, Menubar Webkit allows you to record shortcuts via [native components in Preferences window](Docs/Preferences.md#native-components).

### Preferences

```js
mw.setupPreferences([
  {"label": "General",  "identifier": "general",  "icon": "NSPreferencesGeneral", "height": 192},
  {"label": "Account",  "identifier": "account",  "icon": "NSUserAccounts",       "height": 102},
  {"label": "Shortcut", "identifier": "shortcut", "icon": "NSAdvanced",           "height": 120}
])

// Must be called after mw.setupPreferences()
mw.openPreferences()
mw.closePreferences()
```

Menubar WebKit also provides some native components for preferences.

More detail: [Preferences.md](Docs/Preferences.md)

### Auto Update

```js
// Check for update
mw.checkUpdate("https://rawgit.com/HackPlan/menubar-webkit/master/updater/SampleAppcast.xml")
mw.checkUpdateInBackground("https://rawgit.com/HackPlan/menubar-webkit/master/updater/SampleAppcast.xml")
```

More detail: [AutoUpdate.md](Docs/AutoUpdate.md)

## Integrating Web App

``app/index.html`` is the portal of your menubar app. ``app/preferences/[identifier].html`` are the preference pages (for example, ``app/preferences/general.html``).

To build your app:

0. Delete the current ``app`` folder
0. Put your files into the ``app`` folder
0. [Install CocoaPods](http://guides.cocoapods.org/using/getting-started.html)
0. ``cd`` into the project folder and run ``pod install``
0. Open ``menubar-webkit.xcworkspace`` in Xcode
0. Build and have fun!

Remember that Menubar WebKit is still a WIP. When the project is stable enough, I will definitely simplify the build process.

## FAQ
* Can I use **local storage**? Yes.
* Can I use **WebSQL**? Yes.
* Is Menubar WebKit compatible with Mac App Store? Absolutely yes.

## Credits

**Menubar WebKit** was created by **[LIU Dongyuan (@xhacker)](https://github.com/xhacker)** in the development of [Pomotodo for Mac](http://pomotodo.com).

Some of the code are taken from:

* [MacGap](https://github.com/maccman/macgap) by [@maccman](https://github.com/maccman)
* [Bang](https://github.com/jesseXu/Bang) by [@jesseXu](https://github.com/jesseXu)
* [Cordova OS X](https://github.com/apache/cordova-osx) by [Apache](http://www.apache.org)

Used third-party libraries:

* [MASShortcut](https://github.com/shpakovski/MASShortcut) by [@shpakovski](https://github.com/shpakovski)
* [RHPreferences](https://github.com/heardrwt/RHPreferences) by [@heardrwt](https://github.com/heardrwt)
* [Sparkle](https://github.com/sparkle-project/Sparkle) by [contributors](https://github.com/sparkle-project/Sparkle/graphs/contributors)

## Contribution

Pull requests are welcome! If you want to do something big, please open an issue first.

## License

MIT
