#!/usr/bin/env bash

# Update all STL files from latest SCAD files
# Note: at the time of writing (v2021.01), export does not appear deterministic - you *will* get changes on each run
# even if the effective content hasn't changed

OPENSCAD_PATH=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD

set -euo pipefail

get_script_dir () {
    SOURCE="${BASH_SOURCE[0]}"
    SOURCE_DIR=$( dirname "$SOURCE" )
    SOURCE_DIR=$(cd -P ${SOURCE_DIR} && pwd)
    echo ${SOURCE_DIR}
}

SCRIPT_DIR="$( get_script_dir )"
cd $SCRIPT_DIR

SCAD_FILES=$(find "${SCRIPT_DIR}" -depth 1 -name "*.scad")

for SCAD_FILE in $SCAD_FILES
do
  BASEFILE=$(basename $SCAD_FILE)
  STLFILE="${BASEFILE%.scad}.stl"
  PNGFILE="docs/${BASEFILE%.scad}.png"
  echo "$BASEFILE => $STLFILE"
  $OPENSCAD_PATH -o "$STLFILE" --export-format binstl "$BASEFILE"
  $OPENSCAD_PATH -o "$PNGFILE" --camera=0,0,0,210,0,190,350 --projection=ortho --colorscheme=Tomorrow "$BASEFILE"
done

echo DONE