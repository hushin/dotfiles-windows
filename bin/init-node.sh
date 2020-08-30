#!/bin/bash

git init
# https://github.com/simonwhitaker/gibo
gibo dump Node >> .gitignore
# https://github.com/blaix/license-generator
licgen MIT hushin
touch README.md
# create dir
mkdir test
mkdir lib
mkdir src
# create package.json
# https://github.com/azu/init-package-json-parcel
yes '' | init-package-json
# git
git add .
