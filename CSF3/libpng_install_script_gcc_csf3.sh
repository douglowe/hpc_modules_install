cat /etc/redhat-release

# Location of final root directory
#INROOT=/opt/apps/libs
INROOT=/opt/apps/el9-fix/libs
#APPROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/gcc/libpng
APPROOT=$INROOT/gcc/libpng

APPVER=1.6.39
APPDIR=$APPROOT/$APPVER

#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT


cd $APPROOT
mkdir $APPVER archive build
cd archive

#module load tools/env/proxy2


wget --no-check-certificate https://sourceforge.net/projects/libpng/files/libpng16/${APPVER}/libpng-${APPVER}.tar.gz

cd ../build
tar xzf ../archive/libpng-${APPVER}.tar.gz

cd libpng-${APPVER}


#module load use.own
module load compilers/gcc/8.2.0
module load libs/gcc/zlib/1.2.13

export ZLIBINC=$ZLIBINCLUDE
export LDFLAGS=-L$ZLIBLIB
export CPPFLAGS=-I$ZLIBINC


./configure --prefix=$APPDIR 2>&1 | tee ../config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log


#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPDIR

# module file location
#MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/gcc/libpng
#MDIR=/opt/apps/modules/libs/gcc/libpng
MDIR=/opt/apps/el9-fix/modules/libs/gcc/libpng


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

MPATH=libs/gcc/libpng/${APPVER}










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
set    APPNAME        libpng
set    APPNAMECAPS    LIBPNG
set    APPURL        http://www.libpng.org/pub/png/libpng.html
set    APPCSFURL    http://ri.itservices.manchester.ac.uk/csf3/software/libraries/$APPNAME
# Default gcc will be
set    COMPVER        8.2.0
set    COMPNAME    gcc
set    COMPDIR        \${COMPNAME}

module-whatis    \"Adds \$APPNAME \$APPVER to your environment\"

module load compilers/\$COMPNAME/8.2.0
module load libs/\$COMPNAME/zlib/1.2.13


set     APPDIR    $INROOT/\$COMPNAME/\$APPNAME/\$APPVER

setenv        \${APPNAMECAPS}DIR      \$APPDIR
setenv        \${APPNAMECAPS}_HOME    \$APPDIR
setenv        \${APPNAMECAPS}BIN      \$APPDIR/bin
setenv        \${APPNAMECAPS}LIB      \$APPDIR/lib
setenv        \${APPNAMECAPS}INCLUDE  \$APPDIR/include

# Typical env vars to help a compiler find this library and header files
# and to also allow the library to be found when your compiled code is run.
prepend-path    C_INCLUDE_PATH    \$APPDIR/include
prepend-path    CPATH             \$APPDIR/include
prepend-path    LIBRARY_PATH      \$APPDIR/lib
prepend-path    LD_LIBRARY_PATH   \$APPDIR/lib
prepend-path    PATH              \$APPDIR/bin
prepend-path    MANPATH           \$APPDIR/share/man
# Add any other vars your need...
" > $APPVER
