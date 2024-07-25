#!/bin/bash
#PBS -N YOLO_Train_Config
#PBS -q gpu_long@pbs-m1.metacentrum.cz
#PBS -l ncpus=10
#PBS -l ngpus=1
#PBS -l gpu_mem=10gb
#PBS -l walltime=48:00:00
#PBS -l mem=64gb
#PBS -l scratch_local=1gb
#PBS -m ae

# This script will run YOLO training python script with arguments defined in a 
# .json config file. For this to work you must set the CONFIG environmental 
# variable to the path to the .json config file. The SOURCE_FILE defines the
# python script to run.
################################################################################
# ARGUMENTS

HOMEDIR=/storage/brno2/home/$USER/
CONFIG="/storage/projects/yolo_group/datasets/petr_test/flowers_petr_v9e.json"
SOURCE_FILE="$HOMEDIR/repos/DetectFlow/detectflow/jobs/train.py"
SING_IMAGE=/storage/projects/yolo_group/singularity/DetectFlow:24.04_05.sif


################################################################################
# Set working directory
cd $HOMEDIR

# Check if the $CONFIG variable is set and not empty
if [ -z "$CONFIG" ]; then
    # If CONFIG is not set, set it to a default value
    CONFIG="/storage/brno2/home/chlupp/pycharm/mtc-train/config.json"
fi

echo "Config is set to: $CONFIG"

# Append a line to a file "jobs_info.txt" containing the ID of the job, the 
# hostname of node it is run on and the path to a scratch directory. This 
# information helps to find a scratch directory in case the job fails and you 
# need to remove the scratch directory manually.

echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> $HOMEDIR/jobs_info.txt,

# Load modules here

# Test if scratch directory is set. If scratch directory is not set, 
# issue error message and exit

test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }

################################################################################
# CALCULATIONS

# Note that clearml must be installed and accessible to the singularity image, 
# install into images pythonbase. Alternatively you can install it via pip
# before running the python script by adding "pip install clearml;" just before
# "python '$SOURCE_FILE'"

singularity run -B /auto/brno11-elixir/home/$USER:/auto/brno11-elixir/home/$USER \
                -B /auto/brno12-cerit/home/$USER:/auto/brno12-cerit/home/$USER \
                -B /auto/brno2/home/$USER:/auto/brno2/home/$USER \
                -B /auto/budejovice1/home/$USER:/auto/budejovice1/home/$USER \
                -B /auto/plzen1/home/$USER:/auto/plzen1/home/$USER \
                -B /auto/praha2-natur/home/$USER:/auto/praha2-natur/home/$USER \
                -B /auto/praha5-elixir/home/$USER:/auto/praha5-elixir/home/$USER \
                -B /auto/pruhonice1-ibot/home/$USER:/auto/pruhonice1-ibot/home/$USER \
                -B /auto/vestec1-elixir/home/$USER:/auto/vestec1-elixir/home/$USER \
                -B /storage/projects/yolo_group:/storage/projects/yolo_group \
                -B $SCRATCHDIR:$SCRATCHDIR \
                -B $HOMEDIR:$HOMEDIR \
                --env SCRATCH_DIR=$SCRATCHDIR \
                $SING_IMAGE python $SOURCE_FILE --config_path $CONFIG --hostname $HOSTNAME

# singularity exec -B $HOMEDIR:/auto/brno2/home/$USER/ \
# $SING_IMAGE /bin/bash -c "python '$SOURCE_FILE' --config '$CONFIG' --hostname '$HOSTNAME'"

################################################################################

# Copy everything from scratch directory to $HOME/jobs
cp -r $SCRATCHDIR/* $HOMEDIR/jobs/

clean_scratch
