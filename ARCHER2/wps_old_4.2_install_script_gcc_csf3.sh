#!/bin/bash

# Install script for WPS

# This can't be run as a non-interactive job, as the configuration step requires
#   user input.

## configuration settings
INROOT=/work/n02/n02/lowe/Compiling/

APPVER=4.2
WRFVER=4.2.2
COMPILER=gcc


# WRF directory, for use in compilation
WRFDIR=${INROOT}wrf/build/WRF-${WRFVER}

## running code

# set the install & executable directory
APPROOT=$INROOT/wps

# making the install directory (and change accessibility if needed)
mkdir $APPROOT

# making the executable code directory, and build directory (no archive for this)
cd $APPROOT
mkdir build archive executables running_directories
cd archive

# download the WPS 
wget https://github.com/wrf-model/WPS/archive/refs/tags/v${APPVER}.tar.gz


cd ../build

tar zxf ../archive/v${APPVER}.tar.gz

# create link to WRF compilation directory
rm WRF
ln -s $WRFDIR WRF

# go to build directory
cd WPS-${APPVER}

# load modules needed for compiling the code
# load modules needed for compiling the code
module load PrgEnv-gnu
module load cray-hdf5/1.12.2.1
module load cray-netcdf/4.9.0.1
module load cray-mpich/8.1.23

# use conda for installation of libpng and jasper
# conda create -n wps-libraries jasper=2.0.33 libpng
conda activate
conda activate wps-libraries


# environmental settings
export NETCDF=$NETCDF_DIR
export JASPERINC=/work/n02/n02/lowe/miniconda3/envs/wps-libraries/include/
export JASPERLIB=/work/n02/n02/lowe/miniconda3/envs/wps-libraries/lib/
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
# NOTE - MPI_LIB is misused by compiler, so needs emptying before compilation
#export MPI_LIB=

#### add fixes for gcc compilers > version 10 (pre configure step)
# arch/postamble
sed 's/(F77FLAGS)/& $(FCCOMPAT)/' arch/postamble > arch/postamble.tmp 
sed 's/(FFLAGS)/& $(FCCOMPAT)/' arch/postamble.tmp > arch/postamble.tmp2 
rm arch/postamble.tmp
mv arch/postamble.tmp2 arch/postamble
# ungrib/src/Makefile
sed 's/(FCSUFFIX)/& $(FCCOMPAT)/' ungrib/src/Makefile > ungrib/src/Makefile.tmp 
sed 's/(FFLAGS)/& $(FCCOMPAT)/' ungrib/src/Makefile.tmp > ungrib/src/Makefile.tmp2 
rm ungrib/src/Makefile.tmp
mv ungrib/src/Makefile.tmp2 ungrib/src/Makefile
# ungrib/src/ngl/g2/Makefile
sed 's/(F77FLAGS)/& $(FCCOMPAT)/' ungrib/src/ngl/g2/Makefile > ungrib/src/ngl/g2/Makefile.tmp 
mv ungrib/src/ngl/g2/Makefile.tmp ungrib/src/ngl/g2/Makefile
# ungrib/src/ngl/w3/Makefile
sed 's/(F77FLAGS)/& $(FCCOMPAT)/' ungrib/src/ngl/w3/Makefile > ungrib/src/ngl/w3/Makefile.tmp 
mv ungrib/src/ngl/w3/Makefile.tmp ungrib/src/ngl/w3/Makefile


# configuring the model (option 3) #### THIS MUST BE RUN INTERACTIVELY
./configure

#### add fixes for gcc compilers > version 10 (post configure step)
# configure.wps
sed '/FCSUFFIX/i FCCOMPAT            = -fallow-argument-mismatch' configure.wps > configure.wps.tmp
mv configure.wps.tmp configure.wps


# compile the model (this will take a while)
./compile 2>&1 | tee z_wps_compile_log.txt


# create operational directories, and copy executables (including utilities)
cd $APPROOT/executables
mkdir -p gcc/${APPVER}

cp ../build/WPS-${APPVER}/*.exe ../build/WPS-${APPVER}/*.csh gcc/${APPVER}
cp ../build/WPS-${APPVER}/util/*exe gcc/${APPVER}

# create running directory template directory, and copy necessary setting files
cd $APPROOT/running_directories
mkdir -p gcc/${APPVER}/geogrid gcc/${APPVER}/ungrib gcc/${APPVER}/metgrid
cp -a ../build/WPS-${APPVER}/geogrid/GEOGRID.TBL* gcc/${APPVER}/geogrid/
cp -a ../build/WPS-${APPVER}/ungrib/Variable_Tables gcc/${APPVER}/ungrib/
cp -a ../build/WPS-${APPVER}/metgrid/METGRID.TBL* gcc/${APPVER}/metgrid/






