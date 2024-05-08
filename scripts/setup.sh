#!/bin/bash

source ${BS_DIR}/scripts/colors.sh
source ${BS_DIR}/scripts/tools.sh

# for usage
declare -A targets_info

# parse target description and generate a function runs commands in target
function bs_parse_targets() {
    local target_files=(`ls ${BS_DIR_TARGETS}`)

    for target in ${target_files[@]}; do
        source ${BS_DIR_TARGETS}/${target}

        # check var is defined in REQUIRED_VARS
        for var in ${REQUIRED_VARS[@]}; do
            if ! bs_is_declared ${var}; then
                bs_fatal "$var is required but not declared"
            fi
        done

        # generate target function
        local str_func="function ${BS_PRJ}_${target}() {"
        for key in ${!COMMANDS[@]}; do
            str_func="${str_func} echo -e \"${COLORS[lightcyan]}run${COLORS[nc]} ${COMMANDS[$key]}\";"
            str_func="${str_func} if [ '${DEBUG}' != "true" ]; then ${COMMANDS[$key]}; fi;"
        done
        str_func="${str_func} }"

        eval ${str_func}
        [ "${DEBUG}" == "true" ] && echo ${str_func}

        # set description for usage
        targets_info[${BS_PRJ}_${target}]=${DESC}

        # clear current target's variables
        unset DESC
        unset REQUIRED_VARS
        unset COMMANDS
    done
}

function bs_usage() {
    echo -e "${COLORS[lightcyan]}Available Targets:${COLORS[nc]}"
    for t in ${!targets_info[@]}; do
        echo -e "  ${COLORS[lightblue]}$t${COLORS[nc]}\n    : ${targets_info[$t]}"
    done
}

MODELS=(`ls $BS_DIR_MODELS`)
bs_select_one_from_array MODELS

MODEL_PATH=$BS_DIR_MODELS/$MODELS
if [ ! -f "$MODEL_PATH" ]; then bs_fatal "not exist $MODEL_PATH"; fi

bs_parse_vars_in_file MODEL_VARS MODEL_PATH
bs_select_one_from_each_array_in_list MODEL_VARS
bs_parse_targets
bs_usage
