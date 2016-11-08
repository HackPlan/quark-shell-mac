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

function setupQuarkWithBridge(bridge) {
  var setMethods = function (methods, needOptions) {
    function makeMethod(method, needOptions) {
      if (needOptions){
        return function(options) {
          bridge.callHandler('quark', {'method': method, 'args': [options]});
        }
      } else {
        return function() {
          bridge.callHandler('quark', {'method': method});
        }
      }
    }

    var i;
    for (i = 0; i < methods.length; i++) {
      quark[methods[i]] = makeMethod(methods[i], needOptions);
    }
  }

  setMethods([
    'openPopup', 'closePopup', 'togglePopup',
    'resetMenubarIcon', 'removeAllScheduledNotifications', 'removeAllDeliveredNotifications',
    'clearKeyboardShortcut', 'openPreferences', 'closePreferences',
    'pin', 'unpin',
    'quit'
  ], false);

  setMethods([
    'setupPreferences', 'notify',
    'newWindow', 'changeIcon', 'changeHighlightedIcon', 'showMenu',
    'openURL', 'changeLabel', 'addKeyboardShortcut', 'closeWindow', 'closeWindowById',
    'checkUpdate', 'checkUpdateInBackground', 'setShowDockIcon',
    'resizePopup'
  ], true);

  quark.closeWindow = function (options) {
    bridge.callHandler('quark', {'method': 'closeWindow', 'args': [0]})
  }

  quark.setLaunchAtLogin = function (shouldLaunchAtLogin) {
    shouldLaunchAtLogin = !!shouldLaunchAtLogin
    bridge.callHandler('quark', {'method': 'setLaunchAtLogin', 'args': [shouldLaunchAtLogin.toString()]})
  }

  quark.emit = function (options) {
    bridge.callHandler('quark', {'method': 'emitMessage', 'args': [options]})
  }
  
}

setupWebViewJavascriptBridge(function(bridge) {
  window.bridge = bridge;

  setupQuarkWithBridge(bridge);

  // Message
  quark.msgSubscribers = [];
  quark.onMessage = function(fn) {
    quark.msgSubscribers.push(fn)
  };
  bridge.registerHandler('onQuarkMessage', function(data) {
    quark.msgSubscribers.forEach(function(fn){
      fn(data);
    })
  });
                             
  // windowClose
  quark.closeSubscribers = [];
  quark.onWindowClose = function(fn) {
  quark.closeSubscribers.push(fn)
  };
  bridge.registerHandler('onQuarkWindowClose', function(data) {
                        quark.closeSubscribers.forEach(function(fn){
                                                     fn(data);
                                                     })
                        });
  
  // Shortcut
  quark.shortcutSubscribers = [];
  quark.onShortcut = function(id, fn) {
    quark.shortcutSubscribers.push({id, callback: fn})
  };
  bridge.registerHandler('onQuarkShortcut', function(data) {
    console.log('onQuarkShortcut', data);
    quark.shortcutSubscribers.forEach(function(subscriber){
      if(subscriber['id'] == data){
        subscriber['callback']();
      }
    })
  });

  if (quark.readyList.length > 0){
    quark.readyList.forEach(function(fn){
      fn()
    })
    quark.readyList = []
  }

  quark.isReady = true

})
