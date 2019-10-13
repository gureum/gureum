#!/bin/bash
set -o pipefail

SCRIPT_DIR="$(dirname "$0")"
cd "${SCRIPT_DIR}/.." || exit $?

TMPSCRIPT="${TMPDIR}gureumbuild"

if [ -e "${TMPSCRIPT}" ]; then
    echo "unexpected existing file: ${TMPSCRIPT}"
    exit 255
fi

if [ ! "${CONFIGURATION}" ]; then
    CONFIGURATION='Debug'
fi

echo "Configuration: ${CONFIGURATION}"

(xcodebuild -workspace 'Gureum.xcworkspace' -scheme 'ScriptSupport' -configuration "${CONFIGURATION}" | grep export > "${TMPSCRIPT}") || exit $?
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
