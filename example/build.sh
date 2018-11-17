#!/bin/sh
base=male_human_head_ivory
for anim in walkcycle shoot gunwalk thrust slash hurt spellcast;do
    printf "Build ${anim} animation... "
    ../duplimap.sh ${base}.png ${base}_${anim}.png ../animation/head/male/${anim}.map.csv 64 64
    echo ${base}_${anim}.png
done
echo "Fix shoot animation with hands mask... "
magick convert -background none shoot.png ${base}_shoot.png -compose out -layers flatten ${base}_shoot.png
printf "Combine all animations into one spritesheet... "
magick convert -background none -append ${base}_{spellcast,thrust,walkcycle,slash,shoot,hurt}.png ${base}_all.png
echo ${base}_all.png
printf "Build spritesheet with different skin tone... "
../switchpalette.sh ${base}_all.png male_human_head_coffee_all.png ../palettes/skin/ivory.gpl ../palettes/skin/coffee.gpl
echo male_human_head_coffee_all.png