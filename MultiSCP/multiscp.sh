#!/bin/bash
#
# By EakHawkEye
#
# MultiSCP - use to send files in parallel to multiple systems.

#############
# Variables #
#############
max_conn=100
timeout_conn=10
data_file=
host_file=

#############
# Functions #
#############
function transfer_files()
{
    # Transfer the files to the brokers
    local my_file=${1}
    local host_list=${2}
    local max_connections=${3}
    local timeout_conn=${4}
    local scp_options=${5}
    local processes=()
    host_count=$(/usr/bin/cat ${host_list} \
               | /usr/bin/grep -v "^#" \
               | /usr/bin/wc -l)

    # Iterate through all the hostnames in the file
    for my_host in $(/usr/bin/cat ${host_list} 
                   | /usr/bin/grep -v "^#" \
                   | /usr/bin/cut -d' ' -f1); do 

        # Copy the files and add the queue the PID
        /usr/bin/scp ${scp_options} \
            -o StrictHostKeyChecking=no \
            -o ConnectTimeout=${timeout_conn} \
            -q ${my_file} ${my_host}:. &
        processes+=( $! )

        # When queue is full, wait for a spot to open
        while [ ${#processes[@]} -ge ${max_connections} ]; do
            echo -en "    Remaining copies: ${host_count}    \r"
            /usr/bin/wait ${processes[0]};
            unset processes[0]
            processes=( ${processes[@]} )
            ((host_count--))
        done

    done

    # Wait for remaining jobs to complete
    while [ ${#processes[@]} -gt 0 ]; do
        echo -en "    Remaining copies: ${host_count}    \r"
        /usr/bin/wait ${processes[0]};
        unset processes[0]
        processes=( ${processes[@]} )
        ((host_count--))
    done
    echo

    return 0
}

function usage()
{
    # [USER OUTPUT] Help
    echo -e "  Usage: $( basename $0 ) -h <target_hosts_file> -f <file_to_transfer> [options...]"
    echo -e "\n      Arguments:"
    echo -e "\t        -h         file of hostnames (1/line) | -h hosts/impacted.lst"
    echo -e "\t        -f         file to transfer           | -f auto-fix.sh"
    echo -e "        Options:"
    echo -e "\t        -m         max concurrent connections | -m 100"
    echo -e "\t        -t         connetion timeout (in sec) | -t 10"
    echo -e "\t        -o         ssh/scp options            | -o \"-P 44321 -o StrictHostKeyChecking=no\"\n"
    exit 2
}

#########
# Logic #
#########
# Pass a file of hostnames to the script
if [[ $# -lt 4 ]]; then usage; fi

# [INPUT PARSE] - Arguments
while [ "${1}" ]; do
    case "${1}" in
        "-h" | "--host"* ) host_file=${2}; shift ;;
        "-f" | "--file"* ) data_file=${2}; shift ;;
        "-m" | "--max"*  ) max_conn=${2}; shift ;;
        "-t" | "--time"* ) timeout_conn=${2}; shift ;;
        "-o" | "--ssho"* ) ssh_options=${2}; shift ;;
                       * ) echo "Option: '${1}' is unsupported"; usage;;
    esac
    shift
done

# Make sure the hostlist exists
if ! [ -e ${host_file} ]; then echo "  Missing ${host_file}"; exit 3; fi
if ! [ -e ${data_file} ]; then echo "  Missing ${data_file}"; exit 3; fi

# Process the hostlist
echo "  Transferring '${data_file}' to hosts in ${host_file}"
transfer_files "${data_file}" "${host_file}" ${max_conn} ${timeout_conn} "${ssh_options}"

exit 0