#!/bin/bash

# Install script for WPS

# This can't be run as a non-interactive job, as the configuration step requires
#   user input.

## configuration settings
INROOT=/opt/apps/apps

APPVER=4.6.0
COMPILER=gcc

# settings for modules file
MDIR=/opt/apps/modules/apps/gcc/wps
MPATH=apps/gcc/wps/${APPVER}

## running code

# set the install & executable directory
APPROOT=$INROOT/gcc/wps
APPDIR=$APPROOT/$APPVER

# making the install directory (and change accessibility if needed)
#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT

# making the executable code directory, and build directory (no archive for this)
cd $APPROOT
mkdir $APPVER build archive
cd archive

# download the WRF code
#module load tools/env/proxy2
#git clone https://github.com/UoMResearchIT/WPS.git
wget https://github.com/wrf-model/WPS/archive/refs/tags/v${APPVER}.tar.gz


cd ../build

tar zxf ../archive/v${APPVER}.tar.gz

# go to build directory
cd WPS-${APPVER}

# load modules needed for compiling the code
# (loading netcdf should load hdf5 and zlib libraries too)
module load compilers/gcc/8.2.0
module load libs/${COMPILER}/jasper/2.0.33
module load libs/${COMPILER}/libpng/1.6.39
module load libs/${COMPILER}/netcdf/4.9.2
module load mpi/${COMPILER}/openmpi/4.1.8-gcc-8.2.0
module load apps/gcc/wrf/4.7.1

# load cmake, and supporting libraries
module load libs/gcc/openssl/1.0.2k
module load tools/gcc/cmake/3.28.6



# environmental settings
export NETCDF=$NETCDFDIR
export USENETCDFPAR=0
export JASPERINC=$JASPERINCLUDE
export WRFIO_NCD_LARGE_FILE_SUPPORT=1

# Modify CMake to accept our version of jasper, and remove gcc-10 flags
mv CMakeLists.txt CMakeLists.txt.old
sed -e "s|1.900.29|2.0.33|g" \
    -e "s|-fallow-argument-mismatch||g" \
    CMakeLists.txt.old > CMakeLists.txt


# configuring the model - select all defaults #### THIS MUST BE RUN INTERACTIVELY
./configure_new -i $APPDIR

# compile the model
# NOTE: there will be constant warnings about cmake not determining the version of SSL, these can be ignored
./compile_new 2>&1 | tee z_wps_compile_log.txt

# cmake installs the binaries in the operational directories
# need to create the running directory template though
cd ../../$APPVER

# create running directory template directory, and copy necessary setting files
mkdir run_dir
mkdir run_dir/geogrid run_dir/ungrib run_dir/metgrid
cp -a ../build/WPS-${APPVER}/geogrid/GEOGRID.TBL* run_dir/geogrid/
cp -a ../build/WPS-${APPVER}/ungrib/Variable_Tables run_dir/ungrib/
cp -a ../build/WPS-${APPVER}/metgrid/METGRID.TBL* run_dir/metgrid/


### need some code creating the example batch scripts here???


#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPROOT


# make module file location
#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR
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
set    APPNAME        wps
set    APPNAMECAPS    WPS
set    APPURL        http://www2.mmm.ucar.edu/wrf/users/
set    APPCSFURL     http://ri.itservices.manchester.ac.uk/csf3/software/applications/\$APPNAME
# Default gcc will be
set    COMPVER        8.2.0
set    COMPNAME    gcc
set    COMPDIR        \${COMPNAME}
set    MPIVER         4.1.2

module-whatis    \"Adds \$APPNAME \$APPVER to your environment\"

# load required modules
module load compilers/\$COMPNAME/\$COMPVER
module load libs/\$COMPNAME/netcdf/4.9.2
module load mpi/\$COMPNAME/openmpi/4.1.8-gcc-8.2.0
module load libs/\$COMPNAME/jasper/2.0.33
module load libs/\$COMPNAME/libpng/1.6.39

set     APPDIR    $INROOT/\$COMPNAME/\$APPNAME/\$APPVER

setenv        \${APPNAMECAPS}DIR      \$APPDIR
setenv        \${APPNAMECAPS}_HOME    \$APPDIR
setenv        \${APPNAMECAPS}BIN      \$APPDIR/bin
setenv        \${APPNAMECAPS}_RUNDIR  \$APPDIR/run_dir
setenv        \${APPNAMECAPS}_GEOG    /mnt/data-sets/wrf-geog/4.0

# Typical env vars needed to run an app
prepend-path    PATH              \$APPDIR/bin
prepend-path    LIBRARY_PATH      \$APPDIR/lib
prepend-path    LD_LIBRARY_PATH   \$APPDIR/lib
" > $APPVER