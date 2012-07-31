#!/bin/bash

case "$1" in
  "marionette")
    SUITE="marionette"
    ;;
  "xpcshell")
    SUITE="xpcshell"
    ;;
  *)
    echo "Usage: $0 (test_suite)"
    echo "Valid test suites:"
    echo "- marionette"
    echo "- xpcshell"
    exit 1
    ;;
esac

# ditch the suite arg
shift

. setup.sh

# Determine the absolute path of our location.
B2G_HOME=$(cd `dirname $0`; pwd)

# Use default Gecko location if it's not provided in .config.
if [ -z $GECKO_PATH ]; then
  GECKO_PATH=$B2G_HOME/gecko
fi

# Run standard set of tests by default. Command line arguments can be
# specified to run specific tests (an individual test file, a directory,
# or an .ini file).
#
case $SUITE in
  "marionette")
    TEST_PATH=$GECKO_PATH/testing/marionette/client/marionette/tests/unit-tests.ini
    FLAGS=" --homedir=$B2G_HOME --type=b2g"
    SCRIPT=$GECKO_PATH/testing/marionette/client/marionette/venv_test.sh
    ;;
  "xpcshell")
    TEST_PATH=$B2G_HOME/objdir-gecko/_tests/xpcshell/
    FLAGS=" --b2gpath=$B2G_HOME"
    export MARIONETTE_HOME=$GECKO_PATH/testing/marionette/client
    export XPCSHELLTEST_HOME=$GECKO_PATH/testing/xpcshell
    SCRIPT=$GECKO_PATH/testing/xpcshell/b2g_xpcshell_venv.sh
    ;;
  *)
    exit 1
esac

USE_EMULATOR=yes

# Allow other arguments to override the default --emulator argument
while [ $# -gt 0 ]; do
  case "$1" in
    --address=*|--emulator=*)
      FLAGS+=" $1"
      USE_EMULATOR=no ;;
    --*)
      FLAGS+=" $1" ;;
    *)
      TESTS+=" $1" ;;
  esac
  shift
done

if [ "$USE_EMULATOR" = "yes" ]; then
  if [ "$DEVICE" = "generic_x86" ]; then
    ARCH=x86
  else
    ARCH=arm
  fi
  FLAGS+=" --emulator=$ARCH"
fi

TESTS=${TESTS:-$TEST_PATH}

echo "Running tests: $TESTS"

PYTHON=`which python`

echo bash $SCRIPT "$PYTHON" $FLAGS $TESTS
bash $SCRIPT "$PYTHON" $FLAGS $TESTS
