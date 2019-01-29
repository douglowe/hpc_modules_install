cat /etc/redhat-release

# Location of final root directory
APPROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/python/ecmwfiapi

APPVER=1.5.0
APPDIR=$APPROOT/$APPVER

#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT
chown ${USER}. $APPROOT


cd $APPROOT
mkdir $APPVER archive
cd archive

module load tools/env/proxy2

wget https://software.ecmwf.int/wiki/download/attachments/56664858/ecmwf-api-client-python.tgz

cd ../$APPVER
tar xzf ../archive/ecmwf-api-client-python.tgz




#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPROOT

# module file location
MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/python/ecmwfiapi


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

MPATH=priv_libs/python/ecmwfapi/${APPVER}


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
set    APPNAME        ecmwfapi
set    APPNAMECAPS    ECMWFAPI
set    APPCSFURL      http://ri.itservices.manchester.ac.uk/csf3/software/applications/$APPNAME
set    APPURL         https://confluence.ecmwf.int/display/WEBAPI/Access+ECMWF+Public+Datasets
set    COMPDIR        python

module-whatis    "Adds \$APPNAME \$APPVER to your python environment"

set     APPDIR           /mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/\$COMPDIR/\$APPNAME/\$APPVER

# Typical env vars needed to run an app

prepend-path    PYTHONPATH            $APPDIR
" > $APPVER

