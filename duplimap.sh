#!/bin/bash
# csv cell syntax is: index;xoffset;yoffset
if [ "$#" -lt 4 ]; then
    echo "$0 <file.png> <animation.map.csv> <tile width> <tile height>"
    echo "Example: $0 hair.png animation/walkcycle.map.csv 64 64"
    echo "This needs imagemagick installed"
    exit 1
fi
dimensions=( $(file $1 | grep -Eo "[[:digit:]]* x [[:digit:]]*") )
width=${dimensions[0]}
height=${dimensions[2]}
row=0
num=0
name=$(echo $1 | sed -E "s/\.png//g")
animation=$(basename $2 | sed -E "s/\.map\.csv//g")
mkdir -p tmp_${name}
for line in $(cat $2); do
    col=0
    for cell in $(echo ${line} | tr ',' ' '); do
        array=( $(echo ${cell} | tr ';' ' ') )
        index=${array[0]}
        xoffset=${array[1]}
        yoffset=${array[2]}
        x=$(( ($3 * $index) % $width))
        y=$(($4 * (($3 * $index) / $width) ))
        target=tmp_${name}/$(printf "%03d" ${num}).png
        # cut out
        convert -background none $1 -crop $3x$4+$((x-xoffset))+$((y-yoffset)) ${target}
        # fix size if we lef the area of the image
        convert -background none -extent $3x$4 ${target} ${target} 
        col=$((col+1))
        num=$((num+1))
    done
    row=$((row+1))
done
montage -background none -tile ${col}x${row} tmp_${name}/*.png -geometry +0+0 ${name}_${animation}.png