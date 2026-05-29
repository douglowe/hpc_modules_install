# Location of final root directory
#INROOT=/opt/apps/libs
INROOT=/work/n02/n02/lowe/privatemodules_packages/libs
APPROOT=$INROOT/cray/fftw


APPVER=3.3.8
APPDIR=$APPROOT/$APPVER

#sudo mkdir $APPROOT
#sudo chown ${USER}. $APPROOT
mkdir $APPROOT
#chown ${USER}. $APPROOT


cd $APPROOT
mkdir $APPVER archive build
cd archive

#module load tools/env/proxy2

wget http://www.fftw.org/fftw-${APPVER}.tar.gz


cd ../build
tar xzf ../archive/fftw-${APPVER}.tar.gz


cd fftw-${APPVER}


#module load compilers/pgi/16.5
#module load compilers/intel/18.0.3
module swap cce cce/8.7.7
module swap cray-mpich cray-mpich/7.7.4



# trying just with openmp and threads: enable-mpi can't find the libraries (but might not be needed?)

# compile and install single precision (float) libraries
./configure CC=cc CXX=CC FC=ftn CFLAGS="-O0 -g -D_OPENMP" --prefix=$APPDIR --enable-float --enable-mpi --enable-openmp --enable-threads 2>&1 | tee ../config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log
make clean

# compile and install double precision libraries
./configure CC=cc CXX=CC FC=ftn  CFLAGS="-O0 -g -D_OPENMP" --prefix=$APPDIR --enable-mpi --enable-openmp --enable-threads 2>&1 | tee ../config-$APPVER.log
make 2>&1 | tee make-$APPVER.log
make check 2>&1 | tee make-check-$APPVER.log
make install 2>&1 | tee make-install-$APPVER.log
make clean




#sudo chmod -R og+rX $APPROOT
chmod -R og+rX $APPDIR

# module file location
MDIR=~/privatemodules/libs/cray/fftw
#MDIR=/opt/apps/modules/libs/gcc/jasper


#sudo mkdir $MDIR
#sudo chown ${USER}. $MDIR
mkdir $MDIR

cd $MDIR

MPATH=priv_libs/cray/fftw/${APPVER}


#### module script
# It is a bit of a faff writing a bash script from a bash script - you need to ensure
# any special characters you don't want to be executed are escaped out (using \).
echo "#%Module1.0####################################################
## \$Id\$
## 
##   Module file, based on CRAY template
##

conflict cray-fftw
conflict fftw

set cpu x86_64
if {[info exists env(CRAY_CPU_TARGET)]} {
    set cpu_target $env(CRAY_CPU_TARGET)
    switch \$cpu_target {
        abudhabi -
        interlagos {set cpu interlagos}
        ivybridge {set cpu ivybridge}
        sandybridge {set cpu sandybridge}
        broadwell {set cpu broadwell}
        haswell {set cpu haswell}
        mic-knl {set cpu mic_knl}
        x86-skylake {set cpu x86_skylake}
    }
}

set FFTW_LEVEL      3.3.8
set FFTW_BASE_PATH  /work/n02/n02/lowe/privatemodules_packages/libs/cray/fftw/3.3.8

setenv FFTW_VERSION       \$FFTW_LEVEL
setenv CRAY_FFTW_VERSION  \$FFTW_LEVEL
setenv FFTW_DIR           \$FFTW_BASE_PATH/lib
setenv FFTW_INC           \$FFTW_BASE_PATH/include

prepend-path  PATH                  \$FFTW_BASE_PATH/bin
prepend-path  MANPATH               \$FFTW_BASE_PATH/share/man
prepend-path  CRAY_LD_LIBRARY_PATH  \$FFTW_BASE_PATH/lib


if {[info exists ::env(PKGCONFIG_ENABLED)] && [file exists \$FFTW_BASE_PATH/.set_paths_stub]} {
    source \$FFTW_BASE_PATH/.set_paths_stub
    set_pkgconfig_paths PE_FFTW \$FFTW_BASE_PATH
    set_pkgconfig_libs
} else {
    append-path  PE_PRODUCT_LIST  FFTW
    setenv       CRAY_FFTW_DIR    \$FFTW_BASE_PATH
}


proc ModulesHelp {} {
    set release_info_file \$::FFTW_BASE_PATH/release_info
    if {[file exists \$release_info_file]} {
        set fp [open \$release_info_file]
        set release_notes [read \$fp]
        close \$fp
    } else {
        set release_notes {No help found.}
    }

    puts stderr \"\"
    puts stderr \"===================================================================\"
    puts stderr \"\$release_notes\"
    puts stderr \"===================================================================\"
    puts stderr \"To re-display [module-info name] release information,\"
    puts stderr \"type:    less \$::FFTW_BASE_PATH/release_info\"
    puts stderr \"===================================================================\\n\"
}

module-whatis   \"FFTW $FFTW_LEVEL - Fastest Fourier Transform in the West\"
" > $APPVER









