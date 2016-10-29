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

$(function() {
  $("#toggle-pin").click(function() {
                         if ($(this).html() == "Pin") {
                         pin()
                         $(this).html("Unpin")
                         }
                         else {
                         unpin()
                         $(this).html("Pin")
                         }
                         });
  $("#show-menu").click(function(event) {
                        bridge.callHandler('quark', {
                            'method': 'showMenu',
                            'args': [{
                                items: [
                                        {label: "Test", click: function() { console.log("I am completely operational") } },
                                        {type: "separator"},
                                        {label: "Exit", click: function() { console.log("LIFE FUNCTION TERMINATED") } }
                                        ],
                                x: event.clientX,
                                y: event.clientY
                                }]});
                        });
  });

function setupPref(){
    quark.setupPref([
    {"label": "General", "identifier": "general", "icon": "NSPreferencesGeneral", "height": 192},
    {"label": "Account", "identifier": "account", "icon": "NSUserAccounts", "height": 102},
    {"label": "Shortcut", "identifier": "shortcut", "icon": "NSAdvanced", "height": 80,
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
    }]);
}

onQuarkLoaded = function () {
    quark.notify({title: 'Quark Shell', content: 'Hello World', popupOnClick: true});
}
