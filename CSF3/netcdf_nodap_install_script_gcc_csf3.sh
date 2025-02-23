cat /etc/redhat-release

# Location of final root directory
INROOT=/opt/apps/libs
#APPROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/gcc/netcdf
APPROOT=$INROOT/gcc/netcdf

APPVER=4.9.2
APPDIR=$APPROOT/${APPVER}_nodap
APPMOD=${APPVER}_nodap

# netcdf-fortran version number is different to netcdf-c version
FORTVER=4.6.1

#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT


cd $APPROOT
mkdir $APPVER archive build
cd archive
mkdir netcdf-c netcdf-fortran

module load tools/env/proxy2

cd netcdf-c
wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v${APPVER}.tar.gz
cd ../netcdf-fortran
wget https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${FORTVER}.tar.gz

cd ../../build
tar xzf ../archive/netcdf-c/v${APPVER}.tar.gz -C netcdf-c-${APPVER}-nodap --strip-components=1

cd netcdf-c-${APPVER}-nodap


#module load use.own
#module load libs/gcc/zlib/1.2.11
#module load libs/gcc/hdf5/1.8.21

module load compilers/gcc/8.2.0
module load libs/gcc/zlib/1.2.13
module load libs/gcc/hdf5/1.14.1
#module load libs/gcc/hdf5/1.8.23


export LDFLAGS=-L$HDF5LIB
export CPPFLAGS=-I$HDF5INCLUDE

# 1) using --disable-nczarr to remove extension mapping to key-value pair cloud storage systems 
#    see https://docs.unidata.ucar.edu/netcdf/NUG/nczarr_head.html for more information
# 2) current state of --enable-remote-fortran-bootstrap is not useable (doesn't seem to carry config settings from main script), 
#    so we will replicate the process manually below. Check at future date to see if it is more useable.
#./configure --prefix=$APPDIR --enable-remote-fortran-bootstrap --enable-large-file-tests 2>&1 | tee ../config-$APPVER.log
./configure --prefix=$APPDIR --disable-nczarr --disable-dap --enable-large-file-tests 2>&1 | tee ../config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log


# installing fortran libraries

mkdir netcdf-fortran
cd netcdf-fortran

tar xvf ../../../archive/netcdf-fortran/v${FORTVER}.tar.gz --strip-components=1 


# need to add the netcdf lib and include paths too - so make sure to run make install above before doing this!
export CPPFLAGS="-I$HDF5INCLUDE -I$APPDIR/include"
export LDFLAGS="-L$HDF5LIB -L$APPDIR/lib"
# have to set the library pathways as well as using the LDFLAGS, 
#   as the netcdf-fortran compiler is more of a pain than the netcdf-c compiler
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH;$APPDIR/lib;$HDF5LIB"
export HDF5_PLUGIN_PATH="$HDF5LIB"

./configure --prefix=$APPDIR --disable-zstandard-plugin --enable-large-file-tests 2>&1 | tee config-$APPVER.log
#./configure --prefix=$APPDIR --disable-zstandard-plugin --enable-large-file-tests 2>&1 | tee config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log



#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPROOT

# module file location
#MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/gcc/netcdf
MDIR=/opt/apps/modules/libs/gcc/netcdf


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

MPATH=libs/gcc/netcdf/${APPVER}




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

set    APPVER         ${APPVER}_nodap
set    APPNAME        netcdf
set    APPNAMECAPS    NETCDF
set    APPURL        http://www.unidata.ucar.edu/software/netcdf/
set    APPCSFURL    http://ri.itservices.manchester.ac.uk/csf3/software/libraries/$APPNAME
# Default gcc will be
set    COMPVER        8.2.0
set    COMPNAME    gcc
set    COMPDIR        \${COMPNAME}

module-whatis    \"Adds \$APPNAME \$APPVER to your environment\"


# Do we want to prohibit use of other modulefiles (similar rules to above)
# conflict libs/SOMELIB/older.version

module load compilers/\$COMPNAME/8.2.0
module load libs/\$COMPNAME/zlib/1.2.13
module load libs/\$COMPNAME/hdf5/1.14.1

set     APPDIR    $INROOT/\$COMPNAME/\$APPNAME/\$APPVER

setenv        \${APPNAMECAPS}DIR      \$APPDIR
setenv        \${APPNAMECAPS}_HOME    \$APPDIR
setenv        \${APPNAMECAPS}BIN      \$APPDIR/bin
setenv        \${APPNAMECAPS}LIB      \$APPDIR/lib
setenv        \${APPNAMECAPS}INCLUDE  \$APPDIR/include
setenv        \${APPNAMECAPS}_LIBRARIES      \$APPDIR/lib
setenv        \${APPNAMECAPS}_INCLUDE_DIRS  \$APPDIR/include

# Typical env vars to help a compiler find this library and header files
# and to also allow the library to be found when your compiled code is run.
prepend-path    C_INCLUDE_PATH    \$APPDIR/include
prepend-path    CPATH             \$APPDIR/include
prepend-path    LIBRARY_PATH      \$APPDIR/lib
prepend-path    LD_LIBRARY_PATH   \$APPDIR/lib
prepend-path    PATH              \$APPDIR/bin
prepend-path    MANPATH           \$APPDIR/share/man
# Add any other vars your need...
" > $APPMOD