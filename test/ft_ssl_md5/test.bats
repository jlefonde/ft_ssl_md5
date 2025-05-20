#!/usr/bin/env bats

declare -A files
files["65B"]="65"
files["56B"]="56"
files["64B"]="64"
files["128B"]="128"
files["63B"]="63"
files["100B"]="100"
files["10MB"]="10MB"
files["1B"]="1"
files["57B"]="57"

setup() {
    load "../test_helper/bats-support/load"
    load "../test_helper/bats-assert/load"
}

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

@test "md5 65B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 65B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 65B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 56B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 56B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 56B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 64B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 64B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 64B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 128B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 128B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 128B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 63B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 63B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 63B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 100B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 100B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 100B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 10MB" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 10MB
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 10MB | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 1B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 1B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 1B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 57B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 57B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 57B | awk '{print $2}')
    rm -f "$valgrind_log"
}


# bats file_tags=md5,stdin,openssl

@test "md5 < 65B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 65B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 < 65B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 < 56B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 56B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 < 56B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 < 64B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 64B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 < 64B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 < 128B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 128B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 < 128B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 < 63B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 63B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 < 63B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 < 100B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 100B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 < 100B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 < 10MB" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 10MB
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 < 10MB | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 < 1B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 1B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 < 1B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "md5 < 57B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 57B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 < 57B | awk '{print $2}')
    rm -f "$valgrind_log"
}

# bats file_tags=blake2s,file,openssl

@test "blake2s 65B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 65B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 65B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s 56B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 56B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 56B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s 64B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 64B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 64B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s 128B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 128B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 128B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s 63B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 63B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 63B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s 100B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 100B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 100B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s 10MB" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 10MB
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 10MB | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s 1B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 1B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 1B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s 57B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 57B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 57B | awk '{print $2}')
    rm -f "$valgrind_log"
}


# bats file_tags=blake2s,stdin,openssl

@test "blake2s < 65B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 65B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 < 65B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s < 56B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 56B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 < 56B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s < 64B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 64B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 < 64B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s < 128B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 128B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 < 128B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s < 63B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 63B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 < 63B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s < 100B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 100B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 < 100B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s < 10MB" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 10MB
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 < 10MB | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s < 1B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 1B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 < 1B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2s < 57B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 57B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 < 57B | awk '{print $2}')
    rm -f "$valgrind_log"
}

# bats file_tags=sha256,file,openssl

@test "sha256 65B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 65B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 65B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 56B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 56B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 56B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 64B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 64B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 64B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 128B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 128B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 128B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 63B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 63B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 63B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 100B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 100B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 100B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 10MB" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 10MB
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 10MB | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 1B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 1B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 1B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 57B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 57B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 57B | awk '{print $2}')
    rm -f "$valgrind_log"
}


# bats file_tags=sha256,stdin,openssl

@test "sha256 < 65B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 65B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 < 65B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 < 56B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 56B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 < 56B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 < 64B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 64B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 < 64B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 < 128B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 128B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 < 128B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 < 63B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 63B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 < 63B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 < 100B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 100B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 < 100B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 < 10MB" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 10MB
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 < 10MB | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 < 1B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 1B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 < 1B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "sha256 < 57B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 57B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 < 57B | awk '{print $2}')
    rm -f "$valgrind_log"
}

# bats file_tags=blake2b,file,openssl

@test "blake2b 65B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 65B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 65B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b 56B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 56B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 56B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b 64B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 64B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 64B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b 128B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 128B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 128B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b 63B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 63B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 63B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b 100B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 100B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 100B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b 10MB" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 10MB
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 10MB | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b 1B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 1B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 1B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b 57B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 57B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 57B | awk '{print $2}')
    rm -f "$valgrind_log"
}


# bats file_tags=blake2b,stdin,openssl

@test "blake2b < 65B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 65B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 < 65B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b < 56B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 56B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 < 56B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b < 64B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 64B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 < 64B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b < 128B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 128B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 < 128B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b < 63B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 63B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 < 63B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b < 100B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 100B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 < 100B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b < 10MB" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 10MB
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 < 10MB | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b < 1B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 1B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 < 1B | awk '{print $2}')
    rm -f "$valgrind_log"
}


@test "blake2b < 57B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 57B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 < 57B | awk '{print $2}')
    rm -f "$valgrind_log"
}

