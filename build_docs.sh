#!/bin/bash

# Docs by jazzy
# https://github.com/realm/jazzy
# ------------------------------

git submodule update --remote

# Jazzy
cd KangarooStore
cp .jazzy.yml ../
cp README.md ../
cp -rf Assets ../
cd ../
jazzy --source-directory KangarooStore/Xcode
rm -rf docs/docsets