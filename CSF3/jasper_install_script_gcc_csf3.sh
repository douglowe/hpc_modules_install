cat /etc/redhat-release

# Location of final root directory
INROOT=/opt/apps/libs
#APPROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/gcc/jasper
APPROOT=$INROOT/gcc/jasper


APPVER=2.0.14
APPDIR=$APPROOT/$APPVER

#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT
chown ${USER}. $APPROOT


cd $APPROOT
mkdir $APPVER archive build
cd archive

module load tools/env/proxy2

wget http://www.ece.uvic.ca/~frodo/jasper/software/jasper-${APPVER}.tar.gz

cd ../build
tar xzf ../archive/jasper-${APPVER}.tar.gz

cd jasper-${APPVER}


module load tools/gcc/cmake/3.13.2


SOURCE_DIR=${APPROOT}/build/jasper-${APPVER}
BUILD_DIR=${APPROOT}/build/jasper-${APPVER}-build
OPTIONS="-DJAS_ENABLED_SHARED=true -DJAS_ENABLE_LIBJPEG=true"
mkdir $BUILD_DIR
cmake -G "Unix Makefiles" -H$SOURCE_DIR -B$BUILD_DIR -DCMAKE_INSTALL_PREFIX=$APPDIR $OPTIONS

cd $BUILD_DIR
make clean all 2>&1 | tee make-$APPVER.log
make test ARGS="-V" 2>&1 | tee make-test-$APPVER.log
# NOTE - test 3 will fail. However it looks like this is an issue with the 
#        null result message from the "which" command on CSF3:
#        https://github.com/AAROC/CODE-RADE/issues/36
#  I think that we can safely ignore the failure of test 3.
make install 2>&1 | tee make-install-$APPVER.log


#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPDIR

# module file location
#MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/gcc/jasper
MDIR=/opt/apps/modules/libs/gcc/jasper


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

MPATH=libs/gcc/jasper/${APPVER}


#### module script
# It is a bit of a faff writing a bash script from a bash script - you need to ensure
# any special characters you don't want to be executed are escaped out (using \).
echo "#%Module1.0####################################################
##
## CSF3 LIBRARY-TEMPLATE Modulefile
##
##
proc getenv {key {defaultvalue {}}} {
  global env; expr {[info exist env(\$key)]?\$env(\$key):\$defaultvalue}
}

proc ModulesHelp { } {
    global APPVER APPNAME APPURL APPCSFURL COMPVER COMPNAME

    puts stderr \"
    Adds \$APPNAME \$APPVER to your PATH environment variable and any necessary
    libraries. It has been compiled with the \$COMPNAME \$COMPVER compiler.

    For information on how to run \$APPNAME on the CSF please see:
    \$APPCSFURL
    
    For application specific info see:
    \$APPURL
\"
}

set    APPVER         ${APPVER}
set    APPNAME        jasper
set    APPNAMECAPS    JASPER
set    APPURL        http://www.ece.uvic.ca/~frodo/jasper/
set    APPCSFURL    http://ri.itservices.manchester.ac.uk/csf3/software/libraries/$APPNAME
# Default gcc will be
set    COMPVER        4.8.5
set    COMPNAME    gcc
set    COMPDIR        \${COMPNAME}

module-whatis    \"Adds \$APPNAME \$APPVER to your environment\"

set     APPDIR    $INROOT/\$COMPNAME/\$APPNAME/\$APPVER

setenv        \${APPNAMECAPS}DIR      \$APPDIR
setenv        \${APPNAMECAPS}_HOME    \$APPDIR
setenv        \${APPNAMECAPS}BIN      \$APPDIR/bin
setenv        \${APPNAMECAPS}LIB      \$APPDIR/lib64
setenv        \${APPNAMECAPS}INCLUDE  \$APPDIR/include

# Typical env vars to help a compiler find this library and header files
# and to also allow the library to be found when your compiled code is run.
prepend-path    C_INCLUDE_PATH    \$APPDIR/include
prepend-path    CPATH             \$APPDIR/include
prepend-path    LIBRARY_PATH      \$APPDIR/lib64
prepend-path    LD_LIBRARY_PATH   \$APPDIR/lib64
prepend-path    PATH              \$APPDIR/bin
prepend-path    MANPATH           \$APPDIR/share/man
# Add any other vars your need...
" > $APPVER


