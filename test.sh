#! /bin/bash
set -exv -o pipefail

DOCKER_REGISTRY=${DOCKER_REGISTRY:-}
DOCKER_REGISTRY_ORG=${DOCKER_REGISTRY_ORG:-everpeace}
DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME:-docker-chainer}
TMP_KEY_DIR=${TMP_KEY_DIR:-./ssh-keys}
TEST_RETRY_MAX=${TEST_RETRY_MAX:-10}
TEST_RETRY_INTERVAL=${TEST_RETRY_INTERVAL:-3}

# creating temporary key paris
tmpdir=$(pwd)/tmp
mkdir -p $tmpdir/$TMP_KEY_DIR
set +e
yes | ssh-keygen -N "" -f $tmpdir/$TMP_KEY_DIR/id_rsa
set -e
cp $tmpdir/$TMP_KEY_DIR/id_rsa.pub $tmpdir/$TMP_KEY_DIR/authorized_keys
cp -r $tmpdir/$TMP_KEY_DIR $tmpdir/$TMP_KEY_DIR.export
chmod 700 $tmpdir/$TMP_KEY_DIR
chmod 600 $tmpdir/$TMP_KEY_DIR/*

# download test script
mkdir -p $tmpdir/home
wget -O $tmpdir/home/train_mnist.py https://raw.githubusercontent.com/chainer/chainer/master/examples/mnist/train_mnist.py

# building image
now=$(date "+%s")
docker build . -t $DOCKER_REGISTRY$DOCKER_REGISTRY_ORG/$DOCKER_IMAGE_NAME:test$now

# booting base image
ret=1
set +e
docker run -d --rm \
  --name docker-chainer_test$now \
  -p 2222:22 \
  -v $tmpdir/$TMP_KEY_DIR.export:/ssh-key/chainer \
  -v $tmpdir/home:/home/chainer \
  $DOCKER_REGISTRY$DOCKER_REGISTRY_ORG/$DOCKER_IMAGE_NAME:test$now

# test
for i in $(seq 1 10); do
  sleep 3;
  ssh -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      -i $tmpdir/$TMP_KEY_DIR/id_rsa \
      -p 2222 \
      chainer@localhost \
      python3 train_mnist.py -e 2;
  ret=$?;
  if [ $ret == 0 ]; then break; fi;
done

docker rm -f docker-chainer_test$now
docker rimi $DOCKER_REGISTRY$DOCKER_REGISTRY_ORG/$DOCKER_IMAGE_NAME:test$now
rm -rf $tmpdir/$TMP_KEY_DIR
set -e
exit $ret
