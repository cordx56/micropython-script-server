#!/bin/bash -e

USAGE="Usage: deploy.sh [--dry-run] remote_address [base_dir]"

while [[ -n ${1} && ${1} =~ ^- ]]
do
  case ${1} in
    "--dry-run" ) DRY_RUN=1 ;;
  esac
  shift
done

if [ -z ${1} ]; then
  echo $USAGE
  exit 1
fi

SCRIPT_DIR=$(cd $(dirname $0); pwd)
if [ -z ${2} ]; then
  BASE_DIR_ABS_PATH=$SCRIPT_DIR/src
else
  BASE_DIR_ABS_PATH=$(cd ${2}; pwd)
fi

echo -n "Cleanup..."
if [ -z $DRY_RUN ]; then
  curl -X POST "http://${1}:9000/cleanup"
fi
echo ""

FILE_LIST=$(find $BASE_DIR_ABS_PATH -type f | sed -E "s/^.{$((${#BASE_DIR_ABS_PATH} + 1))}(.*)/\1/")
for v in $FILE_LIST
do
  echo -n "Send ${v}..."
  if [ -z $DRY_RUN ]; then
    $SCRIPT_DIR/deploy_file.sh ${1} $BASE_DIR_ABS_PATH/${v} ${v}
  else
    echo ""
  fi
done

echo -n "Reset..."
if [ -z $DRY_RUN ]; then
  $SCRIPT_DIR/reset.sh ${1}
else
  echo ""
fi
