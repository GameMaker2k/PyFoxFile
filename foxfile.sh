#!/usr/bin/env bash

function PackFoxFile {
 shopt -s globstar
 curinode=0
 numfiles=$(find "${1}" -mindepth 1 -print | wc -l)
 echo -n -e 'FoxFile1\x00${numfiles}\x00' > ${2}
 for file in ${1}/**; do
  fname="${file%/}"
  echo "${fname}"
  flinkname=""
  fcurinode=${curinode}
  finode=$(stat -c %i ${fname})
  ftype=0
  if [ -f ${fname} ]; then
   ftype=0
   fsize=$(printf "%x" $(stat -c %s ${fname}))
  fi
  if [ -L ${fname} ]; then
   ftype=2
   fsize=0
   flinkname="$(readlink -f ${fname})"
  fi
  if [ -c ${fname} ]; then
   ftype=3
   fsize=0
  fi
  if [ -b ${fname} ]; then
   ftype=4
   fsize=0
  fi
  if [ -d ${fname} ]; then
   ftype=5
   fsize=0
  fi
  if [ -p ${fname} ]; then
   ftype=6
   fsize=0
  fi
  if [ -f ${fname} ]; then
   if [[ ${inodetofile[${finode}]} ]]; then
    ftype=1
    flinkname=${inodetofile[${finode}]}
   else
    inodetofile[${finode}]=${fname}
    curinode=$[curinode + 1]
   fi
  fi
  fdev_minor=$(printf "%x" $(stat -c %T ${fname}))
  fdev_major=$(printf "%x" $(stat -c %t ${fname}))
  fatime=$(printf "%x" $(stat -c %X ${fname}))
  fmtime=$(printf "%x" $(stat -c %Y ${fname}))
  fctime=$(printf "%x" $(stat -c %Z ${fname}))
  fbtime=$(printf "%x" $(stat -c %Z ${fname}))
  fmode=$(stat -c %f ${fname})
  fchmode=$(printf "%x" 0$(stat -c %a ${fname}))
  fuid=$(printf "%x" $(stat -c %u ${fname}))
  fgid=$(printf "%x" $(stat -c %g ${fname}))
  funame=$(stat -c %U ${fname})
  fgname=$(stat -c %G ${fname})
  flinkcount=$(printf "%x" $(stat -c %h ${fname}))
  finodehex=$(printf "%x" ${finode})
  ftypehex=$(printf "%x" ${ftype})
  tmpfile=$(mktemp);
  echo -n "${ftypehex}" > ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fname}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${flinkname}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fsize}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fatime}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fmtime}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fctime}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fbtime}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fmode}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fuid}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${funame}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fgid}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fgname}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fcurinode}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${finodehex}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${flinkcount}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fdev_minor}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fdev_major}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fdev_minor}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "${fdev_major}" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  echo -n "0" >> ${tmpfile}
  echo -n -e '\x00' >> ${tmpfile}
  if [ "${4}" == "none" ]; then
   echo -n "${4}" >> ${tmpfile}
   echo -n -e '\x00' >> ${tmpfile}
   foxfileheadercshex="0"
   foxfilecontentcshex="0"
  elif [ "${4}" == "crc32" ] || [ "${4}" == "" ]; then
   echo -n "" >> ${tmpfile}
   echo -n -e '\x00' >> ${tmpfile}
   foxfileheadercshex=$(crc32 ${tmpfile} | cut -d ' ' -f 1)
   if [ -f ${fname} ]; then
    foxfilecontentcshex=$(crc32 ${fname} | cut -d ' ' -f 1)
   else
    foxfilecontentcshex=$(crc32 /dev/null | cut -d ' ' -f 1)
   fi
  elif [ "${4}" == "md5" ]; then
   echo -n "md5" >> ${tmpfile}
   echo -n -e '\x00' >> ${tmpfile}
   foxfileheadercshex=$(md5sum ${tmpfile} | cut -d ' ' -f 1)
   if [ -f ${fname} ]; then
    foxfilecontentcshex=$(md5sum ${fname} | cut -d ' ' -f 1)
   else
    foxfilecontentcshex=$(md5sum /dev/null | cut -d ' ' -f 1)
   fi
  elif [ "${4}" == "sha1" ]; then
   echo -n "${4}" >> ${tmpfile}
   echo -n -e '\x00' >> ${tmpfile}
   foxfileheadercshex=$(sha1sum ${tmpfile} | cut -d ' ' -f 1)
   if [ -f ${fname} ]; then
    foxfilecontentcshex=$(sha1sum ${fname} | cut -d ' ' -f 1)
   else
    foxfilecontentcshex=$(sha1sum /dev/null | cut -d ' ' -f 1)
   fi
  elif [ "${4}" == "sha224" ]; then
   echo -n "${4}" >> ${tmpfile}
   echo -n -e '\x00' >> ${tmpfile}
   foxfileheadercshex=$(sha224sum ${tmpfile} | cut -d ' ' -f 1)
   if [ -f ${fname} ]; then
    foxfilecontentcshex=$(sha224sum ${fname} | cut -d ' ' -f 1)
   else
    foxfilecontentcshex=$(sha224sum /dev/null | cut -d ' ' -f 1)
   fi
  elif [ "${4}" == "sha256" ]; then
   echo -n "${4}" >> ${tmpfile}
   echo -n -e '\x00' >> ${tmpfile}
   foxfileheadercshex=$(sha256sum ${tmpfile} | cut -d ' ' -f 1)
   if [ -f ${fname} ]; then
    foxfilecontentcshex=$(sha256sum ${fname} | cut -d ' ' -f 1)
   else
    foxfilecontentcshex=$(sha256sum /dev/null | cut -d ' ' -f 1)
   fi
  elif [ "${4}" == "sha384" ]; then
   echo -n "${4}" >> ${tmpfile}
   echo -n -e '\x00' >> ${tmpfile}
   foxfileheadercshex=$(sha384sum ${tmpfile} | cut -d ' ' -f 1)
   if [ -f ${fname} ]; then
    foxfilecontentcshex=$(sha384sum ${fname} | cut -d ' ' -f 1)
   else
    foxfilecontentcshex=$(sha384sum /dev/null | cut -d ' ' -f 1)
   fi
  elif [ "${4}" == "sha512" ]; then
   echo -n "${4}" >> ${tmpfile}
   echo -n -e '\x00' >> ${tmpfile}
   foxfileheadercshex=$(sha512sum ${tmpfile} | cut -d ' ' -f 1)
   if [ -f ${fname} ]; then
    foxfilecontentcshex=$(sha512sum ${fname} | cut -d ' ' -f 1)
   else
    foxfilecontentcshex=$(sha512sum /dev/null | cut -d ' ' -f 1)
   fi
  else
   echo -n "crc32" >> ${tmpfile}
   echo -n -e '\x00' >> ${tmpfile}
   foxfileheadercshex=$(crc32 ${tmpfile} | cut -d ' ' -f 1)
   if [ -f ${fname} ]; then
    foxfilecontentcshex=$(crc32 ${fname} | cut -d ' ' -f 1)
   else
    foxfilecontentcshex=$(crc32 /dev/null | cut -d ' ' -f 1)
   fi
  fi
  cat ${tmpfile} >> ${2}
  rm -rf ${tmpfile}
  echo -n "${foxfileheadercshex}" >> ${2}
  echo -n -e '\x00' >> ${2}
  echo -n "${foxfilecontentcshex}" >> ${2}
  echo -n -e '\x00' >> ${2}
  if [ -f ${fname} ]; then
   cat ${fname} >> ${2}
  fi
  echo -n -e '\x00' >> ${2}
 done
 if [ "${3}" == "gzip" ]; then
  gzip --quiet --best ${2}
 elif [ "${3}" == "bzip2" ]; then
  gzip --compress --quiet --best ${2}
 elif [ "${3}" == "zstd" ]; then
  zstd -19 --rm -qq --format=zstd ${2}
 elif [ "${3}" == "lz4" ]; then
  lz4 -9 -z --rm -qq ${2}
 elif [ "${3}" == "lzo" ]; then
  lzop -9 -U -q ${2}
 elif [ "${3}" == "lzma" ]; then
  lzma --compress --quiet -9 --extreme ${2}
 elif [ "${3}" == "xz" ]; then
  xz --compress --quiet -9 --extreme ${2}
 elif [ "${3}" == "brotli" ]; then
  brotli --rm --best ${2}
 fi
}

PackFoxFile "${1}" "${2}" "${3}" "${4}"
