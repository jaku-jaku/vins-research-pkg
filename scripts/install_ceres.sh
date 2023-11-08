### Pre-req: http://ceres-solver.org/installation.html
# CMake
sudo apt-get install -y cmake
# google-glog + gflags
sudo apt-get install -y libgoogle-glog-dev libgflags-dev
# Use ATLAS for BLAS & LAPACK
sudo apt-get install -y libatlas-base-dev
# Eigen3
sudo apt-get install -y libeigen3-dev
# SuiteSparse (optional)
sudo apt-get install -y libsuitesparse-dev

## Download 2.0.0 and build:
cd ~/JX_Linux
if ! [ -f "ceres-solver-2.0.0.tar.gz" ]; then
    wget http://ceres-solver.org/ceres-solver-2.0.0.tar.gz
fi
if ! [ -f "ceres-solver-2.0.0" ]; then
    tar zxf ceres-solver-2.0.0.tar.gz
fi
mkdir ceres-bin
cd ceres-bin
cmake ../ceres-solver-2.0.0
make -j${nproc}
make test
sudo make install