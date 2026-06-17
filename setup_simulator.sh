#!/bin/bash

set -e

# Get environmental variables
. $(dirname "${0}")/.env
echo "*** 终极清理 ***"
rm -rf ${EPS_ETISS_BUILD} 
rm -rf ${EPS_ETISS_INSTALLED}
rm -rf ${EPS_SIM}/build
# Setup ETISS
echo ""
echo "*** Installing ETISS ***"

cd ${EPS_ETISS}/PluginImpl
if [ ! -L SoftwareEvalLib ]; then
    echo " > Linking SoftwareEval Library to ETISS"
    ln -s ${EPS_ETISS_PLUGINS}/SoftwareEvalLib SoftwareEvalLib
fi

echo " > Applying hot-fixes to ETISS"
cp ${EPS_ETISS_HOTFIX}/include/etiss/* ${EPS_ETISS}/include/etiss
cp ${EPS_ETISS_HOTFIX}/src/* ${EPS_ETISS}/src

echo " > Installing..."
mkdir -p ${EPS_ETISS_BUILD}
cd ${EPS_ETISS_BUILD}
cmake -DCMAKE_BUILD_TYPE=Release -DETISS_BUILD_MANUAL_DOC=ON -DCMAKE_INSTALL_PREFIX:PATH=${EPS_ETISS_INSTALLED} -DBoost_NO_SYSTEM_PATHS=ON -DBoost_ROOT=/usr ..
make -j$(nproc) install


# Setup simulator
echo ""
echo "*** Installing simulator ***"
cd ${EPS_SIM}
mkdir -p build
cd build
cmake -DETISS_DIR=${EPS_ETISS_INSTALLED}/lib/CMake/ETISS ..
make -j $(nproc)
