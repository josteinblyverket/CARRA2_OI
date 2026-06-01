#!/usr/bin/bash
#SBATCH --job-name=CARRA2
#SBATCH --qos=nf
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=24GB
##SBATCH --output=stage-mars.%j.out
##SBATCH --error=stage-mars.%j.out

#DATE=$1
#DATE_END=$2

for year in 2013 2014
do
for mm in 01 02 12
do

cat <<EOF > get_ec.mars
retrieve,
class=rr,
date=$year-$mm-01/to/$year-$mm-31,
expver=prod,
levtype=sfc,
origin=no-ar-pa,
param=167,
step=3,
stream=oper,
time=00:00:00/03:00:00/06:00:00/09:00:00/12:00:00/15:00:00/18:00:00/21:00:00,
type=fc,
target="/ec/res4/scratch/sbjb/Projects/Mars/carra2/temp.grib"
EOF

mars get_ec.mars
mv /ec/res4/scratch/sbjb/Projects/Mars/carra2/temp.grib /ec/res4/scratch/sbjb/Projects/Mars/carra2/t2m/CARRA2_t2m_$year$mm.grib"

done
done
