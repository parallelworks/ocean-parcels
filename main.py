#!/usr/bin/env python
# coding: utf-8

# ## Tutorial showing how to create Parcels in Agulhas animated gif

# This brief tutorial shows how to recreate the [animated gif](http://oceanparcels.org/animated-gifs/globcurrent_fullyseeded.gif) showing particles in the Agulhas region south of Africa.

# We start with importing the relevant modules

# In[ ]:


from parcels import FieldSet, ParticleSet, JITParticle, AdvectionRK4, ErrorCode
from datetime import timedelta
import numpy as np


# Now load the Globcurrent fields from the `GlobCurrent_example_data` directory (note that unlike in the main Parcels tutorial we don't use a dictionary for the filenames here; as they are the same for all variables, we don't need to)

# In[ ]:


filenames = "/pw/workflows/ocean_parcels_demo/parcels_examples/GlobCurrent_example_data/20*.nc"
variables = {'U': 'eastward_eulerian_current_velocity',
             'V': 'northward_eulerian_current_velocity'}
dimensions = {'lat': 'lat',
              'lon': 'lon',
              'time': 'time'}
fieldset = FieldSet.from_netcdf(filenames, variables, dimensions)


# Now create vectors of Longitude and Latitude starting locations on a regular mesh, and use these to initialise a `ParticleSet` object.

# In[ ]:


lons, lats = np.meshgrid(range(15, 35), range(-40, -30))
pset = ParticleSet(fieldset=fieldset, pclass=JITParticle, lon=lons, lat=lats)


# Now we want to advect the particles. However, the Globcurrent data that we loaded in is only for a limited, regional domain and particles might be able to leave this domain. We therefore need to tell Parcels that particles that leave the domain need to be deleted. We do that using a `Recovery Kernel`, which will be invoked when a particle encounters an `ErrorOutOfBounds` error:

# In[ ]:


def DeleteParticle(particle, fieldset, time):
    particle.delete()


# Now we can advect the particles. Note that we do this inside a `for`-loop, so we can save a plot every six hours (which is the value of `runtime`). See the [plotting tutorial](http://nbviewer.jupyter.org/github/OceanParcels/parcels/blob/master/examples/tutorial_plotting.ipynb) for more information on the `pset.show()` method.

# In[ ]:


# Inputs: pset, DeleteParticle
# Outputs: list of files (each file name is in savefile)
for cnt in range(3):
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


# This now has created 3 plots. Note that the original animated gif contained 20 plots, but to keep running of this notebook fast we have reduced the number here. Of course, it is trivial to increase the number of plots by changing the value in the `range()` in the cell above.

# As a final step, you can use [ImageMagick](http://www.imagemagick.org/script/index.php) or an online tool to stitch these individual plots together in an animated gif.

# # Execute the above in parallel on remote, custom workers
# 
# + Run OceanParcels in 4 separate experiments at the same time.
# + Each experiment is defined by a Python/OceanParsels script.
# + One experiment per (customizable) worker node.
# + Each instance of OceanParcels is run via a Docker container.

# In[ ]:


import parsl
from parsl.app.app import python_app, bash_app
from parsl.data_provider.files import File
from path import Path
from parsl.configs.local_threads import config
from parslpw import pwconfig,pwargs
parsl.load(pwconfig)

print("pwconfig loaded")


# In[ ]:


@bash_app
def run_ocean_parcels(stdout='ocean_parcels.stdout', 
                      stderr='ocean_parcels.stderr', inputs=[], outputs=[]):
    
    import os
    run_script = os.path.basename(inputs[0])
    container_run = os.path.basename(inputs[1])
    out_file = os.path.splitext(os.path.basename(inputs[0]))[0]+'.gif'
    out_dir = os.path.basename(outputs[0])
    
    run_command = "/bin/bash " + container_run + " python " + run_script
    
    # The text here is interpreted by Python (hence the %s string substitution
    # using strings in the tuple at the end of the long text string) and then
    # run as a bash app.
    return '''
        %s
        outdir=%s
        outfile=%s
        mkdir -p $outdir
        mv movie.gif $outdir/$outfile
    ''' % (run_command,out_dir,out_file)

@bash_app
def get_date(stdout='getdate.stdout',
            stderr='getdate.stderr', inputs=[], outputs=[]):
    
    import os
    out_file = os.path.splitext(os.path.basename(inputs[0]))[0]+'.log'
    out_dir = os.path.basename(outputs[0])
    
    run_command = "date > " + out_dir + "/" + out_file
    
    return '''
        mkdir -p %s
        %s
    ''' % (out_dir, run_command)


# In[ ]:


LOCAL_TESTING = False
if LOCAL_TESTING:
    import argparse
    pwargs = argparse.Namespace()
    pwargs.out_dir = '/pw/storage/test-outputs'
    pwargs.run_files = '/pw/workflows/ocean_parcels_demo/test_ocean_parcels_1.py---/pw/workflows/ocean_parcels_demo/test_ocean_parcels_2.py'
    wrapper = Path("/pw/workflows/ocean_parcels_demo/ocean-parcels/wrap_docker_oceanparcels.sh")
else:
    if pwargs.container_type == "True":
        wrapper = Path("/pw/workflows/ocean_parcels_demo/ocean-parcels/wrap_docker_oceanparcels.sh")
    else:
        wrapper = Path("/pw/workflows/ocean_parcels_demo/ocean-parcels/wrap_singularity_oceanparcels.sh")
        
run_files = pwargs.run_files.split('---')

runs=[]
for run_file_name in run_files:
    
    run_file = Path(run_file_name)
    out_dir = Path(pwargs.out_dir)
    
    r = run_ocean_parcels(inputs=[run_file,wrapper], 
                          outputs=[out_dir])
    
    runs.append(r)

print("Running",len(runs),"OceanParcels executions...")
[r.result() for r in runs]


# In[ ]:




