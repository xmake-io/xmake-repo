package("kotlin-native")
    set_kind("toolchain")
    set_homepage("https://kotlinlang.org")
    set_description("The Kotlin Programming Language. ")

    if is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://github.com/JetBrains/kotlin/releases/download/v$(version)/kotlin-native-prebuilt-windows-x86_64-$(version).zip")
            add_versions("2.1.10", "966f2a18c90bd3dcaf199f40750f78cfd2c260f912868ab34ffe37d9cc84e81a")
        end
    elseif is_host("macosx") then
        if os.arch() == "x86_64" then
            add_urls("https://github.com/JetBrains/kotlin/releases/download/v$(version)/kotlin-native-prebuilt-macos-x86_64-$(version).tar.gz")
            add_versions("2.1.10", "d7aebac0b5c4bf5adf7b76eac0b9c0cf79bee2e350c03ca93ef24c3cfadbe5cb")
        elseif os.arch() == "arm64" then
            add_urls("https://github.com/JetBrains/kotlin/releases/download/v$(version)/kotlin-native-prebuilt-macos-aarch64-$(version).tar.gz")
            add_versions("2.1.10", "b0ae655517c63add979462ac6668f3b1c00159d3fbf312dcb2e5752755facb3c")
        end
    elseif is_host("linux") then
        if os.arch() == "x86_64" then
            add_urls("https://github.com/JetBrains/kotlin/releases/download/v$(version)/kotlin-native-prebuilt-linux-x86_64-$(version).tar.gz")
            add_versions("2.1.10", "bacff7df4425b090dba67653f1408f534009bbbab2b1bdc75584ed6b3a4db0fd")
        end
    end

    add_deps("openjdk")

    on_install("@macosx", "@linux|x86_64", "@windows|x64", function (package)
        os.cp("*", package:installdir())
        local openjdk = package:dep("openjdk")
        local java_home
        if not openjdk:is_system() then
            java_home = openjdk:installdir()
        end
        if java_home then
            package:setenv("JAVA_HOME", java_home)
        end
    end)

    on_test(function (package)
        io.writefile("hello.kt", [[
            fun main() {
                println("Hello, World!")
            }
        ]])
        local suffix = ""
        local suffix2 = ".kexe"
        if is_host("windows") then
            suffix = ".bat"
            suffix2 = ".exe"
        end
        os.vrunv("kotlinc-native" .. suffix, {"./hello.kt", "-o", "hello"})
        os.vrun("./hello" .. suffix2)
    end)
