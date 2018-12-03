#! /bin/bash
#!----------------------------------------------------------------------------
#!
#! myproxydelegate-exampke.sh
#!
#! This shows you how to delegate a proxy and to use it in a secure manner.
#!
#! Usage:
#!     copy this script, change the configuation section
#!     follow steps 0 and 1
#!     uncomment step2 and run it as a cron job if previous steps are OK
#!
#! History:
#!   08Nov17: A. De Silva, First version
#!
#!----------------------------------------------------------------------------

#!----------------------------------------------------------------------------
# configurations
#!----------------------------------------------------------------------------

# do this on any interactive machine to delegate a long-lived (8760 h) no voms
#    proxy, with DN in this example (replace it with yours):
myDN="/C=CA/O=Grid/OU=triumf.ca/CN=Asoka De Silva GC1" 
#    to a proxy server myproxy.cern.ch

# The machine that is going to use this proxy needs to have a host certificate.
#  The host machine certificate DN in this example (replace it with yours):
myHostCertDN="/C=CA/O=Grid/OU=triumf.ca/CN=pilotfactory.triumf.ca"
# The host certificates need to reside in a dir that is owned by the user
#  for this example (replace it with yours):
myHostCertDir="/home/apf/hostcert"

# You also need a credential name; replace it with something meaningful.
myCredentialName="GC1_novoms_pilotfactory"

#!----------------------------------------------------------------------------


# this is how to setup the software for all the commands below
if [ -z $ATLAS_LOCAL_ROOT_BASE ]; then
  export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
  alias setupATLAS='source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh'
fi
setupATLAS -q
lsetup emi 
export GT_PROXY_MODE=rfc


# Step 0 - host certificate:
# Get a host certificte from your country's Grid Certificate Issuer for the 
#  machine (you need the full hostname) that runs xcache.  Install the
#  *.pem files in $myHostCertDir


# Step 1 -  delegate :
#  (you need to do this again when your grid certificate expires in 1 year)
# myproxy-init -n -t 96 -c 8760 -d -s  myproxy.cern.ch -x -Z "$myHostCertDN" -k $myCredentialName

#   how to query if it exists on myproxy.cern.ch (need proxy if not setup):
#   voms-proxy-init -voms atlas  # if needed
#   myproxy-info -s myproxy.cern.ch -k $myCredentialName -l "$myDN"

#   how to delete it from myproxy.cern.ch (need proxy if not setup):
#   voms-proxy-init -voms atlas # if needed
#   myproxy-destroy -s myproxy.cern.ch -k $myCredentialName -l "$myDN"


# Step 2 - use it (run as a cron job uncomment these lines):
# export X509_USER_CERT=$myHostCertDir/hostcert.pem 
# export X509_USER_KEY=$myHostCertDir/hostkey.pem
# \rm -f new.proxy
# myproxy-logon -n -t 96 -s myproxy.cern.ch -k $myCredentialName  -o new.proxy -d -l "$myDN" --voms atlas
# if [ $? -eq 0 ]; then
#   \mv new.proxy /tmp/x509up_u`id -u` 
#   export X509_USER_PROXY=/tmp/x509up_u`id -u`
# else
#   echo "Error: failed to get delegated proxy"
#   exit 64
# fi

