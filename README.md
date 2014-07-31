# Menubar WebKit

**menubar-webkit** helps you create Mac menubar app using HTML and JavaScript without writing any Objective-C code. menubar-webkit exposes an JavaScript object called ``mw`` to provide system functions.

<img alt="Screenshot" width="907" src="Assets/screenshot.png">

## API

APIs may change rapidly before 1.0.

```js
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
  popupOnClick: true // popup when clicking notification
})

// Set global keyboard shortcut
mw.addKeyboardShortcut({
  keycode: 0x7A, // F1 key
  modifierFlags: 0, // no modifier key
  callback: function suchCallback() {
    console.log("wow")
  }
})

// Clear global keyboard shortcut
mw.clearKeyboardShortcut()

// Setup preferences
// "label" is the toolbar item label in preferences window
// "identifier" is the preference html file name and must be unique
mw.setupPreferences([
  {"label": "General",  "identifier": "general",  "icon": "NSPreferencesGeneral"},
  {"label": "Account",  "identifier": "account",  "icon": "NSUserAccounts"},
  {"label": "Shortcut", "identifier": "shortcut", "icon": "NSAdvanced"}
])

// Open preferences
mw.openPreferences()

// Open new window
// "url" is relative to "public" folder
// Notice: You can only open one window at the same time,
// or the later window will replace the former window.
mw.newWindow({
  url: "about.html",
  width: 600,
  height: 400
}

// Close new window
mw.closeWindow()

// Pin/unpin pop-up window (won’t close when click outside the window)
mw.pin()
mw.unpin()
```

### Auto Update

```js
// Check for update
mw.checkUpdate("https://rawgit.com/HackPlan/menubar-webkit/master/updater/SampleAppcast.xml")
mw.checkUpdateInBackground("https://rawgit.com/HackPlan/menubar-webkit/master/updater/SampleAppcast.xml")
```

More detail: [AutoUpdate.md](Docs/AutoUpdate.md)

## Integrating Web App

``public/index.html`` is the portal of your menubar app. ``public/preferences/[identifier].html`` are the preference pages (for example, ``public/preferences/general.html``).

To add your own app:

```bash
rm public
git clone your.repository.address public
```

## FAQ
* Can I use **local storage**? Yes.
* Can I use **WebSQL**? Yes.

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
