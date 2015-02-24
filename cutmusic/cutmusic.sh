#!/usr/bin/env bash

show_help() {
cat << EOF
Usage: ${0##*/} [-hrn] [-t TIMESFILE] [-e ENDTIME] [-o OUTFOLDER] [INPUTFILE]
Cut input file into pieces, based on timesfile.

	-h		display this help and exit
	-r		timings in timesfile are relative, eg only start times are provided
	-t TIMESFILE	file with times
	-e ENDFILE	length of inputfile, needed when timings are relative
	-o OUTFILE	folder for saving output
	-n		add tracknumber
EOF
}

endt="a"
trn=0

# parse options
while getopts "hrt:e:o:n" opt; do
	case "$opt" in
		h)
			show_help
			exit 0
			;;
		r)
			rel=1
			;;
		t)
			timef=$OPTARG
			;;
		e)
			endt=$OPTARG
			;;
		o)
			outf=$OPTARG
			;;
		n)
			trn=1
			;;
		*)
			show_help
			exit 1
			;;
	esac
done

shift "$((OPTIND-1))"

# add end time to timesfile
if [ $endt != "a" ]; then
	echo "END ${endt}" >> $timef
fi

outfo=${outf:-outf}
mkdir $outfo

n=1
prev=0
cur=0

while read line; do
	songtime=$(echo $line | rev | cut -d' ' -f 1 | rev)
	cur=$(echo $songtime | cut -d':' -f 2 | sed 's/^0*//')
	tmp=$(echo $songtime | cut -d':' -f 1 | sed 's/^0*//')
	cur=$((cur + tmp*60))
	if [ -n $rel ]; then
		if [ $n -ne 1 ]; then
			echo "$songtitle - $songtime == $prev - $cur"
			sox $1 $outfo/${songtitle}.mp3 trim $prev =$cur
		fi
		songtitle=$(echo $line | rev | cut -d' ' -f 2- | rev | tr '[:upper:]' '[:lower:]' | sed -e "s/\ /\_/g")
		if [ $trn -gt 0 ]; then
			songtitle=$(printf "$n._$songtitle")
		fi
		prev=$cur
	else
		songtitle=$(echo $line | rev | cut -d' ' -f 2- | rev | tr '[:upper:]' '[:lower:]' | sed -e "s/\ /\_/g")
		if [ $trn -gt 0 ]; then
			songtitle=$(printf "$n._$songtitle")
		fi
		echo "$songtitle - $songtime == $prev - $cur"
		sox $1 $outfo/${songtitle}.mp3 trim $prev $cur
		prev=$((prev+cur))
	fi
	n=$((n+1))
done <$timef
