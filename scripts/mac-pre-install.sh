#!/bin/sh

echo 'Installing on Mac'
echo 'Read More in https://github.com/LearnBoost/node-canvas/wiki/Installation---OSX\n'

install_pkgconfig() {
  if hash pkg-config 2>/dev/null; then
    echo 'Detected `pkg-config` installed.'
  else
    echo 'Installing `pkg-config`'
    if [ ! -f "pkgconfig.tgz" ]; then
      curl http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz -o pkgconfig.tgz
    fi
    tar -zxf pkgconfig.tgz && cd pkg-config-0.28/
    ./configure && make install
    cd ..
  fi
  export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
  export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/X11/lib/pkgconfig
}

install_pixman() {
  echo 'Installing `pixman`'
  if [ ! -f "pixman.tar.gz" ]; then
    curl http://www.cairographics.org/releases/pixman-0.30.0.tar.gz -o pixman.tar.gz
  fi
  tar -zxf pixman.tar.gz && cd pixman-0.30.0/
  ./configure --prefix=/usr/local --disable-dependency-tracking
  make install
  cd ..
}

install_cario() {
  if hash cairo-trace 2>/dev/null; then
    echo 'Detected `cairo` installed.'
  else
    install_pixman

    echo 'Installing `cairo`'
    if [ ! -f "cairo.tar.xz" ]; then
      curl http://cairographics.org/releases/cairo-1.12.8.tar.xz -o cairo.tar.xz
    fi
    tar -xJf cairo.tar.xz && cd cairo-1.12.8
    ./configure --prefix=/usr/local --disable-dependency-tracking
    make install
    cd ..
  fi
}

install_pkgconfig
install_cario
exit 0
