#!/bin/bash

declare -g files=( "0B" "1B" "56B" "57B" "63B" "64B" "65B" "100B" "128B" "10MB" )

declare -gA commands=( ["md5"]="md5" ["sha256"]="sha256" ["blake2s"]="blake2s256" ["blake2b"]="blake2b512" )

> ./ft_ssl_md5/ft_ssl_md5.bats

cat ./ft_ssl_md5/setup.bats >> ./ft_ssl_md5/ft_ssl_md5.bats
echo >> ./ft_ssl_md5/ft_ssl_md5.bats

echo -n "declare -g files=( " >> ./ft_ssl_md5/ft_ssl_md5.bats
for file in "${files[@]}"; do
    echo -n "\"$file\" " >> ./ft_ssl_md5/ft_ssl_md5.bats
done
echo ")" >> ./ft_ssl_md5/ft_ssl_md5.bats
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
    for file in "${files[@]}"; do
        echo >> ./ft_ssl_md5/ft_ssl_md5.bats
        export CMD="$command"
        export OPENSSL_CMD="${commands[$command]}"
        export FILE="$file"
        export INPUT_MODE=""
        envsubst '${CMD} ${OPENSSL_CMD} ${INPUT_MODE} ${FILE}' < ./ft_ssl_md5/openssl_test.template >> ./ft_ssl_md5/ft_ssl_md5.bats
    done
    echo >> ./ft_ssl_md5/ft_ssl_md5.bats
    echo "# bats file_tags=$command,stdin,openssl" >> ./ft_ssl_md5/ft_ssl_md5.bats
    for file in "${files[@]}"; do
        echo >> ./ft_ssl_md5/ft_ssl_md5.bats
        export CMD="$command"
        export OPENSSL_CMD="${commands[$command]}"
        export FILE="$file"
        export INPUT_MODE="< "
        envsubst '${CMD} ${OPENSSL_CMD} ${INPUT_MODE} ${FILE}' < ./ft_ssl_md5/openssl_test.template >> ./ft_ssl_md5/ft_ssl_md5.bats
    done
    echo >> ./ft_ssl_md5/ft_ssl_md5.bats
done
