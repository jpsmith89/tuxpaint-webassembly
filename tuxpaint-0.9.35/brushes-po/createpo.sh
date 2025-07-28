#!/bin/sh

set -e

# "createpo.sh" for Tux Paint brush description files
# (based on "createpo.sh" from `tuxpaint-stamps`)
# Last modified 2024-03-25

# Generate an updated translation template file for the
# descriptions (".pot") based on the main English
# strings found in the text description files ("filename.txt").
chmod 755 txt2pot.py
./txt2pot.py

# Unify any duplicate translations in the message catalog (".pot")
msguniq tuxpaint-brushes.pot | fgrep -v '#-#-#-#-#' > temp.tmp && mv -f temp.tmp tuxpaint-brushes.pot

# Merge the existing translations with the updated ".pot" file
for i in *.po ; do
  echo $i
  msgmerge --quiet --update --previous --no-wrap --backup=none $i tuxpaint-brushes.pot
  # Note: Not using --sort-output, since the POT should be in
  # the order of the files themselves (by filename),
  # and that's much more useful than sorting by "msgid".
done

msguniq --no-wrap --to-code=UTF-8 tuxpaint-brushes.pot > temp.tmp && mv -f temp.tmp tuxpaint-brushes.pot

