#!/bin/bash


# $1 empty
if [[ -z "$1" ]]; then
  echo "Error: A input file is needed." >&2
  exit 1
fi


DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
BASE="$(basename "$(realpath "${BASH_SOURCE[0]}")" .sh )"
cd $DIR

mkdir -p $(dirname $1)
EOFText="EOF"

cat <<EOF > $1
#!/bin/bash

########### Basic Setting ##########

DIR="\$(dirname "\$(realpath "\${BASH_SOURCE[0]}")")"
BASE="\$(basename "\$(realpath "\${BASH_SOURCE[0]}")" .sh )"
cd \$DIR
source "\$DIR/../config"
package=\$(echo \$BASE | cut -d'-' -f1)
version=\$(echo \$BASE | cut -d'-' -f2)

########## Setting by User ##########

URL=""

DEP=()

INSTALLPATH="\$optDir/\$package/\$version"

MF="\$mfDir/Core/\$package/\$version.lua"

MFText=" \\
family("Compiler") \\
prepend_path ("MODULEPATH", pathJoin (mfroot, "Compiler", package)) \\
prepend_path ("MODULEPATH", pathJoin (mfroot, "MPI", package)) \\
"

// (For copy)
# family("Compiler")
# (For copy)
# mkdir -p \$MODULEPATH_ROOT/Compiler/\$package/\$version

########## configure options ##########

# 對於 gcc/g++ 的優化選項: 請查看 https://gcc.gnu.org/onlinedocs/gcc-10.2.0/gcc/Optimize-Options.html#Optimize-Options

# General
#OPT_FLAGS+=" -O3"                # 最佳化等級3，激進的優化
OPT_FLAGS+=" -Ofast"             # 啟動所有優化，無視嚴格的標準合規性
OPT_FLAGS+=" -funroll-loops"     # 展開迴圈來減少迴圈計數開銷，提高效能
OPT_FLAGS+=" -fprefetch-loop-arrays"    # 開啟陣列預取優化，在迴圈中預取陣列數據，提高記憶體訪問效率 (或更差，取決於程式)

# 分次編譯 (兩次 configure)
#OPT_FLAGS+=" -fprofile-generate"      # 執行一次程式以收集執行資料
#OPT_FLAGS+=" -fprofile-use=\$(pwd)"   # 利用收集的資料進行優化


# CPU Specify
OPT_FLAGS+=" -march=native"      # 使用本地CPU架構指令集進行最佳化
OPT_FLAGS+=" -mtune=native"             # 調整編譯選項以最佳化當前CPU
OPT_FLAGS+=" -mfpmath=sse"              # 使用SSE指令集加速浮點運算（對於支持的CPU）
OPT_FLAGS+=" -mavx"                     # 開啟AVX指令集，適用於支援AVX的CPU，可顯著加速浮點數運算
OPT_FLAGS+=" -mavx2"                    # 開啟AVX2指令集，加速矢量運算
OPT_FLAGS+=" -mprefer-vector-width=256" # 優先使用256位的矢量寬度，提高矢量化效率

# LTO
#OPT_FLAGS+=" -fno-lto"                         # 禁用LTO，可用於排除LTO引起的潛在問題，例如: __gttf2@@GCC_4.3.0
# error example: https://aur.archlinux.org/pkgbase/gcc7
#OPT_FLAGS+=" -fwhole-program"                  # 啟用全局變數鏈接時間優化。This option should not be used in combination with -flto. Instead relying on a linker plugin should provide safer and more precise information.

OPT_FLAGS+=" -flto=auto"                        # the standard link-time optimizer
OPT_FLAGS+=" -fuse-linker-plugin"               # 使用鏈接器插件，能使LTO在鏈接階段進行更多優化。不可用時， -fwhole-program 應該使用。
#OPT_FLAGS+=" -flto-partition=one"              # 單一分區的LTO，有助於減少LTO的內存佔用

# Others
OPT_FLAGS+=" -fno-plt"           # 不使用程序鏈接表（PLT）對動態鏈接庫的函數進行直接調用，提高函數調用效率
OPT_FLAGS+=" -pipe"              # 使用管道加速編譯步驟間的數據傳遞

CC="gcc"
CXX="g++"
FC="gfortran"

CONFIGURE_CMD="../configure \\
    CC=\$CC \\
    CXX=\$CXX \\
    FC=\$FC \\
    CFLAGS=\\"\$OPT_FLAGS\\" \\
    CXXFLAGS=\\"\$OPT_FLAGS\\" \\
    FFLAGS=\\"\$OPT_FLAGS\\" \\
    --prefix=\$INSTALLPATH"






########## More Variable ##########

URLFILE=\$(basename "\$URL")
DIRNAME=\$URLFILE
DIRNAME="\${DIRNAME%.zip}"
DIRNAME="\${DIRNAME%.tar*}"
DIRNAME="\${DIRNAME%.rar}"
DIRNAME="\${DIRNAME%.7z*}"

########## Functions ###########

