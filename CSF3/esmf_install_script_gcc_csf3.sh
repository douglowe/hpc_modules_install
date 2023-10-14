#!/bin/bash

# Install script for ESMF 2

# This can't be run as a non-interactive job, as the configuration step requires
#   user input.

module load use.own

INMOD=${HOME}/privatemodules/priv_apps
INROOT=${HOME}/privatemodules_packages/csf3/apps

## configuration settings
#INROOT=/opt/apps/apps

APPVER=8.5
COMPILER=gcc


# settings for modules file
MDIR=${INMOD}/${COMPILER}/esmf
#MDIR=/opt/apps/modules/apps/${COMPILER}/esmf2
MPATH=apps/${COMPILER}/wrf/${APPVER}


## running code

# set the install & executable directory
APPROOT=$INROOT/${COMPILER}/esmf
APPDIR=$APPROOT/$APPVER

# making the install directory (and change accessibility if needed)
#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir -p $APPROOT

# making the executable code directory, and build directory (no archive for this)
cd $APPROOT
mkdir $APPVER build archive
cd archive

# download the WRF code
#module load tools/env/proxy2
# run this in an interactive job, to get access to the internet
#  qrsh -l short -cwd bash
wget https://github.com/esmf-org/esmf/archive/refs/tags/v${APPVER}.0.tar.gz

cd ../build

tar zxvf ../archive/v${APPVER}.0.tar.gz

cd esmf-${APPVER}.0

# load modules needed for compiling the code
# (loading netcdf should load hdf5 and zlib libraries too)
module load compilers/gcc/8.2.0
module load libs/${COMPILER}/netcdf/4.9.2
module load mpi/${COMPILER}/openmpi/4.1.2-gcc-8.2.0

module load libs/lapack/3.5.0/gcc-4.8.5
#module load libs/blas/3.6.0/gcc-4.8.5

module load tools/gcc/cmake/3.16.4

## environmental settings
export ESMF_DIR=$(pwd)
# set ESMF_BOPT="g" to build debug version
export ESMF_BOPT="O"
#export ESMF_OPTLEVEL= #0 to 4

export ESMF_COMM="openmpi"
export ESMF_COMPILER="gfortran"

export ESMF_NETCDF="nc-config"
export ESMF_LAPACK="netlib"
export ESMF_LAPACK_LIBPATH=${LAPACKLIB}

export ESMF_INSTALL_PREFIX=${APPROOT}/${APPVER}
# explicitly setting these directories, or the files are put in `lib\lib0\Linux.gfortran.64.openmpi.default` (for example)
export ESMF_INSTALL_BINDIR=${ESMF_INSTALL_PREFIX}/bin
export ESMF_INSTALL_LIBDIR=${ESMF_INSTALL_PREFIX}/lib
export ESMF_INSTALL_MODDIR=${ESMF_INSTALL_PREFIX}/mod





# view and verify make settings
make info 2>&1 | tee make_info.txt
# (then read through the make_info.txt file)


# make the library
make 2>&1 | tee make_log.txt
#make -j6 2>&1 | tee make_log.txt


# check the build
make check 2>&1 | tee make_check_log.txt

# install the library
make install 2>&1 | tee make_install_log.txt

# check the install
make installcheck 2>&1 | tee make_installcheck_log.txt

# NOTE: This warning has been given of a clash between the following modules
#  compilers/gcc/8.2.0
#  libs/lapack/3.5.0/gcc-4.8.5
# Warning:
#  /usr/bin/ld: warning: libgfortran.so.3, needed by /opt/gridware/depots/8e896c5a/el7/pkg/libs/lapack/3.5.0/gcc-4.8.5/lib/liblapack.so, may conflict with libgfortran.so.5
#
# If we get problems in usage, then we might need to compile a new lapack library 
# for the 8.2.0 gcc compiler



#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPROOT


# make module file location
#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir -p $MDIR
cd $MDIR





### generating the module file

echo "#%Module1.0####################################################
##
## CSF3 APP-TEMPLATE Modulefile
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
set    APPNAME        esmf
set    APPNAMECAPS    ESMF
set    APPURL         https://earthsystemmodeling.org
# Default gcc will be
set    COMPVER        8.2.0
set    COMPNAME       ${COMPILER}
set    COMPDIR        \${COMPNAME}
set    MPIVER         4.1.2

module-whatis    \"Adds \$APPNAME \$APPVER to your environment\"

# load required modules
module load compilers/\$COMPNAME/\$COMPVER
module load libs/\$COMPNAME/netcdf/4.9.2
module load mpi/\$COMPNAME/openmpi/4.1.2-gcc-8.2.0
module load libs/lapack/3.5.0/gcc-4.8.5



set     APPDIR    $INROOT/\$COMPNAME/\$APPNAME/\$APPVER

setenv        \${APPNAMECAPS}DIR      \$APPDIR
setenv        \${APPNAMECAPS}BIN      \$APPDIR/bin
setenv        \${APPNAMECAPS}LIB      \$APPDIR/lib
setenv        \${APPNAMECAPS}INCLUDE  \$APPDIR/include
setenv        ESMFMKFILE              \$APPDIR/lib

# Typical env vars needed to run an app
prepend-path    PATH              \$APPDIR/bin
" > $APPVER