#!/bin/bash

# Install script for WRF

# This can't be run as a non-interactive job, as the configuration step requires
#   user input.

## configuration settings
INROOT=/opt/apps/apps

APPVER=4.0.3
COMPILER=gcc


# settings for modules file
MDIR=/opt/apps/modules/apps/${COMPILER}/wrf
MPATH=apps/${COMPILER}/wrf/${APPVER}


## running code

# set the install & executable directory
APPROOT=$INROOT/${COMPILER}/wrf
APPDIR=$APPROOT/$APPVER

# making the install directory (and change accessibility if needed)
#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT

# making the executable code directory, and build directory (no archive for this)
cd $APPROOT
mkdir $APPVER build
cd build

# download the WRF code
module load tools/env/proxy2
git clone https://github.com/UoMResearchIT/WRF.git

# checkout the specific version that we want
cd WRF
git checkout v$APPVER

# load modules needed for compiling the code
# (loading netcdf should load hdf5 and zlib libraries too)
module load libs/${COMPILER}/netcdf/4.6.2
module load mpi/${COMPILER}/openmpi/3.1.4

# environmental settings
export NETCDF=$NETCDFDIR


# configuring the model (options 34, 1) #### THIS MUST BE RUN INTERACTIVELY
./configure

# compile the model (this will take a while)
./compile em_real 2>&1 | tee z_wrf_compile_log.txt

# create operational directories, and copy executables
cd ../../$APPVER
mkdir bin
cp ../build/WRF/main/*.exe bin/
cp -a ../build/WRF/run run_dir
# copy running data, and delete/rename what's not wanted
cd run_dir
rm *.exe
mv namelist.input namelist.input.example



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
set    APPNAME        wrf
set    APPNAMECAPS    WRF
set    APPURL        http://www2.mmm.ucar.edu/wrf/users/
set    APPCSFURL     http://ri.itservices.manchester.ac.uk/csf3/software/applications/\$APPNAME
# Default gcc will be
set    COMPVER        4.8.5
set    COMPNAME     ${COMPILER}
set    COMPDIR        \${COMPNAME}
set    MPIVER         3.1.4

module-whatis    \"Adds \$APPNAME \$APPVER to your environment\"

# load required modules
module load libs/\$COMPNAME/netcdf/4.6.2
module load mpi/\$COMPNAME/openmpi/3.1.4

set     APPDIR    $INROOT/\$COMPNAME/\$APPNAME/\$APPVER

setenv        \${APPNAMECAPS}DIR      \$APPDIR
setenv        \${APPNAMECAPS}_HOME    \$APPDIR
setenv        \${APPNAMECAPS}BIN      \$APPDIR/bin
setenv        \${APPNAMECAPS}_RUNDIR  \$APPDIR/run_dir

# Typical env vars needed to run an app
prepend-path    PATH              \$APPDIR/bin
" > $APPVER