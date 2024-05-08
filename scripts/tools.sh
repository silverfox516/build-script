#!/bin/bash

#[ -n "${SCRIPTS_TOOLS}" ] && return; SCRIPTS_TOOLS=0; # pragma once

function bs_fatal()
{
    echo -e "${COLORS[lightred]}'ctrl + c' to quit${COLORS[nc]}, $@"
    while [ 1 ]; do sleep 5; done
}

function bs_wrapper()
{
    if [ "${DEBUG}" == "true" ]; then
        echo $@
        return
    fi

    eval "$@"
    if [ $? -eq 0 ]; then return; fi

    bs_fatal "failed $@"
}

function bs_is_array()
{
    local res=$(declare -p $1 2>&1)
    [[ "$res" =~ (declare -a) ]]
}

function bs_is_declared()
{
    local res=$(declare -p $1 2>&1)
    [[ ! "$res" =~ "not found" ]]
}

function bs_is_dir()
{
    [[ -d $1 ]]
}

# ITEMS=(tiger monkey eagle)
# bs_select_one_from_array ITEMS
# echo $ITEMS
function bs_select_one_from_array()
{
    local -n options=$1

    if ! bs_is_array $1; then return; fi

    #clear
    echo "Pick a item for $1"
    local i=1
    local choice
    for choice in ${options[@]}; do
        echo "    $i. $choice"
        i=$(($i+1))
    done
    echo -n "Which would you select? "
    read answer

    local selection=
    if [ -z "$answer" ]; then
        exit 1
    elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$"); then
        if [ $answer -le ${#options[@]} ]; then
            selection=${options[$(($answer-1))]}
        fi
    else
        selection=$answer
    fi

    unset options
    options=$selection
}

# some_path/some_file
#   ANIMAL=dog
#   FRUITS=(apple grape)
# FILE=some_path/some_file
# bs_parse_vars_in_file VARS FILE
# echo $VARS
function bs_parse_vars_in_file()
{
    local -n var_list=$1
    local -n file=$2

    var_list=""

    while read line; do
        if [[ ! ${line} =~ .+=+ ]]; then continue; fi

        local key=$(echo ${line} | cut -d"=" -f 1)
        local value=$(echo ${line} | cut -d"=" -f 2)

        var_list="${var_list} $key"
        eval ${key}=${value}
    done < ${file}
}

# echo $VARS
#   ANIMAL FRUITS
# bs_select_one_from_each_array_in_list VARS
# echo FRUITS
function bs_select_one_from_each_array_in_list()
{
    local -n var_list=$1

    for var in ${var_list}; do
        if ! bs_is_array ${var}; then continue; fi

        bs_select_one_from_array ${var}
    done
}
