set -e -x

export LDFLAGS=-L`pwd`/lib/darwin_x64/

if [ ! -d "build/units_x64" ]; then
    mkdir build/units_x64
fi
fpc -Px86_64 @src/darwin-x64.cfg -B src/dss_capi.lpr
bash custom_link.sh lib/darwin_x64

# Make the lib look in the same folder for KLUSolve
DSS_CAPI_LIB="lib/darwin_x64/libdss_capi.dylib"
CURRENT_LIBKLUSOLVEX=`otool -L "$DSS_CAPI_LIB" | grep libklusolvex | cut -f 1 -d ' ' | sed $'s/^[ \t]*//'`
NEW_LIBKLUSOLVEX="@loader_path/./libklusolvex.dylib"
install_name_tool -change "$CURRENT_LIBKLUSOLVEX" "$NEW_LIBKLUSOLVEX" "$DSS_CAPI_LIB"
install_name_tool -id "@loader_path/./libdss_capi.dylib" "$DSS_CAPI_LIB"

fpc -Px86_64 @src/darwin-x64-dbg.cfg -B src/dss_capid.lpr
bash custom_link.sh lib/darwin_x64

# Make the lib look in the same folder for KLUSolve
DSS_CAPI_LIB="lib/darwin_x64/libdss_capid.dylib"
CURRENT_LIBKLUSOLVEX=`otool -L "$DSS_CAPI_LIB" | grep libklusolvex | cut -f 1 -d ' ' | sed $'s/^[ \t]*//'`
NEW_LIBKLUSOLVEX="@loader_path/./libklusolvex.dylib"
install_name_tool -change "$CURRENT_LIBKLUSOLVEX" "$NEW_LIBKLUSOLVEX" "$DSS_CAPI_LIB"
install_name_tool -id "@loader_path/./libdss_capi.dylib" "$DSS_CAPI_LIB"

mkdir -p release/dss_capi/lib
cp -R lib/darwin_x64 release/dss_capi/lib/darwin_x64
cp -R include release/dss_capi/
# cp -R examples release/dss_capi/
cp LICENSE release/dss_capi/
cp OPENDSS_LICENSE release/dss_capi/
cp klusolvex/LICENSE release/dss_capi/KLUSOLVEX_LICENSE
cd release
tar zcf "dss_capi_${TRAVIS_TAG}_darwin_x64.tar.gz" dss_capi
cd ..
rm -rf release/dss_capi
