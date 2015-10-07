#!/bin/sh

SCRIPT_PATH=$(dirname $(realpath -s $0))

"$SCRIPT_PATH"/em-dosbox/src/packager.py index "$SCRIPT_PATH"/Grafica/bin/GRAFICA.EXE &&
  mv index.html "$SCRIPT_PATH"/www &&
  git subtree push --prefix www origin gh-pages
