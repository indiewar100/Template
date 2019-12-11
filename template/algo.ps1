$i = dir -name  -filter *md
pandoc -N -s --toc --pdf-engine=xelatex --listings  -o Template.pdf   metadata.yaml --template=algo.tex $i 