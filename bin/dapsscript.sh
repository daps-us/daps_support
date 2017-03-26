#!/bin/bash
# this script is used to run other scripts.  It sets the enviornment to be
# drush friendly and writes output to a log named the same as th script.
#
export PATH=/home/daps/daps_support/bin:$PATH

function line {
   local timestamp=`date +"%Y%m%d%H%M%S"`
   echo $scriptname $timestamp $*
}

function quit {
   condition=$1
   shift
   line $@
   case $condition in
      error)
            if [[ -f $logname ]];then
               echo $@ | mailx -s "$script error" -S from=alerts@daps.us -a $logname  daps@daps.us
            else
               echo $@ | mailx -s "$script error" -S from=alerts@daps.us daps@daps.us
            fi
            exit 1
            ;;
      success)
            exit 0
            ;;
      *)
            if [[ -f $logname ]];then
               echo $@ | mailx -s "$script error" -S from=alerts@daps.us -a $logname  daps@daps.us
            else
               echo $@ | mailx -s "$script error" -S from=alerts@daps.us daps@daps.us
            fi
            exit 1
            ;;
   esac
}

# set defaults - I expect these to be replaced.
logdir="/home/daps/daps_support/logs"
script="/home/daps/daps_support/bin/dapsscript.sh"
logname="$logdir/dapsscript.log"

# set initial timestamp
timestamp=`date +"%Y%m%d%H%M%S"`
if [[ $? -ne 0 ]];then
   quit error "ERROR determining timestamp."
fi

# set the name of the script
scriptname=`basename $0`
if [[ -z $scriptname ]];then
   quit error "ERROR determining script name."
fi

cd /home/daps/daps_support/bin
if [[ $? -ne 0 ]];then
    quit error "ERROR changing directories to /home/daps/daps_support/bin"
fi

if [[ $# -eq 0 ]];then
   # no script on command line
   quit error "ERROR fetching script from command line."
fi

# this assigns the first command line argument as the script to execute
script=/home/daps/daps_support/bin/$1

# this causes the first command line argument to be removed from the list of arguments
shift

logname="$logdir/`basename $script .sh`.$timestamp.log"
if [[ $? -ne 0 ]];then
   quit error "ERROR determining logname in."
fi

# this line makes sure the log file is created, and empty
>$logname
if [[ $? -ne 0 ]];then
   quit error "ERROR creating $logname."
fi

# begin in earnest
line "INFO Executing $script with parms $@"
$script $@ > $logname  2>&1
if [[ $? -eq 0 ]];then
   quit success "INFO success executing $script with parms $@"
else
   quit error "ERROR unable to execute $script with parms $@"
fi
