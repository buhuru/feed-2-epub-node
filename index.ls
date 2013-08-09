FeedParser = require("feedparser")
request = require("request")
pandoc = require('pdc')
fs = require 'fs'
stringex = require 'stringex'
log = console.log

dlog = ->
  log.apply console, arguments
  process.exit!

gen-file-name = (str) ->
  return 'filename' if not str
  file-name = stringex.removeFormatting  stringex.toASCII str
  file-name = file-name.replace /[^a-z0-9\-_ \.]/ig, ''
  file-name = file-name.replace /\s{2,*}/ig, ' '
  file-name = file-name.replace /\s+/ig, '_'
  file-name.toLowerCase!


# request 'http://yogasutra-comment.blogspot.com/feeds/posts/default?max-results=1'
request 'http://yogasutra-comment.blogspot.com/feeds/posts/default?alt=rss&max-results=1'
.pipe(new FeedParser )
.on("error", (err) ->
  dlog err
).on("meta", (meta) ->
  # log 'meta', meta
).on "readable", ->
    stream = @
    #stream.pause!

    item = stream.read!

    file = gen-file-name item.title

    (err) <- fs.writeFile "out/source/#file", item.description
    dlog 'fs.err', err if err

    (err, result) <- pandoc item.description,'html', 'plain', ['--smart', '--normalize']
    dlog 'pandoc.err', err if err

    (err) <- fs.writeFile "./out/plain/#file.txt", result
    dlog 'fs.err', err if err

    (err) <- pandoc result, 'markdown', 'epub', ["-o #file.epub"]
    dlog 'pandoc.err', err if err
    dlog 'game ove'