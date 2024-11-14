#!/bin/bash

########### Basic Setting ##########

DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
BASE="$(basename "$(realpath "${BASH_SOURCE[0]}")" .sh )"
cd $DIR
source "$DIR/../config"
package=$(echo $BASE | cut -d'-' -f1)
version=$(echo $BASE | cut -d'-' -f2)

########## Setting by User ##########

# Need to modify 1 : URL
URL="https://www.mpfr.org/mpfr-current/mpfr-4.2.1.tar.xz"

# Need to modify 2 : Dependence (module file)
DEP=("gmp-6.2.1")

# Need to modify 3 : Install Dir
INSTALLPATH="$optDir/$package/$version"


# Need to modify 4 : Module file Dir
MF="$mfDir/Core/$package/$version.lua"

# Need to modify 5 : configure options

OPT_FLAGS="-O3 -march=native -mtune=native -flto -pipe -ffast-math -funroll-loops"
CC="gcc"
CXX="g++"
FC="gfortran"

CONFIGURE_CMD="../configure \
    CC=$CC \
    CXX=$CXX \
    FC=$FC \
    CFLAGS=\"$OPT_FLAGS\" \
    CXXFLAGS=\"$OPT_FLAGS\" \
    FFLAGS=\"$OPT_FLAGS\" \
    --prefix=$INSTALLPATH"

########## More Variable ##########

URLFILE=$(basename "$URL")
DIRNAME=$URLFILE
DIRNAME="${DIRNAME%.zip}"
DIRNAME="${DIRNAME%.tar*}"
DIRNAME="${DIRNAME%.rar}"
DIRNAME="${DIRNAME%.7z*}"

########## Functions ###########

color()
{
  if [ "$#" -ne 2 ] ; then
    echo "[ERROR] color <color-name> <text> expected two arguments, but got $#" >&2
    return 1
  fi

  local -r colorName="$1"
  local -r message="$2"

  local colorCode="0;37"
  case "${colorName,,}" in
    black          ) colorCode='0;30' ;;
    red            ) colorCode='0;31' ;;
    green          ) colorCode='0;32' ;;
    yellow         ) colorCode='0;33' ;;
    blue           ) colorCode='0;34' ;;
    magenta        ) colorCode='0;35' ;;
    cyan           ) colorCode='0;36' ;;
    white          ) colorCode='0;37' ;;
    bright_black   ) colorCode='0;90' ;;
    bright_red     ) colorCode='0;91' ;;
    bright_green   ) colorCode='0;92' ;;
    bright_yellow  ) colorCode='0;93' ;;
    bright_blue    ) colorCode='0;94' ;;
    bright_magenta ) colorCode='0;95' ;;
    bright_cyan    ) colorCode='0;96' ;;
    bright_white   ) colorCode='0;97' ;;
    gray           ) colorCode='0;90' ;;
    *              ) colorCode='0;37' ;;
  esac

  echo -e "\e[${colorCode}m${message}\e[0m"
}

hyphen_h()
{
  echo "Usage: $(basename "$0") [options]"
  echo ""
  echo "Options:"
  echo "-h, --help              Show help"
  echo "--crawlConfigHelp       Crawl a lot of keywords, --with, --enable, \
--disable, --prefix, --bindir, --libdir, --includedir, --debug, --quiet, \
--silent, --verbose, --host, --build, --target, --arch, --check, --test, \
--force, --os, --config, --ld"
  echo "--doWget                Get the source code from URL."
}

