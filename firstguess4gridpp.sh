#!/bin/bash
#SBATCH --qos=nf
#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=1
##SBATCH --mem=24GB
#SBATCH --job-name=firstguess4gridpp

script_dir=/ec/res4/hpcperm/sbjb/github/carra2_t2m_fix
source "/ec/res4/hpcperm/sbjb/github/carra2_t2m_fix/env.sh" firstguess

start_dtg="${1:-2026022712}"
end_dtg="${2:-$start_dtg}"
step_hours="${3:-6}"

if [[ ! "$start_dtg" =~ ^[0-9]{10}$ || ! "$end_dtg" =~ ^[0-9]{10}$ ]]; then
    echo "Usage: $0 START_DTG [END_DTG] [STEP_HOURS]" >&2
    echo "Example: $0 2026022712 2026022818 6" >&2
    exit 1
fi

if [[ ! "$step_hours" =~ ^[0-9]+$ || "$step_hours" -le 0 ]]; then
    echo "STEP_HOURS must be a positive integer." >&2
    exit 1
fi

current_epoch=$(date -d "${start_dtg:0:8} ${start_dtg:8:2}:00" +%s)
end_epoch=$(date -d "${end_dtg:0:8} ${end_dtg:8:2}:00" +%s)
step_seconds=$((step_hours * 3600))

if [[ "$current_epoch" -gt "$end_epoch" ]]; then
    echo "START_DTG must be earlier than or equal to END_DTG." >&2
    exit 1
fi

while [[ "$current_epoch" -le "$end_epoch" ]]; do
    current_dtg=$(date -u -d "@$current_epoch" +%Y%m%d%H)
    output_dtg=$(date -u -d "@$((current_epoch + 3 * 3600))" +%Y%m%d%H)
    input_grib_date=$(date -u -d "@$((current_epoch))" +%Y%m%d)
    input_grib_hour=$(date -u -d "@$((current_epoch))" +%H)
    input_grib="/ec/res4/scratch/sbjb/Projects/Mars/carra2/t2m/t2m_${input_grib_date}_${input_grib_hour}00_3.grib1"
    output_nc="/ec/res4/scratch/sbjb/Projects/CARRA2/carra2_t2m_fix/Firstguess4gridpp_nc/Firstguess4gridpp_${output_dtg}.nc"

    echo "Running FirstGuess4gridpp for ${current_dtg} using ${input_grib} -> ${output_dtg}"

    FirstGuess4gridpp --debug -dtg "$current_dtg" \
        -c "$script_dir/first_guess.yml" \
        -d "$script_dir/carra2.json" \
        -i "$input_grib" \
        -if grib2 \
        -altitude_file "$script_dir/Data/an_t2m.nc" \
        -altitude_format netcdf \
        --altitude_converter none \
        -laf_file "$script_dir/Data/an_t2m.nc" \
        -laf_format netcdf \
        --laf_converter none \
        air_temperature_2m \
        -o "$output_nc" || exit 1

    current_epoch=$((current_epoch + step_seconds))
done
