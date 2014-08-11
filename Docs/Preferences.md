# Preferences

You can build native-like preferences window using following API:

```js
// Setup preferences
// "label" is the toolbar item label in preferences window
// "identifier" is the preference html file name and must be unique
// "height" is the height of the preference tab
mw.setupPreferences([
  {"label": "General",  "identifier": "general",  "icon": "NSPreferencesGeneral", "height": 192},
  {"label": "Account",  "identifier": "account",  "icon": "NSUserAccounts",       "height": 102},
  {"label": "Shortcut", "identifier": "shortcut", "icon": "NSAdvanced",           "height": 120}
])

// Open preferences
mw.openPreferences()
```

## Native Components

Sometimes HTML is not enough for preferences view, Menubar WebKit provides some native components.

### Shortcut Recorder

Sample usage:

```js
mw.setupPreferences([
  //...
  {
    label: "Shortcut",
    identifier: "shortcut",
    icon: "NSAdvanced",
    height: 80,
    nativeComponents: [{
      type: "ShortcutRecorder",
      options: {
        x: 140,
        y: 28,
        callback: function(keycode, modifierFlags) {
          console.log("New shortcut:", keycode, modifierFlags)
        }
      }
    }]
  }
])
```

`x` and `y` in `options` are the coordinates of the recorder view, `callback` will be invoked with the recorded shortcut (if the shortcut is cleared, `keycode` and `modifierFlags` will be `0`). You can then setup the shortcut using [`mw.addKeyboardShortcut()`](https://github.com/HackPlan/menubar-webkit#api), or clear shortcuts using [`mw.clearKeyboardShortcut()`](https://github.com/HackPlan/menubar-webkit#api).
