PROJECT_DIR="."
INFOPLIST_FILE="./arm/Info.plist"

echo "Increment version at plist: $INFOPLIST_FILE"

VERSIONNUM="$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${INFOPLIST_FILE}")"

MINORVERSION=`echo $VERSIONNUM | awk -F "." '{print $2}'`
MAJORVERSION=`echo $VERSIONNUM | awk -F "." '{print $1}'`

MINORVERSION=$(($MINORVERSION + 1))

NEWVERSIONSTRING=`echo $VERSIONNUM | awk -F "." '{print '$MAJORVERSION' "." '$MINORVERSION' }'`

echo "Incremented version: $NEWVERSIONSTRING"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEWVERSIONSTRING" "${PROJECT_DIR}/${INFOPLIST_FILE}"