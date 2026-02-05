#!/usr/bin/env bash
set -euo pipefail

echo "[1/6] Setup mamba (faster conda)..."
conda install -n base -c conda-forge -y mamba

echo "[2/6] Create conda env: blade (FEniCS 2019.1.0 + common deps)..."
mamba create -n blade -c conda-forge -y \
  python=3.9 \
  fenics=2019.1.0 \
  numpy scipy pandas pyyaml matplotlib \
  meshio gmsh \
  sympy

echo "[3/6] Activate env..."
source /opt/conda/etc/profile.d/conda.sh
conda activate blade
python -m pip install -U pip setuptools wheel

echo "[4/6] Clone and install ANBA4..."
mkdir -p external
if [ ! -d "external/anba4" ]; then
  git clone https://github.com/ANBA4/anba4.git external/anba4
fi
python -m pip install -e external/anba4

echo "[5/6] Clone and install SONATA..."
if [ ! -d "external/SONATA" ]; then
  git clone https://github.com/NLRWindSystems/SONATA.git external/SONATA \
    || git clone https://github.com/WISDEM/SONATA.git external/SONATA
fi
python -m pip install -e external/SONATA

echo "[6/6] Quick sanity checks..."
python -c "import dolfin; print('FEniCS(dolfin) version:', dolfin.__version__)"
python -c "import anba4; print('ANBA4 import: OK')"

echo "DONE. Open a new terminal and run: conda activate blade"
