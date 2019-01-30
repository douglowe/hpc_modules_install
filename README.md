# csf3_mod_install
Module install scripts for CSF3 system. Intended for creating private modules only at the moment.

## WRF

Install these packages in this order:
1) zlib_install_script_gcc_csf3.sh
2) hdf5_install_script_gcc_csf3.sh
3) netcdf_install_script_gcc_csf3.sh

## WPS

Install these packages in this order:
1) zlib, hdf5, netcdf (as for WRF)
2) jasper_install_script_gcc_csf3.sh
3) libpng_install_script_gcc_csf3.sh

## ECMWF Data Access API

Standalone python library:
1) ecmwfiapi_install_script.sh
