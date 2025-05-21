#!/usr/bin/env bats

setup() {
    load "../test_helper/bats-support/load"
    load "../test_helper/bats-assert/load"
}

setup_file() {
    echo "And above all," > file

    for file in "${files[@]}"; do
        if [ "$file" = "0B" ]; then
            > 0B
        elif [[ "${file: -2:1}" =~ ^[0-9]+$ ]] && [ "${file: -1}" = "B" ]; then
            dd if=/dev/urandom of="$file" bs="${file%?}" count=1 > /dev/null 2>&1
        else
            dd if=/dev/urandom of="$file" bs="$file" count=1 > /dev/null 2>&1
        fi
    done
}

teardown_file() {
    rm -f file

    for file in "${files[@]}"; do
        rm -f "$file"
    done
}

declare -g files=( "0B" "1B" "56B" "57B" "63B" "64B" "65B" "100B" "128B" "10MB" )

# bats file_tags=md5,subject

@test "echo \"42 is nice\" | ../ft_ssl md5" {
    run ../ft_ssl md5 <<< "42 is nice"
    assert_output "(stdin)= $(openssl md5 <<< "42 is nice" | awk '{print $2}')"
}

@test "echo \"42 is nice\" | ../ft_ssl md5 -p" {
    run ../ft_ssl md5 -p <<< "42 is nice"
    assert_output "(\"42 is nice\")= $(openssl md5 <<< "42 is nice" | awk '{print $2}')"
}

@test "echo \"Pity the living.\" | ../ft_ssl md5 -q -r" {
    run ../ft_ssl md5 -q -r <<< "Pity the living."
    assert_output "$(openssl md5 <<< "Pity the living." | awk '{print $2}')"
}

@test "../ft_ssl md5 file" {
    run ../ft_ssl md5 file
    assert_output "MD5 (file) = $(openssl md5 file | awk '{print $2}')"
}

@test "../ft_ssl md5 -r file" {
    run ../ft_ssl md5 -r file
    assert_output "$(openssl md5 file | awk '{print $2}') file"
}

@test "../ft_ssl md5 -s \"pity those that aren't following baerista on spotify.\"" {
    run ../ft_ssl md5 -s "pity those that aren't following baerista on spotify."
    assert_output "MD5 (\"pity those that aren't following baerista on spotify.\") = $(echo -n "pity those that aren't following baerista on spotify." | openssl md5 | awk '{print $2}')"
}

@test "echo \"be sure to handle edge cases carefully\" | ../ft_ssl md5 -p file" {
    run ../ft_ssl md5 -p file <<< "be sure to handle edge cases carefully"
    assert_output "(\"be sure to handle edge cases carefully\")= $(openssl md5 <<< "be sure to handle edge cases carefully" | awk '{print $2}')
MD5 (file) = $(openssl md5 file | awk '{print $2}')"
}

@test "echo \"some of this will not make sense at first\" | ../ft_ssl md5 file" {
    run ../ft_ssl md5 file <<< "some of this will not make sense at first"
    assert_output "MD5 (file) = $(openssl md5 file | awk '{print $2}')"
}

@test "echo \"but eventually you will understand\" | ../ft_ssl md5 -p -r file" {
    run ../ft_ssl md5 -p -r file <<< "but eventually you will understand"
    assert_output "(\"but eventually you will understand\")= $(openssl md5 <<< "but eventually you will understand" | awk '{print $2}')
$(openssl md5 file | awk '{print $2}') file"
}

