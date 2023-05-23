# script for installing miniconda on ARCHER (using private modules, possibly these wont
#   work on the compute nodes if )

# Location of final root directory
APPROOT=/work/n02/n02/lowe/privatemodules_packages/conda


cd $APPROOT
mkdir archive
cd archive

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh


# check the app version in the install script downloaded above, and change APPVER as needed
# NOTE: conda can update app version - so perhaps we should not specify an app version
#       in the install path?
APPVER=4.5.12
APPDIR=$APPROOT/$APPVER

mkdir $APPDIR

# -b is batch
# -f is no error if PREFIX exists already
# -p $APPDIR is use this as the prefix for installation
bash ../archive/Miniconda3-latest-Linux-x86_64.sh -b -f -p $APPDIR




# module file location
MDIR=/home/n02/n02/lowe/privatemodules/conda


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

MPATH=priv_libs/conda/${APPVER}


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
set    APPNAME        conda
set    APPNAMECAPS    CONDA

module-whatis    \"Adds \$APPNAME \$APPVER to your environment\"

set     APPDIR           /work/n02/n02/lowe/privatemodules_packages/\$APPNAME/\$APPVER

# Typical env vars needed to run an app

setenv  PYTHONPATH       \$APPDIR

prepend-path    PATH            \$APPDIR/bin

" > $APPVER



####### installing conda packages once above has been carried out
module load use.own
module load conda

conda install xarray



