#!/bin/bash

dir=$(dirname "$0")

while read svg; do
    width=$(cat "${svg}" | grep -o 'viewBox="[^"]*"' | sed 's/viewBox=//' | sed 's/"//g' | cut -d' ' -f3)
    height=$(cat "${svg}" | grep -o 'viewBox="[^"]*"' | sed 's/viewBox=//' | sed 's/"//g' | cut -d' ' -f4)
    png=$(echo "${svg}" | sed 's/.svg$/.png/')
    cairosvg -W ${width} -H ${height} -o "${png}" "${svg}"
done < <(find "${dir}" -name "*.svg")
