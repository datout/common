#!/bin/bash
# https://github.com/281677160/build-actions
# common Module by 28677160
# matrix.target=${FOLDER_NAME}
cd ${GITHUB_WORKSPACE}

if [[ ! -d "build" ]]; then
  echo "根目录缺少build文件夹存在"
  SYNCHRONISE="2"
elif [[ ! -d "build/${FOLDER_NAME}" ]]; then
  echo "build文件夹内缺少${FOLDER_NAME}文件夹存在"
  exit 1
elif [[ ! -d "build/${FOLDER_NAME}/relevance" ]]; then
  echo "build文件夹内的${FOLDER_NAME}缺少relevance文件夹存在"
  SYNCHRONISE="2"
elif [[ ! -f "build/${FOLDER_NAME}/relevance/actions_version" ]]; then
  echo "缺少build/${FOLDER_NAME}/relevance/actions_version文件"
  SYNCHRONISE="2"
elif [[ -f "build/${FOLDER_NAME}/relevance/actions_version" ]]; then
  bash <(curl -fsSL https://raw.githubusercontent.com/281677160/common/main/xiugai.sh)
  ACTIONS_VERSION="${ACTIONS_VERSION}"
  A="$(grep -E "a=.*" GITHUB_ENV |grep -Eo [0-9]+\.[0-9]+\.[0-9]+)"
  B="$(echo "${A}" |grep -Eo [0-9]+\.[0-9]+\.[0-9]+ |cut -d"." -f1)"
  C="$(echo "${ACTIONS_VERSION}" |grep -Eo [0-9]+\.[0-9]+\.[0-9]+ |cut -d"." -f1)"
  if [[ "${B}" != "${C}"]]; then
    SYNCHRONISE="2"
  elif [[ "${A}" != "${ACTIONS_VERSION}"]]; then
    SYNCHRONISE="1"
  else
    SYNCHRONISE="0"
  fi
else
  SYNCHRONISE="0"
fi



function Diy_continue() {
git clone -b main --depth 1 https://github.com/281677160/common build/common
mv -f build/common/upgrade.sh build/${FOLDER_NAME}/upgrade.sh
mv -f build/common/xiugai.sh build/${FOLDER_NAME}/common.sh
sudo chmod -R +x build
}

function Diy_synchronise() {
export TONGBU_CANGKU="1"
export GIT_REPOSITORY="${GIT_REPOSITORY}"
export REPO_TOKEN="${REPO_TOKEN}"

cp -Rf ${GITHUB_WORKSPACE}/build/common/bendi/tongbu.sh ${GITHUB_WORKSPACE}/tongbu.sh
source ${GITHUB_WORKSPACE}/tongbu.sh && menu2
cd ${GITHUB_WORKSPACE}/repogx
git add .
git commit -m "强制同步上游仓库 $(date +%Y-%m%d-%H%M%S)"
git push --force "https://${REPO_TOKEN}@github.com/${GIT_REPOSITORY}" HEAD:main
exit 1
}