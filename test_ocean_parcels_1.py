# This Python script for OceanParcels is based on
# the Agulhas Current tutorial Jupyter notebook
# distributed with OceanParcels.  The code therein
# is pretty much the same as here except that
# comments have been trimmed and it's designed
# to be run as an input script to the Dockerized
# version of OceanParcels.

#============================
# Imports
#============================

from parcels import FieldSet, ParticleSet, JITParticle, AdvectionRK4, ErrorCode
from datetime import timedelta
import numpy as np
import subprocess

#============================
# Set ocean current data
#============================

# CAUTION! If running in a container,
# data path here is specific to
# location of data mounted/copied into
# the container.
filenames = "/app/parcels_examples/GlobCurrent_example_data/20*.nc"
variables = {'U': 'eastward_eulerian_current_velocity',
             'V': 'northward_eulerian_current_velocity'}
dimensions = {'lat': 'lat',
              'lon': 'lon',
              'time': 'time'}
fieldset = FieldSet.from_netcdf(filenames, variables, dimensions)

#============================
# Set particle launch locations
#============================
lons, lats = np.meshgrid(range(15, 25), range(-40, -30))
pset = ParticleSet(fieldset=fieldset, pclass=JITParticle, lon=lons, lat=lats)

#============================
# Set boundary condition on
# particles that reach the edges.
#============================
def DeleteParticle(particle, fieldset, time):
    particle.delete()

#============================
# Run and plot output!
#============================
for cnt in range(20):
    # Set filename for output plot
    output_image = 'particles'+str(cnt).zfill(2)
    print(output_image)

    # First plot the particles
    pset.show(savefile=output_image, field='vector', land=True, vmax=2.0)

    # Then advect the particles for 6 hours
    pset.execute(AdvectionRK4,
                 runtime=timedelta(hours=6),  # runtime controls the interval of the plots
                 dt=timedelta(minutes=5),
                 recovery={ErrorCode.ErrorOutOfBounds: DeleteParticle})  # the recovery kernel

#============================
# Convert .png images to .gif
#============================

subprocess.run(['convert', '*.png', 'movie.gif'])

#============================
# Done
#============================
