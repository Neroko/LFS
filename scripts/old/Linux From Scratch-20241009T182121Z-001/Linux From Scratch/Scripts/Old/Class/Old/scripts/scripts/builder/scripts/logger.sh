#!/bin/bash

if [ ! -d "$LFS_LOG_PATH" ]; then
  mkdir $LFS_LOG_PATH
fi

# Install Logger
function SCRIPTENTRY_INSTALL() {
  timeAndDate=`date`
  script_name=`basename "$0"`
  script_name="${script_name%.*}"
  echo "[$timeAndDate] [DEBUG]  > $script_name $FUNCNAME" >> $LOG_INSTALL
}

function SCRIPTEXIT_INSTALL() {
  script_name=`basename "$0"`
  script_name="${script_name%.*}"
  echo "[$timeAndDate] [DEBUG]  < $script_name $FUNCNAME" >> $LOG_INSTALL
}

function ENTRY_INSTALL() {
  local cfn="${FUNCNAME[1]}"
  timeAndDate=`date`
  echo "[$timeAndDate] [DEBUG]  > $cfn $FUNCNAME" >> $LOG_INSTALL
}

function EXIT_INSTALL() {
  local cfn="${FUNCNAME[1]}"
  timeAndDate=`date`
  echo "[$timeAndDate] [DEBUG]  < $cfn $FUNCNAME" >> $LOG_INSTALL
}

function INFO_INSTALL() {
  local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [INFO]  $msg" >> $LOG_INSTALL
}

function DEBUG_INSTALL() {
  local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [DEBUG]  $msg" >> $LOG_INSTALL
}

function ERROR_INSTALL() {
  local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [ERROR]  $msg" >> $LOG_INSTALL
}

# Package Logger
function SCRIPTENTRY() {
  timeAndDate=`date`
  script_name=`basename "$0"`
  script_name="${script_name%.*}"
  echo "[$timeAndDate] [DEBUG]  > $script_name $FUNCNAME" >> $LOG
}

function SCRIPTEXIT() {
  script_name=`basename "$0"`
  script_name="${script_name%.*}"
  echo "[$timeAndDate] [DEBUG]  < $script_name $FUNCNAME" >> $LOG
}

function ENTRY() {
  local cfn="${FUNCNAME[1]}"
  timeAndDate=`date`
  echo "[$timeAndDate] [DEBUG]  > $cfn $FUNCNAME" >> $LOG
}

function EXIT() {
  local cfn="${FUNCNAME[1]}"
  timeAndDate=`date`
  echo "[$timeAndDate] [DEBUG]  < $cfn $FUNCNAME" >> $LOG
}

function INFO() {
  local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [INFO]  $msg" >> $LOG
}

function DEBUG() {
  local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [DEBUG]  $msg" >> $LOG
}

function ERROR() {
  local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [ERROR]  $msg" >> $LOG
}
