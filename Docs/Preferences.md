# Preferences

You can build native-like preferences window using following API:

```js
// "label" is the toolbar item label in preferences window
// "identifier" is the preference html file name and must be unique
// "height" is the height of the preference tab
quark.setupPreferences([
  {"label": "General",  "identifier": "general",  "icon": "NSPreferencesGeneral", "height": 192},
  {"label": "Account",  "identifier": "account",  "icon": "NSUserAccounts",       "height": 102},
  {"label": "Shortcut", "identifier": "shortcut", "icon": "NSAdvanced",           "height": 120}
])

// Must be called after quark.setupPreferences()
quark.openPreferences()
quark.closePreferences()
```

## Native Components

Sometimes HTML is not enough for preferences view, Quark Shell for Mac provides some native components.

### Shortcut Recorder

Sample usage:

```js
quark.setupPreferences([
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
        keycode: 0x7A, // F1 key
        modifierFlags: 0, // no modifier key
        onChange: function (keycode, modifierFlags) {
          console.log("New shortcut:", keycode, modifierFlags)
          quark.clearKeyboardShortcut()
          quark.addKeyboardShortcut({
            keycode: keycode,
            modifierFlags: modifierFlags,
            callback: function () { quark.openPopup() }
          })
        }
      }
    }]

  }
])
```

`x` and `y` in `options` are the coordinates of the recorder view.  
`keycode` and `modifierFlags` are the initial values for the recorder view. Omit these two arguments for a empty recorder view.  
`onChange` will be invoked if user records a new shortcut (`onChange` will also be invoked if the shortcut is cleared, `keycode` and `modifierFlags` will be `0`).

You can then setup the shortcut using [`quark.addKeyboardShortcut()`](https://github.com/HackPlan/quark-shell-mac#api), or clear shortcuts using [`quark.clearKeyboardShortcut()`](https://github.com/HackPlan/quark-shell-mac#api).
