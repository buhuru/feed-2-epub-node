feed-2-epub-node
================


## How to use:
```sh
livescript blinde.ls
for file in `find ./out -name "*.md" | sort -n -t / -k 3`; do cat $file >> all.md; done
pandoc -f markdown -t epub --epub-metadata epub-conf.xml --epub-chapter-level 1 --epub-cover-image cov.jpg  -o all.epub all.md
```