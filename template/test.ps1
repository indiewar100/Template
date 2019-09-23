$i = dir -name  -filter *md
pandoc -N -s --toc --pdf-engine=xelatex --listings  -o template.pdf   metadata.yaml --template=test.tex $i 