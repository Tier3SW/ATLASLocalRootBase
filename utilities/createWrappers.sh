#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! createWrappers.sh
#!
#! creates wrappers
#!
#! Usage: 
#!     createWrappers.sh
#!
#! History:
#!   27Jan14: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

alrb_fn_cleanup()
{
    local alrb_list=";`printf '%s;' "${alrb_linkedFList[@]}"`;"
    local alrb_tmpAr=( `\find $alrb_wrapDir -type l | \sed -e 's|'$alrb_wrapDir'/||g'` )
    local alrb_item
    for alrb_item in "${alrb_tmpAr[@]}"; do
	\echo $alrb_list | \grep -e ";$alrb_item;" > /dev/null 2>&1
	if [ $? -ne 0 ]; then
	    \echo "  deleting wrapper $alrb_wrapDir/$alrb_item"
	    \rm -f $alrb_wrapDir/$alrb_item
	fi
    done

    return 0
}


# for grid middleware
alrb_wrapDir="$ATLAS_LOCAL_ROOT_BASE/wrappers/gridMW"
alrb_wrapfile="grid_wrap.sh"
alrb_linkedFList=( "voms-proxy-info" "voms-proxy-init" "voms-proxy-destroy" "grid-proxy-info" "grid-cert-info" "grid-proxy-destroy" "grid-proxy-init" )
if [ -e "$alrb_wrapDir/$alrb_wrapfile" ]; then
    cd $alrb_wrapDir
    for alrb_item in ${alrb_linkedFList[@]}; do
	if [ ! -e "$alrb_item" ]; then
	    ln -s $alrb_wrapfile $alrb_item
	fi
    done
fi

# for rucio-clients
alrb_wrapDir="$ATLAS_LOCAL_ROOT_BASE/wrappers/rucioClients"
alrb_wrapfile="rucio_wrapper.sh"
alrb_linkedFList=( "rucio" "rucio-admin" )
if [ -e "$alrb_wrapDir/$alrb_wrapfile" ]; then
    cd $alrb_wrapDir
    for alrb_item in ${alrb_linkedFList[@]}; do
	if [ ! -e "$alrb_item" ]; then
	    ln -s $alrb_wrapfile $alrb_item
	fi
    done
fi


# for containers lsf
alrb_wrapDir="$ATLAS_LOCAL_ROOT_BASE/wrappers/containers/lsf"
mkdir -p $alrb_wrapDir
alrb_wrapfile="../delegator.sh"
alrb_linkedFList=(
    bbot
    bhist
    bhosts
    bjobs
    bkill
    bmgroup
    bmod
    bparams
    bpeek
    bqueues
    brequeue
    bresize
    bresources
    bresume
    bstatus
    bstop
    bsub
    bswitch
    btop
    bugroup
    busers
    lsacct
    lsclusters
    lshosts
    lsid
    lsinfo
    lsload
)
alrb_fn_cleanup
if [ -e "$alrb_wrapDir/$alrb_wrapfile" ]; then
    cd $alrb_wrapDir
    for alrb_item in ${alrb_linkedFList[@]}; do
	if [ ! -e "$alrb_item" ]; then
	    ln -s $alrb_wrapfile $alrb_item
	fi
    done
fi


# for containers condor
alrb_wrapDir="$ATLAS_LOCAL_ROOT_BASE/wrappers/containers/condor"
mkdir -p $alrb_wrapDir
alrb_wrapfile="../delegator.sh"
alrb_linkedFList=(
    condor_continue
    condor_gather_info
    condor_history
    condor_hold
    condor_prio
    condor_q
    condor_qedit
    condor_qsub
    condor_release
    condor_reschedule
    condor_rm
    condor_run
    condor_status
    condor_submit
    condor_suspend
    condor_tail
    condor_userlog
    condor_version
)
alrb_fn_cleanup
if [ -e "$alrb_wrapDir/$alrb_wrapfile" ]; then
    cd $alrb_wrapDir
    for alrb_item in ${alrb_linkedFList[@]}; do
	if [ ! -e "$alrb_item" ]; then
	    ln -s $alrb_wrapfile $alrb_item
	fi
    done
fi


# for containers slurm
alrb_wrapDir="$ATLAS_LOCAL_ROOT_BASE/wrappers/containers/slurm"
mkdir -p $alrb_wrapDir
alrb_wrapfile="../delegator.sh"
alrb_linkedFList=(
    sacct
    sbatch
    scancel
    scontrol
    seff
    sinfo
    sprio
    squeue
    srun
    sshare
    sstat
)
alrb_fn_cleanup
if [ -e "$alrb_wrapDir/$alrb_wrapfile" ]; then
    cd $alrb_wrapDir
    for alrb_item in ${alrb_linkedFList[@]}; do
	if [ ! -e "$alrb_item" ]; then
	    ln -s $alrb_wrapfile $alrb_item
	fi
    done
fi

