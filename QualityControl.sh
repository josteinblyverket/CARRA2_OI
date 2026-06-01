#!/bin/bash
#SBATCH --qos=nf
#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=1
##SBATCH --mem=24GB
#SBATCH --job-name=QualityControl

script_dir=/ec/res4/hpcperm/sbjb/github/carra2_t2m_fix
source "/ec/res4/hpcperm/sbjb/github/carra2_t2m_fix/env.sh" qc

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
    output_json_dir="/ec/res4/scratch/sbjb/Projects/CARRA2/carra2_t2m_fix/json/t2m/"
    input_ob="${output_json_dir}/ob${current_dtg}.json"
    output_qc="/ec/res4/scratch/sbjb/Projects/CARRA2/carra2_t2m_fix/json/t2m_qc/qc_obs_t2m_${current_dtg}.json"
    input_fg="/ec/res4/scratch/sbjb/Projects/CARRA2/carra2_t2m_fix/Firstguess4gridpp_nc/Firstguess4gridpp_${current_dtg}.nc"
    rendered_config=$(mktemp)

    sed \
        -e "s|__CURRENT_DTG__|${current_dtg}|g" \
        -e "s|__INPUT_OB__|${input_ob}|g" \
        -e "s|__INPUT_FG__|${input_fg}|g" \
        config.json > "$rendered_config"

    echo "Running QualityControl for ${current_dtg} using ${input_ob} -> ${output_qc}"
   
    titan -i "$rendered_config" -dtg "$current_dtg" --domain carra2.json -v t2m \
        --blacklist blacklist_t2m.json -o "$output_qc" \
        domain blacklist nometa redundancy plausibility fraction sct

    rm -f "$rendered_config"

    current_epoch=$((current_epoch + step_seconds))
    
done






