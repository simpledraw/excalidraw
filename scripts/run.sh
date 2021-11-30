#!/bin/bash
## scp scripts/run.sh root@ly:~
version=""
port=3000
env=production

usage() {
[[ -n $1 ]] && log "$1" ERROR
cat << EOF
Usage:
    $(basename $0) [-v version]

Options:
    -v version
EOF
exit 1
}

while getopts "v:" option; do
    case ${option} in
        v) version="${OPTARG}";;
        *) usage;;
    esac
done

function dingding()
{
msg="$1"
webhook="https://oapi.dingtalk.com/robot/send?access_token=c0932bdb9105735b758983779284391a6c1ff85f1106b13f7c8eaa10d52b1426"
echo "env ${env} webhook use ${webhook}, host logs dir use ${logdir}"

JSON=$(cat <<EOF
{"msgtype": "text","text": {"content":"TEST/运维日志 draw-site更新完毕, version ${version}: ${msg}"}}
EOF
)
curl "${webhook}" \
 -H 'Content-Type: application/json' \
 -d "${JSON}"
}

test "${version}" = "" && usage

image=sampledraw-draw-site:${version}
image_url=registry-vpc.cn-qigndao.aliyuncs.com/datalet/${image}
name=sampledraw-draw-site-instance-${port}
docker pull ${image_url}

echo ">>> stop old instance - ${name}..."
docker stop ${name}

echo ">>> start new instance ..."
 docker run -d --name ${name} -e NODE_ENV=${env} -e ENV=${env} -p ${port}:80 --rm ${image_url}

site=http://localhost:${port}/
echo "restart done, verify it by curl index page - ${site}"
