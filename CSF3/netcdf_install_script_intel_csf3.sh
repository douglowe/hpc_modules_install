cat /etc/redhat-release

# Location of final root directory
#INROOT=/opt/apps/libs/
INROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs
APPROOT=$INROOT/intel/netcdf

APPVER=4.6.2
APPDIR=$APPROOT/$APPVER


#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT


cd $APPROOT
mkdir $APPVER archive build
cd archive

module load tools/env/proxy2

wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-c-${APPVER}.tar.gz

cd ../build
tar xzf ../archive/netcdf-c-${APPVER}.tar.gz

cd netcdf-c-${APPVER}


module load compilers/intel/17.0.7
module load use.own
#module load priv_libs/gcc/zlib/1.2.11
module load priv_libs/intel/hdf5/1.8.21
#module load libs/gcc/zlib/1.2.11
#module load libs/intel/hdf5/1.8.21


export LDFLAGS=-L$HDF5LIB
export CPPFLAGS=-I$HDF5INCLUDE

# current state of --enable-remote-fortran-bootstrap is not useable (doesn't seem to carry config settings from main script), 
#    so we will replicate the process manually below. Check at future date to see if it is more useable.
#./configure --prefix=$APPDIR --enable-remote-fortran-bootstrap --enable-large-file-tests 2>&1 | tee ../config-$APPVER.log
./configure --prefix=$APPDIR --enable-large-file-tests 2>&1 | tee ../config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log


# installing fortran libraries
module load services/git

TARGVERSION="v4.4.5"

git clone http://github.com/unidata/netcdf-fortran
cd netcdf-fortran
git checkout $TARGVERSION

# need to add the netcdf lib and include paths too - so make sure to run make install above before doing this!
export CPPFLAGS="-I$HDF5INCLUDE -I$APPDIR/include"
export LDFLAGS="-L$HDF5LIB -L$APPDIR/lib"
# have to set the library pathways as well as using the LDFLAGS, 
#   as the netcdf-fortran compiler is more of a pain than the netcdf-c compiler
# NOTE: intel compiler module populates LD_LIBRARY_PATH with a lot of path information
#      (while it is empty for the standard gnu compiler), so we need to append this 
#      path information, rather than just create this env variable fresh)
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH;$APPDIR/lib;$HDF5LIB"

./configure --prefix=$APPDIR --enable-large-file-tests 2>&1 | tee config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
# There have been a lot of changes to the checks since 4.4.5 was released in January 
#    (only 2 months ago!!!). In 4.4.5 there are a number of issues in make check (not make),
#    which are solved by those changes (some code corrections, some deletions of old tests).
#    Don't run make check at the moment - but do revisit this step when the next release 
#    comes out!!
#make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log





#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPROOT

# module file location
MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/intel/netcdf
#MDIR=/opt/apps/modules/libs/gcc/netcdf


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

#MPATH=libs/intel/netcdf/${APPVER}
MPATH=priv_libs/intel/netcdf/${APPVER}




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
set    COMPVER        17.0.7
set    COMPNAME    intel
set    COMPDIR        \${COMPNAME}

module-whatis    \"Adds \$APPNAME \$APPVER to your environment\"


# Do we want to prohibit use of other modulefiles (similar rules to above)
# conflict libs/SOMELIB/older.version

module load libs/\$COMPNAME/hdf5/1.8.21

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