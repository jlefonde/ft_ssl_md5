#!/bin/bash

declare -gA files=( ["1B"]="1" ["56B"]="56" ["57B"]="57" ["63B"]="63" ["64B"]="64" ["65B"]="65" ["100B"]="100" ["128B"]="128" ["10MB"]="10MB" )

declare -gA commands=( ["md5"]="md5" ["sha256"]="sha256" ["blake2s"]="blake2s256" ["blake2b"]="blake2b512" )

> ./test/ft_ssl_md5_md5.bats

echo "#!/usr/bin/env bats" >> ./test/ft_ssl_md5_md5.bats
echo >> ./test/ft_ssl_md5_md5.bats

echo "declare -A files" >> ./test/ft_ssl_md5_md5.bats
for key in "${!files[@]}"; do
    echo "files[\"$key\"]=\"${files[$key]}\"" >> ./test/ft_ssl_md5_md5.bats
done
echo >> ./test/ft_ssl_md5_md5.bats

echo "setup() {
    load \"test_helper/bats-support/load\"
    load \"test_helper/bats-assert/load\"
}

setup_file() {
    echo \"And above all,\" > file
    echo \"\" > 0B

    for file in \"\${!files[@]}\"; do
        dd if=/dev/urandom of=\"\$file\" bs=\"\${files[\$file]}\" count=1 > /dev/null 2>&1
    done
}

teardown_file() {
    rm -f file
    rm -f 0B

    for file in \"\${!files[@]}\"; do
        rm -f \"\$file\"
    done
}" >> ./test/ft_ssl_md5_md5.bats
echo >> ./test/ft_ssl_md5_md5.bats

for command in "${!commands[@]}"; do
    echo "# bats file_tags=$command,file,openssl" >> ./test/ft_ssl_md5_md5.bats
    for file in "${!files[@]}"; do
        echo >> ./test/ft_ssl_md5_md5.bats
        export CMD="$command" 
        export OPENSSL_CMD="${commands[$command]}"
        export FILE="$file" 
        envsubst '${CMD} ${OPENSSL_CMD} ${FILE}' < ./test/file_test.template >> ./test/ft_ssl_md5_md5.bats
        echo >> ./test/ft_ssl_md5_md5.bats
    done
    echo >> ./test/ft_ssl_md5_md5.bats
    echo "# bats file_tags=$command,stdin,openssl" >> ./test/ft_ssl_md5_md5.bats
    for file in "${!files[@]}"; do
        echo >> ./test/ft_ssl_md5_md5.bats
        export CMD="$command" 
        export OPENSSL_CMD="${commands[$command]}"
        export FILE="$file" 
        envsubst '${CMD} ${OPENSSL_CMD} ${FILE}' < ./test/stdin_test.template >> ./test/ft_ssl_md5_md5.bats
        echo >> ./test/ft_ssl_md5_md5.bats
    done
done
