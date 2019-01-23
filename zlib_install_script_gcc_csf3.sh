cat /etc/redhat-release

# Location of final root directory
APPROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/gcc/zlib

APPVER=1.2.11
APPDIR=$APPROOT/$APPVER

#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT
chown ${USER}. $APPROOT


cd $APPROOT
mkdir $APPVER archive build
cd archive

module load tools/env/proxy2

wget https://www.zlib.net/zlib-${APPVER}.tar.gz

cd ../build
tar xzf ../archive/zlib-${APPVER}.tar.gz

cd zlib-${APPVER}


./configure --prefix=$APPDIR 2>&1 | tee ../config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log


#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPROOT

# module file location
MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/gcc/zlib


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

#### module script
# It is a bit of a faff writing a bash script from a bash script - you need to ensure
# any special characters you don't want to be executed are escaped out (using \).
echo "#%Module1.0####################################################
##  zlib modulefile
##  @dl (Jan 2019)

proc ModulesHelp { } {
        global release cver cname codeName 

    puts stderr \"	Adds the \$codeName \$release settings to your environment.\"
    puts stderr \"\"
    puts stderr \"	The library was compiled with the \$cname v\$cver compiler.\"
    puts stderr \"	This modulefile will also be loaded automatically.\"
    puts stderr \"\"
	
}


proc getenv {key {defaultvalue {}}} {
  global env; expr {[info exist env(\$key)]?\$env(\$key):\$defaultvalue}
}



set codeName    zlib
set release     ${APPVER}
set cname       GCC
set cver        4.8.5
set buildCompilerDir gcc

module-whatis    \"loads \$codeName \$release settings\"
module-verbosity off

# required modules
# module load compilers/intel/c/$cver

# ZLIB
set              ZLIB_DIR         /mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/\$buildCompilerDir/\$codeName/\$release
prepend-path     LD_LIBRARY_PATH  \${ZLIB_DIR}/lib
prepend-path     LIBRARY_PATH     \${ZLIB_DIR}/lib
prepend-path     INCLUDE          \${ZLIB_DIR}/include
prepend-path	 MANPATH	  \${ZLIB_DIR}/share/man

# export ZLIBHOME to user environment
setenv ZLIBHOME  \$ZLIB_DIR
setenv ZLIBDIR   \$ZLIB_DIR
# WRF compilation like this one
setenv ZLIB_PATH \$ZLIB_DIR

" > $APPVER
