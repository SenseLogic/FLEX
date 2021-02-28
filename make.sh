#!/bin/sh
set -x
dmd -m64 flex.d
rm *.o