@test "echo \"GL HF let's go\" | ../ft_ssl md5 -p -s \"foo\" file" {
    run ../ft_ssl md5 -p -s "foo" file <<< "GL HF let's go"
    assert_output "(\"GL HF let's go\")= $(openssl md5 <<< "GL HF let's go" | awk '{print $2}')
MD5 (\"foo\") = $(echo -n "foo" | openssl md5 | awk '{print $2}')
MD5 (file) = $(openssl md5 file | awk '{print $2}')"
}

@test "echo \"one more thing\" | ../ft_ssl md5 -r -p -s \"foo\" file -s \"bar\"" {
    run ../ft_ssl md5 -r -p -s "foo" file -s "bar" <<< "one more thing"
    assert_output "(\"one more thing\")= $(openssl md5 <<< "one more thing" | awk '{print $2}')
$(echo -n "foo" | openssl md5 | awk '{print $2}') \"foo\"
$(openssl md5 file | awk '{print $2}') file
ft_ssl: md5: -s: No such file or directory
ft_ssl: md5: bar: No such file or directory"
}

@test "echo \"just to be extra clear\" | ../ft_ssl md5 -r -q -p -s \"foo\" file" {
    run ../ft_ssl md5 -r -q -p -s "foo" file <<< "just to be extra clear"
    assert_output "just to be extra clear
$(openssl md5 <<< "just to be extra clear" | awk '{print $2}')
$(echo -n "foo" | openssl md5 | awk '{print $2}')
$(openssl md5 file | awk '{print $2}')"
}

# bats file_tags=md5,file,openssl

@test "md5 0B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 0B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 0B | awk '{print $2}')
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

# bats file_tags=md5,stdin,openssl

@test "md5 < 0B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl md5 -q < 0B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl md5 < 0B | awk '{print $2}')
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

# bats file_tags=blake2s,subject

@test "echo \"42 is nice\" | ../ft_ssl blake2s" {
    run ../ft_ssl blake2s <<< "42 is nice"
    assert_output "(stdin)= $(openssl blake2s256 <<< "42 is nice" | awk '{print $2}')"
}

@test "echo \"42 is nice\" | ../ft_ssl blake2s -p" {
    run ../ft_ssl blake2s -p <<< "42 is nice"
    assert_output "(\"42 is nice\")= $(openssl blake2s256 <<< "42 is nice" | awk '{print $2}')"
}

@test "echo \"Pity the living.\" | ../ft_ssl blake2s -q -r" {
    run ../ft_ssl blake2s -q -r <<< "Pity the living."
    assert_output "$(openssl blake2s256 <<< "Pity the living." | awk '{print $2}')"
}

@test "../ft_ssl blake2s file" {
    run ../ft_ssl blake2s file
    assert_output "BLAKE2S (file) = $(openssl blake2s256 file | awk '{print $2}')"
}

@test "../ft_ssl blake2s -r file" {
    run ../ft_ssl blake2s -r file
    assert_output "$(openssl blake2s256 file | awk '{print $2}') file"
}

@test "../ft_ssl blake2s -s \"pity those that aren't following baerista on spotify.\"" {
    run ../ft_ssl blake2s -s "pity those that aren't following baerista on spotify."
    assert_output "BLAKE2S (\"pity those that aren't following baerista on spotify.\") = $(echo -n "pity those that aren't following baerista on spotify." | openssl blake2s256 | awk '{print $2}')"
}

@test "echo \"be sure to handle edge cases carefully\" | ../ft_ssl blake2s -p file" {
    run ../ft_ssl blake2s -p file <<< "be sure to handle edge cases carefully"
    assert_output "(\"be sure to handle edge cases carefully\")= $(openssl blake2s256 <<< "be sure to handle edge cases carefully" | awk '{print $2}')
BLAKE2S (file) = $(openssl blake2s256 file | awk '{print $2}')"
}

@test "echo \"some of this will not make sense at first\" | ../ft_ssl blake2s file" {
    run ../ft_ssl blake2s file <<< "some of this will not make sense at first"
    assert_output "BLAKE2S (file) = $(openssl blake2s256 file | awk '{print $2}')"
}

@test "echo \"but eventually you will understand\" | ../ft_ssl blake2s -p -r file" {
    run ../ft_ssl blake2s -p -r file <<< "but eventually you will understand"
    assert_output "(\"but eventually you will understand\")= $(openssl blake2s256 <<< "but eventually you will understand" | awk '{print $2}')
$(openssl blake2s256 file | awk '{print $2}') file"
}

@test "echo \"GL HF let's go\" | ../ft_ssl blake2s -p -s \"foo\" file" {
    run ../ft_ssl blake2s -p -s "foo" file <<< "GL HF let's go"
    assert_output "(\"GL HF let's go\")= $(openssl blake2s256 <<< "GL HF let's go" | awk '{print $2}')
BLAKE2S (\"foo\") = $(echo -n "foo" | openssl blake2s256 | awk '{print $2}')
BLAKE2S (file) = $(openssl blake2s256 file | awk '{print $2}')"
}

@test "echo \"one more thing\" | ../ft_ssl blake2s -r -p -s \"foo\" file -s \"bar\"" {
    run ../ft_ssl blake2s -r -p -s "foo" file -s "bar" <<< "one more thing"
    assert_output "(\"one more thing\")= $(openssl blake2s256 <<< "one more thing" | awk '{print $2}')
$(echo -n "foo" | openssl blake2s256 | awk '{print $2}') \"foo\"
$(openssl blake2s256 file | awk '{print $2}') file
ft_ssl: blake2s: -s: No such file or directory
ft_ssl: blake2s: bar: No such file or directory"
}

@test "echo \"just to be extra clear\" | ../ft_ssl blake2s -r -q -p -s \"foo\" file" {
    run ../ft_ssl blake2s -r -q -p -s "foo" file <<< "just to be extra clear"
    assert_output "just to be extra clear
$(openssl blake2s256 <<< "just to be extra clear" | awk '{print $2}')
$(echo -n "foo" | openssl blake2s256 | awk '{print $2}')
$(openssl blake2s256 file | awk '{print $2}')"
}

# bats file_tags=blake2s,file,openssl

@test "blake2s 0B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 0B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 0B | awk '{print $2}')
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

# bats file_tags=blake2s,stdin,openssl

@test "blake2s < 0B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2s -q < 0B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2s256 < 0B | awk '{print $2}')
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

# bats file_tags=sha256,subject

@test "echo \"42 is nice\" | ../ft_ssl sha256" {
    run ../ft_ssl sha256 <<< "42 is nice"
    assert_output "(stdin)= $(openssl sha256 <<< "42 is nice" | awk '{print $2}')"
}

@test "echo \"42 is nice\" | ../ft_ssl sha256 -p" {
    run ../ft_ssl sha256 -p <<< "42 is nice"
    assert_output "(\"42 is nice\")= $(openssl sha256 <<< "42 is nice" | awk '{print $2}')"
}

@test "echo \"Pity the living.\" | ../ft_ssl sha256 -q -r" {
    run ../ft_ssl sha256 -q -r <<< "Pity the living."
    assert_output "$(openssl sha256 <<< "Pity the living." | awk '{print $2}')"
}

@test "../ft_ssl sha256 file" {
    run ../ft_ssl sha256 file
    assert_output "SHA256 (file) = $(openssl sha256 file | awk '{print $2}')"
}

@test "../ft_ssl sha256 -r file" {
    run ../ft_ssl sha256 -r file
    assert_output "$(openssl sha256 file | awk '{print $2}') file"
}

@test "../ft_ssl sha256 -s \"pity those that aren't following baerista on spotify.\"" {
    run ../ft_ssl sha256 -s "pity those that aren't following baerista on spotify."
    assert_output "SHA256 (\"pity those that aren't following baerista on spotify.\") = $(echo -n "pity those that aren't following baerista on spotify." | openssl sha256 | awk '{print $2}')"
}

@test "echo \"be sure to handle edge cases carefully\" | ../ft_ssl sha256 -p file" {
    run ../ft_ssl sha256 -p file <<< "be sure to handle edge cases carefully"
    assert_output "(\"be sure to handle edge cases carefully\")= $(openssl sha256 <<< "be sure to handle edge cases carefully" | awk '{print $2}')
SHA256 (file) = $(openssl sha256 file | awk '{print $2}')"
}

@test "echo \"some of this will not make sense at first\" | ../ft_ssl sha256 file" {
    run ../ft_ssl sha256 file <<< "some of this will not make sense at first"
    assert_output "SHA256 (file) = $(openssl sha256 file | awk '{print $2}')"
}

@test "echo \"but eventually you will understand\" | ../ft_ssl sha256 -p -r file" {
    run ../ft_ssl sha256 -p -r file <<< "but eventually you will understand"
    assert_output "(\"but eventually you will understand\")= $(openssl sha256 <<< "but eventually you will understand" | awk '{print $2}')
$(openssl sha256 file | awk '{print $2}') file"
}

@test "echo \"GL HF let's go\" | ../ft_ssl sha256 -p -s \"foo\" file" {
    run ../ft_ssl sha256 -p -s "foo" file <<< "GL HF let's go"
    assert_output "(\"GL HF let's go\")= $(openssl sha256 <<< "GL HF let's go" | awk '{print $2}')
SHA256 (\"foo\") = $(echo -n "foo" | openssl sha256 | awk '{print $2}')
SHA256 (file) = $(openssl sha256 file | awk '{print $2}')"
}

@test "echo \"one more thing\" | ../ft_ssl sha256 -r -p -s \"foo\" file -s \"bar\"" {
    run ../ft_ssl sha256 -r -p -s "foo" file -s "bar" <<< "one more thing"
    assert_output "(\"one more thing\")= $(openssl sha256 <<< "one more thing" | awk '{print $2}')
$(echo -n "foo" | openssl sha256 | awk '{print $2}') \"foo\"
$(openssl sha256 file | awk '{print $2}') file
ft_ssl: sha256: -s: No such file or directory
ft_ssl: sha256: bar: No such file or directory"
}

@test "echo \"just to be extra clear\" | ../ft_ssl sha256 -r -q -p -s \"foo\" file" {
    run ../ft_ssl sha256 -r -q -p -s "foo" file <<< "just to be extra clear"
    assert_output "just to be extra clear
$(openssl sha256 <<< "just to be extra clear" | awk '{print $2}')
$(echo -n "foo" | openssl sha256 | awk '{print $2}')
$(openssl sha256 file | awk '{print $2}')"
}

# bats file_tags=sha256,file,openssl

@test "sha256 0B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 0B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 0B | awk '{print $2}')
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

# bats file_tags=sha256,stdin,openssl

@test "sha256 < 0B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl sha256 -q < 0B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl sha256 < 0B | awk '{print $2}')
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

# bats file_tags=blake2b,subject

@test "echo \"42 is nice\" | ../ft_ssl blake2b" {
    run ../ft_ssl blake2b <<< "42 is nice"
    assert_output "(stdin)= $(openssl blake2b512 <<< "42 is nice" | awk '{print $2}')"
}

@test "echo \"42 is nice\" | ../ft_ssl blake2b -p" {
    run ../ft_ssl blake2b -p <<< "42 is nice"
    assert_output "(\"42 is nice\")= $(openssl blake2b512 <<< "42 is nice" | awk '{print $2}')"
}

@test "echo \"Pity the living.\" | ../ft_ssl blake2b -q -r" {
    run ../ft_ssl blake2b -q -r <<< "Pity the living."
    assert_output "$(openssl blake2b512 <<< "Pity the living." | awk '{print $2}')"
}

@test "../ft_ssl blake2b file" {
    run ../ft_ssl blake2b file
    assert_output "BLAKE2B (file) = $(openssl blake2b512 file | awk '{print $2}')"
}

@test "../ft_ssl blake2b -r file" {
    run ../ft_ssl blake2b -r file
    assert_output "$(openssl blake2b512 file | awk '{print $2}') file"
}

@test "../ft_ssl blake2b -s \"pity those that aren't following baerista on spotify.\"" {
    run ../ft_ssl blake2b -s "pity those that aren't following baerista on spotify."
    assert_output "BLAKE2B (\"pity those that aren't following baerista on spotify.\") = $(echo -n "pity those that aren't following baerista on spotify." | openssl blake2b512 | awk '{print $2}')"
}

@test "echo \"be sure to handle edge cases carefully\" | ../ft_ssl blake2b -p file" {
    run ../ft_ssl blake2b -p file <<< "be sure to handle edge cases carefully"
    assert_output "(\"be sure to handle edge cases carefully\")= $(openssl blake2b512 <<< "be sure to handle edge cases carefully" | awk '{print $2}')
BLAKE2B (file) = $(openssl blake2b512 file | awk '{print $2}')"
}

@test "echo \"some of this will not make sense at first\" | ../ft_ssl blake2b file" {
    run ../ft_ssl blake2b file <<< "some of this will not make sense at first"
    assert_output "BLAKE2B (file) = $(openssl blake2b512 file | awk '{print $2}')"
}

@test "echo \"but eventually you will understand\" | ../ft_ssl blake2b -p -r file" {
    run ../ft_ssl blake2b -p -r file <<< "but eventually you will understand"
    assert_output "(\"but eventually you will understand\")= $(openssl blake2b512 <<< "but eventually you will understand" | awk '{print $2}')
$(openssl blake2b512 file | awk '{print $2}') file"
}

@test "echo \"GL HF let's go\" | ../ft_ssl blake2b -p -s \"foo\" file" {
    run ../ft_ssl blake2b -p -s "foo" file <<< "GL HF let's go"
    assert_output "(\"GL HF let's go\")= $(openssl blake2b512 <<< "GL HF let's go" | awk '{print $2}')
BLAKE2B (\"foo\") = $(echo -n "foo" | openssl blake2b512 | awk '{print $2}')
BLAKE2B (file) = $(openssl blake2b512 file | awk '{print $2}')"
}

@test "echo \"one more thing\" | ../ft_ssl blake2b -r -p -s \"foo\" file -s \"bar\"" {
    run ../ft_ssl blake2b -r -p -s "foo" file -s "bar" <<< "one more thing"
    assert_output "(\"one more thing\")= $(openssl blake2b512 <<< "one more thing" | awk '{print $2}')
$(echo -n "foo" | openssl blake2b512 | awk '{print $2}') \"foo\"
$(openssl blake2b512 file | awk '{print $2}') file
ft_ssl: blake2b: -s: No such file or directory
ft_ssl: blake2b: bar: No such file or directory"
}

@test "echo \"just to be extra clear\" | ../ft_ssl blake2b -r -q -p -s \"foo\" file" {
    run ../ft_ssl blake2b -r -q -p -s "foo" file <<< "just to be extra clear"
    assert_output "just to be extra clear
$(openssl blake2b512 <<< "just to be extra clear" | awk '{print $2}')
$(echo -n "foo" | openssl blake2b512 | awk '{print $2}')
$(openssl blake2b512 file | awk '{print $2}')"
}

# bats file_tags=blake2b,file,openssl

@test "blake2b 0B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 0B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 0B | awk '{print $2}')
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

# bats file_tags=blake2b,stdin,openssl

@test "blake2b < 0B" {
    local valgrind_log=$(mktemp)
    run valgrind --log-file="$valgrind_log" ../ft_ssl blake2b -q < 0B
    grep -q "All heap blocks were freed -- no leaks are possible" "$valgrind_log"
    assert_success
    grep -q "ERROR SUMMARY: 0 errors from 0 contexts" "$valgrind_log"
    assert_success
    assert_output $(openssl blake2b512 < 0B | awk '{print $2}')
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