color()
{
  if [ "\$#" -ne 2 ] ; then
    echo "[ERROR] color <color-name> <text> expected two arguments, but got \$#" >&2
    return 1
  fi

  local -r colorName="\$1"
  local -r message="\$2"

  local colorCode="0;37"
  case "\${colorName,,}" in
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

  echo -e "\\e[\${colorCode}m\${message}\\e[0m"
}

hyphen_h()
{
  echo "Usage: \$(basename "\$0") [options]"
  echo ""
  echo "Options:"
  echo "-h, --help              Show help"
  echo "--crawlConfigHelp       Crawl a lot of keywords, --with, --enable, \\
--disable, --prefix, --bindir, --libdir, --includedir, --debug, --quiet, \\
--silent, --verbose, --host, --build, --target, --arch, --check, --test, \\
--force, --os, --config, --ld"
  echo "--doWget                Get the source code from URL."
}

hyphen_crawlConfigHelp()
{
  if [[ ! -d "\$DIRNAME" ]]; then
  color red "\$DIRNAME doesn't exist."
  exit 1
  fi
  cd \$DIRNAME

  local tmp="mytmpfile.tmp"

  echo "########## Dependences ##########" >> \$tmp
  ./configure --help | grep "\-\-with" >> \$tmp
  echo "########## Feature ##########" >> \$tmp
  ./configure --help | grep "\-\-enable" >> \$tmp
  ./configure --help | grep "\-\-disable" >> \$tmp
  echo "########## Path ###########" >> \$tmp
  ./configure --help | grep "\-\-prefix" >> \$tmp
  ./configure --help | grep "\-\-binddir" >> \$tmp
  ./configure --help | grep "\-\-libdir" >> \$tmp
  ./configure --help | grep "\-\-includedir" >> \$tmp
  echo "########## Outputting ###########" >> \$tmp
  ./configure --help | grep "\-\-debug" >> \$tmp
  ./configure --help | grep "\-\-quiet" >> \$tmp
  ./configure --help | grep "\-\-slient" >> \$tmp
  ./configure --help | grep "\-\-verbose" >> \$tmp
  echo "########## Platform ###########" >> \$tmp
  ./configure --help | grep "\-\-host" >> \$tmp
  ./configure --help | grep "\-\-build" >> \$tmp
  ./configure --help | grep "\-\-target" >> \$tmp
  ./configure --help | grep "\-\-arch" >> \$tmp
  echo "########## Others ###########" >> \$tmp
  ./configure --help | grep "\-\-check" >> \$tmp
  ./configure --help | grep "\-\-test" >> \$tmp
  ./configure --help | grep "\-\-force" >> \$tmp
  ./configure --help | grep "\-\-os" >> \$tmp
  ./configure --help | grep "\-\-config" >> \$tmp
  ./configure --help | grep "\-\-ld" >> \$tmp

  cat \$tmp
  rm \$tmp

  color bright_green "crawl finished."
}

hyphen_doWget()
{
  wget -q \$URL
  if [[ ! -f "\$URLFILE" ]]; then
    color red "Error: Download failed for \$URLFILE."
    exit 1
  fi
  color green "wget \$URL"

  # 如果存在之前 unzip 之後的殘餘，刪掉
  rm -r \$DIRNAME
  color green "remove \$DIRNAME"

  bsdtar -xf \$URLFILE || { echo "Extraction failed"; exit 1; }
  color green "Unzip \$URLFILE"

  rm "\$URLFILE"
  color green "remove \$URLFILE"

 color bright_green "wget \$URL successed."
}

########## Arguments Setting ##########

ARGS=\$(getopt -o \\
h\\
\\
\\
 --long \\
help,crawlConfigHelp,doWget\\
\\
\\
 -n \$(basename "\$0") -- "\$@")


if [ \$? != 0 ]; then
    color red "Inavild options!" >&2
    exit 1
fi

eval set -- "\$ARGS"

while true; do
  case "\$1" in
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
    color red "Inavild options!" >&2
    exit 1
    ;;
  esac
done

########## LOAD MODULE ##########

for dep in \${DEP[@]}
do
  depName=\$(echo "\$dep" | cut -d'-' -f1)
  depVersion=\$(echo "\$dep" | cut -d'-' -f2)

if ! module load \$depName/\$depVersion ; then
    color red "Error: Failed to load \$dep"
    exit 1
fi
done

color bright_green "Module loaded successed."

########## Modify Env Variable ##########

# gcc 會抱怨 . (::) 出現在 LIBRARY_PATH 中，此命令去除這個問題。
LIBRARY_PATH=\$(echo "\$LIBRARY_PATH" | sed 's/::/:/g; s/:$//; s/^://')


########## INSTALL PATH CHECK ##########

mkdir -p \$INSTALLPATH

