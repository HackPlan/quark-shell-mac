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
  window.quark = {};
  
  window.quark.setupPref = function (options) {
    bridge.callHandler('quark', {'method': 'setupPreferences', 'args': [options]});
  }

  window.quark.openPreferences = function () {
    bridge.callHandler('quark', {'method': 'openPreferences'})
  }

  window.quark.pin = function () {
    bridge.callHandler('quark', {'method': 'pin'})
  }

  window.quark.unpin = function () {
      bridge.callHandler('quark', {'method': 'unpin'})
  }

  window.quark.notify = function (options) {
      bridge.callHandler('quark', {'method': 'notify', 'args': [options]})
  }

  window.quark.closeWindow = function (options) {
      bridge.callHandler('quark', {'method': 'closeWindow', 'args': [0]})
  }

  window.quark.emit = function (options) {
      bridge.callHandler('quark', {'method': 'emitMessage', 'args': [options]})
  }

  window.quark.newWindow = function (options) {
      bridge.callHandler('quark', {'method': 'newWindow', 'args': [options]})
  }

  window.quark.setIcon = function (base64) {
    bridge.callHandler('quark', {'method': 'changeIcon', 'args': [base64]})
  }

}

setupWebViewJavascriptBridge(function(bridge) {
  window.bridge = bridge;

  setupQuarkWithBridge(bridge);
  // TODO: implement quark.on('name', function(data) {})
  bridge.registerHandler('onQuarkMessages', function(data) {
    console.error('ObjC called testJavascriptHandler with', data)
  });

  if (window.onQuarkLoaded){
    window.onQuarkLoaded()
  }
})