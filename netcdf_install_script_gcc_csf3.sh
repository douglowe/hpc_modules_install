cat /etc/redhat-release

# Location of final root directory
APPROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/gcc/netcdf

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


module load use.own
module load priv_libs/gcc/zlib/1.2.11
module load priv_libs/gcc/hdf5/1.10.4

export LDFLAGS=-L$HDF5LIB
export CPPFLAGS=-I$HDF5INCLUDE

./configure --prefix=$APPDIR --enable-remote-fortran-bootstrap --enable-large-file-tests 2>&1 | tee ../config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log


#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPROOT

# module file location
MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/gcc/netcdf


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

MPATH=priv_libs/gcc/netcdf/${APPVER}


# module script
echo "#%Module1.0#####################################################################
##
## Alces Clusterware - Library module file
## Copyright (c) 2008-2015 Alces Software Ltd
##
## path: ${MPATH}
################################################################################
if { [info exists ::env(ALCES_TRACE)] } {
    puts stderr \" -> $::ModulesCurrentModulefile\"
}

if { [namespace exists alces] == 0 } {
    if { [info exists ::env(MODULES_ALCES_TCL)] } { 
    source \$::env(MODULES_ALCES_TCL)
    } else {
    # compatibility mode for module use without availability of Alces tools
    proc ::process {body} { eval \$body }
    proc ::depend {module {version \"\"} {_ \"\"}} { 
        set req [regsub {\-} $module {/}]/\$version
        if { [catch { prereq \$req }] } {
        puts stderr \"Could not satisfy prereq: \$req\"
        break
        }
    }
    proc ::alces {_ module} { return \$module }
    proc ::search {_ _ _} { }
    }
}

proc ModulesHelp { } {
    global app
    global appdir
    global appcaps
    global version
    puts stderr \"
                      ======== netcdf ========                      
                               NetCDF                               
                       =======================                       

This module sets up your environment for the use of the 'netcdf'
library. This module sets up version '4.3.0' of the
library.


>> SYNOPSIS <<

NetCDF (network Common Data Form) is a set of interfaces for
array-oriented data access and a freely-distributed collection of
data access libraries for C, Fortran, C++, Java, and other
languages. The netCDF libraries support a machine-independent format
for representing scientific data. Together, the interfaces,
libraries, and format support the creation, access, and sharing of
scientific data.

NetCDF data is:

  * Self-Describing - a netCDF file includes information about the
    data it contains
  * Portable - a netCDF file can be accessed by computers with
    different ways of storing integers, characters, and
    floating-point numbers
  * Scalable - a small subset of a large dataset may be accessed
    efficiently
  * Appendable - data may be appended to a properly structured
    netCDF file without copying the dataset or redefining its
    structure
  * Sharable - one writer and multiple readers may simultaneously
    access the same netCDF file
  * Archivable - access to all earlier forms of netCDF data will be
    supported by current and future versions of the software


>> LICENSING <<

This package is made available subject to the following license(s):

\tSet of interfaces and libraries for array-oriented data access

Please refer to the website for further details regarding licensing.


>> FURTHER INFORMATION <<

More information about this software can be found at the website:

\thttp://www.unidata.ucar.edu/software/netcdf/

For further details regarding this module, including the environment
modifications it will apply, execute:

\tmodule show ${MPATH}


>> GET STARTED <<

Please refer to the website for further details on usage of this
package.
\"
}

set     app      netcdf
set     version  ${APPVER}
set     appcaps  NETCDF
set     appdir   ${APPDIR}

#if { [ namespace exists alces ] } { set dependencies \"     Dependencies: [alces pretty libs/gcc/system] (using: [alces pretty [search libs-gcc 4.8.5 0f6c756b]])
#                   [alces pretty apps/hdf5_serial/1.8.9/gcc-4.8.5] (using: [alces pretty [search apps-hdf5_serial 1.8.9 a42b5d44]])\" } { set dependencies \"\" }
module-whatis   \"

            Title: netcdf
          Summary: NetCDF
          License: Set of interfaces and libraries for array-oriented data access
            Group: Libraries
              URL: http://www.unidata.ucar.edu/software/netcdf/

             Name: netcdf
          Version: ${APPVER}
           Module: [alces pretty ${MPATH}]
      Module path: ${MDIR}/${APPVER}
     Package path: ${APPDIR}

       Repository: 
          Package: 
      Last update: 2019-01-23

          Builder: Doug Lowe
       Build date: 2019-01-23
    Build modules: 
         Compiler: [alces pretty compilers/gcc/system]
           System: Linux 3.10.0-327.4.5.el7.x86_64 x86_64
             Arch: Intel(R) Xeon(R) CPU E5-2640 v3 @ 2.60GHz, 2x8 (319a959a)
\\\$dependencies

For further information, execute:

    module help ${MPATH}
\"

#process {
#depend libs-gcc 4.8.5 0f6c756b
#depend apps-hdf5_serial 1.8.9 a42b5d44
#
#conflict libs/netcdf
#}

setenv \${appcaps}DIR \${appdir}
setenv \${appcaps}BIN \${appdir}/bin
setenv \${appcaps}LIB \${appdir}/lib
setenv \${appcaps}INCLUDE \${appdir}/include

prepend-path LD_LIBRARY_PATH \${appdir}/lib
prepend-path PATH \${appdir}/bin
prepend-path PKG_CONFIG_PATH \${appdir}/lib/pkgconfig
prepend-path MANPATH \${appdir}/share/man
" > $APPVER
