#!/bin/bash

# A estrutura é: "Linha1\nLinha2"
# O separador entre itens é o "|"

echo -e "Música 01\nArtista A|Música 02\nArtista B|Música 03\nArtista C" | \
rofi -dmenu \
     -sep "|" \
     -eh 2 \
     -p "Playlist"