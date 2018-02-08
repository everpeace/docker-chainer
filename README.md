[![Docker Build Status](https://img.shields.io/docker/build/jrottenberg/ffmpeg.svg)](https://hub.docker.com/r/everpeace/docker-chainer/) [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/everpeace/docker-chainer/latest.svg)](https://hub.docker.com/r/everpeace/docker-chainer/)

# docker-chainer

[DockeHub](https://hub.docker.com/r/everpeace/docker-chainer/)

All-in-one docker image for instant distributed machine learning based on:  

- [chainer](https://github.com/chainer/chainer/)
- [chainermn](https://github.com/chainer/chainermn/)
- [OpenMPI](https://www.open-mpi.org/)
- [cupy](https://github.com/cupy/cupy)
- [cuda](https://developer.nvidia.com/cuda-downloads)
- [cuDNN](https://developer.nvidia.com/cudnn)
- [NCCL2](https://developer.nvidia.com/nccl)

# Examples
## Single Node Mode
```
$ docker run --rm -it everpeace/docker-chainer  sh -c ' \
    wget https://raw.githubusercontent.com/chainer/chainer/master/examples/mnist/train_mnist.py \
    && python3 train_mnist.py -e 3'
```

## Multi Node Mode (Distributed Machine Learning)
```
$ cd multi-node-example

# generate temporary ssh key
# generated key will be stored in ./tmp/ssh-key directory
$ ./gen-ssh-key.sh

# up mpi cluster with 1 master and 4 workers
$ docker-compose up -d

# once it was up, ready to ssh to 'mpi-master' with 'chainer' user.
$ ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i ./tmp/ssh-key/id_rsa \
    -p 3333 chainer@localhost \ 
    -- ./train_mnist.sh \
...
==========================================
Num process (COMM_WORLD): 4
Using hierarchical communicator
Num unit: 1000
Num Minibatch-size: 10
Num epoch: 3
==========================================
epoch       main/loss   validation/main/loss  main/accuracy  validation/main/accuracy  elapsed_time
     total [#.................................................]  2.22%
this epoch [###...............................................]  6.67%
       100 iter, 0 epoch / 3 epochs
       inf iters/sec. Estimated time to finish: 0:00:00.
```
