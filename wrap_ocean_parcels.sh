#!/bin/bash
docker run --rm -v $PWD:/scratch -w /scratch stefanfgary/ocean_parcels $*