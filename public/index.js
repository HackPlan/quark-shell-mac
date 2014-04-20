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
})
