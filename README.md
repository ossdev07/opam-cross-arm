opam-cross-arm
==================

This repository contains an up-to-date Arm toolchain featuring OCaml 4.07.0, as well as some commonly used packages.

The supported build systems are 32-bit and 64-bit x86 Linux. The supported target systems are 32-bit and 64-bit x86 Arm.

If you need support for other platforms or versions, please [open an issue](https://github.com/ossdev07/opam-cross-arm/issues).

Prerequisites
-------------

On 64-bit Linux build systems, 32-bit libraries must be installed. On Debian derivatives they are provided in the `gcc-multilib` package.

A C cross-compiler targeting the appropriate Arm platform must be installed. On Debian derivatives they are provided in the `arm-linux-gnueabihf` (for 32-bit Arm targets) or `aarch64-linux-gnu` (for 64-bit Arm targets) packages.

Installation
------------

Add this repository to OPAM:

    opam repository add arm git://github.com/ossdev07/opam-cross-arm

On 64-bit build systems, switch to 32-bit compiler when compiling for 32-bit targets:

    opam switch 4.07.0+32bit
    eval `opam config env`

Otherwise, use a regular compiler; its version must match the version of the cross-compiler:

    opam switch 4.07.0
    eval `opam config env`

Pin some prerequisite packages that don't yet have fixes merged upstream:

    opam pin add topkg https://github.com/whitequark/topkg.git

If desired, request the compiler to be built with [flambda][] optimizers:

    opam install conf-flambda-arm

[flambda]: https://caml.inria.fr/pub/docs/manual-ocaml/flambda.html

Install the compiler:

    opam install ocaml-arm

The compiler version is selected automatically based on the current OPAM switch;
either ocaml-arm32 or ocaml-arm64 can be installed in any single one.


Build some code:

    echo 'let () = print_endline "Hello, world!"' >helloworld.ml
    ocamlfind -toolchain arm ocamlc helloworld.ml -o helloworld.byte
    ocamlfind -toolchain arm ocamlopt helloworld.ml -o helloworld.native

Run it:

    wine cmd /c "set PATH=Z:/$(ocamlfind -toolchain arm printconf path)/../bin;%PATH%
                 && ./helloworld.byte"
    wine ./helloworld.native

Install some packages:

    opam install re-arm

Write some code using them:

    let () =
      let regexp = Re_pcre.regexp {|\b([a-z]+)\b|} in
      let result = Re.exec regexp "Hello, world!" in
      Format.printf "match: %s\n" (Re.get result 1)

Build it:

    ocamlfind -toolchain arm ocamlopt -package re.pcre -linkpkg test_pcre.ml -o test_pcre

Make an object file out of it and link it with your native project (you'll need to call `caml_startup(argv)` to run OCaml code; see [this article](http://www.mega-nerd.com/erikd/Blog/CodeHacking/Ocaml/calling_ocaml.html)):

    ocamlfind -toolchain arm ocamlopt -package re.pcre -linkpkg -output-complete-obj test_pcre.ml -o test_pcre.o

With opam-windows-cross, cross-compilation is easy!

Porting packages
----------------

OCaml packages often have components that execute at compile-time (camlp4 or ppx syntax extensions, cstubs, OASIS, ...). Thus, it is not possible to just blanketly cross-compile every package in the OPAM repository; sometimes you would even need a cross-compiled and a non-cross-compiled package at once. The package definitions also often need package-specific modification in order to work.

As a result, if you want a package to be cross-compiled, you have to copy the definition from [opam-repository](https://github.com/ocaml/opam-repository), rename the package to add `-arm` suffix while updating any dependencies it could have, and update the build script. Don't forget to add `ocaml-arm` as a dependency!

Findlib 1.5.4 adds a feature that makes porting packages much simpler; namely, an `OCAMLFIND_TOOLCHAIN` environment variable that is equivalent to the `-toolchain` command-line flag. Now it is not necessary to patch the build systems of the packages to select the Arm toolchain; it is often enough to add `["env" "OCAMLFIND_TOOLCHAIN=arm" make ...]` to the build command in the `opam` file.

For projects using OASIS, the following steps will work:

    build: [
      ["env" "OCAMLFIND_TOOLCHAIN=arm"
       "ocaml" "setup.ml" "-configure" "--prefix" "%{prefix}%/arm-sysroot"
                                       "--override" "ext_dll" ".dll"]
      ["env" "OCAMLFIND_TOOLCHAIN=arm"
       "ocaml" "setup.ml" "-build"]
    ]
    install: [
      ["env" "OCAMLFIND_TOOLCHAIN=arm"
       "ocaml" "setup.ml" "-install"]
    ]
    remove: [["ocamlfind" "-toolchain" "arm" "remove" "pkg"]]
    depends: ["ocaml-arm" ...]

The output of the `configure` script will be entirely wrong, referring to the host configuration rather than target configuration. Thankfully, it is not actually used in the build process itself, so it doesn't matter.

For projects installing the files via OPAM's `.install` files (e.g. [topkg](https://github.com/dbuenzli/topkg)), the following steps will work:

    build: [["ocaml" "pkg/pkg.ml" "build" "--toolchain" "arm" ]]
    install: [["opam-installer" "--prefix=%{prefix}%/arm-sysroot" "pkg.install"]]
    remove: [["ocamlfind" "-toolchain" "arm" "remove" "pkg"]]
    depends: ["ocaml-arm" ...]

Internals
---------

The aim of this repository is to build a cross-compiler while altering the original codebase in the minimal possible way. (Indeed, only about 50 lines are changed.) There are no attempts to alter the `configure` script; rather, the configuration is provided directly. The resulting cross-compiler has several interesting properties:

  * All paths to the Arm toolchain are embedded inside `ocamlc` and `ocamlopt`; thus, no knowledge of the Arm toolchain is required even for packages that have components in C, provided they use the OCaml driver to compile the C code. (This is usually the case.)
  * The build system makes several assumptions that are not strictly valid while cross-compiling, mainly the fact that the bytecode the cross-compiler has just built can be ran by the `ocamlrun` on the build system. Thus, the requirement for a 32-bit build compiler for 32-bit targets, as well as for the matching versions.
  * The `.opt` versions of the compiler are built using itself, which doesn't work while cross-compiling, so all provided tools are bytecode-based.

License
-------

All files contained in this repository are licensed under the [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) license.

References
----------

See also [ocaml-cross-android](https://github.com/whitequark/ocaml-cross-android) and [ocaml-cross-ios](https://github.com/whitequark/ocaml-cross-ios).
