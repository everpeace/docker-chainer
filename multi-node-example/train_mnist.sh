#! /bin/bash

MPI_EXEC="mpiexec --hostfile /hostfile --mca mpi_cuda_support 0 -n 4"

$MPI_EXEC -- wget https://raw.githubusercontent.com/chainer/chainermn/v1.2.0/examples/mnist/train_mnist.py

$MPI_EXEC -- python3 train_mnist.py --batchsize 5 --epoch 2
