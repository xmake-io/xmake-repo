package("bazel")

    set_kind("binary")
    set_homepage("https://bazel.build/")
    set_description("A fast, scalable, multi-language and extensible build system")

    if is_host("windows") and os.arch() == "x64" then
        add_urls("https://github.com/bazelbuild/bazel/releases/download/$(version)/bazel-$(version)-windows-x86_64.exe")
        add_versions("5.0.0", "452217bcc4f8153c521fd985256316cd0bcad869fd192e1afd406dcb16f880d6")
        add_versions("7.1.0", "f3e01effd7674364ef2d7539d5ece6cd2f68d212ee94652623ae2405b53feeaf")
    elseif is_host("macosx") and os.arch() == "x86_64" then
        add_urls("https://github.com/bazelbuild/bazel/releases/download/$(version)/bazel-$(version)-darwin-x86_64")
        add_versions("5.0.0", "60558f06b9410b15602d6f41a294cec2cb69436c6e64d72ea78f42056373b8b9")
        add_versions("7.1.0", "52ad8d57c22e4f873c724473a09ecfd98966c3a2950e102a7bd7e8c612b8001c")
    elseif is_host("macosx") and os.arch() == "arm64" then
        add_urls("https://github.com/bazelbuild/bazel/releases/download/$(version)/bazel-$(version)-darwin-arm64")
        add_versions("5.0.0", "86ba0e31b61b675afdfe393bd3b02e12b8fe1196eb5ea045da86f067547fe90f")
        add_versions("7.1.0", "fb5e7bc62fc3c8f2511e3b64d795296444129b26f13d8dece4d4cee1845b758f")
    elseif is_host("linux") and os.arch() == "x86_64" then
        add_urls("https://github.com/bazelbuild/bazel/releases/download/$(version)/bazel-$(version)-linux-x86_64")
        add_versions("5.0.0", "399eedb225cff7a13f9f027f7ea2aad02ddb668a8eb89b1d975d222e4dc12ed9")
        add_versions("7.1.0", "62d62c699c1eb9f9be6a88030912a54d19fe45ae29329c7e5c53aba787492522")
    elseif is_host("linux") and os.arch() == "arm64" then
        add_urls("https://github.com/bazelbuild/bazel/releases/download/$(version)/bazel-$(version)-linux-arm64")
        add_versions("5.0.0", "4a88b8f48cac3bf6fe657332631c36b4d255628c87bd77eb3159f4eb166f5e66")
        add_versions("7.1.0", "b8cb5f842ce457606fbff3dba7a47e973f72bba0af1b7575ae500ca5a3d44282")
    end

    on_install("@windows|x64", "@macosx", "@linux|x86_64", "@linux|arm64", function (package)
        if is_host("windows") then
            os.cp("../bazel-*.exe", path.join(package:installdir("bin"), "bazel.exe"))
        else
            os.cp("../bazel-*", path.join(package:installdir("bin"), "bazel"))
        end
        if is_host("linux") then
            os.vrunv("chmod", {"+x", path.join(package:installdir("bin"), "bazel")})
        end
    end)

    on_test(function (package)
        os.vrun("bazel version")
    end)
