#!/bin/bash
#
# Needs: exiv2, imagemagick
#
EXPR="*.JPG"
for FILE in ${EXPR};
do
    echo "FILE: ${FILE}"
    PRE="${FILE%.JPG}"
    #
    EXP_TIME=$(exiv2 ${FILE} | grep "Exposure time") #value=${str#*=}
    EXP_TIME=${EXP_TIME#*:}
    EXP_TIME=${EXP_TIME:1:-2}
    #echo $EXP_TIME
    #
    APERTURE=$(exiv2 ${FILE} | grep "Aperture  ") #value=${str#*=}
    APERTURE=${APERTURE#*:}
    #echo $APERTURE
    #
    ISO=$(exiv2 ${FILE} | grep "ISO speed") #value=${str#*=}
    ISO=${ISO#*:}
    ISO="${ISO#"${ISO%%[![:space:]]*}"}" # remove trailing space
    #echo $ISO
    #
    TS=$(exiv2 ${FILE} | grep "Image timestamp") #value=${str#*=}
    TS=${TS#*:}
    #echo $PRE $TS
    #
    JPG="${PRE}a.jpg"
    #echo $FILE $JPG
    #
    XxY=$(exiv2 ${FILE} | grep "Image size") #value=${str#*=}
    XxY=${XxY#*:}
    XxY="${XxY#"${XxY%%[![:space:]]*}"}" # remove trailing space
    #echo $XxY
    XYs=(${XxY//x/ })
    #echo ${XYs[0]} ${XYs[1]}
    Ys=${XYs[1]} # height
    Fs=$((Ys / 40)) # font size 1/40 of height
    #echo $Fs
    #
    if [ ! -e "${JPG}" ]; then
	echo convert "${FILE}" -auto-orient "${JPG}" # Rotate correctly
	convert "${FILE}" -auto-orient "${JPG}"
	#
	MODE=1
	#
	FONT=""
	if [ -e "./DOTMATRI.TTF" ]; then
	    FONT="-font ./DOTMATRI.TTF"
	fi
	if [ -e "./ScreenMatrix.ttf" ]; then
	    FONT="-font ./ScreenMatrix.ttf"
	fi
	#
	if [ $MODE -eq 0 ]; then
	    INFO0=" ${EXP_TIME} @ ${APERTURE} ISO ${ISO}"
	    DRAW0=(-annotate +10+10 "${INFO0}")
	    INFO1="${TS}"
	    DRAW1=(-annotate +10+110 "${INFO1}")
	    echo mogrify -pointsize ${Fs} -fill yellow ${FONT} -gravity northwest "${DRAW0[@]}" -gravity northwest  "${DRAW1[@]}"  ${JPG}
	    mogrify -pointsize ${Fs} -fill yellow ${FONT} -gravity northwest "${DRAW0[@]}" -gravity northwest  "${DRAW1[@]}"  ${JPG}
	fi
	#
	if [ $MODE -eq 1 ]; then
	    INFO0=" ${EXP_TIME} @ ${APERTURE} ISO ${ISO} ${TS}"
	    echo mogrify -pointsize ${Fs} -fill orange "${FONT}" -gravity southeast "${DRAW0[@]}"  ${JPG}
	    DRAW0=(-annotate +4+4 "${INFO0}")
	    mogrify -pointsize ${Fs} -fill black  ${FONT} -gravity southeast "${DRAW0[@]}"  ${JPG}
	    OFF=$((Fs / 20)) # offset
	    OFF=$((4 + OFF))
	    DRAW0=(-annotate +${OFF}+${OFF} "${INFO0}") # +4+4 and +10+10 depends on fontsize...
	    mogrify -pointsize ${Fs} -fill orange ${FONT} -gravity southeast "${DRAW0[@]}"  ${JPG}
	fi
    else
	echo "${EXP_TIME} @ ${APERTURE} ISO ${ISO}, ${TS}"
	echo "${JPG} exists."
    fi
done

