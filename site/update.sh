#!/bin/sh
set -e

cd www
../../em-dosbox/src/packager.py index ../../Grafica/bin/GRAFICA.EXE

cd $(git rev-parse --show-toplevel)
git subtree push --prefix site/www origin gh-pages
