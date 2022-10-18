#!/bin/sh
# ========================================================================
# Initialization of IIC Open-Source EDA Environment
#
# SPDX-FileCopyrightText: 2021-2022 Harald Pretl, Johannes Kepler 
# University, Institute for Integrated Circuits
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0
#
# This script installs OpenLane, xschem, ngspice, magic, netgen,
# and a few other tools for use with SkyWater Technology SKY130.
# ========================================================================

# Define setup environment
# ------------------------
export MY_PDK_ROOT="$HOME/pdk"
export MY_STDCELL=sky130_fd_sc_hd
export SRC_DIR="$HOME/src"
export OPENLANE_DIR="$HOME/OpenLane"
my_path=$(realpath "$0")
my_dir=$(dirname "$my_path")
export SCRIPT_DIR="$my_dir"
export NGSPICE_VERSION=36
export KLAYOUT_VERSION=0.27.11
# This selects which sky130 PDK flavor (A=sky130A, B=sky130B, all=both)  is installed
export OPEN_PDK_ARGS="--with-sky130-variants=A"
export MY_PDK=sky130A

# Install/Update KLayout
# ---------------------
echo ">>>> Installing KLayout-$KLAYOUT_VERSION"
wget https://www.klayout.org/downloads/Ubuntu-22/klayout_$KLAYOUT_VERSION-1_amd64.deb
sudo apt -qq install -y klayout_$KLAYOUT_VERSION-1_amd64.deb
rm klayout_$KLAYOUT_VERSION-1_amd64.deb