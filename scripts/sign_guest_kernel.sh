#!/bin/bash
set -e
# calculate signature over integrity check data, kernel image and device tree
SIGN_VERSION=0x0200

usage() {
	echo "$0 -p <private_key -i <guest id>  -k <kernel> --d <dtb load address> - D <dtb file> -o <output name>"
	echo ""
	echo "  Create kernel image signature file"
}

while getopts "h?p:l:i:k:a:d:D:o:" opt; do
	case "$opt" in
		h|\?)
			usage
			exit 0
		;;
		p)  PRIV_KEY=$OPTARG
		;;
		i)  GUESTID=$OPTARG
		;;
		k)  KERNEL=$OPTARG
		;;
		d)  DTB_ADDR=$OPTARG
		;;
		D)  DTB_FILE=$OPTARG
		;;
		o)  OUTFILE=$OPTARG
		;;
	esac
done

echo ""
echo "$0 using:"
echo "key=$PRIV_KEY"
echo "guest_id=$GUESTID"
echo "kernel=$KERNEL"
echo "dtb file=$DTB_FILE"
echo "dtb address=$DTB_ADDR"
echo "outfile=$OUTFILE"
echo ""

if [ -z "${PRIV_KEY}" ] || [ -z "${KERNEL}" ] || [ -z "${OUTFILE}" ] ; then
    usage
    echo exit
    exit 1
fi

KERNEL_LEN=$(stat -c"%s" $KERNEL)
#add zeros to end of image so that its size is page multiple
PADS=$(( 4096 - $KERNEL_LEN % 4096 ))

KERNEL_TMP=$(mktemp)
cp ${KERNEL}  ${KERNEL_TMP}

#add zeros to end of image so that its size is page multiple
dd if=/dev/zero of=${KERNEL_TMP} bs=$PADS count=1 oflag=append conv=notrunc > /dev/null 2>&1
KERNEL_LEN=$(stat -c"%s" $KERNEL_TMP)
KERNEL_PAGES=$(( $KERNEL_LEN / 4096 ))

if [ -z "$DTB_FILE" ]; then
	DTB_LEN=0
else
	DTB_LEN=$(stat -c"%s" ${DTB_FILE})
fi

echo -n "SIGN" > ${OUTFILE}
printf "0: %.8x" $(( $SIGN_VERSION )) | sed -E 's/0: (..)(..)(..)(..)/0:\4\3\2\1/' | xxd -r >> ${OUTFILE}
printf "0: %.16x" $(( $KERNEL_LEN ))  | sed -E 's/0: (..)(..)(..)(..)(..)(..)(..)(..)/0:\8\7\6\5\4\3\2\1/' | xxd -r >> ${OUTFILE}
printf "0: %.16x" $(( $DTB_ADDR ))  | sed -E 's/0: (..)(..)(..)(..)(..)(..)(..)(..)/0:\8\7\6\5\4\3\2\1/' | xxd -r >> ${OUTFILE}
printf "0: %.16x" $(( $DTB_LEN ))  | sed -E 's/0: (..)(..)(..)(..)(..)(..)(..)(..)/0:\8\7\6\5\4\3\2\1/' | xxd -r >> ${OUTFILE}

# add guest id to data area
echo -n ${GUESTID} >> ${OUTFILE}
dd if=/dev/zero of=${OUTFILE} bs=$(( 16 - ${#GUESTID} )) count=1 oflag=append conv=notrunc > /dev/null 2>&1

#do signature
cat  ${OUTFILE} ${KERNEL_TMP} ${DTB_FILE} | openssl dgst -sha256 -sign ${PRIV_KEY} >>  ${OUTFILE}

# add zeros to th eend of signarure so that its ize is one page
DATA_LEN=$(stat -c"%s" ${OUTFILE})
PADS=$(( 4096 - $DATA_LEN % 4096 ))
dd if=/dev/zero of=${OUTFILE} bs=$PADS count=1 oflag=append conv=notrunc > /dev/null 2>&1

#copy kernel to output so that first page of kernel is moved to end of image
dd if=${KERNEL_TMP} of=${OUTFILE} ibs=4096 count=$(( $KERNEL_PAGES -1 )) skip=1 oflag=append conv=notrunc > /dev/null 2>&1
dd if=${KERNEL_TMP} of=${OUTFILE} bs=4096 count=1 oflag=append conv=notrunc > /dev/null 2>&1

#copy device tree to output if defined
if [ -n "$DTB_FILE" ]; then
	cat ${DTB_FILE} >> ${OUTFILE}
fi

rm ${KERNEL_TMP}
echo Signature file ${OUTFILE} is ready

