# Location of final root directory
#INROOT=/opt/apps/libs
INROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs
APPROOT=$INROOT/pgi/fftw


APPVER=3.3.8
APPDIR=$APPROOT/$APPVER

#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT
chown ${USER}. $APPROOT


cd $APPROOT
mkdir $APPVER archive build
cd archive

module load tools/env/proxy2

wget http://www.fftw.org/fftw-${APPVER}.tar.gz


cd ../build
tar xzf ../archive/fftw-${APPVER}.tar.gz


cd fftw-${APPVER}


module load compilers/pgi/16.5


#
#  Configure and compile on the interactive job nodes! (qrsh -l short)
#
#  The login nodes are haswell, while the short job nodes are sandybridge.
#  Currently configure finds out the architecture to compile for automatically (change this later)
#  Code compiled for sandybridge will work on haswell, but not the other way round.
#



# trying just with openmp and threads: enable-mpi can't find the libraries (but might not be needed?)

./configure --prefix=$APPDIR --enable-float --enable-sse --enable-openmp --enable-threads 2>&1 | tee ../config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log





#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPDIR

# module file location
MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/pgi/fftw
#MDIR=/opt/apps/modules/libs/gcc/jasper


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

MPATH=libs/pgi/fftw/${APPVER}


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
set    APPNAME        fftw
set    APPNAMECAPS    FFTW
set    APPURL        http://www.fftw.org/
set    APPCSFURL    http://ri.itservices.manchester.ac.uk/csf3/software/libraries/$APPNAME
# Default gcc will be
set    COMPVER        16.5
set    COMPNAME    pgi
set    COMPDIR        \${COMPNAME}

module-whatis    \"Adds \$APPNAME \$APPVER to your environment\"

module load     compilers/\${COMPNAME}/\${COMPVER}

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


