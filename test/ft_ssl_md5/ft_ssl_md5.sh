#!/bin/bash

declare -gA files=( ["1B"]="1" ["56B"]="56" ["57B"]="57" ["63B"]="63" ["64B"]="64" ["65B"]="65" ["100B"]="100" ["128B"]="128" ["10MB"]="10MB" )

declare -gA commands=( ["md5"]="md5" ["sha256"]="sha256" ["blake2s"]="blake2s256" ["blake2b"]="blake2b512" )

> test.bats

echo "#!/usr/bin/env bats" >> test.bats
echo >> test.bats

echo "declare -A files" >> test.bats
for file in "${!files[@]}"; do
    echo "files[\"$file\"]=\"${files[$file]}\"" >> test.bats
done
echo >> test.bats

echo "setup() {
    load \"../test_helper/bats-support/load\"
    load \"../test_helper/bats-assert/load\"
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
}" >> test.bats
echo >> test.bats

for command in "${!commands[@]}"; do
    echo "# bats file_tags=$command,file,openssl" >> test.bats
    for file in "${!files[@]}"; do
        echo >> test.bats
        export CMD="$command"
        export OPENSSL_CMD="${commands[$command]}"
        export FILE="$file"
        export INPUT_MODE=""
        envsubst '${CMD} ${OPENSSL_CMD} ${INPUT_MODE} ${FILE}' < ./openssl_test.template >> test.bats
        echo >> test.bats
    done
    echo >> test.bats
    echo "# bats file_tags=$command,stdin,openssl" >> test.bats
    for file in "${!files[@]}"; do
        echo >> test.bats
        export CMD="$command"
        export OPENSSL_CMD="${commands[$command]}"
        export FILE="$file"
        export INPUT_MODE="< "
        envsubst '${CMD} ${OPENSSL_CMD} ${INPUT_MODE} ${FILE}' < ./openssl_test.template >> test.bats
        echo >> test.bats
    done
done
