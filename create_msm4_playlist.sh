#!/bin/bash
#
# Skript zum erstellen einer Playlist sowie umbennen 
# der MP3-Dateien in das vom MSM4 Soundmodul erwartete Format.
#
# Author PW
# Version 1.0

# Anzahl der genutzten Tasten
BUTTON_NR="8"
# Playlistname
PLAYLISTBASE="playlst"

if [ $# -lt 4 ]; then
echo ""
echo "Aufruf: $0 -p [0..${BUTTON_NR}] -s [Quellverzeichniss] [-o Ausgabeverzeichnis]"
echo ""
echo "-p Playlist-Nummer"
echo "-s Quellverzeichniss"
echo ""
echo "Wenn kein Ausgabeverzeichnis angegeben wurde, werden die "
echo "Dateien in das aktuelle Verzeichnis abgelegt."
exit 1
fi

# Playlistnummer im Tasten-Bereich?
if [ ${2} -gt ${BUTTON_NR} -o ${2} -lt 0 ]; then
echo "Fehler: Playlist-Nummer ungültig."
exit 1
fi 
PLAYLIST_NR=${2}

# Quellverzeichniss
SRC=${4}

# Anzahl der Audiodateien anzeigen.
AUDIO_ANZ=$(ls "${SRC}"/*.mp3 | wc -l)
echo "${AUDIO_ANZ} Audiodateien im Verzeichis \"${SRC}\" gefunden."

if [ ${AUDIO_ANZ} -lt 1 ]; then
echo "Ende"
exit 1
fi

# Zielverzeichnis überprüfen geg.falls anlegen
if [ x${6} == x ]; then
echo "kein Ausgabeverzeichnis angegeben"
DEST="${PLAYLISTBASE}${PLAYLIST_NR}"
echo "die Dateien werden in Verzeichnis \"${DEST}\" gespeichert" 
else
DEST="${6}"
fi

if [ -d ${DEST} ]; then
echo "Fehler: Ausgabeverzeichnis existiert bereits"
exit 1
fi

mkdir -p "${DEST}" 
if [ $? -ne 0 ]; then
echo "Fehler: Ausgabeverzeichnis konnte nicht angelegt werden"
exit 1
fi

MP3ARRAY=()

while IFS= read -r -d $'\0'; do
MP3ARRAY+=("$REPLY")
done < <(find "${SRC}" -type f -name '*.mp3' -print0 | sort -z)

echo "Dateien kopieren"

# copy and rename mp3s
PLAYLIST="${PLAYLIST_NR}00"
i=0

echo "MP3ARRAY ${#MP3ARRAY[*]}"

while [ $i -lt ${#MP3ARRAY[*]} ]; do
MP3="${MP3ARRAY[$i]}"
FILENAME="${MP3##*/}"
PLAYLISTENTRY="$PLAYLIST"

echo "MP3 $MP3"
echo "FILENAME $FILENAME"

echo $((( ${PLAYLIST} + $i)))";" >> ${DEST}/${PLAYLISTBASE}${PLAYLIST_NR}.txt
echo " ${FILENAME}"
cp "${MP3ARRAY[$i]}" "${DEST}/$(( ${PLAYLIST} +$i))_${FILENAME}"
i=$((i+1))

done

echo "fertig!"

