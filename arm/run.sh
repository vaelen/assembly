#!/bin/bash

make -s $1
echo "--------------------"
./$1 
rc=$?
echo "--------------------"
echo "Return Code: $rc"
