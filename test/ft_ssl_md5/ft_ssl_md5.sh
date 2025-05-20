#!/bin/bash

declare -gA files=( ["1B"]="1" ["56B"]="56" ["57B"]="57" ["63B"]="63" ["64B"]="64" ["65B"]="65" ["100B"]="100" ["128B"]="128" ["10MB"]="10MB" )

declare -gA commands=( ["md5"]="md5" ["sha256"]="sha256" ["blake2s"]="blake2s256" ["blake2b"]="blake2b512" )

> ./ft_ssl_md5/ft_ssl_md5.bats

cat ./ft_ssl_md5/setup.bats >> ./ft_ssl_md5/ft_ssl_md5.bats
echo >> ./ft_ssl_md5/ft_ssl_md5.bats

echo "declare -gA files" >> ./ft_ssl_md5/ft_ssl_md5.bats
for file in "${!files[@]}"; do
    echo "files[\"$file\"]=\"${files[$file]}\"" >> ./ft_ssl_md5/ft_ssl_md5.bats
done
echo >> ./ft_ssl_md5/ft_ssl_md5.bats

for command in "${!commands[@]}"; do
    echo "# bats file_tags=$command,subject" >> ./ft_ssl_md5/ft_ssl_md5.bats
    echo >> ./ft_ssl_md5/ft_ssl_md5.bats
    export CMD="$command"
    export CMD_UPPERCASE=$(echo $CMD | tr a-z A-Z)
    export OPENSSL_CMD="${commands[$command]}"
    envsubst '${CMD} ${CMD_UPPERCASE} ${OPENSSL_CMD}' < ./ft_ssl_md5/subject_test.template >> ./ft_ssl_md5/ft_ssl_md5.bats
    echo >> ./ft_ssl_md5/ft_ssl_md5.bats

    echo "# bats file_tags=$command,file,openssl" >> ./ft_ssl_md5/ft_ssl_md5.bats
    for file in "${!files[@]}"; do
        echo >> ./ft_ssl_md5/ft_ssl_md5.bats
        export CMD="$command"
        export OPENSSL_CMD="${commands[$command]}"
        export FILE="$file"
        export INPUT_MODE=""
        envsubst '${CMD} ${OPENSSL_CMD} ${INPUT_MODE} ${FILE}' < ./ft_ssl_md5/openssl_test.template >> ./ft_ssl_md5/ft_ssl_md5.bats
    done
    echo >> ./ft_ssl_md5/ft_ssl_md5.bats
    echo "# bats file_tags=$command,stdin,openssl" >> ./ft_ssl_md5/ft_ssl_md5.bats
    for file in "${!files[@]}"; do
        echo >> ./ft_ssl_md5/ft_ssl_md5.bats
        export CMD="$command"
        export OPENSSL_CMD="${commands[$command]}"
        export FILE="$file"
        export INPUT_MODE="< "
        envsubst '${CMD} ${OPENSSL_CMD} ${INPUT_MODE} ${FILE}' < ./ft_ssl_md5/openssl_test.template >> ./ft_ssl_md5/ft_ssl_md5.bats
    done
    echo >> ./ft_ssl_md5/ft_ssl_md5.bats
done
