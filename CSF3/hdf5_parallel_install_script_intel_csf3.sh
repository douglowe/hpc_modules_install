cat /etc/redhat-release

# Location of final root directory
INROOT=/opt/apps/libs/
#INROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs
APPROOT=$INROOT/intel-19.1/hdf5

#APPBASE=1.8
#APPVER=$APPBASE.21
APPBASE=1.14
APPVER=$APPBASE.1
APPDIR=$APPROOT/${APPVER}_mpi

#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT


cd $APPROOT
mkdir $APPVER archive build
cd archive

### not doing the above tasks, as we are sharing space with another admin - so
### look in archive/mbessdl2 and build/mbessdl2 instead

module load tools/env/proxy2

wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${APPBASE}/hdf5-${APPVER}/src/hdf5-${APPVER}-2.tar.gz

cd ../build
tar xzf ../archive/hdf5-${APPVER}-2.tar.gz

cd hdf5-${APPVER}-2


#module load use.own
module load compilers/intel/19.1.2
module load mpi/intel-19.1/openmpi/4.1.1
#module load priv_libs/intel-18.0/zlib/1.2.13
module load libs/intel-19.1/zlib/1.2.13

export CC=mpicc
export FC=mpifort
export F77=mpif77
export F90=mpif90
export CXX=mpicxx

./configure --prefix=$APPDIR --enable-parallel --enable-fortran --with-zlib=$ZLIB_HOME/include,$ZLIB_HOME/lib 2>&1 | tee ../config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
# need to run tests on parallel node
qrsh -l short -V -cwd -pe smp.pe 12 make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log


#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPDIR

# module file location
#MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/gcc/hdf5
MROOT=/opt/apps/modules/libs
#MROOT=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs
MDIR=$MROOT/intel-19.1/hdf5


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

#MPATH=priv_libs/intel-18.0/hdf5/${APPVER}
MPATH=libs/intel-19.1/hdf5/${APPVER}_mpi










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
set    COMPVER        19.1.2
set    COMPNAME    intel
set    COMPDIR        \${COMPNAME}-19.1

module-whatis    \"Adds \$APPNAME \$APPVER to your environment\"

conflict libs/\$COMPDIR/hdf5

module load compilers/\${COMPNAME}/\${COMPVER}
module load mpi/\${COMPDIR}/openmpi/4.1.1
module load libs/\${COMPDIR}/zlib/1.2.13

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
" > ${APPVER}_mpi
