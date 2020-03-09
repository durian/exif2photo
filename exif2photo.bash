#!/bin/bash
#
# Needs: exiv2, imagemagick
#
for FILE in ITM*JPG;
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
	#
	if [ $MODE -eq 0 ]; then
	    INFO0=" ${EXP_TIME} @ ${APERTURE} ISO ${ISO}"
	    DRAW0=(-annotate +10+10 "${INFO0}")
	    INFO1="${TS}"
	    DRAW1=(-annotate +10+110 "${INFO1}")
	    echo mogrify -pointsize 100 -fill yellow "${FONT}" -gravity northwest "${DRAW0[@]}" -gravity northwest  "${DRAW1[@]}"  ${JPG}
	    mogrify -pointsize 100 -fill yellow "${FONT}" -gravity northwest "${DRAW0[@]}" -gravity northwest  "${DRAW1[@]}"  ${JPG}
	fi
	#
	if [ $MODE -eq 1 ]; then
	    INFO0=" ${EXP_TIME} @ ${APERTURE} ISO ${ISO} ${TS}"
	    echo mogrify -pointsize 100 -fill orange "${FONT}" -gravity southeast "${DRAW0[@]}"  ${JPG}
	    DRAW0=(-annotate +4+4 "${INFO0}")
	    mogrify -pointsize 100 -fill black  ${FONT} -gravity southeast "${DRAW0[@]}"  ${JPG}
	    DRAW0=(-annotate +10+10 "${INFO0}")
	    mogrify -pointsize 100 -fill orange ${FONT} -gravity southeast "${DRAW0[@]}"  ${JPG}
	fi
    else
	echo "${EXP_TIME} @ ${APERTURE} ISO ${ISO}, ${TS}"
	echo "${JPG} exists."
    fi
done

