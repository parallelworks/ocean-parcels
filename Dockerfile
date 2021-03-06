#------------------------------------
# Docker container for OceanParcels: https://oceanparcels.org/
#
# To build:
# sudo docker build -t stefanfgary/ocean_parcels .
#
# To run:
# sudo docker run --rm -it stefanfgary/ocean_parcels /bin/bash
#------------------------------------

#------------------------------------
# Use official Ubuntu as base image
#------------------------------------

FROM ubuntu:latest

#------------------------------------
# Set the working directory to /app
#------------------------------------

WORKDIR /app
ADD ./test_ocean_parcels.py /app/test_ocean_parcels.py

#------------------------------------
# Configure time zone so apt-get update
# does not hang.  Thanks to Grigor Khachatryan at:
# https://grigorkh.medium.com/fix-tzdata-hangs-docker-image-build-cdb52cc3360d

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#------------------------------------
# Install some key packages
#------------------------------------

RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    apt-utils \
    git-core \
    imagemagick \
    software-properties-common

#------------------------------------
# Install Miniconda and Python packages
#------------------------------------

# Use -b for batch mode. Does not edit PATH or
# .bashrc or .bash_profile.  Thanks to tcoil.info
# for template at:
# https://tcoil.info/build-custom-miniconda-docker-image-with-dockerfile/

# Python 3.9 -> not compatible with OceanParcels
#RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh; \
#    bash Miniconda3-py39_4.9.2-Linux-x86_64.sh -b; \
#    rm Miniconda3-py39_4.9.2-Linux-x86_64.sh

# Python 3.7 -> /root/miniconda3/pkgs/python-3.7.1-h0371630_7/bin/python: No such file or directory
#RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86.sh; \
#    bash Miniconda3-latest-Linux-x86.sh -b; \
#    rm Miniconda3-latest-Linux-x86.sh

# Python 3.8 -> Works!
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh; \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /app/miniconda3; \
    rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH=/app/miniconda3/bin:${PATH}

# Make all RUN commands use a specific environment:
# (See https://pythonspeed.com/articles/activate-conda-dockerfile/ )
SHELL ["conda", "run", "-n", "base", "/bin/bash", "-c"]

RUN conda update -y conda; \
    conda install -y -c conda-forge parcels \
    	  	     		    ffmpeg \
				    cartopy

#------------------------------------
# Add some sample data for demos
# This is done as a separate layer
# that can be removed later for
# for faster container transfer.
#------------------------------------

RUN parcels_get_examples parcels_examples

#------------------------------------
# TODO - need to test this solution
# Sometimes cartopy wants to download
# coastline shapefiles that are not
# installed by default on cartopy.
# Some possible solutions are here:
# https://github.com/SciTools/cartopy/issues/1325
# The most relevant solution by alpha-beta-soup
# would add the following commands to
# the Dockerfile:
#------------------------------------
#ENV CARTOPY_DIR=/usr/local/cartopy-data
#ENV NE_PHYSICAL=${CARTOPY_DIR}/shapefiles/natural_earth/physical
#RUN mkdir -p ${NE_PHYSICAL}
#RUN wget https://www.naturalearthdata.com/http//www.naturalearthdata.com/downlo#ad/10m/physical/ne_10m_coastline.zip -P ${CARTOPY_DIR}
#RUN apt-get -yq install unzip
#RUN unzip ${CARTOPY_DIR}/ne_10m_coastline.zip -d  ${NE_PHYSICAL}
#RUN rm ${CARTOPY_DIR}/*.zip
#
# and then in python:
# import os
# import cartopy
# cartopy.config['data_dir'] = os.getenv('CARTOPY_DIR', cartopy.config.get('data_dir'))

# Or, a simple alternative is to just call
# a simple OceanParcels script that will
# require plotting so the key files are
# downloaded during the container build
# process and saved in default locations:
RUN python test_ocean_parcels.py
RUN rm /app/*.png /app/movie.gif

# The code to run when container is started,
# You can add additional parameters on
# command line, e.g. https://stackoverflow.com/questions/53543881/docker-run-pass-arguments-to-entrypoint
# Add the oceanparcels conda environment to match
# that on the cluster conda install.  ##DOES NOT ADDRESS ROOT ISSUE!##
COPY ./container_entrypoint.sh /app/container_entrypoint.sh
RUN conda create --name oceanparcels --clone base
SHELL ["conda", "run", "-n", "oceanparcels", "/bin/bash", "-c"]
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "oceanparcels", "/app/container_entrypoint.sh"]

# Singularity cannot use the entrypoint because it
# needs to create a tmp file in /app/miniconda3?
# Simply making it writable does not work b/c
# Singularity runs as read-only filesystem.
#RUN chmod a+w /app; \
#    chmod a+w /app/miniconda3;

#------------------------------------
# Optional container startup command
#------------------------------------
#CMD ["echo", "Hello from Docker!"]
