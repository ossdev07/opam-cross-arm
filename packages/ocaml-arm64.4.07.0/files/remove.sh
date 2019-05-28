#!/bin/sh -e

PREFIX="$1"

for bin in ocaml ocamlc ocamlcp ocamldebug ocamldep ocamldoc ocamllex ocamlmklib ocamlmktop ocamlobjinfo ocamlopt ocamloptp ocamlprof ocamlrun ocamlyacc; do
  rm -f "${PREFIX}/arm-sysroot/bin/${bin}"
done

rm -rf "${PREFIX}/arm-sysroot/lib/ocaml"
rm -rf "${PREFIX}/lib/findlib.conf.d/arm.conf"
