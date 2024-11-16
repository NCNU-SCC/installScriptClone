#!/bin/bash

# 顯示環境變量
echo "PATH: $(env | grep '^PATH=' | cut -d'=' -f2)"
echo ""
echo "LIBRARY_PATH: $(env | grep '^LIBRARY_PATH=' | cut -d'=' -f2)"
echo ""
echo "LD_LIBRARY_PATH: $(env | grep '^LD_LIBRARY_PATH=' | cut -d'=' -f2)"
echo ""
echo "C_INCLUDE_PATH: $(env | grep '^C_INCLUDE_PATH=' | cut -d'=' -f2)"
echo ""
echo "CPLUS_INCLUDE_PATH: $(env | grep '^CPLUS_INCLUDE_PATH=' | cut -d'=' -f2)"
echo ""
echo "MANPATH: $(env | grep '^MANPATH=' | cut -d'=' -f2)"
echo ""
echo "INFOPATH: $(env | grep '^INFOPATH=' | cut -d'=' -f2)"
echo ""
echo "PKG_CONFIG_PATH: $(env | grep '^PKG_CONFIG_PATH=' | cut -d'=' -f2)"
echo ""
echo "CMAKE_PREFIX_PATH: $(env | grep '^CMAKE_PREFIX_PATH=' | cut -d'=' -f2)"
echo ""
echo "ACLOCAL_PATH: $(env | grep '^ACLOCAL_PATH=' | cut -d'=' -f2)"

