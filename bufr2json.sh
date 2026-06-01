#!/bin/bash
#SBATCH --qos=nf
#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=1
##SBATCH --mem=24GB
#SBATCH --job-name=bufr2json

script_dir=/ec/res4/hpcperm/sbjb/github/carra2_t2m_fix
source "$script_dir/env.sh" bufr2json

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
    input_bufr="/scratch/fasg/CARRA2/greenland_obs_issue/prepobs/merged/synop_merged_${current_dtg}"
    output_json_dir="/ec/res4/scratch/sbjb/Projects/CARRA2/carra2_t2m_fix/json/t2m"
    output_json="${output_json_dir}/ob${current_dtg}.json"

    echo "Running Bufr2json for ${current_dtg}"

    mkdir -p "$output_json_dir"

    bufr2json -b "$input_bufr" -v \
        airTemperatureAt2M relativeHumidityAt2M stationOrSiteName -o "$output_json" \
        -dtg "$current_dtg" -range 1800 || exit 1
    

    current_epoch=$((current_epoch + step_seconds))
done
