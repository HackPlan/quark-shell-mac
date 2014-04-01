# Menubar WebKit

**menubar-webkit** helps you create Mac menubar app using HTML and JavaScript without writing any Objective-C code. menubar-webkit exposes an JavaScript object called ``mw`` to provide system functions.

## API

```JavaScript
// Quit application
mw.quit()

// Open URL in default browser
mw.openURL("http://pomotodo.com")

// Set menubar icon
mw.setMenubarIcon("images/icon.png")

// Auto start with system
mw.setAutoStart(true)

// Send system notification
mw.notify({
  title: "Pomotodo",
  content: "Break is over!"
})
```

## Progress

| API               | Implemented? |
| ----------------- | ------------ |
| mw.quit           | Yes          |
| mw.openURL        | Yes          |
| mw.setMenubarIcon | No           |
| mw.setAutoStart   | No           |
| mw.notify         | Yes          |
