

#!/bin/bash

env_target="${1:-firstguess}"

case "$env_target" in
	firstguess|fg)
		module load python3/3.8.8-01
		module load ecmwf-toolbox/2021.08.3.0
		module load udunits/2.2.28

		export PYSURFEX_INSTALL_DIR="/ec/res4/scratch/sbjb/Projects/CARRA2/carra2_t2m_fix/pysurfex"
		export PATH="$PYSURFEX_INSTALL_DIR/bin:$PATH"
		export PYTHONPATH="$PYSURFEX_INSTALL_DIR:$PYSURFEX_INSTALL_DIR/site:$PYSURFEX_INSTALL_DIR/epygram:$PYTHONPATH"
		export LD_LIBRARY_PATH="$UDUNITS_DIR/lib:$LD_LIBRARY_PATH"
		;;
	bufr2json|qc|oi|obsproc)
        export EXP=CARRA2
		source /perm/fac2/hm_lib/carra2_201909/Env_system
		source /perm/fac2/hm_lib/carra2_201909/ecf/config_exp.h
		;;
	*)
		echo "Usage: source env.sh [firstguess|bufr2json|qc|oi]" >&2
		return 1 2>/dev/null || exit 1
		;;
esac
