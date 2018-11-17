#!/bin/bash
# csv cell syntax is: index;xoffset;yoffset
# csv is a primitive spreadsheet format
if [ "$#" -lt 5 ]; then
    echo "$0 <in.png> <out.png> <animation.map.csv> <tile width> <tile height>"
    echo "Example: $0 male_human_head_ivory.png male_human_head_ivory_walkcycle.png animation/head/male/walkcycle.map.csv 64 64"
    echo "This needs imagemagick installed"
    exit 1
fi
dimensions=( $(file $1 | grep -Eo "[[:digit:]]* x [[:digit:]]*") )
width=${dimensions[0]}
height=${dimensions[2]}
row=0
num=0
name=$(echo $1 | sed -E "s/\.png//g")
animation=$(basename $3 | sed -E "s/\.map\.csv//g")
tmp=tmp_$(echo $2 | sed -E "s/\.png//g")
mkdir -p ${tmp}
for line in $(cat $3); do
    col=0
    for cell in $(echo ${line} | tr ',' ' '); do
        array=( $(echo ${cell} | tr ';' ' ') )
        index=${array[0]}
        xoffset=${array[1]}
        yoffset=${array[2]}
        x=$(( ($4 * $index) % $width))
        y=$(($5 * (($4 * $index) / $width) ))
        target=${tmp}/$(printf "%03d" ${num}).png
        # cut out
        magick convert -background none $1 -crop $4x$5+$((x-xoffset))+$((y-yoffset)) ${target}
        # fix size if we left the area of the image
        if [ "${y}" -gt 0 ];then
            gravity="north"
        else
            gravity="south"
        fi
        if [ "${x}" -gt 0 ];then
            gravity="${gravity}west"
        else
            gravity="${gravity}east"
        fi
        magick convert -background none -gravity ${gravity} -extent $4x$5 ${target} ${target} 
        col=$((col+1))
        num=$((num+1))
    done
    row=$((row+1))
done
magick montage -background none -tile ${col}x${row} ${tmp}/*.png -geometry +0+0 $2