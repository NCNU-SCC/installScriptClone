#!/bin/bash

# install lua-5.1.4.9
wget https://sourceforge.net/projects/lmod/files/lua-5.1.4.9.tar.bz2
tar xf lua-5.1.4.9.tar.bz2
rm lua-5.1.4.9.tar.bz2
cd lua-5.1.4.9
./configure --prefix=/opt/apps/lua/5.1.4.9
make; make install
cd /opt/apps/lua; ln -s 5.1.4.9 lua
mkdir /usr/local/bin; ln -s /opt/apps/lua/lua/bin/lua /usr/local/bin

sudo apt update
sudo apt install tcl tcl-dev tcl8.6 tcl8.6-dev:amd64

git clone https://github.com/TACC/Lmod.git
cd Lmod
./configure --prefix=/opt/apps
make -j$(nproc)
make install -j$(nproc)

# export PATH=/opt/apps/lmod/8.7.53/libexec:$PATH

sudo ln -s /opt/apps/lmod/lmod/init/profile        /etc/profile.d/z00_lmod.sh
sudo ln -s /opt/apps/lmod/lmod/init/cshrc          /etc/profile.d/z00_lmod.csh


# /etc/bash.bashrc

# if [ -d /etc/profile.d ]; then
#   for i in /etc/profile.d/*.sh; do
#     if [ -r $i ]; then
#       . $i
#     fi
#   done
# fi                                   

