#!/bin/bash
COCOS_ROOT_DIR=$(cd "$(dirname $0)" && pwd)
cd $COCOS_ROOT_DIR

echo -e "\033[33mCOCOS_ROOT_DIR\033[0m"
pwd
echo ""

function buildIOS()
{
    echo -e "\033[33mBuild for iOS\033[0m"

    if [ "$PROJECT_LANG" == "cpp" ]; then
        PROJECT_ROOT_DIR=proj.ios_mac
    else
        PROJECT_ROOT_DIR=frameworks/runtime-src/proj.ios_mac
    fi

    xcodebuild -target ${PROJECT_NAME}_${PROJECT_LANG}-mobile \
        -configuration Debug \
        -project ${PROJECT_ROOT_DIR}/${PROJECT_NAME}_${PROJECT_LANG}.xcodeproj
}

function runIOS()
{
    echo -e "\033[33mInstall and run on iOS device\033[0m"

    if [ "$PROJECT_LANG" == "cpp" ]; then
        PROJECT_ROOT_DIR=proj.ios_mac
    else
        PROJECT_ROOT_DIR=frameworks/runtime-src/proj.ios_mac
    fi

    ios-deploy --noninteractive --debug \
        --bundle ${PROJECT_ROOT_DIR}/build/Debug-iphoneos/${PROJECT_NAME}_${PROJECT_LANG}-mobile.app
}

function buildAndroid()
{
    echo -e "\033[33mBuild for iOS\033[0m"

    cocos compile -m debug -p android

    echo ""
    echo ""

    ls -l bin/debug/android

    echo ""
    echo ""
}

function runAndroid()
{
    echo -e "\033[33mInstall and run on Android device\033[0m"

    # adb wait-for-device
    adb install -rtdg bin/debug/android/${PROJECT_NAME}-debug.apk

    echo ""
    echo ""

    PACKAGE_NAME=com.sdkbox.sample.${PROJECT_NAME}.${PROJECT_LANG}
    adb shell am start -n ${PACKAGE_NAME}/org.cocos2dx.cpp.AppActivity |
    {
        ERROR=0
        while read line
        do
            echo $line
            if [[ "$line" =~ "Error" ]]; then
                ERROR=1
            fi
        done
        if [ $ERROR != 0 ]; then
            exit
        fi
    }

    echo ""
    echo -e "\033[33mCheck log ...\033[0m"
    echo ""

    adb shell ps | grep ${PACKAGE_NAME} |
    {
        while read line
        do
            set $line
        done

        PID=$2
        if [ "$PID" != "" ]; then
            adb logcat | grep "\(${PID}\)"
        fi
    }
}

function help()
{
    echo "run_sample.sh PLATFORM PROJECT_NAME PROJECT_LANG"
    echo ""
    echo "examples:"
    echo "    run_sample.sh ios facebook lua"
    echo "    run_sample.sh android facebook cpp"
    echo ""
}

# init

if [ "$3" == "" ]; then
    help
    exit
fi

PLATFORM=$1
PROJECT_NAME=$2
PROJECT_LANG=$3

cd ..

WORKING_DIR=`pwd`
echo -e "\033[33mWORKING_DIR\033[0m"
echo $WORKING_DIR
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

if [ "$PLATFORM" == "ios" ]; then
    buildIOS
    runIOS
elif [ "$PLATFORM" == "android" ]; then
    buildAndroid
    runAndroid
fi
