#!/bin/bash

make -s $1
rc=$?
if [ $rc -ne 0 ]; then
	exit $rc
fi

echo "--------------------"
./$1 
rc=$?
echo "--------------------"
echo "Return Code: $rc"
