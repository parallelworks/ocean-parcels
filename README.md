# ocean-parcels
Dockerfile and other documentation for ocean-parcels workflow.  Includes converting to Singularity.

# Workflow installation

After pulling this repository from github.com/parallelworks/ocean-parcles,
symlink or copy main.ipynb and workflow.xml into the empty PW workflow
directory.  (Note, if you make symlinks, this will prevent sharing the
workflow via the PW market place.) Add OceanParcels Python scripts
(e.g. copies of test_ocean_parcels.py or more sophisticated scripts)
to the empty workflow directory.

Other dependencies:
1. paths.py
2. parcels_examples (obtained via command line, e.g.: `/contrib/Stefan.Gary/miniconda3/envs/oceanparcels/bin/parcels_get_examples parcels_examples`)
3. utils


Run the workflow from the `Compute` tab on the PW platform.

# Worker image

I started with a default Ubuntu20 Mimimal image and
I installed Docker and Singularity and converted the
OceanParcels Docker container to Singularity in the
same session on a worker image. The worker setup
process is documented in `build_worker.sh`.

When logging into the (Ubuntu20 Minimal) machine:
```bash
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install git-core # Adds 40MB
git clone https://github.com/parallelworks/ocean-parcels
```
Then you can run the Docker and Singularity install
steps in the build_worker.sh script. The script is based on the [Docker installation](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository) and the [Singularity installation](https://sylabs.io/guides/3.0/user-guide/installation.html) instructions.

The install script does *not* include the additional
steps of pulling the Docker container image to the
worker you're building and converting that container image
to Singularity.  Those steps were done manually and
are documented below.

# Container

## Docker (and Singularity)

The Dockerfile is based on the Dockerfile at
github.com/stefangary/socks with some minor
experimentation.  In particular, it was essential
to get the right Python/Miniconda version.

Docker and Singularity differ in some important ways,
[Turner-Trauring (2021)](https://pythonspeed.com/articles/containers-filesystem-data-processing/) is an **excellent** summary.
Key take home points:
1. **Docker** containers are *isolated* so special processes are necessary for the container to see host system files (e.g. Docker Volumes, mounting).
2. **Singularty** containers are *permeable* (you keep the same UID, automatic access $HOME, $PWD, and /tmp on host file system).

In general, I like to make images as Docker containers
because they can be easily converted to Singularity.
It's harder for Mac/Win users to run Singularity
containers; by providing Docker containers, it's easier
to share with others.

## Building the Docker container image

To create the container, while in this directory with
the included Dockerfile and test_ocean_parcels.py,
```bash
sudo docker build . -t stefanfgary/ocean_parcels
sudo docker push stefanfgary/ocean_parcels
```
(Tag it with your own DockerHub ID for your own records.)

## Converting OceanParcels to Singularity

First, pull the Docker container if it wasn't already
built/pulled on this system:  (I built the container
on a local laptop and then pulled it to a cloud worker)
```bash
sudo docker pull stefanfgary/ocean_parcels
```

Second, pull the Docker container into Singularity:
```bash
singularity pull docker://stefanfgary/ocean_parcels
```

This Singularity operation placed the container .sif
in the current directory; I moved the Singularity
container image to /usr/local/ocean_parcels_latest.sif
and gave all users permissions.

**Note:** While building the Docker container, it is
essential to run test_ocean_parcels.py because this
will download a file needed by cartopy to make ploats.
This is does not matter for the Docker container
(because it is fully isolated from the underlying system)
but this file must be preinstalled for the Singularity
container to run because the default location for it
is normally in a space that the Singularity user cannot
access.

**To do:** The Singularity `.sif` file on the worker is
compressed so every time the container is run, it takes
about a minute to decompress the file.  I have experimented
with trying to run from a `--sandbox` version of the `.sif`
but I have run into permissions issues.  Actually, I don't
think it has anything to do with the container itself -
with some experimentation, it seems that the temporary
sandbox is created with the --fakeroot option.  This
has been verified - the container starts up much faster
now that miniconda is not installed in /root so there
is no need to run as --fakeroot.

**To do:** The Singularity container does not appear
to use the Dockerfile's ENTRYPOINT with `exec`.  However,
using `singularity run` breaks on gclusters.

## Worker-installed (preloaded) Parsl-PW Conda environment

The `parsl-pw` Conda environment is the default environment
for executing PW platform parallelization via Parsl.  While
the platform can copy this environment to a given worker,
preloading this Conda environment will speed up worker spin-up
time since copying and unpacking the Conda environment takes
a long time.

First, copy the /pw/.packs/miniconda3.tgz file from your account
on PW to the cloud worker.  The fastest way to do this is to
sftp directly to the external IP address of the worker which
can be looked up on the GCE console.

Then untar the file to /var/lib/pworks/.miniconda3. Update the
conda paths from /pw/.miniconda3 to /var/lib/pworks/.miniconda3
**Do not use /tmp/.miniconda3 to preload the Conda env files because
/tmp is not persistent on cloud worker images.**
