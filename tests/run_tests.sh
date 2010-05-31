#!/bin/bash

SCRIPT_DIR=`dirname $0`
ROOT_DIR=`cd $SCRIPT_DIR/.. && pwd`

ENVSPEC=`stat -c %Y $ROOT_DIR/tests/environment.pip`
ENVTIME=`test -d $ROOT_DIR/.ve && stat -c %Y $ROOT_DIR/.ve`

set -e

cd $ROOT_DIR
if [ $ENVSPEC -gt 0$ENVTIME ]; then
    # Setup environment
    virtualenv --no-site-packages $ROOT_DIR/.ve
    source $ROOT_DIR/.ve/bin/activate
    pip install -r $ROOT_DIR/tests/environment.pip
    touch $ROOT_DIR/.ve
else
    source $ROOT_DIR/.ve/bin/activate
fi

# pylint
pylint --rcfile=$ROOT_DIR/.pylintrc django_nose > pylint.out || echo 'PyLint done'
tail -n5 pylint.out

# existing tests
cd $ROOT_DIR/tests
./runtests.sh
