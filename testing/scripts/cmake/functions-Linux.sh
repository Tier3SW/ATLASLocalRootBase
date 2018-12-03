#!----------------------------------------------------------------------------
#!
#! functions-Linux.sh
#!
#! functions for testing the tools
#!
#! Usage:
#!     not directly
#!
#! History:
#!   08Mar18: A. De Silva, First version
#!
#!----------------------------------------------------------------------------


#!---------------------------------------------------------------------------- 
alrb_fn_cmakeTest()
#!---------------------------------------------------------------------------- 
{
    
    local alrb_retCode=0
    local alrb_runName="cmake"

    \mkdir -p $alrb_relTestDir/workdir

    \cat  <<  EOF >> $alrb_relTestDir/workdir/helloworld.cpp
#include<iostream>

int main(int argc, char *argv[]){
  std::cout << "Hello World!" <<  std::endl;
  return 0;
}
EOF

    \cat  <<  EOF >> $alrb_relTestDir/workdir/CMakeLists.txt
cmake_minimum_required(VERSION 3.7.0)
project (hello)
add_executable(hello helloworld.cpp)
EOF

    local alrb_cmdCmakeRun="cmake ."
    local alrb_cmdCmakeRunName="$alrb_relTestDir/cmake-run.out"

    local alrb_cmdCmakeCompile="make"
    local alrb_cmdCmakeCompileName="$alrb_relTestDir/cmake-make.out"

    local alrb_cmdCmakeRunApp="./hello"
    local alrb_cmdCmakeRunAppName="$alrb_relTestDir/cmake-hello.out"
    
    local alrb_runScript="$alrb_relTestDir/cmake-script-$alrb_runName"
    \rm -f $alrb_runScript
    \cat  << EOF >> $alrb_runScript
source $alrb_relTestDir/cmake-script-setup.sh
alrb_exitCode=0
\cd $alrb_relTestDir/workdir

source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdCmakeRun" $alrb_cmdCmakeRunName $alrb_Verbose
alrb_exitCode=\$?

if [ \$alrb_exitCode -eq 0 ]; then
  source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdCmakeCompile" $alrb_cmdCmakeCompileName $alrb_Verbose
  alrb_exitCode=\$?
fi

if [ \$alrb_exitCode -eq 0 ]; then
  source $ATLAS_LOCAL_ROOT_BASE/utilities/evaluator.sh "$alrb_cmdCmakeRunApp" $alrb_cmdCmakeRunAppName $alrb_Verbose
  alrb_exitCode=\$?
fi

exit \$alrb_exitCode
EOF

    alrb_fn_runShellScript $alrb_thisShell $alrb_runScript
    alrb_retCode=$?

    return $alrb_retCode   
}


#!---------------------------------------------------------------------------- 
alrb_fn_cmakeTestSetupEnv()
#!---------------------------------------------------------------------------- 
{

    \rm -f $alrb_relTestDir/cmake-script-setup.sh
    \cat << EOF >> $alrb_relTestDir/cmake-script-setup.sh
source $alrb_envFile.sh
export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
lsetup "cmake" $alrb_VerboseOpt
if [ \$? -ne 0 ]; then
  exit 64
fi
EOF
    
    return 0
}


#!---------------------------------------------------------------------------- 
alrb_fn_cmakeTestRun()
#!---------------------------------------------------------------------------- 
{
    local alrb_retCode=0
    local alrb_thisEnv
    local alrb_thisShell

    \echo -e "
\e[1mcmake test\e[0m"
    (
	export ATLAS_LOCAL_ROOT_BASE=$ATLAS_LOCAL_ROOT_BASE
	source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh -q
	lsetup cmake -q
	cmake --version
    )
 
    for alrb_thisShell in ${alrb_testShellAr[@]}; do
	
	local alrb_addStatus=""
	local alrb_relTestDir="$alrb_toolWorkdir/$alrb_thisShell"
	\mkdir -p $alrb_relTestDir

	alrb_fn_cmakeTestSetupEnv
	if [ $? -ne 0 ]; then
	    return 64
	fi

	alrb_fn_initSummary $alrb_tool $alrb_thisShell "cmake test"
	alrb_fn_cmakeTest
	alrb_fn_addSummary $? continue

    done

    return 0
}


