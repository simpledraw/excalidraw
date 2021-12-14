#!/bin/bash

# deploy to server
env=staging
server=root@hz1
logdir=/logs/${env}

while getopts "e:" option; do
    case ${option} in
        e) env="${OPTARG}";;
        *) usage;;
    esac
done

if [ "${env}" = "staging" ];
then
webhook="https://oapi.dingtalk.com/robot/send?access_token=c0932bdb9105735b758983779284391a6c1ff85f1106b13f7c8eaa10d52b1426"
port=3000
else
echo "unsupport env ${env}"
exit -2
fi

branch=`git branch |grep '*'|awk '//{print $2}'`
re=".*/v(.*)$"
if [[ $branch =~ $re ]]; then
version=${BASH_REMATCH[1]}
fi

echo "deploy branch as ${branch}, version ${version}"

rootdir='~/excalidraw'

workdir=${rootdir}
echo "deploy api to ${server} for branch ${branch}"

echo ">>>>>>>> fetch code from branch ${branch} ..."
ssh ${server} "cd ${workdir};git clean -fd; git reset --hard; git checkout master; git branch -D ${branch}; git fetch origin ${branch}:${branch};git checkout ${branch}; git status"
echo ">>>>>>>> fetch code done..."

image=simpledraw-excalidraw:${version}
name=simpledraw-excalidraw-instance-${port}

echo ">>>>>>>> rebuild the docker image - ${image}..."
ssh ${server} "cd ${workdir}; docker build . -t ${image}"
echo "<<<<<<<< build docker image ${image} done..."
echo

echo ">>>>>>>> restart instance - ${name}..."
ssh ${server} "docker stop ${name}; docker run -d --name ${name} -e NODE_ENV=${env} -e ENV=${env} -p ${port}:80 --rm ${image}"

api=http://localhost:${port}/
echo ">>>>>>>> verify site - ${api}"
ssh ${server} "sleep 2; curl ${api}"
echo "<<<<<<<< verify done."

JSON=$(cat <<EOF
{"msgtype": "text","text": {"content":"TEST/日志 ${env} server更新完毕, 分支 ${branch} 版本 ${version}"}}
EOF
)
curl "${webhook}" \
 -H 'Content-Type: application/json' \
 -d "${JSON}"