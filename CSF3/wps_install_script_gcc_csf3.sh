#!/bin/bash

# Install script for WPS

# This can't be run as a non-interactive job, as the configuration step requires
#   user input.

## configuration settings
#INROOT=/opt/apps/apps
INROOT=/opt/apps/el9-fix/apps

APPVER=4.5
COMPILER=gcc

# settings for modules file
#MDIR=/opt/apps/modules/apps/gcc/wps
MDIR=/opt/apps/el9-fix/modules/apps/gcc/wps
MPATH=apps/gcc/wps/${APPVER}

# WRF directory, for use in compilation
WRFDIR=$INROOT/gcc/wrf/build/WRF

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

# create link to WRF compilation directory
ln -s $WRFDIR WRF

# go to build directory
cd WPS-${APPVER}

# load modules needed for compiling the code
# (loading netcdf should load hdf5 and zlib libraries too)
module load compilers/gcc/8.2.0
module load libs/${COMPILER}/jasper/2.0.33
module load libs/${COMPILER}/libpng/1.6.39
module load libs/${COMPILER}/netcdf/4.9.2
#module load mpi/${COMPILER}/openmpi/4.1.2-gcc-8.2.0
module load mpi/${COMPILER}/openmpi/4.1.8-gcc-8.2.0



# environmental settings
export NETCDF=$NETCDFDIR
export USENETCDFPAR=0
export JASPERINC=$JASPERINCLUDE
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
# NOTE - MPI_LIB is misused by compiler, so needs emptying before compilation
export MPI_LIB=



# configuring the model (option 3) #### THIS MUST BE RUN INTERACTIVELY
./configure

# compile the model (this will take a while)
./compile 2>&1 | tee z_wps_compile_log.txt

# create operational directories, and copy executables (including utilities)
cd ../../$APPVER
mkdir bin
cp ../build/WPS-${APPVER}/*.exe ../build/WPS-${APPVER}/*.csh bin/
cp ../build/WPS-${APPVER}/util/*exe bin/

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
" > $APPVER