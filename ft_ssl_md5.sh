#!/bin/bash

declare -gA files=( ["1B"]="1" ["56B"]="56" ["57B"]="57" ["63B"]="63" ["64B"]="64" ["65B"]="65" ["100B"]="100" ["128B"]="128" ["50MB"]="50MB" )

declare -gA commands=( ["md5"]="md5" ["sha256"]="sha256" ["blake2s"]="blake2s256" ["blake2b"]="blake2b512" )

> md5_test

for command in "${!commands[@]}"; do
    echo "# bats file_tags=$command,file,openssl" >> md5_test
    for file in "${!files[@]}"; do
        echo >> md5_test
        export CMD="$command" 
        export OPENSSL_CMD="${commands[$command]}"
        export FILE="$file" 
        envsubst '${CMD} ${OPENSSL_CMD} ${FILE}' < ./test/file_test.template >> md5_test
        echo >> md5_test
    done
    echo >> md5_test
    echo "# bats file_tags=$command,stdin,openssl" >> md5_test
    for file in "${!files[@]}"; do
        echo >> md5_test
        export CMD="$command" 
        export OPENSSL_CMD="${commands[$command]}"
        export FILE="$file" 
        envsubst '${CMD} ${OPENSSL_CMD} ${FILE}' < ./test/stdin_test.template >> md5_test
        echo >> md5_test
    done
done
