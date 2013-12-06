#! /bin/sh

set -e

# copy sources from puppetlabs/puppet and extract to .tmp/package/lib/puppet
# what is interesting for us

if [ $# -lt 1 ]; then
  echo "error: missing argument" >&2
  echo "syntax:" >&2
  echo "  $0 dir/to/puppet/source" >&2
  exit 1
fi

ROOT=$(readlink -f "$(dirname $0)/..")
SOURCE=$(readlink -ef $1)
TARGET=".tmp/package"

function do_import {
  rm -rf "${TARGET}/lib/puppet"
  (find "${SOURCE}/lib/puppet/provider/package" -type f; \
   ls   "${SOURCE}/lib/puppet/provider/package.rb" \
        "${SOURCE}/lib/puppet/type/package.rb") | grep -v '\.swp$' |\
    while read F; do 
      F2=$(echo $F | sed -e "s:^${SOURCE}:${TARGET}:") ;
      D2=$(dirname $F2);
      test -e $D2 || mkdir -p $D2;
      cp $F $F2; 
    done
}

(cd $ROOT && do_import)
echo "import complete, results went to ${TARGET}"
