#!/bin/bash
set -e
start=$(date +%s)
#trap "set +x; sleep 1; set -x" DEBUG
#export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin/"
#IP_REGEX='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'

####-----Functions-------------------------------------------------------------

usage() { 
    printf "%b" "    Usage: $0

    This script executes the overcloud deployment with all base parameters.  It only takes one parameter, <depName>

    Pre-Requisites:
    To run this you will need to have installed the following packages;
        - bc [sudo apt-get install bc]
        - OpenStack python command line [see: https://docs.openstack.org/newton/user-guide/common/cli-install-openstack-command-line-clients.html]
    "$IRed"Note:\033[0m Please be careful of the parameter construction, it must match exactly to work...
    Example: /home/stack/rhosp-post-install.sh stackrcfile=/home/stack/stackrc overcloudrcfile=/home/stack/thomas14rc imagedir=/home/stack/vm_images

    Parameters:
    "$IYellow"depName=\033[0m<The Deployment Name you want to use example: [overcloud01]>
    \n"
    exit 1
}

doLog() {
    # ------------------------------------------------------------------------------
    # MAKE SURE TO TAKE A LOG FILE AS A PARAMETER
    # echo pass params and print them to a log file and terminal
    # with timestamp and $host_name and $0 PID
    # usage:
    # doLog "INFO INFO some info message"
    # doLog "INFO DEBUG some debug message"
    # doLog "INFO WARN some warning message"
    # doLog "INFO ERROR some really ERROR message"
    # doLog "INFO FATAL some really fatal message"
    # ------------------------------------------------------------------------------
    type_of_msg=$(echo $*|cut -d" " -f1)
    msg=$(echo "$*"|cut -d" " -f2-)
    [[ $type_of_msg == DEBUG ]] && [[ $do_print_debug_msgs -ne 1 ]] && return
    [[ $type_of_msg == INFO ]] && type_of_msg="INFO" # one space for aligning
    [[ $type_of_msg == WARN ]] && type_of_msg="WARN" # as well

    # print to the terminal if we have one
    if [[ $type_of_msg == "INFO" ]]; then
        test -t 1 && echo -e "${IYellow}[$type_of_msg] `date "+%Y.%m.%d-%H:%M:%S %Z"` ${msg}\033[0m"
    elif [[ $type_of_msg == "WARN" ]]; then
        test -t 1 && echo -e "${IRed}[$type_of_msg] `date "+%Y.%m.%d-%H:%M:%S %Z"` ${msg}\033[0m"
    else
        test -t 1 && echo -e "${IGreen}[$type_of_msg] `date "+%Y.%m.%d-%H:%M:%S %Z"` ${msg}\033[0m"
    fi
    # define default log file none specified in cnf file
    #test -z $log_file && mkdir -p $product_instance_dir/dat/log/bash && log_file="$product_instance_dir/dat/log/bash/$run_unit.`date "+%Y%m"`.log"
    echo " [$type_of_msg] `date "+%Y.%m.%d-%H:%M:%S %Z"` ""$msg" >> $log_file
}

noLog() {
    # ------------------------------------------------------------------------------
    # echo pass params and print them to a log file and terminal
    # with timestamp and $host_name and $0 PID
    # usage:
    # doLog "INFO INFO some info message"
    # doLog "INFO DEBUG some debug message"
    # doLog "INFO WARN some warning message"
    # doLog "INFO ERROR some really ERROR message"
    # doLog "INFO FATAL some really fatal message"
    # ------------------------------------------------------------------------------
    type_of_msg=$(echo $*|cut -d" " -f1)
    msg=$(echo "$*"|cut -d" " -f2-)
    [[ $type_of_msg == DEBUG ]] && [[ $do_print_debug_msgs -ne 1 ]] && return
    [[ $type_of_msg == INFO ]] && type_of_msg="INFO" # one space for aligning
    [[ $type_of_msg == WARN ]] && type_of_msg="WARN" # as well

    # print to the terminal if we have one
    if [[ $type_of_msg == "INFO" ]]; then
        test -t 1 && echo -e "${IYellow}[$type_of_msg] `date "+%Y.%m.%d-%H:%M:%S %Z"` ${msg}\033[0m"
    elif [[ $type_of_msg == "WARN" ]]; then
        test -t 1 && echo -e "${IRed}[$type_of_msg] `date "+%Y.%m.%d-%H:%M:%S %Z"` ${msg}\033[0m"
    else
        test -t 1 && echo -e "${IGreen}[$type_of_msg] `date "+%Y.%m.%d-%H:%M:%S %Z"` ${msg}\033[0m"
    fi
    # define default log file none specified in cnf file
    #test -z $log_file && mkdir -p $product_instance_dir/dat/log/bash && log_file="$product_instance_dir/dat/log/bash/$run_unit.`date "+%Y%m"`.log"
    #echo " [$type_of_msg] `date "+%Y.%m.%d-%H:%M:%S %Z"` ""$msg"
}

spinner() {
    ## How to use:
    ## sleep 10 &
    ## spinner "$!"
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

version_gt() { 
    # ------------------------------------------------------------------------------
    # first_version=5.100.2
    # second_version=5.1.2
    # if version_gt $first_version $second_version; then
    #     echo "$first_version is greater than $second_version !"
    # fi
    # ------------------------------------------------------------------------------
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; 
}

getJsonVal() {
   python -c "import sys, json; print json.load(sys.stdin)$1";   
}

preReqs() {
    result=$(( bc --version ) 2>&1)

    if [[ $result == *"The program"* ]]; then
        doLog "WARN bc is not installed..."
        echo "Do you want me to install it? [Y/n]"
        read yn
        if [[ $yn = Y || y ]]; then
            sudo apt install bc -yn
        else
            doLog "WARN Exiting Script"
            doLog "WARN The program bc must be installed to use this script."
            exit 101
        fi
    fi

    result=$(( openstack --version ) 2>&1)

    if [[ $result == *"The program"* ]]; then
        doLog "WARN Python OpenStackClient is not installed..."
        echo "Do you want me to install it? [Y/n]"
        read yn
        if [[ $yn = Y || y ]]; then
            sudo apt install python3-openstackclient -yn
        else
            doLog "WARN Exiting Script"
            doLog "WARN The program python openstackclient must be installed to use this script."
            exit 101
        fi
    fi
}

colors() {
    # Text Colors:
    # Use echo -e "${RED}<text>"
    # Reset'\033[0m'       # Text Reset

    # Regular Colors
    Black='\033[0;30m'        # Black
    Red='\033[0;31m'          # Red
    Green='\033[0;32m'        # Green
    Yellow='\033[0;33m'       # Yellow
    Blue='\033[0;34m'         # Blue
    Purple='\033[0;35m'       # Purple
    Cyan='\033[0;36m'         # Cyan
    White='\033[0;37m'        # White

    # Bold
    BBlack='\033[1;30m'       # Black
    BRed='\033[1;31m'         # Red
    BGreen='\033[1;32m'       # Green
    BYellow='\033[1;33m'      # Yellow
    BBlue='\033[1;34m'        # Blue
    BPurple='\033[1;35m'      # Purple
    BCyan='\033[1;36m'        # Cyan
    BWhite='\033[1;37m'       # White

    # Underline
    UBlack='\033[4;30m'       # Black
    URed='\033[4;31m'         # Red
    UGreen='\033[4;32m'       # Green
    UYellow='\033[4;33m'      # Yellow
    UBlue='\033[4;34m'        # Blue
    UPurple='\033[4;35m'      # Purple
    UCyan='\033[4;36m'        # Cyan
    UWhite='\033[4;37m'       # White

    # Background
    On_Black='\033[40m'       # Black
    On_Red='\033[41m'         # Red
    On_Green='\033[42m'       # Green
    On_Yellow='\033[43m'      # Yellow
    On_Blue='\033[44m'        # Blue
    On_Purple='\033[45m'      # Purple
    On_Cyan='\033[46m'        # Cyan
    On_White='\033[47m'       # White

    # High Intensity
    IBlack='\033[0;90m'       # Black
    IRed='\033[0;91m'         # Red
    IGreen='\033[0;92m'       # Green
    IYellow='\033[0;93m'      # Yellow
    IBlue='\033[0;94m'        # Blue
    IPurple='\033[0;95m'      # Purple
    ICyan='\033[0;96m'        # Cyan
    IWhite='\033[0;97m'       # White

    # Bold High Intensity
    BIBlack='\033[1;90m'      # Black
    BIRed='\033[1;91m'        # Red
    BIGreen='\033[1;92m'      # Green
    BIYellow='\033[1;93m'     # Yellow
    BIBlue='\033[1;94m'       # Blue
    BIPurple='\033[1;95m'     # Purple
    BICyan='\033[1;96m'       # Cyan
    BIWhite='\033[1;97m'      # White

    # High Intensity backgrounds
    On_IBlack='\033[0;100m'   # Black
    On_IRed='\033[0;101m'     # Red
    On_IGreen='\033[0;102m'   # Green
    On_IYellow='\033[0;103m'  # Yellow
    On_IBlue='\033[0;104m'    # Blue
    On_IPurple='\033[0;105m'  # Purple
    On_ICyan='\033[0;106m'    # Cyan
    On_IWhite='\033[0;107m'   # White
}

## Call the colors() function
colors

## Uncomment if we are taking parameters into the script
if [ "$#" -eq "0" ]; then
  usage
else
    while [[ "$#" > "0" ]]
    do
        case $1 in
            (*=*) eval $1;;
        esac
    shift
    done
    if [ -z "$depName" ]; then
        usage
    fi
fi

## Uncomment to output all parameters to a log file
noLog "INFO ""
    depName         $depName"

####-----End Of Functions------------------------------------------------------

####-----Put Code Below Here---------------------------------------------------

preReqs

noLog "INFO -------------------------------------------------------------"
noLog "INFO Pre-requisites installed..."
noLog "INFO -------------------------------------------------------------"

noLog "INFO -------------------------------------------------------------"
noLog "INFO Starting OverCloud Deployment or Update..."
noLog "INFO -------------------------------------------------------------"

openstack overcloud deploy \
    --answers-file /home/stack/templates/answers.yaml \
    -r /home/stack/templates/my_roles_data.yaml \
    -n /home/stack/templates/network_data.yaml \
    --stack ${depName} \
    --ntp-server "time.google.com" \
    --libvirt-type qemu \
    --deployed-server \
    --disable-validations \
    --overcloud-ssh-user stack \
    --overcloud-ssh-key /home/stack/.ssh/id_rsa \
    2>&1 | tee ${depName}_install.log

## Exiting
end=$(date +%s)
## Use the preReqs() function to make sure bc is installed 
seconds=$(echo "$end - $start" | bc)
formattedSec=$(awk -v t=$seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}')
noLog "INFO -------------------------------------------------------------"
noLog "INFO Exiting OverCloud Deployment ${depName} in $formattedSec..."
noLog "INFO -------------------------------------------------------------"
noLog "INFO -------------------------------------------------------------"
noLog "INFO You can find the log file ${depName}_install.log in your home directory."
noLog "INFO -------------------------------------------------------------"
exit 0