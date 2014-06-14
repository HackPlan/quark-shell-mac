function suchCallback() {
    console.log("wow")
}

$(function() {
    $("input").focus()

    mw.addKeyboardShortcut({
        keycode: 0x7A, // F1 key
        modifierFlags: 0, // no modifier key
        callbackName: "suchCallback"
    })

    mw.setupPreferences([
        {"name": "General", "icon": "NSPreferencesGeneral", "fields": [
            {"type": "checkbox", "content": "Checkbox", "preference_key": "preference_1"}
        ]},
        {"name": "Account", "icon": "NSUserAccounts"},
        {"name": "Shortcut", "icon": "NSAdvanced"}
    ])
})

function setIcon() {
    var iconCanvas = document.getElementById('icon')
    iconCanvas.width = 40
    iconCanvas.height = 40
    var iconCtx = iconCanvas.getContext('2d')
    iconCtx.fillRect(5, 7, 30, 30)
    iconCtx.clearRect(10, 12, 20, 20)

    var highlightedIconCanvas = document.getElementById('highlighted-icon')
    highlightedIconCanvas.width = 40
    highlightedIconCanvas.height = 40
    var highlightedIconCtx = highlightedIconCanvas.getContext('2d')
    highlightedIconCtx.fillStyle = "white"
    highlightedIconCtx.fillRect(5, 7, 30, 30)
    highlightedIconCtx.clearRect(10, 12, 20, 20)

    mw.setMenubarIcon(iconCanvas.toDataURL())
    mw.setMenubarHighlightedIcon(highlightedIconCanvas.toDataURL())
}
