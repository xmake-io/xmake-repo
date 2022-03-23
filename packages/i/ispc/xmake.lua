package("ispc")

    set_kind("toolchain")
    set_homepage("https://ispc.github.io/")
    set_description("Intel® Implicit SPMD Program Compiler")
    set_license("BSD-3-Clause")

    if is_host("windows") then
        add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-windows.zip")
        add_versions("1.17.0", "e9a7cc98f69357482985bcbf69fa006632cee7b3606069b4d5e16dc62092d660")
    elseif is_host("macosx") then
        add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-macOS.tar.gz")
        add_versions("1.17.0", "e7fdcdbd5c272955249148c452ccd7295d7cf77b35ca1dec377e72b49c847bff")
    elseif is_host("linux") then
        add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-linux.tar.gz")
        add_versions("1.17.0", "6acc5df75efdce437f79b1b6489be8567c6d009e19dcc4851b9b37012afce1f7")
    end

    on_install("@windows", "@macosx", "@linux", function (package)
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        os.vrun("ispc --version")
    end)
