# Script for installing WRF(Chem) utilities

## configuration settings
INROOT=/work/n02/n02/lowe/Compiling/wrf-utilities/

COMPILER=gcc

mkdir $INROOT
cd $INROOT
mkdir build archive executables data
mkdir -p executables/gcc/bin

# load modules needed for compiling the code
module load PrgEnv-gnu
module load cray-hdf5/1.12.2.1
module load cray-netcdf/4.9.0.1
module load cray-mpich/8.1.23


#### UCAR tools

## Mozart (and other global model) boundary condition preprocessor
cd ${INROOT}/archive
wget https://www.acom.ucar.edu/wrf-chem/mozbc.tar

mkdir ../build/mozbc
cd ../build/mozbc
tar xvf ../../archive/mozbc.tar

## Following Will Hatheway's script for adapting the build scripts for gcc > 10: 
## https://github.com/HathewayWill/WRFCHEM-TOOLS-MOSIT/blob/main/WRFCHEM_TOOLS_MOSIT.sh
sed 's/"${ar_libs} -lnetcdff"/"-lnetcdff ${ar_libs}"/' make_mozbc > make_mozbc.tmp
mv make_mozbc.tmp make_mozbc
sed '8s/FFLAGS = --g/& -fallow-argument-mismatch/' Makefile > Makefile.tmp
sed '10s/FFLAGS = -g/& -fallow-argument-mismatch/' Makefile.tmp > Makefile.tmp2
rm Makefile.tmp
mv Makefile.tmp2 Makefile

# build tool
export FC=gfortran
chmod u+x make_mozbc
./make_mozbc

# move tool to bin directory
cp mozbc ../../executables/gcc/bin/




## MEGAN biogenic emission tool
cd ${INROOT}/archive
wget https://www.acom.ucar.edu/wrf-chem/megan_bio_emiss.tar
wget https://www.acom.ucar.edu/wrf-chem/megan.data.tar.gz

mkdir ../build/megan
cd ../build/megan
tar xvf ../../archive/megan_bio_emiss.tar 


## Following Will Hatheway's script for adapting the build scripts for gcc > 10: 
## https://github.com/HathewayWill/WRFCHEM-TOOLS-MOSIT/blob/main/WRFCHEM_TOOLS_MOSIT.sh
sed 's/"${ar_libs} -lnetcdff"/"-lnetcdff ${ar_libs}"/' make_util > make_util.tmp
mv make_util.tmp make_util
sed '8s/FFLAGS = --g/& -fallow-argument-mismatch/' Makefile > Makefile.tmp
sed '10s/FFLAGS = -g/& -fallow-argument-mismatch/' Makefile.tmp > Makefile.tmp2
rm Makefile.tmp
mv Makefile.tmp2 Makefile

# build tool
export FC=gfortran
chmod u+x make_util
./make_util megan_bio_emiss
./make_util megan_xform
./make_util surfdata_xform

# move tools to bin directory
cp megan_bio_emiss megan_xform surfdata_xform ../../executables/gcc/bin/

# extract input data
mkdir ${INROOT}/data/megan
cd ${INROOT}/data/megan
tar zxvf ${INROOT}/archive/megan.data.tar.gz 


## anthro-emis tool
cd ${INROOT}/archive
wget https://www.acom.ucar.edu/wrf-chem/EPA_ANTHRO_EMIS.tgz

mkdir ../build/anthro-emis
cd ../build/anthro-emis
tar zxvf ../../archive/EPA_ANTHRO_EMIS.tgz --strip-components=1

## Following Will Hatheway's script for adapting the build scripts for gcc > 10: 
## https://github.com/HathewayWill/WRFCHEM-TOOLS-MOSIT/blob/main/WRFCHEM_TOOLS_MOSIT.sh
sed 's/"${ar_libs} -lnetcdff"/"-lnetcdff ${ar_libs}"/' make_anthro > make_anthro.tmp
mv make_anthro.tmp make_anthro
sed '28s/FFLAGS +=/& -fallow-argument-mismatch/' Makefile > Makefile.tmp
mv Makefile.tmp Makefile

# build tool
export FC=gfortran
chmod u+x make_anthro
./make_anthro

# move tools to bin directory
cp anthro_emis ../../executables/gcc/bin/







