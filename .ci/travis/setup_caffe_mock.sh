#!/bin/bash
set -e # exit with nonzero exit code if anything fails

echo "Setup mock caffe...Begin"

if [[ -z "$DEPS_DIR" ]]; then
    # DEPS_DIR is destination directory
    echo "DEPS_DIR not set!"
fi;

ROOT_DIR=$TRAVIS_BUILD_DIR
if [[ -z "$ROOT_DIR" ]]; then
    echo "ROOT_DIR not set!"
    exit 1
fi;
    
# For mocking caffe
mkdir -p $CAFFE_ROOT/python/caffe
echo "Place mock caffe package"
mv $ROOT_DIR/.ci/travis/caffe_mock.py $CAFFE_ROOT/python/caffe/__init__.py

echo "Compile protobuf message definitions "
mkdir -p $CAFFE_ROOT/python/caffe/proto
protoc -I=$CAFFE_ROOT/src/caffe/proto --python_out=$CAFFE_ROOT/python/caffe/proto/ $CAFFE_ROOT/src/caffe/proto/caffe.proto

touch $CAFFE_ROOT/python/caffe/proto/__init__.py # enable import

echo "Setup mock caffe...Done"
