#!/bin/bash

BUILD_DEPS="0"
BUILD_BAMBU_STUDIO="0"
BUILD_QUICK="0"
PACKAGE_APP="0"

usage () {
    echo "Usage: ./build-macos.sh [-d][-s][-m][-p][-h]"
    echo "  -d: build deps (optional)"
    echo "  -s: build bambu-studio (optional)"
    echo "  -q: quick - skip cmake prepare"
    echo "  -h: help - display this message"
    echo "For a first use, you want './build-macos.sh -ds'"
    echo "   subsequent builds may use './build-macos.sh -sq'"
}


while getopts ":dsqph" opt; do
    case ${opt} in
        d )
            BUILD_DEPS="1"
            ;;
        s )
            BUILD_BAMBU_STUDIO="1"
            ;;
        q )
            BUILD_QUICK="1"
            ;;
        p )
            PACKAGE_APP="1"
            ;;
        h ) usage
            exit 0
            ;;
    esac
done

if [ $OPTIND -eq 1 ]
then
    usage
    exit 1
fi




./write_gitid_to_resources.sh

ulimit -n 1024

export LIBRARY_PATH=$LIBRARY_PATH:$(brew --prefix zstd)/lib/

BASEPATH="$(pwd)"
DEPS_BUILD_DIR="$BASEPATH/deps/build"
DEPS_DEST_DIR="$BASEPATH/build/BambuStudio_dep"
INSTALL_DIR="$BASEPATH/build/install_dir"
INSTALL_BUILD_DIR="$BASEPATH/build/build"
PACKAGE_APP_DIR="$BASEPATH/build/dist"
ARCH="x86_64"

uname_p=$(uname -p)
if [ $uname_p == "arm" ]
then
	ARCH="arm64"
fi

echo building for $ARCH


build_deps () {
    mkdir -p "$DEPS_BUILD_DIR"
    mkdir -p "$DEPS_DEST_DIR"


    cd "$DEPS_BUILD_DIR"
    cmake ../ -DDESTDIR="$DEPS_DEST_DIR" -DOPENSSL_ARCH="darwin64-${ARCH}-cc"

    make -j6

    cd ..
}

build_bambu_studio () {
    mkdir -p "$INSTALL_BUILD_DIR"
    cd "$INSTALL_BUILD_DIR"

    rm -r "$INSTALL_DIR/bin"

    if [ $BUILD_QUICK != "1" ]
    then
        cmake ../..  -DBBL_RELEASE_TO_PUBLIC=1 -DCMAKE_PREFIX_PATH="$DEPS_DEST_DIR/usr/local" -DCMAKE_INSTALL_PREFIX="../install_dir" -DCMAKE_BUILD_TYPE=Release -DCMAKE_MACOSX_RPATH=ON -DCMAKE_INSTALL_RPATH="$DEPS_DEST_DIR/BambuStudio_dep/usr/local" -DCMAKE_MACOSX_BUNDLE=on
    fi
    
    cmake --build . --target install --config Release -j6
}

package_app () {
    mkdir -p "$PACKAGE_APP_DIR"
    cp -R "$INSTALL_DIR/bin/BambuStudio.app" "$PACKAGE_APP_DIR"
    rm "$PACKAGE_APP_DIR/BambuStudio.app/Contents/Resources"
    cp -R "$BASEPATH/resources" "$PACKAGE_APP_DIR/BambuStudio.app/Contents/Resources"
}


if [ $BUILD_DEPS == "1" ] 
then      
    build_deps
fi

if [ $BUILD_BAMBU_STUDIO == "1" ]
then
    build_bambu_studio
fi


if [ $PACKAGE_APP == "1" ]
then
    package_app
fi
