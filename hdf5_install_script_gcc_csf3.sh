cat /etc/redhat-release

# Location of final root directory
APPROOT=/mnt/iusers01/support/mbessdl2/privatemodules_packages/csf3/libs/gcc/hdf5

APPBASE=1.10
APPVER=$APPBASE.4
APPDIR=$APPROOT/$APPVER

#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT


cd $APPROOT
mkdir $APPVER archive build
cd archive

module load tools/env/proxy2

wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${APPBASE}/hdf5-${APPVER}/src/hdf5-${APPVER}.tar.gz

cd ../build
tar xzf ../archive/hdf5-${APPVER}.tar.gz

cd hdf5-${APPVER}


module load use.own
module load priv_libs/gcc/zlib/1.2.11

./configure --prefix=$APPDIR --enable-fortran --enable-cxx --with-zlib=$ZLIBHOME/include,$ZLIBHOME/lib 2>&1 | tee ../config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log


#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPROOT

# module file location
MDIR=/mnt/iusers01/support/mbessdl2/privatemodules/priv_libs/gcc/hdf5


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

MPATH=priv_libs/gcc/hdf5/${APPVER}


#### module script
# It is a bit of a faff writing a bash script from a bash script - you need to ensure
# any special characters you don't want to be executed are escaped out (using \).
echo "#%Module1.0#####################################################################
##
## Alces Clusterware - Application module file
## Copyright (c) 2008-2015 Alces Software Ltd
##
## path: ${MPATH}
################################################################################
if { [info exists ::env(ALCES_TRACE)] } {
    puts stderr \" -> \$::ModulesCurrentModulefile\"
}

if { [namespace exists alces] == 0 } {
    if { [info exists ::env(MODULES_ALCES_TCL)] } { 
    source \$::env(MODULES_ALCES_TCL)
    } else {
    # compatibility mode for module use without availability of Alces tools
    proc ::process {body} { eval \$body }
    proc ::depend {module {version \"\"} {_ \"\"}} { 
        set req [regsub {\-} \$module {/}]/\$version
        if { [catch { prereq \$req }] } {
        puts stderr \"Could not satisfy prereq: \$req\"
        break
        }
    }
    proc ::alces {_ module} { return \$module }
    proc ::search {_ _ _} { }
        proc ::assert_packages { } { }
    }
}

proc ModulesHelp { } {
    global app
    global appdir
    global appcaps
    global version
    puts stderr \"
                       ======== HDF5 ========                       
        Data model, library, and file format for storing and         
                            managing data                            
                        =====================                        

This module sets up your environment for the use of the 'hdf5_serial'
application. This module sets up version '${APPVER}' of the
application.


>> SYNOPSIS <<

HDF5 is a data model, library, and file format for storing and
managing data. It supports an unlimited variety of datatypes, and is
designed for flexible and efficient I/O and for high volume and
complex data. HDF5 is portable and is extensible, allowing
applications to evolve in their use of HDF5. The HDF5 Technology
suite includes tools and applications for managing, manipulating,
viewing, and analyzing data in the HDF5 format.


>> LICENSING <<

This package is made available subject to the following license(s):

\tBSD-style, see http://www.hdfgroup.org/products/licenses.html

Please refer to the website for further details regarding licensing.


>> FURTHER INFORMATION <<

More information about this software can be found at the website:

\thttp://www.hdfgroup.org/HDF5/

For further details regarding this module, including the environment
modifications it will apply, execute:

\tmodule show ${MPATH}


>> GET STARTED <<

Please refer to the website for further details on usage of this
package.
\"
}

set     app      hdf5
set     version  ${APPVER}
set     appcaps  HDF5
set     appdir   ${APPDIR}

#if { [ namespace exists alces ] } { set dependencies \"     Dependencies: [alces pretty libs/gcc/system] (using: [alces pretty [search libs-gcc 4.8.5 0f6c756b]])\" } { set dependencies \"\" }
module-whatis   \"

            Title: HDF5
          Summary: Data model, library, and file format for storing and managing data
          License: BSD-style, see http://www.hdfgroup.org/products/licenses.html
            Group: Libraries
              URL: http://www.hdfgroup.org/HDF5/

             Name: hdf5
          Version: ${APPVER}
           Module: [alces pretty ${MPATH}]
      Module path: ${MDIR}/${APPVER}
     Package path: ${APPDIR}

       Repository: 
          Package: 
      Last update: 2019-01-22

          Builder: Doug Lowe
       Build date: 2019-01-22
         Compiler: [alces pretty compilers/gcc/system]
           System: Linux 3.10.0-693.17.1.el7.x86_64 x86_64
             Arch: Intel(R) Xeon(R) CPU E5-2650 v2 @ 2.60GHz, 2x8 (2f9d4464)
\\\$dependencies

For further information, execute:

    module help ${MPATH}
\"

#assert_packages

#process {
#depend libs-gcc 4.8.5 0f6c756b
#
#conflict apps/hdf5_serial
#}

setenv \${appcaps}DIR \${appdir}
setenv \${appcaps}BIN \${appdir}/bin
setenv \${appcaps}LIB \${appdir}/lib
setenv \${appcaps}INCLUDE \${appdir}/include

prepend-path PATH \${appdir}/bin
prepend-path LD_LIBRARY_PATH \${appdir}/lib

" > $APPVER
