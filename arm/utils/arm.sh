#!/bin/bash

os="none"
api="eabi"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: . arm.sh [platform]"
  echo "  Description: Configures gcc aliases for ARM development."
  echo "  Valid Platforms: none (default), gnu, gnuhf"
  exit 1
elif [ "$1" = "gnu" ]; then
  os="linux"
  api="gnueabi"
elif [ "$1" = "gnuhf" ]; then
  os="linux"
  api="gnueabihf"
elif [ "$1" = "none" ]; then
  os="none"
  api="eabi"
elif [ $# -gt 0 ]; then
  echo "Unrecognized platform: ${1}"
  exit 1
fi

alias addr2line="arm-${os}-${api}-addr2line"
alias gcc-4.9.3="arm-${os}-${api}-gcc-4.9.3"
alias objcopy="arm-${os}-${api}-objcopy"
alias ar="arm-${os}-${api}-ar"
alias gcc-ar="arm-${os}-${api}-gcc-ar"
alias objdump="arm-${os}-${api}-objdump"
alias as="arm-${os}-${api}-as"
alias gcc-nm="arm-${os}-${api}-gcc-nm"
alias ranlib="arm-${os}-${api}-ranlib"
alias c++="arm-${os}-${api}-c++"
alias gcc-ranlib="arm-${os}-${api}-gcc-ranlib"
alias readelf="arm-${os}-${api}-readelf"
alias c++filt="arm-${os}-${api}-c++filt"
alias gcov="arm-${os}-${api}-gcov"
alias size="arm-${os}-${api}-size"
alias cpp="arm-${os}-${api}-cpp"
alias gprof="arm-${os}-${api}-gprof"
alias strings="arm-${os}-${api}-strings"
alias elfedit="arm-${os}-${api}-elfedit"
alias ld="arm-${os}-${api}-ld"
alias strip="arm-${os}-${api}-strip"
alias g++="arm-${os}-${api}-g++"
alias ld.bfd="arm-${os}-${api}-ld.bfd"
alias gcc="arm-${os}-${api}-gcc"
alias nm="arm-${os}-${api}-nm"

