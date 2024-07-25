# TRAIN PBS TEMPLATE

This PBS job template is designed for training YOLO models on GPU nodes using
a Singularity container running a python script with a JSON configuration file.

Resources like queue, CPUs, GPUs, memory, and walltime are adjustable in the script's PBS
-l directives. 

Set the CONFIG variable to specify the JSON config file path.
Set the SOURCE_FILE to point to your installation of DetectFlow and the train.py script.
Set the HOMEDIR to assign the output directory or additional binding to the container.
Set SING_IMAGE to the desired singularity image.

Post-execution, outputs are saved to $HOMEDIR/jobs/. Check jobs_info.txt
for details on job and scratch directory.