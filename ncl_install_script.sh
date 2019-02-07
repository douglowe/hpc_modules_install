# Information on downloading NCL binaries available here: https://www.ncl.ucar.edu/Download/install_from_binary.shtml

# Location of final root directory
APPROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/gcc/ncl

APPVER=6.5.0
APPDIR=$APPROOT/$APPVER

#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT
chown ${USER}. $APPROOT


cd $APPROOT
mkdir $APPVER archive
cd archive

module load tools/env/proxy2

wget https://www.earthsystemgrid.org/dataset/ncl.650.nodap/file/ncl_ncarg-6.5.0-CentOS7.5_64bit_nodap_gnu485.tar.gz
#wget https://www.earthsystemgrid.org/dataset/ncl.650.nodap/file/ncl_ncarg-6.5.0-CentOS7.4_64bit_nodap_gnu730.tar.gz


cd ../$APPVER
#tar xzf ../archive/ncl_ncarg-6.5.0-CentOS7.4_64bit_nodap_gnu730.tar.gz
tar xzf ../archive/ncl_ncarg-6.5.0-CentOS7.5_64bit_nodap_gnu485.tar.gz




#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPROOT

# module file location
MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/gcc/ncl


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

MPATH=priv_libs/gcc/ncl/${APPVER}


#### module script
# It is a bit of a faff writing a bash script from a bash script - you need to ensure
# any special characters you don't want to be executed are escaped out (using \).
echo "#%Module1.0####################################################
##
## binapp (template) Modulefile
##
##
proc getenv {key {defaultvalue {}}} {
  global env; expr {[info exist env(\$key)]?\$env(\$key):\$defaultvalue}
}

proc ModulesHelp { } {
    global APPVER APPNAME APPCSFURL APPURL 

    puts stderr \"
    Adds \$APPNAME \$APPVER to your PATH environment variable and any necessary
    dependent modulefiles.

    For information on how to run \$APPNAME on the CSF please see:
    \$APPCSFURL
    
    For application specific info see:
    \$APPURL
\"
}

set    APPVER         ${APPVER}
set    APPNAME        ncl
set    APPNAMECAPS    NCL
set    APPCSFURL      http://ri.itservices.manchester.ac.uk/csf3/software/applications/$APPNAME
set    APPURL         https://www.ncl.ucar.edu
set    COMPDIR        gcc

module-whatis    "Adds \$APPNAME \$APPVER to your environment"

set     APPDIR           /mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/\$COMPDIR/\$APPNAME/\$APPVER

# Typical env vars needed to run an app

setenv  NCARG_ROOT       \$APPDIR

prepend-path    PATH            \$APPDIR/bin

" > $APPVER

