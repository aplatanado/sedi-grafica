#!/bin/sh
../em-dosbox/src/packager.py index ../Grafica/bin/GRAFICA.EXE &&
  mv index.html www &&
  ( cd .. && git subtree push --prefix site/www origin gh-pages )
