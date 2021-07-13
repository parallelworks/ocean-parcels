#!/bin/bash
#==============================================
# This Singularity container was created from
# a Docker container whose Conda environment
# is set up to run as root.  So the container
# needs to be started with --fakeroot and we
# DO NOT want the home of root on the host
# file system, so choose --no-home.
#
# Instead, explictly pick whatever PWD the
# job control tool starts with since that
# is where the script to be run is most likely
# to be staged.  The script to be run is
# given as an input argument to this wrapper.
#==============================================
singularity exec --no-home --fakeroot --bind ${PWD}:/scratch --pwd /scratch /usr/local/ocean_parcels_latest.sif $*
