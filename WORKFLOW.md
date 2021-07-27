# Jupyter notebook/Parsl workflow to run OceanParcels via Singularity container

Currently, this workflow only launches from the `main_slurm_no_form.ipynb` notebook.  A workflow that is launched from a GUI form is under development (and you can see a template form in `workflow.xml`).

# Resource configuration

The default version of this workflow does not require
substantial resources.  Workers with 2 CPU and 8GB RAM
are sufficient.  If you choose to run on bigger model
output fields and/or with more particles, then you'll
want to adjust resources accordingly.

# Dependencies

The first 5 cells in this notebook are taken directly from
the [Ocean Parcels tutorial](https://oceanparcels.org/) and
are executed locally (i.e. on the head node of the cluster).
The local execution of OceanParcels requires the following
(recommend installing in separate steps):
```bash
conda install -y -c conda-forge parcels
conda install -y -c conda-forge ffmpeg
conda install -y -c conda-forge cartopy
```

The last 3 cells in the notebook are the workflow proper;
they setup and then launch several workers, each worker
runs one of the `test_ocean_parcels_X.py` scripts in a
Singularity container (public container at https://hub.docker.com/r/stefanfgary/ocean_parcels which
can be converted to Singularity via `singularity pull docker://stefanfgary/ocean_parcels`).  The path to the
container is set in `wrap_singularity_oceanparcels_slurm.sh`
and it's most easily launched via that script.  The workflow
is parallelized with Parsl, please ensure it is present in
your local environment:
```bash
conda install -y -c conda-forge parsl
```


# Future work

1. The current container is large and it can be trimmed to run faster.
2. Workflow file staging to and out of workers can be streamlined.
3. Run workflow from the GUI form.