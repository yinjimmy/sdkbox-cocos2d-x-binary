#!/bin/bash
CUR_DIR=$(cd "$(dirname $0)" && pwd)
source "$CUR_DIR"/sample_func.sh

function help()
{
    echo "run_sample.sh PROJECT_NAME PROJECT_LANG PLATFORM [PACKAGE_NAME]"
    echo ""
    echo "examples:"
    echo "    run_sample.sh facebook lua ios"
    echo "    run_sample.sh facebook cpp android"
    echo ""
}

# init

if [ "$3" == "" ]; then
    help
    exit
fi

PROJECT_NAME=$1
PROJECT_LANG=$2
PLATFORM=$3

PACKAGE_NAME=
UPDATE=

if [ "$4" == "--update" ]; then
    UPDATE='--update'
elif [ "$4" == "--update-staging" ]; then
    UPDATE='--update-staging'
else
    PACKAGE_NAME="$4"
fi

echo ""

SAMPLE_ROOT_DIR=${WORKING_DIR}/sdkbox-sample-${PROJECT_NAME}

if [ ! -d "$SAMPLE_ROOT_DIR" ]; then
    echo "ERR: not found sample dir $SAMPLE_ROOT_DIR"
    echo ""
    help
    exit
fi

cd $SAMPLE_ROOT_DIR

if [ ! -d "$PROJECT_LANG" ]; then
    echo "ERR: not found sample project dir ${SAMPLE_ROOT_DIR}/${PROJECT_LANG}"
    echo ""
    help
    exit
fi

echo -e "\033[33mSAMPLE_ROOT_DIR\033[0m"
pwd

cd $PROJECT_LANG
pwd
echo ""

if [ "$UPDATE" == "--update" ]; then
    cleanupSample
    updateSample
fi

if [ "$UPDATE" == "--update-staging" ]; then
    cleanupSample
    updateStagingSample
fi

if [ "$PLATFORM" == "ios" ]; then
    buildIOS
    runIOS
elif [ "$PLATFORM" == "android" ]; then
    buildAndroid
    runAndroid
fi
