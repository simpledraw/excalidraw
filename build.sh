#!/bin/bash

usage() {
[[ -n $1 ]] && log "$1" ERROR
cat << EOF
Usage:
    $(basename $0) [-v version] [-B] [-P]

Options:
    -v version
    -P push
    -B no build
EOF
exit 1
}

region=hangzhou
version=""
PUSH=""
BUILD="1"
cwd=$(cd $(dirname $0) && pwd)

while getopts "v::BP" option; do
    case ${option} in
        v) version="${OPTARG}";;
        P) PUSH="1";;
        B) BUILD="";;
        *) usage;;
    esac
done

[ "${version}" == "" ] && usage

imageid=simpledraw-draw-site:${version}

echo ">>>>>>> start to build VERSION file"
COMMIT_ID=$(git rev-parse --verify HEAD)
branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
echo "branch=${branch}" > VERSION
echo "commit=${COMMIT_ID}" >> VERSION
echo "version=${version}" >> VERSION
echo "VERSION file as "
cat VERSION

if [ "${BUILD}" == "1" ];
then
echo ">>>>>>> start to build ${imageid}"
docker build . -t ${imageid}
else
echo "ignore build docker."
fi

if [ "${PUSH}" == "1" ];
then
echo ">>>>>>> push to registery ..."
docker tag ${imageid} registry.cn-${region}.aliyuncs.com/datalet/${imageid}
docker push registry.cn-${region}.aliyuncs.com/datalet/${imageid}
echo "<<<<<<< pushed done, please goto server to deploy!"
else
echo "no push, use -P to push it"
fi