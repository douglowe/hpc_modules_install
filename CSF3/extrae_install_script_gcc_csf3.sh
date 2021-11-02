cat /etc/redhat-release

# Location of final root directory
APPROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/gcc/extrae

APPVER=3.8.3
APPDIR=$APPROOT/$APPVER
APPSTR="$(echo $APPVER | sed 's/\./\_/g')"

#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT
chown ${USER}. $APPROOT


cd $APPROOT
mkdir $APPVER archive build
cd archive

module load tools/env/proxy2
module load mpi/gcc/openmpi/4.1.0
#module load mpi/gcc/openmpi/4.0.1-ucx-1.6.0-C7.9--gcc-4.8.5


wget https://ftp.tools.bsc.es/extrae/extrae-${APPVER}-src.tar.bz2

cd ../build
tar xf ../archive/extrae-${APPVER}-src.tar.bz2

cd extrae-${APPVER}


ENV_FLAGS="--with-mpi=$OPENMPI_DIR --with-unwind=/usr --with-papi=/usr --with-dwarf=/usr --with-elf=/usr --with-boost=/usr"
DYN_FLAGS="--with-dyninst=/usr --with-dyninst-libs=/usr/lib64/dyninst --with-dyninst-headers=/usr/include/dyninst"
export CFLAGS="-std=gnu99"

./configure --prefix=$APPDIR 2>&1 $ENV_FLAGS $DYN_FLAGS | tee ../config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log



#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPROOT

# module file location
MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/gcc/expat


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

MPATH=priv_libs/gcc/expat/${APPVER}


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
set    APPNAME        expat
set    APPNAMECAPS    EXPAT
set    APPURL        https://github.com/libexpat/libexpat
set    APPCSFURL    http://ri.itservices.manchester.ac.uk/csf3/software/libraries/$APPNAME
# Default gcc will be
set    COMPVER        4.8.5
set    COMPNAME    gcc
set    COMPDIR        \${COMPNAME}

module-whatis    \"Adds \$APPNAME \$APPVER to your environment\"

# Do we want to ensure the user (or another modulefile) has loaded the compiler?
# Can be a dirname (any modulefile from that dir) or a specific version.
# Multiple names on one line mean this OR that OR theothere
# Multiple prereq lines mean prereq this AND prepreq that AND prereq theother
#prereq  priv_libs/\$COMPNAME/zlib/1.2.11

# Do we want to prohibit use of other modulefiles (similar rules to above)
# conflict libs/SOMELIB/older.version

# Do we want to load dependency modulefiles on behalf of the user?
# You MIGHT HAVE TO REMOVE THE prereq MODULEFILES FROM ABOVE
# module load libs/otherlib/7.8.9
# module load ......
#module load priv_libs/\$COMPNAME/zlib/1.2.11

set     APPDIR    /mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/\$COMPNAME/\$APPNAME/\$APPVER

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


