#!/usr/bin/env bats

declare -gA files=( ["1B"]="1" ["56B"]="56" ["57B"]="57" ["63B"]="63" ["64B"]="64" ["65B"]="65" ["100B"]="100" ["128B"]="128" ["50MB"]="50MB" )

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

# bats file_tags=md5,subject

@test "echo \"42 is nice\" | ../ft_ssl md5" {
    run ../ft_ssl md5 <<< "42 is nice"
    assert_output "(stdin)= 35f1d6de0302e2086a4e472266efb3a9"
}

@test "echo \"42 is nice\" | ../ft_ssl md5 -p" {
    run ../ft_ssl md5 -p <<< "42 is nice"
    assert_output "(\"42 is nice\")= 35f1d6de0302e2086a4e472266efb3a9"
}

@test "echo \"Pity the living.\" | ../ft_ssl md5 -q -r" {
    run ../ft_ssl md5 -q -r <<< "Pity the living."
    assert_output "e20c3b973f63482a778f3fd1869b7f25"
}

@test "../ft_ssl md5 file" {
    run ../ft_ssl md5 file
    assert_output "MD5 (file) = 53d53ea94217b259c11a5a2d104ec58a"
}

@test "../ft_ssl md5 -r file" {
    run ../ft_ssl md5 -r file
    assert_output "53d53ea94217b259c11a5a2d104ec58a file"
}

@test "../ft_ssl md5 -s \"pity those that aren't following baerista on spotify.\"" {
    run ../ft_ssl md5 -s "pity those that aren't following baerista on spotify."
    assert_output "MD5 (\"pity those that aren't following baerista on spotify.\") = a3c990a1964705d9bf0e602f44572f5f"
}

@test "echo \"be sure to handle edge cases carefully\" | ../ft_ssl md5 -p file" {
    run ../ft_ssl md5 -p file <<< "be sure to handle edge cases carefully"
    assert_output "(\"be sure to handle edge cases carefully\")= 3553dc7dc5963b583c056d1b9fa3349c
MD5 (file) = 53d53ea94217b259c11a5a2d104ec58a"
}

@test "echo \"some of this will not make sense at first\" | ../ft_ssl md5 file" {
    run ../ft_ssl md5 file <<< "some of this will not make sense at first"
    assert_output "MD5 (file) = 53d53ea94217b259c11a5a2d104ec58a"
}

@test "echo \"but eventually you will understand\" | ../ft_ssl md5 -p -r file" {
    run ../ft_ssl md5 -p -r file <<< "but eventually you will understand"
    assert_output "(\"but eventually you will understand\")= dcdd84e0f635694d2a943fa8d3905281
53d53ea94217b259c11a5a2d104ec58a file"
}

