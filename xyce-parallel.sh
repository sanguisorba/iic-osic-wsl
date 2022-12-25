#!/bin/sh
# ========================================================================
# This script will install Xyce parallel
# ========================================================================

# Define setup environment
# ------------------------
export MY_PDK_ROOT="$HOME/pdk"
export SRC_DIR="$HOME/src"
my_path=$(realpath "$0")
my_dir=$(dirname "$my_path")
export SCRIPT_DIR="$my_dir"
export SRCDIR="$SRC_DIR/Trilinos12.12/Trilinos-trilinos-release-12-12-1"
export ARCHDIR="$SRC_DIR/trilinos_libs/parallel"
export FLAGS="-O3 -fPIC"
export CXXFLAGS="-O3"
export CPPFLAGS="-I/usr/include/suitesparse"
export INSTALL_DIR="$HOME/xyce/parallel"
# Also change $PATH if you change $INSTALL_DIR

# Install all the packages available via apt
# ------------------------------------------
echo ">>>> Installing required (and useful) packages via APT"
sudo apt -qq install -y gcc g++ gfortran make cmake bison flex libfl-dev libfftw3-dev \
	libsuitesparse-dev libblas-dev liblapack-dev libtool autoconf automake
sudo apt -qq install -y libopenmpi-dev openmpi-bin

# Get trilinos 12.12.1
# ------------------------
if [ ! -d  "$SRC_DIR/Trilinos12.12" ]; then
	echo ">>>> Installing trilinos 12.12.1"
	mkdir "$SRC_DIR/Trilinos12.12"
	cd "$SRC_DIR/Trilinos12.12" || exit
	wget "https://github.com/trilinos/Trilinos/archive/refs/tags/trilinos-release-12-12-1.tar.gz"
	gunzip trilinos-release-12-12-1.tar.gz
	tar xf trilinos-release-12-12-1.tar
	rm trilinos-release-12-12-1.tar
fi

# Install trilinos 12.12.1
# ------------------------
if [ ! -d  "$SRC_DIR/trilinos_libs/parallel" ]; then
	cd "$SRC_DIR/Trilinos12.12" || exit
	cd "Trilinos-trilinos-release-12-12-1"
	rm -rf CMakeCache.txt CMakeFiles/
	cd ..
	cmake -G "Unix Makefiles" -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpic++ \
	-DCMAKE_Fortran_COMPILER=mpif77 -DCMAKE_CXX_FLAGS="$FLAGS" \
	-DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_Fortran_FLAGS="$FLAGS" \
	-DCMAKE_INSTALL_PREFIX=$ARCHDIR -DCMAKE_MAKE_PROGRAM="make" \
	-DTrilinos_ENABLE_NOX=ON -DNOX_ENABLE_LOCA=ON \
	-DTrilinos_ENABLE_EpetraExt=ON -DEpetraExt_BUILD_BTF=ON \
	-DEpetraExt_BUILD_EXPERIMENTAL=ON -DEpetraExt_BUILD_GRAPH_REORDERINGS=ON \
	-DTrilinos_ENABLE_TrilinosCouplings=ON -DTrilinos_ENABLE_Ifpack=ON \
	-DTrilinos_ENABLE_Isorropia=ON \
	-DTrilinos_ENABLE_AztecOO=ON -DTrilinos_ENABLE_Belos=ON \
	-DTrilinos_ENABLE_Teuchos=ON -DTrilinos_ENABLE_COMPLEX_DOUBLE=ON \
	-DTrilinos_ENABLE_Amesos=ON -DAmesos_ENABLE_KLU=ON \
	-DTrilinos_ENABLE_Amesos2=ON -DAmesos2_ENABLE_KLU2=ON \
	-DAmesos2_ENABLE_Basker=ON -DTrilinos_ENABLE_Sacado=ON \
	-DTrilinos_ENABLE_Stokhos=ON -DTrilinos_ENABLE_Kokkos=ON \
	-DTrilinos_ENABLE_Zoltan=ON \
	-DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=OFF \
	-DTrilinos_ENABLE_CXX11=ON -DTPL_ENABLE_AMD=ON \
	-DAMD_LIBRARY_DIRS="/usr/lib64" \
	-DTPL_AMD_INCLUDE_DIRS="/usr/include/suitesparse" \
	-DTPL_ENABLE_BLAS=ON -DTPL_ENABLE_LAPACK=ON \
	-DTPL_ENABLE_MPI=ON $SRCDIR
	make -j"$(nproc)" && sudo make install
fi

# Install/Update Xyce
# ------------------------
if [ ! -d "$SRC_DIR/xyce/src" ]; then
	echo ">>>> Installing xyce"
	git clone https://github.com/Xyce/Xyce.git "$SRC_DIR/xyce/src"
	cd "$SRC_DIR/xyce/src" || exit
	./bootstrap
else
	echo ">>>> Updating xyce"
	cd "$SRC_DIR/xyce/src" || exit
	git pull
	./bootstrap
fi
./configure \
CXXFLAGS="-O3" \
ARCHDIR="$SRC_DIR/trilinos_libs/parallel" \
CPPFLAGS="-I/usr/include/suitesparse" \
--enable-mpi \
CXX=mpicxx CC=mpicc F77=mpif77 \
--enable-stokhos \
--enable-amesos2 \
--prefix="$INSTALL_DIR"
cd src/DeviceModelPKG/ADMS
make -j"$(nproc)"
# see the building guide if you fail this step!
cd $SRC_DIR/xyce/src
make -j"$(nproc)" && sudo make install

/usr/bin/printf "export PATH=\x24PATH:\x24HOME/xyce/parallel/bin\n" >> "$HOME/.bashrc"

echo ""
echo ">>>> All done."
echo ""