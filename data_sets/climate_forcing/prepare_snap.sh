#!/bin/bash

x_min=-420000
y_min=150000
x_max=1660000
y_max=1660000

options='-overwrite -r average -co FORMAT=NC4 -co COMPRESS=DEFLATE -co ZLEVEL=1'
grid=2000

file=pr_decadal_summaries_AK_CAN_2km_CRU_TS31_historical.zip
wget -nc http://data.snap.uaf.edu/data/Base/AK_CAN_2km/historical/CRU_TS/Historical_Monthly_and_Derived_Precipitation_Products_2km_CRU_TS/$file
unzip -f $file

file=tas_decadal_summaries_AK_CAN_2km_CRU_TS31_historical.zip
wget -nc http://data.snap.uaf.edu/data/Base/AK_CAN_2km/historical/CRU_TS/Historical_Monthly_and_Derived_Temperature_Products_2km_CRU_TS/$file
unzip -f  $file

# file=iem_prism_dem_1km.tif
# wget -nc http://data.snap.uaf.edu/data/IEM/Inputs/ancillary/elevation/$file
# unzip -f  $file

start_decade=1910
end_decade=2000
while [ $start_decade -le $end_decade ]; do
    a=$start_decade
    e=$(($a+9))

    gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid decadal_mean/pr_decadal_mean_annual_total_mm_cru_TS31_historical_${a}_${e}.tif decadal_mean/pr_decadal_mean_annual_total_mm_cru_TS31_historical_${a}_${e}.nc
    gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid decadal_mean/tas_decadal_mean_annual_mean_c_cru_TS31_historical_${a}_${e}.tif  decadal_mean/tas_decadal_mean_annual_mean_c_cru_TS31_historical_${a}_${e}.nc
    cdo settaxis,${a}-1-1 -setreftime,1910-1-1 decadal_mean/pr_decadal_mean_annual_total_mm_cru_TS31_historical_${a}_${e}.nc pr_decadal_mean_annual_total_mm_cru_TS31_historical_${a}_${e}.nc
    cdo settaxis,${a}-1-1 -setreftime,1910-1-1 decadal_mean/tas_decadal_mean_annual_mean_c_cru_TS31_historical_${a}_${e}.nc tas_decadal_mean_annual_mean_c_cru_TS31_historical_${a}_${e}.nc
    start_decade=$(($start_decade+10))
done

gdalwarp $options -te $x_min $y_min $x_max $y_max -tr $grid $grid AKCanada_2km_DEM_mosaic.tif AKCanada_2km_DEM_mosaic.nc

cdo setattribute,precipitation@units="kg m-2 year-1" -chname,Band1,precipitation -timmean -mergetime pr_decadal_mean_annual_total_mm_cru_TS31_historical_*.nc  pr_mean_annual_total_mm_cru_TS31_historical_1910_2009.nc
cdo setattribute,air_temp@units="deg_C" -chname,Band1,air_temp -timmean -mergetime tas_decadal_mean_annual_mean_c_cru_TS31_historical_*.nc  tas_mean_annual_mean_c_cru_TS31_historical_1910_2009.nc
cdo setattribute,usurf@units="m",usurf@standard_name="surface_elevation" -chname,Band1,usurf  AKCanada_2km_DEM_mosaic.nc usurf_akcanada_2km_dem.nc
cdo -O setmisstoc,0 -merge pr_mean_annual_total_mm_cru_TS31_historical_1910_2009.nc tas_mean_annual_mean_c_cru_TS31_historical_1910_2009.nc  usurf_akcanada_2km_dem.nc climate_cru_TS31_historical_1910_2009.nc


