$(function() {
    $("#app-version").html(mw.appVersion);
    $("#app-bundle-version").html("(" + mw.appBundleVersion + ")");

    mw.addKeyboardShortcut({
        keycode: 0x7A, // F1 key
        modifierFlags: 0, // no modifier key
        callback: function () {
            console.log("wow")
            mw.openPopup()
        }
    })

    mw.setupPreferences([
        {"label": "General", "identifier": "general", "icon": "NSPreferencesGeneral", "height": 192},
        {"label": "Account", "identifier": "account", "icon": "NSUserAccounts", "height": 102},
        {
            "label": "Shortcut", "identifier": "shortcut", "icon": "NSAdvanced", "height": 80,
            "nativeComponents": [{
                type: "ShortcutRecorder",
                options: {
                    x: 140,
                    y: 28,
                    keycode: 0x7A, // F1 key
                    modifierFlags: 0, // no modifier key
                    onChange: function (keycode, modifierFlags) {
                        console.log("New shortcut:", keycode, modifierFlags)
                        mw.clearKeyboardShortcut()
                        mw.addKeyboardShortcut({
                            keycode: keycode,
                            modifierFlags: modifierFlags,
                            callback: function () {
                                console.log("wow")
                                mw.openPopup()
                            }
                        })
                    }
                }
            }]
        }
    ])

    $("#toggle-pin").click(function() {
        if ($(this).html() == "Pin") {
            mw.pin()
            $(this).html("Unpin")
        }
        else {
            mw.unpin()
            $(this).html("Pin")
        }
    })

    $("#show-menu").click(function(event) {
        var buttontext = $(this).text();
        mw.showMenu({
            items: [
                {label: "Test", click: function() { 
                        console.log("Clicked: "+ buttontext);
                        console.log("I am completely operational") 
                    } 
                },
                {type: "separator"},
                {label: "Exit", click: function() { console.log("LIFE FUNCTION TERMINATED") } }
            ],
            x: event.clientX,
            y: event.clientY
        }, buttontext)
    })

    var db = openDatabase('test', '1.0', 'Menubar WebKit supports WebSQL database', 5 * 1024 * 1024)

    mw.on("TestMessage", function(message) {
        console.log(message)
    })
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