hyphen_crawlConfigHelp()
{
  if [[ ! -d "$DIRNAME" ]]; then
  color bright_red "$DIRNAME doesn't exist."
  exit 1
  fi
  cd $DIRNAME

  local tmp="mytmpfile.tmp"

  echo "########## Dependences ##########" >> $tmp
  ./configure --help | grep "\-\-with" >> $tmp
  echo "########## Feature ##########" >> $tmp
  ./configure --help | grep "\-\-enable" >> $tmp
  ./configure --help | grep "\-\-disable" >> $tmp
  echo "########## Path ###########" >> $tmp
  ./configure --help | grep "\-\-prefix" >> $tmp
  ./configure --help | grep "\-\-binddir" >> $tmp
  ./configure --help | grep "\-\-libdir" >> $tmp
  ./configure --help | grep "\-\-includedir" >> $tmp
  echo "########## Outputting ###########" >> $tmp
  ./configure --help | grep "\-\-debug" >> $tmp
  ./configure --help | grep "\-\-quiet" >> $tmp
  ./configure --help | grep "\-\-slient" >> $tmp
  ./configure --help | grep "\-\-verbose" >> $tmp
  echo "########## Platform ###########" >> $tmp
  ./configure --help | grep "\-\-host" >> $tmp
  ./configure --help | grep "\-\-build" >> $tmp
  ./configure --help | grep "\-\-target" >> $tmp
  ./configure --help | grep "\-\-arch" >> $tmp
  echo "########## Others ###########" >> $tmp
  ./configure --help | grep "\-\-check" >> $tmp
  ./configure --help | grep "\-\-test" >> $tmp
  ./configure --help | grep "\-\-force" >> $tmp
  ./configure --help | grep "\-\-os" >> $tmp
  ./configure --help | grep "\-\-config" >> $tmp
  ./configure --help | grep "\-\-ld" >> $tmp

  cat $tmp
  rm $tmp

  color bright_green "crawl finished."
}


hyphen_doWget()
{
  wget -q $URL
  if [[ ! -f "$URLFILE" ]]; then
    color bright_red "Error: Download failed for $URLFILE."
    exit 1
  fi
  color bright_blue "wget $URL"

  # 如果存在之前 unzip 之後的殘餘，刪掉
  rm -r $DIRNAME
  color bright_blue "remove $DIRNAME"

  bsdtar -xf $URLFILE || { echo "Extraction failed"; exit 1; }
  color bright_blue "Unzip $URLFILE"

  rm "$URLFILE"
  color bright_blue "remove $URLFILE"

 color bright_green "wget $URL successed."
}


########## Arguments Setting ##########

ARGS=$(getopt -o \
h\
\
\
 --long \
help,crawlConfigHelp,doWget\
\
\
 -n $(basename "$0") -- "$@")


if [ $? != 0 ]; then
    color bright_red "Inavild options!" >&2
    exit 1
fi



eval set -- "$ARGS"

while true; do
  case "$1" in
  -h | --help)
    hyphen_h
    exit 0
    ;;
  --crawlConfigHelp )
    hyphen_crawlConfigHelp
    exit 0
    ;;
  --doWget )
    hyphen_doWget
    exit 0
    ;;
  --)
    shift
    break
    ;;
  *)
    color bright_red "Inavild options!" >&2
    exit 1
    ;;
  esac
done


########## LOAD MODULE ##########

for dep in ${DEP[@]}
do
  depName=$(echo "$dep" | cut -d'-' -f1)
  depVersion=$(echo "$dep" | cut -d'-' -f2)

if ! module load $depName/$depVersion ; then
    color bright_red "Error: Failed to load $dep"
    exit 1
fi
done

color bright_green "Module loaded successed."

########## INSTALL PATH CHECK ##########

mkdir -p $INSTALLPATH

