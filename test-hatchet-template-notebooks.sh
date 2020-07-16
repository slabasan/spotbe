#!/bin/bash

user_in_spotdev()
{
    if id -nG $1 | grep -qw spotdev; then
        echo "Yes"
    else
        echo "No"
    fi
}

if [ $# -ne 1 ]; then
    echo "Usage: $0 <cali-file>"
    exit 1
fi

CALI_FILE=$1

# run spot.py to update variables in template notebook
JUPYTER_NB=$(./spot.py --ci_testing jupyter ${CALI_FILE})
OUTFILE=$(echo ${JUPYTER_NB} | rev | cut -d "." -f 2- | rev).nbconvert.ipynb

echo -e "CI Testing for Jupyter:"
echo -e "    Running As: ${USER}"
echo -e "    Member of spotdev?: $(user_in_spotdev ${USER})"
echo -e "    Input Jupyter Notebook:"
echo -e "        ${JUPYTER_NB}"
echo -e "    Output Jupyter Notebook:"
echo -e "        ${OUTFILE}"
echo -e "    Cali File:"
echo -e "        ${CALI_FILE}"

echo -e ""

# run notebook programmatically from command line
jupyter nbconvert \
    --to notebook \
    --execute \
    --ExecutePreprocessor.timeout=60 \
    --output ${OUTFILE} \
    ${JUPYTER_NB}

err=$?

echo -e ""
if [ ${err} -eq 0 ]; then
    echo -e "SUCCESS $0"
else
    echo -e "FAILURE $0"
fi

#
