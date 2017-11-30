#!/bin/bash
#
# DNS Nameserver Test
#   Core Test: By PeZa https://serverfault.com/users/236284/peza)
#                      https://serverfault.com/questions/91063/how-do-i-benchmark-performance-of-external-dns-lookups
#   Everything else: by eakhawkeye



#############
# Variables #
#############
myscript=$( basename "$0" )
verbose=false
quiet=false
site="google.com"
IPfile="$1"
typeset iterations=20
unset ary_ns



#############
# Functions #
#############
function help_me() {
    # Output help info
    echo -e "  Usage: ${myscript} [-n|-f] [-t] [-i]"
    echo -e "\t[--name    |-n]\t\"Nameserver\""
    echo -e "\t[--file    |-f]\t\"Nameservers File (line separated)\""
    echo -e "\t[--site    |-s]\t\"Site name to resolve\""
    echo -e "\t[--iter    |-i]\t\"Number of tests per nameserver\""
    echo -e "\t[--quiet   |-q]\t\"Quiet the live output (for automation)\""
    echo -e "\t[--verbose |-v]\t\"Show verbose information\""
    echo -e "\n\tDefault Values: (if missing any parameter)"
    echo -e "\t  File:    /etc/resolv.conf"
    echo -e "\t  Target:  www.google.com"
    echo -e "\t  Iter:    20\n"
}

function does_exist() {
    # Check if a file exists
    local my_file=${1}
    if ! [ -f ${my_file} ]; then echo "ERROR: Missing ${my_file}. Exiting."; exit 3; fi
}

function from_resolv() {
    # Get the nameservers from /etc/resolv.conf
    local resolv="/etc/resolv.conf"
    local rtrn=1
    if [ -e ${resolv} ]; then 
        awk '$1=="nameserver" {print $2}' ${resolv}
    else
        echo "  Failed to load ${resolv}. Exiting"
    fi
}

function from_file() {
    # Expand a hostfile
    local h_file=${1}
    /bin/cat ${h_file}
}

function dns_test() {
    # Pass: array_of_nameservers, site, iteration amount, verbosity, quiet
    declare -a ary_ns=${!1}
    local site=${2}
    local iter=${3}
    local verb=${4}
    local quiet=${5}
    local vmax=10
    local i vi
    typeset -i i vi

    # ServerFault - Test and Store the results
    while [[ $i -lt ${iter} ]]; do
        ((i++))
        for IP in ${ary_ns[@]}; do
            if ! ${quiet}; then echo -en "Test: ${i}     \r"; fi
            time=`dig @$IP $site| awk '/Query time:/ {print " "$4}'`
            IPtrans=`echo $IP|tr \. _`
            eval `echo result$IPtrans=\"\\$result$IPtrans$time\"`
        done
    done

    # Verbose Output - Cycle through displaying each response time in a grid
    if ${verb}; then
        for IP in ${ary_ns[@]}; do
            local IPtrans=`echo $IP|tr \. _`
            vi=1; printf "%-25s" ${IP}":";
            for ms in $(echo -e `eval "echo \\$result$IPtrans"`); do
                # Start a new line if the max width is reached
                if [[ vi -gt ${vmax} ]]; then printf "\n%30s" ${ms}; vi=2; continue; fi
                printf "%5s" ${ms}; ((vi++))
            done; echo; echo
        done; echo
    fi

    # ServerFault - Determine status (min/max/avg) for each NS and display
    printf "%-20s %5s %5s %5s %4s %6s\n" "_Nameserver" "_avg" "_min" "_max" "(ms)" "_#resp"
    for IP in ${ary_ns[@]}; do
        local IPtrans=`echo $IP|tr \. _`
        printf "%-20s " $IP
        echo -e `eval "echo \\$result$IPtrans"`\
         | tr ' ' "\n" \
         | awk '/.+/ {  
                        rt=$1;
                        rec=rec+1; 
                        total=total+rt; 
                        if (minn>rt || minn==0) {minn=rt}; 
                        if (maxx<rt) {maxx=rt}; 
                     }
                END  { 
                        if (rec==0) {ave=0} else {ave=total/rec};
                        printf "%5i %5i %5i %11i\n", ave,minn,maxx,rec 
                     }'
    done

    return 0
}



#########
# Logic #
#########
# Process the user's input
while ! [ "${1}x" == "x" ] ; do
    case "${1}" in
        "--name*"|"-n" ) ary_ns+=( ${2} ); shift;;
        "--file"|"-f") h_file=${2}; does_exist ${h_file}; ary_ns+=( $(from_file ${h_file}) ); shift;;
        "--site"|"-s" ) site=${2}; shift;;
        "--iter"|"-i" ) iterations=${2}; shift;;
        "--quite"|"-q") quiet=true;;
        "--verbose"|"-v") verbose=true;;
        * ) help_me; exit 2;;
    esac
    shift
done

# If no nameservers then use /etc/resolve.conf
if [[ ${#ary_ns[@]} -eq 0 ]]; then ary_ns+=( $(from_resolv) ); fi

# Run the tests
dns_test ary_ns[@] ${site} ${iterations} ${verbose} ${quiet}

exit $?