if [ "$(ls -A $INSTALLPATH)" ]; then
  # User Input
  read -p "$(color bright_red 'INSTALLPATH:') $INSTALLPATH $(color bright_red 'is not empty. Delete its contents?') (y/yes to confirm) " confirmation

  if [[ "$confirmation" =~ ^(y|Y|yes|Yes)$ ]]; then
    color bright_blue "Deleting contents of $INSTALLPATH..."
    rm -rf $INSTALLPATH/*
  else
    color bright_blue "Deletion aborted, continue."
  fi
else
  color bright_blue "$INSTALLPATH is empty. No deletion needed."
fi

########## MODULE FILE ##########

mkdir -p $(dirname $MF)
>$MF

########## INSTALL ##########

if [[ ! -d "$DIRNAME" ]]; then
  color bright_red "$DIRNAME doesn't exist."
  exit 1
fi


cd $DIRNAME
color bright_blue "cd $DIRNAME"
mkdir -p build
color bright_blue "mkdir build"
cd build/
color bright_blue "cd build"

# -ftree-vectorize
# -fomit-frame-pointer
# -fno-exceptions
# -fno-rtti -mavx2, -mfma, -msse4.2
# -ffunction-sections, -fdata-sections

eval $CONFIGURE_CMD > configure.log 2>&1

echo "########## Keyword Detected ##########"
## ERR
ret=$?
echo "$(grep --color=never "error" configure.log | sed 's/error/\x1b[31m&\x1b[0m/g')"
echo "$(grep --color=never "require" configure.log | sed 's/require/\x1b[31m&\x1b[0m/g')"
echo "$(grep --color=never "missing" configure.log | sed 's/missing/\x1b[31m&\x1b[0m/g')"
echo "$(grep --color=never "warning" configure.log | sed 's/warning/\x1b[33m&\x1b[0m/g')"
if [ $ret -ne 0 ]; then
  color bright_red "Error: Configure failed"
  echo "Configure log written to $(color bright_white "$(pwd)/configure.log")"
  exit 1
fi

echo "Configure log written to $(color bright_white "$(pwd)/configure.log")"


make -j$(nproc) > make.log 2>&1

## ERR
ret=$?
echo "$(grep --color=never "error" make.log | sed 's/error/\x1b[31m&\x1b[0m/g')"
if [ $ret -ne 0 ]; then
  color bright_red "Error: Make failed"
  echo "Make log written to $(color bright_white "$(pwd)/make.log")"
  exit 1
fi

echo "Make log written to $(color bright_white "$(pwd)/make.log")"

make install -j$(nproc) > install.log 2>&1

## ERR
ret=$?
echo "$(grep "error" "install.log" )"
if [ $? -ne 0 ]; then
    color bright_red "Error: Make install failed"
    echo "Install log written to $(color bright_white "$(pwd)/install.log")"
    exit 1
fi

echo "Install log written to $(color bright_white "$(pwd)/install.log" )"
echo ""
echo "Install at $INSTALLPATH"
echo ""





########## Modulefile Template ##########
packageHOME="${package}HOME"

echo "local root = \"$INSTALLPATH\"" > $MF
echo "" >> $MF

for dep in ${DEP[@]}
do
  depName=$(echo "$dep" | cut -d'-' -f1)
  depVersion=$(echo "$dep" | cut -d'-' -f2)

  echo "depends_on(\"$depName/$depVersion\")" >> $MF

done

cat <<EOF >> $MF

-- all path prepend --
prepend_path("$packageHOME", root)
prepend_path("PATH", pathJoin(root, "bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(root, "lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(root, "lib64"))
prepend_path("C_INCLUDE_PATH", pathJoin(root, "include"))
prepend_path("CPLUS_INCLUDE_PATH", pathJoin(root, "include"))
prepend_path("LIBRARY_PATH", pathJoin(root, "lib"))
prepend_path("LIBRARY_PATH", pathJoin(root, "lib64"))
prepend_path("MANPATH", pathJoin(root, "share/man"))
prepend_path("INFOPATH", pathJoin(root, "share/info"))
prepend_path("ACLOCAL_PATH", pathJoin(root, "share/aclocal"))
prepend_path("PKG_CONFIG_PATH", pathJoin(root, "lib/pkgconfig"))
prepend_path("PKG_CONFIG_PATH", pathJoin(root, "lib64/pkgconfig"))
prepend_path("CMAKE_PREFIX_PATH", root)

if (mode() == "load") then
   io.stderr:write(myModuleFullName() .. " loaded\n")
end

if (mode() == "unload") then
   io.stderr:write(myModuleFullName() .. " unloaded\n")
end
EOF

echo "Module file written to $MF"
color bright_green "Install successed."


