#!/bin/bash
## scp scripts/run-simpledraw-draw.sh root@hz1:~/run-simpledraw-draw.sh
version=""
env=""
region=hangzhou
dingding_kw=TEST
webhook=""

usage() {
[[ -n $1 ]] && log "$1" ERROR
cat << EOF
Usage:
    $(basename $0) [-v version] [-e environment]

Options:
    -v version
    -e production|staging
EOF
exit 1
}

while getopts "v:e:" option; do
    case ${option} in
        v) version="${OPTARG}";;
        e) env="${OPTARG}";;
        *) usage;;
    esac
done

test "${env}" == "" && usage && exit -2;

if [ "${env}" == "production" ];
then
port=14100
webhook="https://oapi.dingtalk.com/robot/send?access_token=cf01cb3536ee59b83c47b922072a4213bf62fbda5d15056610b103161ef6b90f"
dingding_kw=运维事件
echo "port use ${port} for env ${env}"
else
port=3000
webhook="https://oapi.dingtalk.com/robot/send?access_token=660224cc307d43d9cf235dddf06cf5e255f0c0cb9a2704c6e14cbe97109539c2"
echo "port use ${port} for env ${env}"
fi

function dingding()
{
msg="$1"
echo "env ${env} webhook use ${webhook}, host logs dir use ${logdir}"

JSON=$(cat <<EOF
{"msgtype": "text","text": {"content":"${dingding_kw} draw-site更新完毕, version ${version}: ${msg}"}}
EOF
)
curl "${webhook}" \
 -H 'Content-Type: application/json' \
 -d "${JSON}"
}

test "${version}" = "" && usage

image=simpledraw-draw:${version}
image_url=registry-vpc.cn-${region}.aliyuncs.com/datalet/${image}
name=simpledraw-draw-instance-${port}
docker pull ${image_url}

echo ">>> stop old instance - ${name}..."
docker stop ${name}

echo ">>> start new instance ..."
docker run -d --name ${name} -e NODE_ENV=${env} -e ENV=${env} -p ${port}:80 --rm ${image_url}

site=http://localhost:${port}/
echo "restart done, verify it by curl index page - ${site}"
curl ${site}

dingding
