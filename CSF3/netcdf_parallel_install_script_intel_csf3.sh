cat /etc/redhat-release

# Location of final root directory
INROOT=/opt/apps/libs/
#INROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs
APPROOT=$INROOT/intel-19.1/netcdf

APPVER=4.9.2
APPDIR=$APPROOT/${APPVER}_mpi

# netcdf-fortran version number is different to netcdf-c version
FORTVER=4.6.1

# parallel netcdf version number is different to netcdf-c and netcdf-fortran versions
PNETVER=1.12.3

#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT


cd $APPROOT
mkdir $APPVER archive build
cd archive
mkdir pnetcdf netcdf-c netcdf-fortran


module load tools/env/proxy2

cd pnetcdf
wget https://parallel-netcdf.github.io/Release/pnetcdf-${PNETVER}.tar.gz
cd ../netcdf-c
wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v${APPVER}.tar.gz
cd ../netcdf-fortran
wget https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${FORTVER}.tar.gz

cd ../../build

module load compilers/intel/19.1.2
module load mpi/intel-19.1/openmpi/4.1.1
module load libs/intel-19.1/zlib/1.2.13
module load libs/intel-19.1/hdf5/1.14.1_mpi

export CC=mpicc
export FC=mpifort
export F77=mpif77
export F90=mpif90
export CXX=mpicxx

## installing parallel netcdf

tar xvf ../archive/pnetcdf/pnetcdf-${PNETVER}.tar.gz

cd pnetcdf-${PNETVER}

./configure --prefix=$APPDIR --enable-shared --enable-static | tee ../config-$PNETVER.log
make 2>&1 | tee make-$PNETVER.log
# serial tests
make check 2>&1 | tee make-check-$PNETVER.log
# parallel tests - run on parallel nodes (qrsh -l short -pe smp.pe 12)
qrsh -l short -V -cwd -pe smp.pe 12 make ptests 2>&1 | tee make-ptests-$PNETVER.log
make install 2>&1 | tee make-install-$PNETVER.log

export PNETCDF=$APPDIR


## installing netcdf-c

cd ../

tar xzf ../archive/netcdf-c/v${APPVER}.tar.gz

cd netcdf-c-${APPVER}

export LDFLAGS="-L$MPI_LIB -L$HDF5LIB -L$APPDIR/lib"
export CPPFLAGS="-I$MPI_INCLUDE -I$HDF5INCLUDE -I$APPDIR/include"

# 1) using --disable-nczarr to remove extension mapping to key-value pair cloud storage systems 
#    see https://docs.unidata.ucar.edu/netcdf/NUG/nczarr_head.html for more information
# 2) current state of --enable-remote-fortran-bootstrap is not useable (doesn't seem to carry config settings from main script), 
#    so we will replicate the process manually below. Check at future date to see if it is more useable.
#./configure --prefix=$APPDIR --enable-remote-fortran-bootstrap --enable-large-file-tests 2>&1 | tee ../config-$APPVER.log
./configure --prefix=$APPDIR --disable-nczarr --enable-pnetcdf --enable-parallel-tests --enable-large-file-tests 2>&1 | tee ../config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
qrsh -l short -V -cwd -pe smp.pe 16 make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log


## installing fortran libraries
mkdir netcdf-fortran
cd netcdf-fortran

tar xvf ../../../archive/netcdf-fortran/v${FORTVER}.tar.gz --strip-components=1 

# need to add the netcdf lib and include paths too - so make sure to run make install above before doing this!
export LDFLAGS="-L$MPI_LIB -L$HDF5LIB -L$APPDIR/lib"
export CPPFLAGS="-I$MPI_INCLUDE -I$HDF5INCLUDE -I$APPDIR/include"
# have to set the library pathways as well as using the LDFLAGS, 
#   as the netcdf-fortran compiler is more of a pain than the netcdf-c compiler
# NOTE: intel compiler module populates LD_LIBRARY_PATH with a lot of path information
#      (while it is empty for the standard gnu compiler), so we need to append this 
#      path information, rather than just create this env variable fresh)
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH;$APPDIR/lib;$HDF5LIB;$MPI_INCLUDE"
export HDF5_PLUGIN_PATH="$HDF5LIB"
export LIBS="-lnetcdf -lpnetcdf -lcurl -lhdf5_hl -lhdf5"


# zstandard plugin is failing tests, so disable for the moment
./configure --prefix=$APPDIR --enable-parallel-tests --disable-zstandard-plugin --enable-large-file-tests 2>&1 | tee config-$FORTVER.log
make 2>&1 | tee make-$FORTVER.log
qrsh -l short -V -cwd -pe smp.pe 16 make check 2>&1 | tee make-check-$FORTVER.log
make install 2>&1 | tee make-install-$FORTVER.log





#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPROOT

# module file location
#MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/intel-18.0/netcdf
MDIR=/opt/apps/modules/libs/intel-19.1/netcdf


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

MPATH=libs/intel-19.1/netcdf/${APPVER}
#MPATH=priv_libs/intel-18.0/netcdf/${APPVER}




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
set    APPNAME        netcdf
set    APPNAMECAPS    NETCDF
set    APPURL        http://www.unidata.ucar.edu/software/netcdf/
set    APPCSFURL    http://ri.itservices.manchester.ac.uk/csf3/software/libraries/$APPNAME
# Default gcc will be
set    COMPVER        19.1.2
set    COMPNAME    intel
set    COMPDIR        \${COMPNAME}-19.1

module-whatis    \"Adds \$APPNAME \$APPVER to your environment\"


# Do we want to prohibit use of other modulefiles (similar rules to above)
# conflict libs/SOMELIB/older.version

module load compilers/\${COMPNAME}/\${COMPVER}
module load libs/\$COMPDIR/zlib/1.2.13
module load libs/\$COMPDIR/hdf5/1.14.1

set     APPDIR    $INROOT/\$COMPDIR/\$APPNAME/\$APPVER

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