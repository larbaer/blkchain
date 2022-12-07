#!/bin/bash

# Colourize

NORMAL='\033[0;39m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
LILA='\033[0;35m'

# Default Variables

dataLine=""
contentFile=""
chain=""
genesis=""
id_Block="1"

# Optional Parameters
while getopts 'c:f:g:' OPTION ; do
  case "$OPTION" in
    c) chain="$OPTARG"
    ;;                 
    f) contentFile="$OPTARG"
    ;;
    g) genesis="$OPTARG" 
    ;;
    *) # Help display
    ;;
  esac
done


# Functions
calcHash(){
  sha256sum "./$contentFile" | cut -d " " -f 1
}

check_dataLine(){
  echo -e $LILA  "$(echo $dataLine | cut -d ";" -f 1)$NORMAL;"\
                 "$(echo $dataLine | cut -d ";" -f 2)$NORMAL;"\
          $BLUE  "$(echo $dataLine | cut -d ";" -f 3)$NORMAL;"\
          $GREEN "$(echo $dataLine | cut -d ";" -f 4)$NORMAL"
}

### Main ###___________________________________________________________________________________

# Genesis Block---------------------------------------------------------------------------------
if [[ "$genesis" == true ]]; then
  # Generate Genesis - Block
  touch "./default-chain.csv"

  # Build dataLine
  dataLine+="$id_Block;"
  dataLine+="$(cat "$contentFile");"
  dataLine+="$(fish -c "random" | sha256sum | cut -d " " -f 1);" # for random start of chain 
  # dataLine+="$(echo 123 | sha256sum | cut -d " " -f 1);"
  dataLine+="$( echo "$dataLine" | sha256sum | cut -d " " -f 1)"

  # Add dataLine to the chain 
  echo "$dataLine" > "./default-chain.csv"
fi

# Add Block -------------------------------------------------------------------------------------
if ! [[ "$chain" == "" ]]; then
  
  # Read last record
  lastRecord="$(tail -n 1 $chain)"

  # Build dataLine
  dataLine+="$(fish -c "math $(echo $lastRecord | cut -d ";" -f 1) + 1");" # id_Block previous + 1 
  dataLine+="$(cat "$contentFile");" # Adding the Content 
  dataLine+="$(echo $lastRecord | cut -d ";" -f 4);" # Adding the previous Hash 
  dataLine+="$( echo "$dataLine" | sha256sum | cut -d " " -f 1)"
  echo $dataLine >> "./$chain"

fi
