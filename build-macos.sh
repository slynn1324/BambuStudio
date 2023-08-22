#!/bin/bash

./write_gitid_to_resources.sh

ulimit -n 1024

export LIBRARY_PATH=$LIBRARY_PATH:$(brew --prefix zstd)/lib/

BASEPATH="$(pwd)"
DEPS_BUILD_DIR="$BASEPATH/deps/build"
DEPS_DEST_DIR="$BASEPATH/build/BambuStudio_dep"
INSTALL_DIR="$BASEPATH/build/install_dir"
INSTALL_BUILD_DIR="$BASEPATH/build/build"

build_deps () {
    mkdir -p "$DEPS_BUILD_DIR"
    mkdir -p "$DEPS_DEST_DIR"


    cd "$DEPS_BUILD_DIR"
    cmake ../ -DDESTDIR="$DEPS_DEST_DIR" -DOPENSSL_ARCH="darwin64-x86_64-cc"

    make -j6

    cd ..
}

build_slicer () {
    mkdir -p "$INSTALL_BUILD_DIR"
    cd "$INSTALL_BUILD_DIR"

    rm -r "$INSTALL_DIR/bin"

    # cmake ../..  -DBBL_RELEASE_TO_PUBLIC=1 -DCMAKE_PREFIX_PATH="$DEPS_DEST_DIR/usr/local" -DCMAKE_INSTALL_PREFIX="../install_dir" -DCMAKE_BUILD_TYPE=Release -DCMAKE_MACOSX_RPATH=ON -DCMAKE_INSTALL_RPATH="$DEPS_DEST_DIR/BambuStudio_dep/usr/local" -DCMAKE_MACOSX_BUNDLE=on
    
    cmake --build . --target install --config Release -j6
}

build_deps
build_slicer
