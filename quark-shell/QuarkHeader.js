window.quark = {
  isReady: false
}
quark.readyList = []
quark.ready = function (fn) {
  if (quark.isReady){
    fn()
  } else {
    quark.readyList.push(fn)
  }
}