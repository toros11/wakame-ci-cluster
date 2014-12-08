#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

boxes="
     minimal-6.6-x86_64.kvm.box
"

function download_file() {
  local filename=${1}
  if [[ -f ${filename}.tmp ]]; then
    # %Y time of last modification, seconds since Epoc
    local lastmod=$(stat -c %Y ${filename}.tmp)
    local now=$(date +%s)
    local ttl=$((60 * 60 * 6)) # 6 hours

    if [[ "$((${now} - ${lastmod}))" -lt ${ttl} ]]; then
      return 0
    fi

    rm -f ${filename}.tmp
  fi

  curl -fSkLR --retry 3 --retry-delay 3 http://dlc.wakame.axsh.jp/wakameci/kemumaki-box-rhel6/current/${filename} -o ${filename}.tmp
  mv ${filename}.tmp ${filename}
}

for box in ${boxes}; do
  echo ... ${box}

  download_file ${box}.md5
  remote_md5=$(< ${box}.md5)

  if [[ -f ${box} ]]; then
    local_md5=$(md5sum ${box} | awk '{print $1}')
    [[ "${remote_md5}" == "${local_md5}" ]] && continue
  fi

  download_file ${box}
done
