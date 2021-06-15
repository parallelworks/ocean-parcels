# ocean-parcels
Dockerfile and other documentation for ocean-parcels workflow.  Includes converting to Singularity.

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
However, it's harder for Mac/Win users to run Singularity
containers - by providing Docker containers, it's easier
to ensure others can cross-check your work -> transparency.

## Installing Docker and Singularity

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

## Converting OceanParcels to Singularity

First, pull the Docker container:
```bash
sudo docker pull stefanfgary/ocean_parcels
```

Second, pull the Docker container into Singularity:
```bash
singularity pull docker://stefanfgary/ocean_parcels
```

I moved the container to /usr/local/

