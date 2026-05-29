# NOT A MODULE
# Notes for installing CESM2

# https://escomp.github.io/CESM/versions/cesm2.1/html/introduction.html

# Create conda environment for svn
conda create -n svn svn

# Setup working environment
conda activate
conda activate svn


# Run this on an interactive job, to enable internet access
# qrsh -l short -V -cwd bash

git clone -b release-cesm2.1.3 https://github.com/ESCOMP/CESM.git my_cesm_sandbox
cd my_cesm_sandbox

git tag --list 'release-cesm2*'
git checkout release-cesm2.1.3

# make sure to cache your github SSH key before running this step!
# And run this on your local computer, then scp the data to CSF3.
./manage_externals/checkout_externals --verbose



# compiling the model?
module load compilers/gcc/8.2.0
module load libs/gcc/netcdf/4.9.2
module load mpi/gcc/openmpi/4.1.2-gcc-8.2.0

module load libs/lapack/3.5.0/gcc-4.8.5
module load libs/blas/3.6.0/gcc-4.8.5
