#! /bin/bash

## create sticker images and small cube images
for file in {"woodenCube.png","woddenCubeDark.png","stackableCube.png","stackableCubeDark.png","magicCube.png","magicCubeDark.png"}; do
	filename=${file%%.*}
	extension=${file##*.}

	newfile=$filename"Sticker."$extension
	cp $file $newfile
	sips --resampleWidth 300 $newfile

	for i in {1,2,3}; do
		newfile=$filename$i"."$extension
		cp $file $newfile
		sips --resampleHeight $(($i*40)) $newfile
	done
done


## create launch icons
for file in {"woodenCube.png","woddenCubeDark.png"}; do
	filename=${file%%.*}
	extension=${file##*.}

	for i in {1,2,3}; do
		newfile=$filename"Launch$i."$extension
		cp $file $newfile
		sips --resampleHeight $(($i*300)) $newfile
	done

done


## create app icons

file="woodenCube.png"
tmpfile="AppIconTmp.png"
tmpMfile="AppIconMTmp.png"
rawfile="AppIconRaw.png"
rawMfile="AppIconMRaw.png"
height=`file $file | cut -f 7 -d " " | sed s/x*,//`

cp $file $tmpfile
cp $file $tmpMfile
sips --cropToHeightWidth $((3*$height/2)) $((3*$height/2)) $tmpfile
sips --cropToHeightWidth $((3*$height/2)) $((2*$height)) $tmpMfile
pngtopam -background=rgb:ff/ff/ff -mix $tmpfile | pnmtopng - > $rawfile
pngtopam -background=rgb:ff/ff/ff -mix $tmpMfile | pnmtopng - > $rawMfile

for i in {16,20,29,32,40,58,60,64,76,80,87,120,128,152,167,180,256,512,1024}; do
	newfile="AppIcon"$i".png"
	cp $rawfile $newfile
	sips --resampleHeight $i $newfile
done

for i in {54,64,81,96,120,134,148,180,1024}; do
	newfile="AppIconM"$i".png"
	cp $rawMfile $newfile
	sips --resampleWidth $i $newfile
	if (($i == 148))
	then
		sips --cropToHeightWidth 110 148 $newfile
	fi
done


