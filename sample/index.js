$(function() {
    $("#notify").click(function(event) {
        mw.notify({title: 'Menubar WebKit', content: 'Hello World'})
    })

    $("#open").click(function(event) {
        mw.openURL('http://www.google.com')
    })

    $("#quit").click(function(event) {
        mw.quit()
    })

    $("#set-icon").click(function(event) {
        var iconCanvas = document.getElementById('icon')
        var highlightedIconCanvas = document.getElementById('highlighted-icon')
        mw.setMenubarIcon(iconCanvas.toDataURL())
        mw.setMenubarHighlightedIcon(highlightedIconCanvas.toDataURL())
    })

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
})
