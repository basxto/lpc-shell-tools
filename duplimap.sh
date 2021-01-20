#!/bin/bash
# csv cell syntax is: index;xoffset;yoffset
# index;; defaults to index;0;0
# :in:dex in is the row and dex the column
# #index is <current row>:index
# -index mirrors the tile horizontally (-# and -: are valid)
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
tilewidth=$4
tileheight=$5
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
        mirror=""
        index=${array[0]}
        if [ "${index:0:1}" == "-" ]; then
            mirror="-flop"
            index="${index:1}"
        fi
        case $index in
         ':'*)
            coords=( $(echo ${index:1} | tr ':' ' ') )
            index=$((${coords[0]} * (${width}/${tilewidth}) + ${coords[1]} ))
            ;;
         '#'*)
            index=$((${row} * (${width}/${tilewidth}) + ${index:1} ))
            ;;
        esac
        xoffset=${array[1]:-0}
        yoffset=${array[2]:-0}
        x=$(( (${tilewidth} * $index) % $width))
        y=$((${tileheight} * ((${tilewidth} * $index) / $width) ))
        target=${tmp}/$(printf "%03d" ${num}).png
        # cut out
        magick convert -background none $1 -crop ${tilewidth}x${tileheight}+$((x-xoffset))+$((y-yoffset)) ${mirror} ${target}
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
        magick convert -background none -gravity ${gravity} -extent ${tilewidth}x${tileheight} ${target} ${target} 
        col=$((col+1))
        num=$((num+1))
    done
    row=$((row+1))
done
magick montage -background none -tile ${col}x${row} ${tmp}/*.png -geometry +0+0 $2