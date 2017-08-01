#!/bin/bash

dir=$(dirname "$0")

${dir}/swiftframe \
    --config "${dir}/swiftframe.config" \
    --title-texts "${dir}/titles.txt" \
    --screenshot-directory "${dir}/Screenshots" \
    --verbose
