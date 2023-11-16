#!/bin/bash

# Loop through HEIC files in the current diretory and convert to PNG using
# the heif-convert utility. - 11/16/2023

for file_name in ./*.heic; do
	heif-convert "${file_name}" "${file_name}.png"
done