@test "echo \"GL HF let's go\" | ../ft_ssl md5 -p -s \"foo\" file" {
    run ../ft_ssl md5 -p -s "foo" file <<< "GL HF let's go"
    assert_output "(\"GL HF let's go\")= d1e3cc342b6da09480b27ec57ff243e2
MD5 (\"foo\") = acbd18db4cc2f85cedef654fccc4a4d8
MD5 (file) = 53d53ea94217b259c11a5a2d104ec58a"
}

@test "echo \"one more thing\" | ../ft_ssl md5 -r -p -s \"foo\" file -s \"bar\"" {
    run ../ft_ssl md5 -r -p -s "foo" file -s "bar" <<< "one more thing"
    assert_output "(\"one more thing\")= a0bd1876c6f011dd50fae52827f445f5
acbd18db4cc2f85cedef654fccc4a4d8 \"foo\"
53d53ea94217b259c11a5a2d104ec58a file
ft_ssl: md5: -s: No such file or directory
ft_ssl: md5: bar: No such file or directory"
}

@test "echo \"just to be extra clear\" | ../ft_ssl md5 -r -q -p -s \"foo\" file" {
    run ../ft_ssl md5 -r -q -p -s "foo" file <<< "just to be extra clear"
    assert_output "just to be extra clear
3ba35f1ea0d170cb3b9a752e3360286c
acbd18db4cc2f85cedef654fccc4a4d8
53d53ea94217b259c11a5a2d104ec58a"
}

# bats file_tags=md5,file,openssl

@test "md5 0B" {
    run ../ft_ssl md5 -q 0B
    assert_output $(openssl md5 0B | awk '{print $2}')
}

@test "md5 1B" {
    run ../ft_ssl md5 -q 1B
    assert_output $(openssl md5 1B | awk '{print $2}')
}

@test "md5 56B" {
    run ../ft_ssl md5 -q 56B
    assert_output $(openssl md5 56B | awk '{print $2}')
}

@test "md5 57B" {
    run ../ft_ssl md5 -q 57B
    assert_output $(openssl md5 57B | awk '{print $2}')
}

@test "md5 63B" {
    run ../ft_ssl md5 -q 63B
    assert_output $(openssl md5 63B | awk '{print $2}')
}

@test "md5 64B" {
    run ../ft_ssl md5 -q 64B
    assert_output $(openssl md5 64B | awk '{print $2}')
}

@test "md5 65B" {
    run ../ft_ssl md5 -q 65B
    assert_output $(openssl md5 65B | awk '{print $2}')
}

@test "md5 128B" {
    run ../ft_ssl md5 -q 128B
    assert_output $(openssl md5 128B | awk '{print $2}')
}

@test "md5 50MB" {
    run ../ft_ssl md5 -q 50MB
    assert_output $(openssl md5 50MB | awk '{print $2}')
}

# bats file_tags=md5,stdin,openssl

@test "md5 < 0B" {
    run ../ft_ssl md5 -q < 0B
    assert_output $(openssl md5 < 0B | awk '{print $2}')
}

@test "md5 < 1B" {
    run ../ft_ssl md5 -q < 1B
    assert_output $(openssl md5 < 1B | awk '{print $2}')
}

@test "md5 < 56B" {
    run ../ft_ssl md5 -q < 56B
    assert_output $(openssl md5 < 56B | awk '{print $2}')
}

@test "md5 < 57B" {
    run ../ft_ssl md5 -q < 57B
    assert_output $(openssl md5 < 57B | awk '{print $2}')
}

@test "md5 < 63B" {
    run ../ft_ssl md5 -q < 63B
    assert_output $(openssl md5 < 63B | awk '{print $2}')
}

@test "md5 < 64B" {
    run ../ft_ssl md5 -q < 64B
    assert_output $(openssl md5 < 64B | awk '{print $2}')
}

@test "md5 < 65B" {
    run ../ft_ssl md5 -q < 65B
    assert_output $(openssl md5 < 65B | awk '{print $2}')
}

@test "md5 < 128B" {
    run ../ft_ssl md5 -q < 128B
    assert_output $(openssl md5 < 128B | awk '{print $2}')
}

@test "md5 < 50MB" {
    run ../ft_ssl md5 -q < 50MB
    assert_output $(openssl md5 < 50MB | awk '{print $2}')
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
    run ../ft_ssl sha256 -q 0B
    assert_output $(openssl sha256 0B | awk '{print $2}')
}

@test "sha256 1B" {
    run ../ft_ssl sha256 -q 1B
    assert_output $(openssl sha256 1B | awk '{print $2}')
}

@test "sha256 56B" {
    run ../ft_ssl sha256 -q 56B
    assert_output $(openssl sha256 56B | awk '{print $2}')
}

@test "sha256 57B" {
    run ../ft_ssl sha256 -q 57B
    assert_output $(openssl sha256 57B | awk '{print $2}')
}

@test "sha256 63B" {
    run ../ft_ssl sha256 -q 63B
    assert_output $(openssl sha256 63B | awk '{print $2}')
}

@test "sha256 64B" {
    run ../ft_ssl sha256 -q 64B
    assert_output $(openssl sha256 64B | awk '{print $2}')
}

@test "sha256 65B" {
    run ../ft_ssl sha256 -q 65B
    assert_output $(openssl sha256 65B | awk '{print $2}')
}

@test "sha256 128B" {
    run ../ft_ssl sha256 -q 128B
    assert_output $(openssl sha256 128B | awk '{print $2}')
}

@test "sha256 50MB" {
    run ../ft_ssl sha256 -q 50MB
    assert_output $(openssl sha256 50MB | awk '{print $2}')
}

# bats file_tags=sha256,stdin,openssl

@test "sha256 < 0B" {
    run ../ft_ssl sha256 -q < 0B
    assert_output $(openssl sha256 < 0B | awk '{print $2}')
}

@test "sha256 < 1B" {
    run ../ft_ssl sha256 -q < 1B
    assert_output $(openssl sha256 < 1B | awk '{print $2}')
}

@test "sha256 < 56B" {
    run ../ft_ssl sha256 -q < 56B
    assert_output $(openssl sha256 < 56B | awk '{print $2}')
}

@test "sha256 < 57B" {
    run ../ft_ssl sha256 -q < 57B
    assert_output $(openssl sha256 < 57B | awk '{print $2}')
}

@test "sha256 < 63B" {
    run ../ft_ssl sha256 -q < 63B
    assert_output $(openssl sha256 < 63B | awk '{print $2}')
}

@test "sha256 < 64B" {
    run ../ft_ssl sha256 -q < 64B
    assert_output $(openssl sha256 < 64B | awk '{print $2}')
}

@test "sha256 < 65B" {
    run ../ft_ssl sha256 -q < 65B
    assert_output $(openssl sha256 < 65B | awk '{print $2}')
}

@test "sha256 < 128B" {
    run ../ft_ssl sha256 -q < 128B
    assert_output $(openssl sha256 < 128B | awk '{print $2}')
}

@test "sha256 < 50MB" {
    run ../ft_ssl sha256 -q < 50MB
    assert_output $(openssl sha256 < 50MB | awk '{print $2}')
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
    run ../ft_ssl blake2s -q 0B
    assert_output $(openssl blake2s256 0B | awk '{print $2}')
}

@test "blake2s 1B" {
    run ../ft_ssl blake2s -q 1B
    assert_output $(openssl blake2s256 1B | awk '{print $2}')
}

@test "blake2s 56B" {
    run ../ft_ssl blake2s -q 56B
    assert_output $(openssl blake2s256 56B | awk '{print $2}')
}

@test "blake2s 57B" {
    run ../ft_ssl blake2s -q 57B
    assert_output $(openssl blake2s256 57B | awk '{print $2}')
}

@test "blake2s 63B" {
    run ../ft_ssl blake2s -q 63B
    assert_output $(openssl blake2s256 63B | awk '{print $2}')
}

@test "blake2s 64B" {
    run ../ft_ssl blake2s -q 64B
    assert_output $(openssl blake2s256 64B | awk '{print $2}')
}

@test "blake2s 65B" {
    run ../ft_ssl blake2s -q 65B
    assert_output $(openssl blake2s256 65B | awk '{print $2}')
}

@test "blake2s 128B" {
    run ../ft_ssl blake2s -q 128B
    assert_output $(openssl blake2s256 128B | awk '{print $2}')
}

@test "blake2s 50MB" {
    run ../ft_ssl blake2s -q 50MB
    assert_output $(openssl blake2s256 50MB | awk '{print $2}')
}

# bats file_tags=blake2s,stdin,openssl

@test "blake2s < 0B" {
    run ../ft_ssl blake2s -q < 0B
    assert_output $(openssl blake2s256 < 0B | awk '{print $2}')
}

@test "blake2s < 1B" {
    run ../ft_ssl blake2s -q < 1B
    assert_output $(openssl blake2s256 < 1B | awk '{print $2}')
}

@test "blake2s < 56B" {
    run ../ft_ssl blake2s -q < 56B
    assert_output $(openssl blake2s256 < 56B | awk '{print $2}')
}

@test "blake2s < 57B" {
    run ../ft_ssl blake2s -q < 57B
    assert_output $(openssl blake2s256 < 57B | awk '{print $2}')
}

@test "blake2s < 63B" {
    run ../ft_ssl blake2s -q < 63B
    assert_output $(openssl blake2s256 < 63B | awk '{print $2}')
}

@test "blake2s < 64B" {
    run ../ft_ssl blake2s -q < 64B
    assert_output $(openssl blake2s256 < 64B | awk '{print $2}')
}

@test "blake2s < 65B" {
    run ../ft_ssl blake2s -q < 65B
    assert_output $(openssl blake2s256 < 65B | awk '{print $2}')
}

@test "blake2s < 128B" {
    run ../ft_ssl blake2s -q < 128B
    assert_output $(openssl blake2s256 < 128B | awk '{print $2}')
}

@test "blake2s < 50MB" {
    run ../ft_ssl blake2s -q < 50MB
    assert_output $(openssl blake2s256 < 50MB | awk '{print $2}')
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
    run ../ft_ssl blake2b -q 0B
    assert_output $(openssl blake2b512 0B | awk '{print $2}')
}

@test "blake2b 1B" {
    run ../ft_ssl blake2b -q 1B
    assert_output $(openssl blake2b512 1B | awk '{print $2}')
}

@test "blake2b 56B" {
    run ../ft_ssl blake2b -q 56B
    assert_output $(openssl blake2b512 56B | awk '{print $2}')
}

@test "blake2b 57B" {
    run ../ft_ssl blake2b -q 57B
    assert_output $(openssl blake2b512 57B | awk '{print $2}')
}

@test "blake2b 63B" {
    run ../ft_ssl blake2b -q 63B
    assert_output $(openssl blake2b512 63B | awk '{print $2}')
}

@test "blake2b 64B" {
    run ../ft_ssl blake2b -q 64B
    assert_output $(openssl blake2b512 64B | awk '{print $2}')
}

@test "blake2b 65B" {
    run ../ft_ssl blake2b -q 65B
    assert_output $(openssl blake2b512 65B | awk '{print $2}')
}

@test "blake2b 128B" {
    run ../ft_ssl blake2b -q 128B
    assert_output $(openssl blake2b512 128B | awk '{print $2}')
}

@test "blake2b 50MB" {
    run ../ft_ssl blake2b -q 50MB
    assert_output $(openssl blake2b512 50MB | awk '{print $2}')
}

# bats file_tags=blake2b,stdin,openssl

@test "blake2b < 0B" {
    run ../ft_ssl blake2b -q < 0B
    assert_output $(openssl blake2b512 < 0B | awk '{print $2}')
}

@test "blake2b < 1B" {
    run ../ft_ssl blake2b -q < 1B
    assert_output $(openssl blake2b512 < 1B | awk '{print $2}')
}

@test "blake2b < 56B" {
    run ../ft_ssl blake2b -q < 56B
    assert_output $(openssl blake2b512 < 56B | awk '{print $2}')
}

@test "blake2b < 57B" {
    run ../ft_ssl blake2b -q < 57B
    assert_output $(openssl blake2b512 < 57B | awk '{print $2}')
}

@test "blake2b < 63B" {
    run ../ft_ssl blake2b -q < 63B
    assert_output $(openssl blake2b512 < 63B | awk '{print $2}')
}

@test "blake2b < 64B" {
    run ../ft_ssl blake2b -q < 64B
    assert_output $(openssl blake2b512 < 64B | awk '{print $2}')
}

@test "blake2b < 65B" {
    run ../ft_ssl blake2b -q < 65B
    assert_output $(openssl blake2b512 < 65B | awk '{print $2}')
}

@test "blake2b < 128B" {
    run ../ft_ssl blake2b -q < 128B
    assert_output $(openssl blake2b512 < 128B | awk '{print $2}')
}

@test "blake2b < 50MB" {
    run ../ft_ssl blake2b -q < 50MB
    assert_output $(openssl blake2b512 < 50MB | awk '{print $2}')
}
