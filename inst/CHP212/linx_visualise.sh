#!/usr/bin/env bash
set -euo pipefail

# Developer Variables
dependencies=("docker")
version="0.0.1"
FORMATTED_TEXT_ENABLED=true
verbose=false
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


#Colours
c_normal="\e[0m"
c_bold="\e[1m"
c_red="\e[31m"
c_green="\e[32m"
c_cyan="\e[96"
c_magenta="\e[35m"
c_underlined="\e[4m"
c_yellow="\e[33m"
c_line="--------------------------------------------"


# Echo
function echoerr() {
    echo -e "$@" >&2
}


function echoerrformatted() {
    if $FORMATTED_TEXT_ENABLED; then
        echoerr "$1${@:2}$c_normal"
    else
        echoerr "${@:2}"
    fi
}

function echoerrfail() {
    echoerrformatted $c_bold$c_red "$@"
}

function echoerrwarning() {
    echoerrformatted $c_yellow "$@"
}

function echoerrsuccess() {
    echoerrformatted $c_green "$@"
}

#Test Dependencies
function test_dependencies() {
    failed=false
    for dependency in $@; do

        if which $dependency > /dev/null; then
            if "$verbose"; then
                echoerr "Testing Dependencies: "
                echoerr " $dependency"
                echoerrsuccess "    > $(which $dependency)"
            fi
        else
            echoerr "Testing Dependencies: "
            echoerr " $dependency"
            echoerrfail "   > MISSING"
            failed=true
        fi
    done

    if $failed; then
        echoerrformatted $c_bold$c_red "\nplease install missing dependencies"
        exit 1
    elif $verbose; then
        echoerr ""
    fi
}

# Usage
function usage() {
    echoerr "$0 <sampleId> <clusterId>"
    echoerr " -l | --linx_directory     )  directory containing files generated by linx"
    echoerr " -v | --version    )   print version"
    echoerr " -h | --help       )   print this help message"


    exit 1
}


# If zero arguments are supplied, print usage
if [ "$#" == "0" ]; then
	usage
fi


#Parse Arguments
positional_arg="NA"
positional_arg2="NA"
linx_directory="/Users/selkamand/garage/ecDNA/data/all_linx_output"
while (("$#")); do
    case $1 in
        -h | --help)
            usage
            exit
            ;;
        -v | --version)
            echoerr "Version: $version"
            exit
            ;;
        -l | --linx_directory)
            shift
            linx_directory=$1
            ;;
        *)
            if [ "$positional_arg" = "NA" ]; then
                positional_arg=$1
            elif [ "$positional_arg2"="NA" ]; then
                positional_arg2=$1
            else
                echoerrfail "Wrong number of positional arguments\n"
                usage
            fi
            ;;
    esac
    shift
done

#Test dependencies
test_dependencies ${dependencies[@]}

#Options for qc
#Ensure postitional argument is supplied
if [ $positional_arg == "NA" ]; then
    echoerrfail "Must supply a positional argument"
    exit 1
fi

if [ $positional_arg2 == "NA" ]; then
    echoerrfail "Must supply a second positional argument"
    exit 1
fi

[ -d $linx_directory ] || { echoerrfail "could not find linx directory: $linx_directory"; exit 1; }

docker run -it -v $linx_directory:/app/mounted "linx_visualiser:v0.0.1" linx_visualise.sh $positional_arg $positional_arg2

echoerrsuccess "If successfull the visualisation will be in $linx_directory/vis_plot"
