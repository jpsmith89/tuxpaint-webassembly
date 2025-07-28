#!/bin/sh

# "createtxt.sh" for Tux Paint text description files
# (based on "createtxt.sh" from `tuxpaint-stamps`)
# Last modified 2023-03-25

set -e

# Unify any duplicate translations
for i in *.po* ; do
  msguniq --no-wrap --to-code=UTF-8 $i > temp.tmp && mv -f temp.tmp $i
done

# Regenerate the description text files ("filename.txt")
# from translation files (".po")
chmod 755 po2txt.py
./po2txt.py
