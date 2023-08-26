#!/bin/bash --login

# Install script for WRF.

# This is designed for 

# This can't be run as a non-interactive job, as the configuration step requires
#   user input.

## configuration settings
INROOT=/work/n02/n02/lowe/Compiling/

APPVER=3.9.1.1


## running code

# set the install & executable directory
APPROOT=$INROOT/wrf

# making the install directory (and change accessibility if needed)
mkdir $APPROOT

# making the executable code directory, and build directory (no archive for this)
cd $APPROOT
mkdir $APPVER-wrfchem build archive executables running_directories
cd archive

# download the WRF code
git clone https://github.com/wrf-model/WRF.git WRF-repo
cd WRF-repo
git fetch --all --tags
#wget https://github.com/wrf-model/WRF/releases/download/v${APPVER}/v${APPVER}.tar.gz
#wget https://github.com/wrf-model/WRF/archive/refs/tags/v${APPVER}.tar.gz

cd ../../build
cp -a ../archive/WRF-repo WRF-$APPVER
cd WRF-$APPVER
git checkout tags/V3.9.1.1


# load modules needed for compiling the code
module load PrgEnv-gnu
module load cray-hdf5/1.12.2.1
module load cray-netcdf/4.9.0.1
module load cray-mpich/8.1.23

# load the conda environment into which we have installed the flex package
### conda create -n wrf-compile flex
conda activate
conda activate wrf-compile

# environmental settings
export NETCDF=$NETCDF_DIR
export FLEX_LIB_DIR=/work/n02/n02/lowe/miniconda3/envs/wrf-compile/lib
export YACC="yacc -d"

# set the Chem specific flags
export WRF_CHEM=1
export WRF_KPP=1

#### add fixes for gcc compilers > version 10 (pre configure step)
# arch/postamble
sed 's/(FORMAT_FIXED)/& $(FCCOMPAT)/' Makefile > Makefile.tmp 
mv Makefile.tmp Makefile
#### swap out landread.c source code, if required libraries do not exist
if [ ! -f /usr/include/rpc/types.h ] ; then
  cp share/landread.c.dist share/landread.c
fi
#### fix the chemistry profile input code, so that CRIMECH can have an empty array
sed 's/ny1:ny2,lo ) :: stor/ny1:ny2,0:lo ) :: stor/' chem/module_input_chem_data.F > module_input_chem_data.F.tmp
sed '/stor(nx1:nx2,nz1:nz2,ny1:ny2,1:lo)/i\ \ \ \ \ \ stor(nx1:nx2,nz1:nz2,ny1:ny2,0) = 0.0' module_input_chem_data.F.tmp > module_input_chem_data.F.tmp2
rm module_input_chem_data.F.tmp
mv module_input_chem_data.F.tmp2 chem/module_input_chem_data.F

# configuring the model (options 34, 1) #### THIS MUST BE RUN INTERACTIVELY
./configure

#### add fixes for gcc compilers > version 10 (post configure step)
# configure.wps
sed '/^FCSUFFIX/i FCCOMPAT        =      -fallow-argument-mismatch -fallow-invalid-boz' configure.wrf > configure.wrf.tmp
sed 's/(BYTESWAPIO)$/& $(FCCOMPAT)/' configure.wrf.tmp > configure.wrf.tmp2
rm configure.wrf.tmp
mv configure.wrf.tmp2 configure.wrf



# compile the model (this will take a while)
./compile em_real 2>&1 | tee z_wrf_compile_log.txt

# create operational directories, and copy executables
cd $APPDIR
mkdir bin
cp ../build/WRF-Chem/main/*.exe bin/
cp -a ../build/WRF-Chem/run run_dir
# copy running data, and delete/rename what's not wanted
cd run_dir
rm *.exe MPTABLE.TBL
cp ../../build/WRF-Chem/phys/noahmp/parameters/MPTABLE.TBL .
mv namelist.input namelist.input.example




