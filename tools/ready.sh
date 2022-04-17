#!/bin/bash
set -o pipefail

SCRIPT_DIR="$(dirname "$0")"
cd "${SCRIPT_DIR}/.." || exit $?

TMPSCRIPT="${TMPDIR}gureumbuild"

if [ -e "${TMPSCRIPT}" ]; then
    echo "unexpected existing file: ${TMPSCRIPT}"
    echo "현재 다른 구름 빌드가 진행중이거나, 이전의 구름 빌드가 불완전하게 종료되었을 수 있습니다."
    echo "다른 구름 빌드가 실행중이 아니라면 이 파일을 삭제 후 다시 실행해 주세요."
    exit 255
fi

if [ ! "${CONFIGURATION}" ]; then
    CONFIGURATION='Debug'
fi

echo "Configuration: ${CONFIGURATION}"

(xcodebuild -project 'Gureum.xcodeproj' -scheme 'ScriptSupport' \
    -configuration "${CONFIGURATION}" | grep export > "${TMPSCRIPT}") || \
    exit $?
# shellcheck disable=1090
. "${TMPSCRIPT}" > /dev/null 2>&1
rm "${TMPSCRIPT}"

XCVERSION="$(cat OSX/Version.xcconfig)"
# shellcheck disable=2034
PACKAGE_NAME="Gureum-${XCVERSION#VERSION = }"

if [ "${PRODUCT_NAME}" != "Gureum" ]; then
    echo 'something wrong'
    exit 255
fi
