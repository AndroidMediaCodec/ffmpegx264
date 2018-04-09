#!/bin/bash

. abi_settings.sh $1 $2 $3

pushd ffmpeg

case $1 in
  armeabi-v7a | armeabi-v7a-neon)
    CPU='cortex-a8'
  ;;
  arm64-v8a )
    CPU='cortex-a8'
  ;;

  x86)
    CPU='i686'
  ;;
esac

NDK_ABI=$1

GENERAL="\
--enable-small \
--enable-cross-compile \
--extra-libs="-lgcc" \
--cc=${CROSS_PREFIX}gcc \
--cross-prefix=$CROSS_PREFIX \
--nm=$NM \
--extra-cflags="-I../x264/android/x86/include" \
--extra-ldflags="-L../x264/android/x86/lib""

MODULES="\
--enable-gpl \
--enable-libx264"

function build_x86
{
  ./configure \
  --logfile=conflog.txt \
  --target-os="$TARGET_OS" \
  --prefix="${2}/build/${1}" \
  --arch="$NDK_ABI" \
  ${GENERAL} \
  --sysroot="$NDK_SYSROOT" \
  --extra-cflags="-I${TOOLCHAIN_PREFIX}/include $CFLAGS" \
  --disable-shared \
  --enable-static \
  --extra-cflags="-march=i686 -mtune=intel -mssse3 -mfpmath=sse -m32" \
  --extra-ldflags="-lx264 -Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog" \
  --enable-zlib \
  --disable-doc \
  ${MODULES}

  make clean
  make -j${NUMBER_OF_CORES} && make install || exit 1
}

build_x86

echo Android X86 builds finished

popd

