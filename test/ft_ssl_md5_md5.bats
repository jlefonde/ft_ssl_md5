#!/usr/bin/env bats

setup() {
    load "test_helper/bats-support/load"
    load "test_helper/bats-assert/load"
}

declare -gA files=( ["1B"]="1" ["56B"]="56" ["57B"]="57" ["63B"]="63" ["64B"]="64" ["65B"]="65" ["100B"]="100" ["128B"]="128" ["50MB"]="50MB" )

setup_file() {
    echo "And above all," > file
    echo "" > 0B

    for file in "${!files[@]}"; do
        dd if=/dev/urandom of="$file" bs="${files[$file]}" count=1 > /dev/null 2>&1
    done
}

teardown_file() {
    rm -f file
    rm -f 0B

    for file in "${!files[@]}"; do
        rm -f "$file"
    done
}

# bats file_tags=md5,file,openssl

@test "md5 < 0B" {
    local valgrind_log=$(mktemp)

    run valgrind --log-file="$valgrind_log" ./ft_ssl md5 -q 0B
    
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success

    assert_output $(openssl md5 0B | awk '{print $2}')

    rm -f "$valgrind_log"
}