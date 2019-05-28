#!/bin/sh

PREFIX=$1
LIBKERNEL32=$(${PREFIX}gcc -print-file-name=libkernel32.a)
RELDIR=$(dirname ${LIBKERNEL32})
INCLUDE=$(cd ${RELDIR}/../include && pwd)
LIB=$(cd ${RELDIR} && pwd)
HOST=$(${PREFIX}gcc -dumpmachine)

echo "prefix: \"${PREFIX}\"" > conf-gcc-arm.config
echo "c-include: \"${INCLUDE}\"" >> conf-gcc-arm.config
echo "c-lib: \"${LIB}\"" >> conf-gcc-arm.config
echo "host: \"${HOST}\"" >> conf-gcc-arm.config
