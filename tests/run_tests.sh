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
export PYTHONPATH=$ROOT_DIR:$ROOT_DIR/tests

django_test() {
    TEST="django-admin.py test --settings=testapp.$1"
    $TEST 2>&1 | grep 'Ran 1 test' > /dev/null
    if [ $? -gt 0 ]
    then
        echo FAIL: $2
        $TEST
        exit 1;
    else
        echo PASS: $2
    fi

    # Check that we're hijacking the help correctly.
    $TEST --help 2>&1 | grep 'NOSE_DETAILED_ERRORS' > /dev/null
    if [ $? -gt 0 ]
    then
        echo FAIL: $2 '(--help)'
        exit 1;
    else
        echo PASS: $2 '(--help)'
    fi
}

set +e
django_test 'settings' 'normal settings'
django_test 'settings_with_south' 'with south in installed apps'
django_test 'settings_old_style' 'django_nose.run_tests format'

