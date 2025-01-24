<<<<<<< Updated upstream

if [ "$(hostname)" = "CIHR" ]; then
   
   # Set this to point to the top level of the TailBench data directory
	DATA_ROOT=/home/jofepre/Documentos/Huawei_project/tailbench.inputs
	
	# Set this to point to the top level installation directory of the Java
	# Development Kit. Only needed for Specjbb
	JDK_PATH=/usr/lib/jvm/java-8-openjdk-amd64

	# This location is used by applications to store scratch data during execution.
	SCRATCH_DIR=/home/jofepre/Documentos/Huawei_project/tailbench_repo/tailbench/pathtoscratch

elif [ "$(hostname)" == "xpl4" ]; then

	DATA_ROOT=/vmssd/tailbench/tailbench.inputs
	JDK_PATH=/usr/lib/jvm/java-8-openjdk-amd64
	SCRATCH_DIR=/homenvm/jofepre/tailbench/pathtoscratch

elif [ "$(hostname)" == "xpl2" ]; then
	
	DATA_ROOT=/home/tailbench_data/tailbench.inputs
	JDK_PATH=/usr/lib/jvm/java-8-openjdk-amd64
	SCRATCH_DIR=/home/jofepre/tailbench/pathtoscratch

else
	
	DATA_ROOT=/home/master/tailbench.inputs
	JDK_PATH=/usr/lib/jvm/java-8-openjdk-amd64
	SCRATCH_DIR=/home/master/tailbench/scratch
fi

=======
DATA_ROOT=/home/master/Documents/tailbench.inputs
JDK_PATH=/usr/lib/jvm/java-8-openjdk-amd64
SCRATCH_DIR=/home/master/Documents/scratch
>>>>>>> Stashed changes
