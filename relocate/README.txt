relocate allows for /cvmfs to be mounted elsewhere; eg: /mnt/cvmfs

In order to use ALRB with relocate, this is the procedure:

export ATLAS_SW_BASE=/mnt/cvmfs
mkdir -p $HOME/myLocalConfig
export ALRB_localConfigDir=$HOME/myLocalConfig
export ALRB_RELOCATECVMFS="YES"
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_SW_BASE/atlas.cern.ch/repo/ATLASLocalRootBase
alias setupATLAS='source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh'
setupATLAS





