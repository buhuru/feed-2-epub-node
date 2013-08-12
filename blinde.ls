pandoc = require 'pdc'
parser = require 'blindparser'
fs = require 'fs'
stringex = require 'stringex'
log = console.log
{reject, map, reverse } = require \prelude-ls

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

opts =
    followRedirect : false
    timeout  : 10000
url = 'http://yogasutra-comment.blogspot.com/feeds/posts/default?alt=rss&max-results=100'
# url = 'http://yogasutra-comment.blogspot.com/feeds/posts/default?max-results=1'
(err, out) <- parser.parseURL url, opts
dlog 'parser.err', err if err

# show full list
# dlog map (-> title: it.title[0], link: it.link), out.items

exclude = [
    # 'Наш блог начал публиковаться и на английском языке'
    'http://yogasutra-comment.blogspot.com/2012/12/blog-post_7.html'

    # С новым годом:
    'http://yogasutra-comment.blogspot.com/2012/12/blog-post_30.html'

    # Приветствие единомышленникам 
    'http://yogasutra-comment.blogspot.com/2013/01/blog-post_20.html'

    # Кумбхамела 2013 или катарсис по индийски
    'http://yogasutra-comment.blogspot.com/2013/02/2013.html'

    # 'YOGA: Physiology, Psychosomatics, Bioenergetics by Andrey G. Safronov'
    'http://yogasutra-comment.blogspot.com/2013/05/yoga-physiology-psychosomatics.html'
]

items = reject (-> it.link[0] in exclude ), out.items

gtitle = out.metadata.title[0]
gtitle = [
    "##gtitle"
    "&copy; Андрей Сафронов, (\*yogasutra-comment.blogspot.com\*)"
    "", "", "***", "", ""
].join "\n"

(err) <- fs.writeFile "./out/0.md", gtitle
dlog 'fs.err', err if err

for article, i in reverse items
    let item = article
        title = item.title[0]
        # console.log "Converting #title"
        # file = gen-file-name title
        file = "#{i+1}"
        
        (err) <- fs.writeFile "out/source/#file.html", item.desc[0]
        dlog 'fs.err', err if err

        (err, result) <- pandoc item.desc[0],'html', 'markdown'
        dlog 'pandoc.err', err if err

        arr = result.split "\n"
        arr = reject (-> /(http:)|(https:)+/ig.test it ), arr
        arr = reject (-> /^(#| )+$/ig.test it ), arr
        arr = map (-> it.replace /{.*}/ig, '' ), arr
        result = arr.join "\n"

        (err) <- fs.writeFile "./out/#file.md", "\n\n##{i+1}. #title\n\n" + result
        dlog 'fs.err', err if err
        
        
# workflow
# livescript blinde.ls
# for file in `find ./out -name "*.md" | sort -n -t / -k 3`; do cat $file >> all.md; done
#  pandoc -f markdown -t epub --epub-metadata epub-conf.xml --epub-chapter-level 1 --epub-cover-image cov.jpg  -o all.epub all.md