# "Classical" platform, standard PW:
object = Path("file", prefix="file://parslhost")

# For SLURM runs on GCE cluster
object = Path(path, prefix = prefix)

# Do do this, 
from config import config, prefix
parsl.load(config)

# The config lines at: https://github.com/parallelworks/mimo_regressor_parsl/blob/main/parslml/config.py
# Note that prefix and config are set based on the compute environment.

import parsl
import os

parsl_env = 'parslpw'
#parsl_env = 'local'
#parsl_env = 'slurm'

if parsl_env == 'local':
    prefix = ''
    from parsl.config import Config
    from parsl.executors.threads import ThreadPoolExecutor
    local_threads = Config(
    	executors=[ThreadPoolExecutor(max_threads = 2)])
    config = local_threads

elif parsl_env == 'parslpw':
    prefix = 'file://parslhost'
    os.environ['PARSLMODS'] = '/pw/workflows/mimo_regressor/parsl_patch/parslmods/parslmods.tgz'
    from parslpw import pwconfig
    config = pwconfig

elif parsl_env == 'slurm':
    prefix = ''
    from parsl.config import Config
    from parsl.executors.threads import ThreadPoolExecutor
    from parsl.executors import HighThroughputExecutor
    from parsl.providers import SlurmProvider
    config = Config(
         executors=[
	     HighThroughputExecutor(
		label='slurm',
		worker_debug=False,
		cores_per_worker=int(1),
		working_dir = os.getcwd(),
		worker_logdir_root = os. getcwd() + '/parsllogs',
		provider = SlurmProvider(
			 partition = 'compute',
			 nodes_per_block = 1,
			 min_blocks = int(0),
			 max_blocks = int(10),
			worker_init = 'source /contrib/Alvaro.Vidal/miniconda3/etc/profile.d/conda.sh; conda activate parsl_py36',
			parallelism = 1 # Was 0.80 ### # FIXME?,
	        )
	    )
        ]
    )

# GET COMMAND LINE ARGS FROM PW FORM
import argparse
parser=argparse.ArgumentParser()
parsed, unknown = parser.parse_known_args()
for arg in unknown:
    if arg.startswith(("-", "--")):
            parser.add_argument(arg)
	    pwargs=parser.parse_args()
	    print("pwargs:",pwargs)

