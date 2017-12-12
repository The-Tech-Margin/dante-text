#! /bin/sh

#	remove control M's (CR's) from a file

tr -d '\015' $*
