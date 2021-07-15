#!/bin/bash
#==============================================
# Explictly pick whatever PWD the
# job control tool starts with since that
# is where the script to be run is most likely
# to be staged.  The script to be run is
# given as an input argument to this wrapper.
#==============================================
singularity exec --bind ${PWD}:/scratch --pwd /scratch /contrib/Stefan.Gary/ocean_parcels_latest.sif /app/container_entrypoint.sh $*