if [ "\$(ls -A \$INSTALLPATH)" ]; then
  # User Input
  read -p "\$(color red 'INSTALLPATH:') \$(color blue \$INSTALLPATH) \$(color red 'is not empty. Delete its contents?') (y/yes to confirm) " confirmation

  if [[ "\$confirmation" =~ ^(y|Y|yes|Yes)$ ]]; then
    echo " \$(color green 'Deleting contents of') \$(color blue '\$INSTALLPATH')"
    rm -rf \$INSTALLPATH/*
  else
    color green "Deletion aborted, continue."
  fi
else
  echo "\$(color blue '\$INSTALLPATH') \$(color green 'is empty. No deletion needed.')"
fi

########## MODULE FILE ##########


########## INSTALL ##########

if [[ ! -d "\$DIRNAME" ]]; then
  color red "\$DIRNAME doesn't exist."
  exit 1
fi

cd \$DIRNAME
color green "cd \$DIRNAME"
mkdir -p build
color green "mkdir build"
cd build/
color green "cd build"

# -ftree-vectorize
# -fomit-frame-pointer
# -fno-exceptions
# -fno-rtti -mavx2, -mfma, -msse4.2
# -ffunction-sections, -fdata-sections

eval sudo -E \$CONFIGURE_CMD > configure.log 2>&1

echo "########## Keyword Detected ##########"
## ERR
ret=\$?
echo "\$(grep --color=never "error" configure.log | sed 's/error/\\x1b[31m&\\x1b[0m/g')"
echo "\$(grep --color=never "require" configure.log | sed 's/require/\\x1b[31m&\\x1b[0m/g')"
echo "\$(grep --color=never "missing" configure.log | sed 's/missing/\\x1b[31m&\\x1b[0m/g')"
echo "\$(grep --color=never "warning" configure.log | sed 's/warning/\\x1b[31m&\\x1b[0m/g')"
if [ \$ret -ne 0 ]; then
  color red "Error: Configure failed"
  echo "Configure log written to \$(color blue "\$(pwd)/configure.log")"
  exit 1
fi

echo "Configure log written to \$(color blue "\$(pwd)/configure.log")"

sudo -E make -j\$(nproc) > make.log 2>&1

## ERR
ret=\$?
echo "\$(grep --color=never "error" make.log | sed 's/error/\\x1b[31m&\\x1b[0m/g')"
if [ \$ret -ne 0 ]; then
  color red "Error: Make failed"
  echo "Make log written to \$(color blue "\$(pwd)/make.log")"
  exit 1
fi

echo "Make log written to \$(color blue "\$(pwd)/make.log")"

sudo -E make install -j\$(nproc) > install.log 2>&1

## ERR
ret=\$?
echo "\$(grep --color=never "error" install.log | sed 's/error/\\x1b[31m&\\x1b[0m/g')"
if [ \$? -ne 0 ]; then
    color red "Error: Make install failed"
    echo "Install log written to \$(color blue "\$(pwd)/install.log")"
    exit 1
fi

echo "Install log written to \$(color blue "\$(pwd)/install.log" )"
echo ""
echo "Install at \$(color blue \$INSTALLPATH)"
echo ""

########## Modulefile Template ##########

mkdir -p \$(dirname \$MF)
>\$MF

packageHOME="\${package}HOME"

echo "local root = \\"\$INSTALLPATH\\"" > \$MF
echo "local package = \\\$package/\$version"
echo "local mfroot = os.getenv ("MODULEPATH_ROOT")"
echo "" >> \$MF

for dep in \${DEP[@]}
do
  depName=\$(echo "\$dep" | cut -d'-' -f1)
  depVersion=\$(echo "\$dep" | cut -d'-' -f2)

  echo "depends_on(\"\$depName/\$depVersion\")" >> \$MF

done

cat <<EOF >> \$MF

-- all path prepend --
prepend_path("\$packageHOME", root)
prepend_path("PATH", pathJoin(root, "bin"))
prepend_path("PATH", pathJoin(root, "libexec"))
prepend_path("LD_LIBRARY_PATH", pathJoin(root, "lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(root, "lib64"))
prepend_path("C_INCLUDE_PATH", pathJoin(root, "include"))
prepend_path("CPLUS_INCLUDE_PATH", pathJoin(root, "include"))
prepend_path("LIBRARY_PATH", pathJoin(root, "libexec"))
prepend_path("LIBRARY_PATH", pathJoin(root, "lib"))
prepend_path("LIBRARY_PATH", pathJoin(root, "lib64"))
prepend_path("MANPATH", pathJoin(root, "share/man"))
prepend_path("INFOPATH", pathJoin(root, "share/info"))
prepend_path("ACLOCAL_PATH", pathJoin(root, "share/aclocal"))
prepend_path("PKG_CONFIG_PATH", pathJoin(root, "lib/pkgconfig"))
prepend_path("PKG_CONFIG_PATH", pathJoin(root, "lib64/pkgconfig"))
prepend_path("CMAKE_PREFIX_PATH", root)

\$MFText

if (mode() == "load") then
   io.stderr:write(myModuleFullName() .. " loaded\\n")
end

if (mode() == "unload") then
   io.stderr:write(myModuleFullName() .. " unloaded\\n")
end
$EOFText

echo "Module file written to \$(color blue "\$MF")"
color bright_green "Install successed."


EOF
