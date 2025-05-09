cat /etc/redhat-release

# Location of final root directory
#INROOT=/opt/apps/libs
INROOT=/opt/apps/el9-fix/libs
#APPROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/gcc/hdf5
APPROOT=$INROOT/gcc/hdf5

#APPBASE=1.8
#APPVER=$APPBASE.23
APPBASE=1.14
APPVER=$APPBASE.1
APPDIR=$APPROOT/$APPVER

#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT


cd $APPROOT
mkdir $APPVER archive build
cd archive

### not doing the above tasks, as we are sharing space with another admin - so
### look in archive/mbessdl2 and build/mbessdl2 instead

#module load tools/env/proxy2

#wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${APPBASE}/hdf5-${APPVER}/src/hdf5-${APPVER}.tar.gz
wget https://support.hdfgroup.org/releases/hdf5/v1_14/v1_14_1/downloads/hdf5-${APPVER}-2.tar.gz

cd ../build
tar xzf ../archive/hdf5-${APPVER}-2.tar.gz

mv hdf5-1.14.1-2 hdf5-1.14.1
cd hdf5-${APPVER}


#module load use.own
#module load priv_libs/gcc/zlib/1.2.11
module load compilers/gcc/8.2.0
module load libs/gcc/zlib/1.2.13

./configure --prefix=$APPDIR --enable-fortran --enable-cxx --with-zlib=$ZLIB_HOME/include,$ZLIB_HOME/lib 2>&1 | tee ../config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log


#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPDIR

# module file location
#MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/gcc/hdf5
#MROOT=/opt/apps/modules/libs
MROOT=/opt/apps/el9-fix/modules/libs
MDIR=$MROOT/gcc/hdf5


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

#MPATH=priv_libs/gcc/hdf5/${APPVER}
MPATH=libs/gcc/hdf5/${APPVER}










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
set    APPNAME        hdf5
set    APPNAMECAPS    HDF5
set    APPURL        https://support.hdfgroup.org/HDF5/
set    APPCSFURL    http://ri.itservices.manchester.ac.uk/csf3/software/libraries/$APPNAME
# Default gcc will be
set    COMPVER        8.2.0
set    COMPNAME    gcc
set    COMPDIR        \${COMPNAME}

module-whatis    \"Adds \$APPNAME \$APPVER to your environment\"

conflict libs/\$COMPNAME/hdf5

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
