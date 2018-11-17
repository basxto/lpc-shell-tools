#!/bin/bash
# gpl is the palette format used by gimp and mtpaint
# the index within the palette matters
if [ "$#" -lt 4 ]; then
    echo "$0 <in.png> <out.png> <from.gpl> <to.gpl>"
    echo "Example: $0 male_human_head_ivory.png male_human_head_coffee.png palettes/skin/ivory.gpl palettes/skin/coffee.gpl"
    echo "This needs imagemagick installed"
    exit 1
fi

parse_gpl(){
    cat "$1" | grep -vE "^(GIMP|Name|Columns|#)" | while read line ; do
        color=(${line});
        echo "rgb(${color[0]},${color[1]},${color[2]})"
    done;
}

from_name=$(basename $3 | sed -E "s/\.gpl//g")
to_name=$(basename $4 | sed -E "s/\.gpl//g")
name=$(echo $1 | sed -E "s/\.png//g" | sed -E "s/_${from_name}//g")
from=( $(parse_gpl $3) )
to=( $(parse_gpl $4) )
# get smallest array size
size=$(echo -e "${#from[@]}\n${#to[@]}" | sort -n | head -n 1)
cmd="magick convert $1"
for i in $(seq 0 $((size-1))); do
    # fill must come first
    cmd="${cmd} -fill ${to[i]} -opaque ${from[i]}";
done
cmd="${cmd} $2"
${cmd}