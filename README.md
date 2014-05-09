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
mw.setAutoStart(true)

// Send system notification
mw.notify({
  title: "Pomotodo",
  content: "Break is over!"
})
```

## Integrating Web App

Too see the sample app:

```bash
mv sample public
```

To add your own app:

```bash
git clone your.repository.address public
```

## Progress

| API                          | Implemented? |
| ---------------------------- | ------------ |
| mw.quit                      | Yes          |
| mw.openURL                   | Yes          |
| mw.setMenubarIcon            | Yes          |
| mw.setMenubarHighlightedIcon | Yes          |
| mw.setAutoStart              | No           |
| mw.notify                    | Yes          |
