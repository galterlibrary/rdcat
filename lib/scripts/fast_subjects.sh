#!/bin/bash

# Download Linked Data Format N-Triples 'All files' from:
# http://www.oclc.org/research/themes/data-science/fast/download.html
# Pass the folder with unzipped files at the first and only argument
for f in $1/*nt; do
  grep -F '<http://www.w3.org/2004/02/skos/core#prefLabel>' $f |\
    sed 's/.*org\/fast\//  - id: "/' |\
    sed 's/> <http:.*prefLabel> /"\n    name: /' |\
    sed 's/" \+./"/'
done
