require 'shelljs/global'

linuxInstall = ->
  echo 'Installing on Ubuntu, refers to https://github.com/LearnBoost/node-canvas/wiki/Installation---Ubuntu'
  exec 'sudo apt-get update'
  exec 'sudo apt-get install libcairo2-dev libjpeg8-dev libpango1.0-dev libgif-dev build-essential g++'

macInstall = -> 
  ## install pkg-config
  echo 'Installing on Mac, refers to https://github.com/LearnBoost/node-canvas/wiki/Installation---OSX'
  if !which 'pkg-config'
    echo 'Installing `pkg-config`'

    if ls('pkgconfig.tgz').length == 0
      exec 'curl http://pkgconfig.freedesktop.org/releases/pkg-config-0.23.tar.gz -o pkgconfig.tgz'

    exec 'tar -zxf pkgconfig.tgz'
    cd 'pkg-config-0.23/'
    exec './configure'
    exec 'make install'
  else
    echo 'Detected `pkg-config` installed.'

  ## install Pixman
  if !which 'pixman'
    echo 'Installing `pixman`'

    if ls('pixman.tar.gz').length == 0
      exec 'curl http://www.cairographics.org/releases/pixman-0.22.0.tar.gz -o pixman.tar.gz'

    exec 'tar -zxf pixman.tar.gz'
    cd 'pixman-0.22.0/'
    exec './configure --prefix=/usr/local --disable-dependency-tracking'
    exec 'make install'
  else
    echo 'Detected `pixman` installed.'

  ## install Cairo
  if !which 'cairo-trace'
    echo 'Installing `cairo`'

    if ls('cairo.tar.xz').length == 0
      exec 'curl http://cairographics.org/releases/cairo-1.12.8.tar.xz -o cairo.tar.xz'

    exec 'tar -xJf cairo.tar.xz'
    cd 'cairo-1.12.8'
    exec './configure --prefix=/usr/local --disable-dependency-tracking'
    exec 'make install'
  else
    echo 'Detected `cairo` installed.'

platform = process.platform
if platform is 'darwin'
  macInstall()
  exit 0
else if platform is 'linux'
  linuxInstall()
  exit 0
else
  echo 'Installing in Fedora, refers to https://github.com/LearnBoost/node-canvas/wiki/Installation---Fedora'
  echo 'Installing in Windows, refers to https://github.com/LearnBoost/node-canvas/wiki/Installation---Windows'
  exit 2

