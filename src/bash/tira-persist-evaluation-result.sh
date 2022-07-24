#!/bin/bash -e

SRC_DIR=${TIRA_EVALUATION_OUTPUT_DIR}

DIR_TO_CHANGE=$(echo ${TIRA_OUTPUT_DIR}| awk -F '/output' '{print $1}')


if [ -f "${DIR_TO_CHANGE}/job-to-execute.txt" ]; then

    git remote set-url origin "https://$(cat /etc/tira-git-credentials/GITCREDENTIALUSERNAME):$(cat /etc/tira-git-credentials/GITCREDENTIALPASSWORD)@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git"

    git remote get-url origin

    git config user.email "tira-automation@tira.io"
    git config user.name "TIRA Automation"

    mv ${DIR_TO_CHANGE}/job-to-execute.txt ${DIR_TO_CHANGE}/job-executed-on-$(date +'%Y-%m-%d-%I-%M-%S').txt
    git rm ${DIR_TO_CHANGE}/job-to-execute.txt
    git add ${DIR_TO_CHANGE}/executed-job.txt
    git commit -m "TIRA-Automation: software was executed and evaluated." || echo "No changes to commit"

    git push -o ci.skip origin HEAD:$CI_COMMIT_BRANCH
else
    echo "The file ${DIR_TO_CHANGE}/job-to-execute.txt does not exist, I cant change it."
fi

if [ -f "${TIRA_FINAL_EVALUATION_OUTPUT_DIR}" ]; then
    echo "${TIRA_FINAL_EVALUATION_OUTPUT_DIR} exists already. Exit."
    exit 0
fi

if [ -d "${TIRA_FINAL_EVALUATION_OUTPUT_DIR}" ]; then
    echo "${TIRA_FINAL_EVALUATION_OUTPUT_DIR} exists already. Exit."
    exit 0
fi

mkdir -p "${SRC_DIR}"
mkdir -p "${TIRA_FINAL_EVALUATION_OUTPUT_DIR}"

echo "cp -r ${SRC_DIR} ${TIRA_FINAL_EVALUATION_OUTPUT_DIR}"
cp -r ${SRC_DIR} ${TIRA_FINAL_EVALUATION_OUTPUT_DIR}

env|grep 'TIRA' >> task.env

