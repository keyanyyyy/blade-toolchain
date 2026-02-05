#!/usr/bin/env bash
set -euo pipefail

echo "[1/6] Setup mamba (faster conda)..."
conda install -n base -c conda-forge -y mamba

echo "[2/6] Create conda env: blade (FEniCS 2019.1.0 + common deps)..."
# 说明：ANBA4 文档里就是推荐 conda + fenics(2019.1.0) 这一套思路
# 如果你后续发现 SONATA 需要额外包，直接在下面这行继续加即可。
mamba create -n blade -c conda-forge -y \
  python=3.9 \
  fenics=2019.1.0 \
  numpy scipy pandas pyyaml matplotlib \
  meshio gmsh \
  sympy

echo "[3/6] Activate env..."
# shellcheck disable=SC1091
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
  # 优先用新组织（WISDEM 已迁移到 NLRWindSystems 的迹象很明显）
  # 如果你网络/权限导致失败，下面 fallback 会再试一次旧路径。
  git clone https://github.com/NLRWindSystems/SONATA.git external/SONATA \
    || git clone https://github.com/WISDEM/SONATA.git external/SONATA
fi
python -m pip install -e external/SONATA

echo "[6/6] Quick sanity checks..."
python -c "import dolfin; print('FEniCS(dolfin) version:', dolfin.__version__)"
python -c "import anba4; print('ANBA4 import: OK')"

echo "DONE. Open a new terminal and run: conda activate blade"
