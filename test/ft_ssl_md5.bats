#!/usr/bin/env bats

files=("1B" "56B" "57B" "63B" "64B" "65B" "100B" "128B" "50MB")

setup() {
    load "test_helper/bats-support/load"
    load "test_helper/bats-assert/load"

    echo "And above all," > file
    echo "" > 0B

    for file in ${files[@]}; do
        dd if=/dev/urandom of=$file bs=$file count=1
    done
}

teardown() {
    rm -f file
    rm -f 0B

    for file in ${files[@]}; do
        rm -f $file
    done;
}

# bats file_tags=md5:subject, subject

@test "echo \"42 is nice\" | ./ft_ssl md5" {
    run ./ft_ssl md5 <<< "42 is nice"
    assert_output "(stdin)= 35f1d6de0302e2086a4e472266efb3a9"
}

@test "echo \"42 is nice\" | ./ft_ssl md5 -p" {
    run ./ft_ssl md5 -p <<< "42 is nice"
    assert_output "(\"42 is nice\")= 35f1d6de0302e2086a4e472266efb3a9"
}

@test "echo \"Pity the living.\" | ./ft_ssl md5 -q -r" {
    run ./ft_ssl md5 -p <<< "Pity the living."
    assert_output "e20c3b973f63482a778f3fd1869b7f25"
}

@test "./ft_ssl md5 file" {
    run ./ft_ssl md5 file
    assert_output "MD5 (file) = 53d53ea94217b259c11a5a2d104ec58a"
}

@test "./ft_ssl md5 -r file" {
    run ./ft_ssl md5 -r file
    assert_output "53d53ea94217b259c11a5a2d104ec58a file"
}

@test "./ft_ssl md5 -s \"pity those that aren't following baerista on spotify.\"" {
    run ./ft_ssl md5 -s "pity those that aren't following baerista on spotify."
    assert_output "MD5 (\"pity those that aren't following baerista on spotify.\") = a3c990a1964705d9bf0e602f44572f5f"
}

@test "echo \"be sure to handle edge cases carefully\" | ./ft_ssl md5 -p file" {
    run ./ft_ssl md5 -p file <<< "be sure to handle edge cases carefully"
    assert_output "(\"be sure to handle edge cases carefully\")= 3553dc7dc5963b583c056d1b9fa3349c
MD5 (file) = 53d53ea94217b259c11a5a2d104ec58a"
}

@test "echo \"some of this will not make sense at first\" | ./ft_ssl md5 file" {
    run ./ft_ssl md5 file <<< "some of this will not make sense at first"
    assert_output "MD5 (file) = 53d53ea94217b259c11a5a2d104ec58a"
}

@test "echo \"but eventually you will understand\" | ./ft_ssl md5 -p -r file" {
    run ./ft_ssl md5 -p -r file <<< "but eventually you will understand"
    assert_output "(\"but eventually you will understand\")= dcdd84e0f635694d2a943fa8d3905281
53d53ea94217b259c11a5a2d104ec58a file"
}

