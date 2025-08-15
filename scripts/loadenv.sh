#!/bin/bash
set -e

# defaults
uri=false
output=""
prefix=""

# parse options (from https://stackoverflow.com/a/28466267)
die() { echo "$*" >&2; exit 2; } # define function to STDERR and exit

while getopts o:p:-: OPT; do      # allow -p and -- "with arg"
    if [ "$OPT" = "-" ]; then     # long option: reformulate OPT and OPTARG
        OPT="${OPTARG%%=*}"       # extract long option name
        OPTARG="${OPTARG#"$OPT"}" # extract long option argument (may be empty)
        OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
    fi
    case "$OPT" in
        uri )          uri=true ;;
        p | prefix )   prefix="${OPTARG}" ;;
        o | output )   output="${OPTARG}" ;;
        \? )           exit 2 ;;  # bad short option (error reported via getopts)
        * )            die "Illegal option --$OPT" ;;            # bad long option
    esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list
OPTIND=0 # reset OPTIND variable

# check if prefix is valid
if [[ ! $prefix =~ ^[0-9a-zA-Z_]*$ ]]; then
    die "The prefix should be made os letters or '_'."
fi

env_variables=""
newline="
"

# load env variables
while read -r line; do
    if [[ $line =~ ^([0-9a-zA-Z_]+)\=(.+)$ ]]; then
        export ${prefix:+${prefix^^}_}${BASH_REMATCH[1]}=${BASH_REMATCH[2]}

        env_variables="${env_variables}${prefix:+${prefix^^}_}${BASH_REMATCH[1]}${newline}"

        if [[ $uri == true ]]; then
            uri_encoded="$(python3 -c "from urllib.parse import quote; print(quote('${BASH_REMATCH[2]}'))")"
            export ${prefix:+${prefix^^}_}${BASH_REMATCH[1]}_URIENCODED=${uri_encoded}
        fi
    fi
done

if [ -n "$output" ]; then
    export ${output}="$env_variables"
fi
