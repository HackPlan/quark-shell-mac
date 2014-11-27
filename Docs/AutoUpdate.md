# Auto Update

## AppCast.xml

To enable auto update, you need to prepare an **AppCast.xml** ([sample](https://github.com/HackPlan/quark-shell-mac/blob/master/updater/SampleAppcast.xml)) like this:

```xml
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title>[App Name]</title>
        <link>[AppCast.xml Link]</link>
        <description>Most recent changes with links to updates.</description>
        <language>en</language>
        <item>
            <title>Version [x.yz]</title>
            <sparkle:releaseNotesLink>[Link to Release Notes]</sparkle:releaseNotesLink>
            <pubDate>[Release Date]</pubDate>
            <enclosure url="[Update File URL]" sparkle:version="[Version String]" length="[Update File Length]" type="application/octet-stream" />
            <sparkle:minimumSystemVersion>[Minimum System Version]</sparkle:minimumSystemVersion>
        </item>
    </channel>
</rss>
```

## Code Signing

For safety reasons, you have to code sign your app properly to enable auto update.

## Check for Update

We provide two JavaScript APIs for checking update, both require an URL to AppCast.xml:

```js
quark.checkUpdate("https://rawgit.com/HackPlan/quark-shell-mac/master/updater/SampleAppcast.xml")
quark.checkUpdateInBackground("https://rawgit.com/HackPlan/quark-shell-mac/master/updater/SampleAppcast.xml")
```

## Under the Hood

Quark Shell for Mac uses [Sparkle](https://github.com/sparkle-project/Sparkle) as update engine, refer to the documentation for Sparkle for more details.