@test "echo \"GL HF let's go\" | ./ft_ssl md5 -p -s \"foo\" file" {
    run ./ft_ssl md5 -p -s "foo" file <<< "GL HF let's go"
    assert_output "(\"GL HF let's go\")= d1e3cc342b6da09480b27ec57ff243e2
MD5 (\"foo\") = acbd18db4cc2f85cedef654fccc4a4d8
MD5 (file) = 53d53ea94217b259c11a5a2d104ec58a"
}

@test "echo \"one more thing\" | ./ft_ssl md5 -r -p -s \"foo\" file -s \"bar\"" {
    run ./ft_ssl md5 -r -p -s "foo" file -s "bar" <<< "one more thing"
    assert_output "(\"one more thing\")= a0bd1876c6f011dd50fae52827f445f5
acbd18db4cc2f85cedef654fccc4a4d8 \"foo\"
53d53ea94217b259c11a5a2d104ec58a file
ft_ssl: md5: -s: No such file or directory
ft_ssl: md5: bar: No such file or directory"
}

@test "echo \"just to be extra clear\" | ./ft_ssl md5 -r -q -p -s \"foo\" file" {
    run ./ft_ssl md5 -r -q -p -s "foo" file <<< "just to be extra clear"
    assert_output "just to be extra clear
3ba35f1ea0d170cb3b9a752e3360286c
acbd18db4cc2f85cedef654fccc4a4d8
53d53ea94217b259c11a5a2d104ec58a"
}

# bats file_tags=md5:file, md5, file, openssl

@test "md5 0B" {
    run ./ft_ssl md5 -q 0B
    assert_output $(openssl md5 0B | awk '{print $2}')
}

@test "md5 1B" {
    run ./ft_ssl md5 -q 1B
    assert_output $(openssl md5 1B | awk '{print $2}')
}

@test "md5 56B" {
    run ./ft_ssl md5 -q 56B
    assert_output $(openssl md5 56B | awk '{print $2}')
}

@test "md5 57B" {
    run ./ft_ssl md5 -q 57B
    assert_output $(openssl md5 57B | awk '{print $2}')
}

@test "md5 63B" {
    run ./ft_ssl md5 -q 63B
    assert_output $(openssl md5 63B | awk '{print $2}')
}

@test "md5 64B" {
    run ./ft_ssl md5 -q 64B
    assert_output $(openssl md5 64B | awk '{print $2}')
}

@test "md5 65B" {
    run ./ft_ssl md5 -q 65B
    assert_output $(openssl md5 65B | awk '{print $2}')
}

@test "md5 128B" {
    run ./ft_ssl md5 -q 128B
    assert_output $(openssl md5 128B | awk '{print $2}')
}

@test "md5 50MB" {
    run ./ft_ssl md5 -q 50MB
    assert_output $(openssl md5 50MB | awk '{print $2}')
}

# bats file_tags=md5:stdin, md5, stdin, openssl

@test "md5 <<< 0B" {
    run ./ft_ssl md5 -q <<< 0B
    assert_output $(openssl md5 <<< 0B | awk '{print $2}')
}

@test "md5 <<< 1B" {
    run ./ft_ssl md5 -q <<< 1B
    assert_output $(openssl md5 <<< 1B | awk '{print $2}')
}

@test "md5 <<< 56B" {
    run ./ft_ssl md5 -q <<< 56B
    assert_output $(openssl md5 <<< 56B | awk '{print $2}')
}

@test "md5 <<< 57B" {
    run ./ft_ssl md5 -q <<< 57B
    assert_output $(openssl md5 <<< 57B | awk '{print $2}')
}

@test "md5 <<< 63B" {
    run ./ft_ssl md5 -q <<< 63B
    assert_output $(openssl md5 <<< 63B | awk '{print $2}')
}

@test "md5 <<< 64B" {
    run ./ft_ssl md5 -q <<< 64B
    assert_output $(openssl md5 <<< 64B | awk '{print $2}')
}

@test "md5 <<< 65B" {
    run ./ft_ssl md5 -q <<< 65B
    assert_output $(openssl md5 <<< 65B | awk '{print $2}')
}

@test "md5 <<< 128B" {
    run ./ft_ssl md5 -q <<< 128B
    assert_output $(openssl md5 <<< 128B | awk '{print $2}')
}

@test "md5 <<< 50MB" {
    run ./ft_ssl md5 -q <<< 50MB
    assert_output $(openssl md5 <<< 50MB | awk '{print $2}')
}

# bats file_tags=sha256:subject, subject

@test "echo \"42 is nice\" | ./ft_ssl sha256" {
    run ./ft_ssl sha256 <<< "42 is nice"
    assert_output "(stdin)= 35f1d6de0302e2086a4e472266efb3a9"
}

@test "echo \"42 is nice\" | ./ft_ssl sha256 -p" {
    run ./ft_ssl sha256 -p <<< "42 is nice"
    assert_output "(\"42 is nice\")= 35f1d6de0302e2086a4e472266efb3a9"
}

@test "echo \"Pity the living.\" | ./ft_ssl sha256 -q -r" {
    run ./ft_ssl sha256 -p <<< "Pity the living."
    assert_output "e20c3b973f63482a778f3fd1869b7f25"
}

@test "./ft_ssl sha256 file" {
    run ./ft_ssl sha256 file
    assert_output "SHA256 (file) = 53d53ea94217b259c11a5a2d104ec58a"
}

@test "./ft_ssl sha256 -r file" {
    run ./ft_ssl sha256 -r file
    assert_output "53d53ea94217b259c11a5a2d104ec58a file"
}

@test "./ft_ssl sha256 -s \"pity those that aren't following baerista on spotify.\"" {
    run ./ft_ssl sha256 -s "pity those that aren't following baerista on spotify."
    assert_output "SHA256 (\"pity those that aren't following baerista on spotify.\") = a3c990a1964705d9bf0e602f44572f5f"
}

@test "echo \"be sure to handle edge cases carefully\" | ./ft_ssl sha256 -p file" {
    run ./ft_ssl sha256 -p file <<< "be sure to handle edge cases carefully"
    assert_output "(\"be sure to handle edge cases carefully\")= 3553dc7dc5963b583c056d1b9fa3349c
SHA256 (file) = 53d53ea94217b259c11a5a2d104ec58a"
}

@test "echo \"some of this will not make sense at first\" | ./ft_ssl sha256 file" {
    run ./ft_ssl sha256 file <<< "some of this will not make sense at first"
    assert_output "SHA256 (file) = 53d53ea94217b259c11a5a2d104ec58a"
}

@test "echo \"but eventually you will understand\" | ./ft_ssl sha256 -p -r file" {
    run ./ft_ssl sha256 -p -r file <<< "but eventually you will understand"
    assert_output "(\"but eventually you will understand\")= dcdd84e0f635694d2a943fa8d3905281
53d53ea94217b259c11a5a2d104ec58a file"
}

@test "echo \"GL HF let's go\" | ./ft_ssl sha256 -p -s \"foo\" file" {
    run ./ft_ssl sha256 -p -s "foo" file <<< "GL HF let's go"
    assert_output "(\"GL HF let's go\")= d1e3cc342b6da09480b27ec57ff243e2
SHA256 (\"foo\") = acbd18db4cc2f85cedef654fccc4a4d8
SHA256 (file) = 53d53ea94217b259c11a5a2d104ec58a"
}

@test "echo \"one more thing\" | ./ft_ssl sha256 -r -p -s \"foo\" file -s \"bar\"" {
    run ./ft_ssl sha256 -r -p -s "foo" file -s "bar" <<< "one more thing"
    assert_output "(\"one more thing\")= a0bd1876c6f011dd50fae52827f445f5
acbd18db4cc2f85cedef654fccc4a4d8 \"foo\"
53d53ea94217b259c11a5a2d104ec58a file
ft_ssl: sha256: -s: No such file or directory
ft_ssl: sha256: bar: No such file or directory"
}

@test "echo \"just to be extra clear\" | ./ft_ssl sha256 -r -q -p -s \"foo\" file" {
    run ./ft_ssl sha256 -r -q -p -s "foo" file <<< "just to be extra clear"
    assert_output "just to be extra clear
3ba35f1ea0d170cb3b9a752e3360286c
acbd18db4cc2f85cedef654fccc4a4d8
53d53ea94217b259c11a5a2d104ec58a"
}

# bats file_tags=sha256:file, sha256, file, openssl

@test "sha256 0B" {
    run ./ft_ssl sha256 -q 0B
    assert_output $(openssl sha256 0B | awk '{print $2}')
}

@test "sha256 1B" {
    run ./ft_ssl sha256 -q 1B
    assert_output $(openssl sha256 1B | awk '{print $2}')
}

@test "sha256 56B" {
    run ./ft_ssl sha256 -q 56B
    assert_output $(openssl sha256 56B | awk '{print $2}')
}

@test "sha256 57B" {
    run ./ft_ssl sha256 -q 57B
    assert_output $(openssl sha256 57B | awk '{print $2}')
}

@test "sha256 63B" {
    run ./ft_ssl sha256 -q 63B
    assert_output $(openssl sha256 63B | awk '{print $2}')
}

@test "sha256 64B" {
    run ./ft_ssl sha256 -q 64B
    assert_output $(openssl sha256 64B | awk '{print $2}')
}

@test "sha256 65B" {
    run ./ft_ssl sha256 -q 65B
    assert_output $(openssl sha256 65B | awk '{print $2}')
}

@test "sha256 128B" {
    run ./ft_ssl sha256 -q 128B
    assert_output $(openssl sha256 128B | awk '{print $2}')
}

@test "sha256 50MB" {
    run ./ft_ssl sha256 -q 50MB
    assert_output $(openssl sha256 50MB | awk '{print $2}')
}

# bats file_tags=sha256:stdin, sha256, stdin, openssl

@test "sha256 <<< 0B" {
    run ./ft_ssl sha256 -q <<< 0B
    assert_output $(openssl sha256 <<< 0B | awk '{print $2}')
}

@test "sha256 <<< 1B" {
    run ./ft_ssl sha256 -q <<< 1B
    assert_output $(openssl sha256 <<< 1B | awk '{print $2}')
}

@test "sha256 <<< 56B" {
    run ./ft_ssl sha256 -q <<< 56B
    assert_output $(openssl sha256 <<< 56B | awk '{print $2}')
}

@test "sha256 <<< 57B" {
    run ./ft_ssl sha256 -q <<< 57B
    assert_output $(openssl sha256 <<< 57B | awk '{print $2}')
}

@test "sha256 <<< 63B" {
    run ./ft_ssl sha256 -q <<< 63B
    assert_output $(openssl sha256 <<< 63B | awk '{print $2}')
}

@test "sha256 <<< 64B" {
    run ./ft_ssl sha256 -q <<< 64B
    assert_output $(openssl sha256 <<< 64B | awk '{print $2}')
}

@test "sha256 <<< 65B" {
    run ./ft_ssl sha256 -q <<< 65B
    assert_output $(openssl sha256 <<< 65B | awk '{print $2}')
}

@test "sha256 <<< 128B" {
    run ./ft_ssl sha256 -q <<< 128B
    assert_output $(openssl sha256 <<< 128B | awk '{print $2}')
}

@test "sha256 <<< 50MB" {
    run ./ft_ssl sha256 -q <<< 50MB
    assert_output $(openssl sha256 <<< 50MB | awk '{print $2}')
}

# bats file_tags=sha256:file, sha256, file, openssl

@test "blake2s 0B" {
    run ./ft_ssl blake2s -q 0B
    assert_output $(openssl blake2s-256 0B | awk '{print $2}')
}

@test "blake2s 1B" {
    run ./ft_ssl blake2s -q 1B
    assert_output $(openssl blake2s-256 1B | awk '{print $2}')
}

@test "blake2s 56B" {
    run ./ft_ssl blake2s -q 56B
    assert_output $(openssl blake2s-256 56B | awk '{print $2}')
}

@test "blake2s 57B" {
    run ./ft_ssl blake2s -q 57B
    assert_output $(openssl blake2s-256 57B | awk '{print $2}')
}

@test "blake2s 63B" {
    run ./ft_ssl blake2s -q 63B
    assert_output $(openssl blake2s-256 63B | awk '{print $2}')
}

@test "blake2s 64B" {
    run ./ft_ssl blake2s -q 64B
    assert_output $(openssl blake2s-256 64B | awk '{print $2}')
}

@test "blake2s 65B" {
    run ./ft_ssl blake2s -q 65B
    assert_output $(openssl blake2s-256 65B | awk '{print $2}')
}

@test "blake2s 128B" {
    run ./ft_ssl blake2s -q 128B
    assert_output $(openssl blake2s-256 128B | awk '{print $2}')
}

@test "blake2s 50MB" {
    run ./ft_ssl blake2s -q 50MB
    assert_output $(openssl blake2s-256 50MB | awk '{print $2}')
}

# bats file_tags=blake2s:stdin, blake2s, stdin, openssl

@test "blake2s <<< 0B" {
    run ./ft_ssl blake2s -q <<< 0B
    assert_output $(openssl blake2s-256 <<< 0B | awk '{print $2}')
}

@test "blake2s <<< 1B" {
    run ./ft_ssl blake2s -q <<< 1B
    assert_output $(openssl blake2s-256 <<< 1B | awk '{print $2}')
}

@test "blake2s <<< 56B" {
    run ./ft_ssl blake2s -q <<< 56B
    assert_output $(openssl blake2s-256 <<< 56B | awk '{print $2}')
}

@test "blake2s <<< 57B" {
    run ./ft_ssl blake2s -q <<< 57B
    assert_output $(openssl blake2s-256 <<< 57B | awk '{print $2}')
}

@test "blake2s <<< 63B" {
    run ./ft_ssl blake2s -q <<< 63B
    assert_output $(openssl blake2s-256 <<< 63B | awk '{print $2}')
}

@test "blake2s <<< 64B" {
    run ./ft_ssl blake2s -q <<< 64B
    assert_output $(openssl blake2s-256 <<< 64B | awk '{print $2}')
}

@test "blake2s <<< 65B" {
    run ./ft_ssl blake2s -q <<< 65B
    assert_output $(openssl blake2s-256 <<< 65B | awk '{print $2}')
}

@test "blake2s <<< 128B" {
    run ./ft_ssl blake2s -q <<< 128B
    assert_output $(openssl blake2s-256 <<< 128B | awk '{print $2}')
}

@test "blake2s <<< 50MB" {
    run ./ft_ssl blake2s -q <<< 50MB
    assert_output $(openssl blake2s-256 <<< 50MB | awk '{print $2}')
}
