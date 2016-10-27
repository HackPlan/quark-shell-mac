/*
$(function() {
    quark.debug = true

    $("#app-version").html(quark.appVersion)
    $("#app-bundle-version").html("(" + quark.appBundleVersion + ")")

    quark.addKeyboardShortcut({
        keycode: 0x7A, // F1 key
        modifierFlags: 0, // no modifier key
        callback: function () {
            console.log("wow")
            quark.togglePopup()
        }
    })

    quark.setClickAction(function () {
        console.log("Don’t click me!")
    })
    quark.setSecondaryClickAction(function () {
        console.log("What did I say?")
    })

    quark.setupPreferences([
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
                        quark.clearKeyboardShortcut()
                        quark.addKeyboardShortcut({
                            keycode: keycode,
                            modifierFlags: modifierFlags,
                            callback: function () {
                                console.log("wow")
                                quark.togglePopup()
                            }
                        })
                    }
                }
            }]
        }
    ])

    $("#toggle-pin").click(function() {
        if ($(this).html() == "Pin") {
            quark.pin()
            $(this).html("Unpin")
        }
        else {
            quark.unpin()
            $(this).html("Pin")
        }
    })

    $("#show-menu").click(function(event) {
        quark.showMenu({
            items: [
                {label: "Test", click: function() { console.log("I am completely operational") } },
                {type: "separator"},
                {label: "Exit", click: function() { console.log("LIFE FUNCTION TERMINATED") } }
            ],
            x: event.clientX,
            y: event.clientY
        })
    })

    var db = openDatabase('test', '1.0', 'Quark Shell supports WebSQL database', 5 * 1024 * 1024)

    quark.on("TestMessage", function(message) {
        console.log(message)
    })
})
 */

function setIcon() {
    var iconCanvas = document.getElementById('icon')
    iconCanvas.width = 40
    iconCanvas.height = 40
    var iconCtx = iconCanvas.getContext('2d')
    iconCtx.fillRect(6, 8, 28, 28)
    iconCtx.clearRect(12, 14, 16, 16)

    var highlightedIconCanvas = document.getElementById('highlighted-icon')
    highlightedIconCanvas.width = 40
    highlightedIconCanvas.height = 40
    var highlightedIconCtx = highlightedIconCanvas.getContext('2d')
    highlightedIconCtx.fillStyle = "white"
    highlightedIconCtx.fillRect(6, 8, 28, 28)
    highlightedIconCtx.clearRect(12, 14, 16, 16)
    
    bridge.callHandler('quark', {'method': 'changeIcon', 'args': [iconCanvas.toDataURL()]})
}

function notify(options){
    bridge.callHandler('quark', {'method': 'notify', 'args': [options]})
}

function emit(options){
    bridge.callHandler('quark', {'method': 'emitMessage', 'args': [options]})
}

function newWindow(options){
    bridge.callHandler('quark', {'method': 'newWindow', 'args': [options]})
}

function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
    if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}

setupWebViewJavascriptBridge(function(bridge) {
    window.bridge = bridge;
    bridge.registerHandler('onQuarkMessages', function(data) {
        console.error('ObjC called testJavascriptHandler with', data)
    })
})
