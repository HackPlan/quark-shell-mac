# Menubar WebKit

**menubar-webkit** helps you create Mac menubar app using HTML and JavaScript without writing any Objective-C code. menubar-webkit exposes an JavaScript object called ``mw`` to provide system functions.

## API

APIs may change rapidly before 1.0.

```JavaScript
// Quit application
mw.quit()

// Open URL in default browser
mw.openURL("http://pomotodo.com")

// Set menubar icon
mw.setMenubarIcon("data:image/png;base64,iVBORw...SuQmCC")
mw.setMenubarHighlightedIcon("data:image/png;base64,iVBORw...SuQmCC")

// Auto start with system
mw.setAutoStart(true) // not implemented yet

// Send system notification
mw.notify({
  title: "Pomotodo",
  content: "Break is over!"
})

// Set global keyboard shortcut
function suchCallback() {
  console.log("wow")
}
mw.addKeyboardShortcut({
  keycode: 0x7A, // F1 key
  modifierFlags: 0, // no modifier key
  callbackName: "suchCallback"
})
```

## Integrating Web App

To see the sample app:

```bash
mv sample public
```

To add your own app:

```bash
git clone your.repository.address public
```

## Credits

Some of the code are taken from:

* [MacGap](https://github.com/maccman/macgap) by [@maccman](https://github.com/maccman)
* [Bang](https://github.com/jesseXu/Bang) by [@jesseXu](https://github.com/jesseXu)

Used third-party libraries:

* [MASShortcut](https://github.com/shpakovski/MASShortcut) by [@shpakovski](https://github.com/shpakovski)
