#! /bin/sh

set -e

# convert 'package' source placed in .tmp/package to 'packagex' sources and
# store them in .tmp/packagex

ROOT=$(readlink -f "$(dirname $0)/..")
SOURCE=".tmp/package"
TARGET=".tmp/packagex"

function do_convert {
  rm -rf "${TARGET}/lib/puppet"
  find "${SOURCE}/lib/puppet" -type f | grep -v '\.swp$' | while read F; do 
      F2=$(echo $F | sed -e "s:^${SOURCE}:${TARGET}:" -e 's/\<package\>/packagex/');
      D2=$(dirname $F2);
      test -e $D2 || mkdir -p $D2;
      cp $F $F2; 
    done
  find "${TARGET}/lib/puppet" -type f | grep -v '\.swp$'  | xargs sed -i \
      -e 's/:\<package\>/:packagex/g' \
      -e 's/\<Puppet::\(Type\|Provider\)::Package\>/Puppet::\1::Packagex/g' \
      -e 's:\<puppet/\(type\|provider\)/package\>:puppet/\1/packagex:g' \
      -e 's/Package\[openssl\]/Packagex\[openssl\]/g'
}

(cd $ROOT && do_convert)
echo "conversion complete, results stored to ${TARGET}"
