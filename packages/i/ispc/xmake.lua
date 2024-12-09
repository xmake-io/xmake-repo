package("ispc")

    set_kind("toolchain")
    set_homepage("https://ispc.github.io/")
    set_description("Intel® Implicit SPMD Program Compiler")
    set_license("BSD-3-Clause")

    add_configs("oneapi", {description = "Use the OneAPI version on Linux", default = false, type = "boolean"})

    if is_host("windows") then
        add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-windows.zip")
        add_versions("1.17.0", "e9a7cc98f69357482985bcbf69fa006632cee7b3606069b4d5e16dc62092d660")
        add_versions("1.25.3", "3a97e325f236c34a68013bf56fcb4e23c811b404207a60c010dc38fa24e60c55")
    elseif is_host("macosx") then
        if is_arch("x86_64") then
            add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-macOS.x86_64.tar.gz")
            add_versions("1.25.3", "6f35c5aec01a607c98d5661ef0f9e4d13665011247b17dfbc2f6a326120cb2aa")
        elseif is_arch("arm64") then
            add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-macOS.arm64.tar.gz")
            add_versions("1.25.3", "a2bc150402bb9523261063d45a0f0deae50900c62238ae031cf9b9530393a4ac")
        else
            add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-macOS.universal.tar.gz")
            add_versions("1.25.3", "c6a83d1d0c37698f3bba7fd1a44835af0236248efdaf2b4a32b768e9cbd04163")
        end
    elseif is_host("linux") then
        add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-linux.tar.gz")
        add_versions("1.17.0", "6acc5df75efdce437f79b1b6489be8567c6d009e19dcc4851b9b37012afce1f7")
        add_versions("1.25.3", "4a89260cc1d216881735db4e60be72ca4630b8453f352b159867e215c85e1dbd")

        if is_arch("aarch64") then
            add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-linux.aarch64.tar.gz")
            add_versions("1.25.3", "990c509244f32189c7b6e4ea49793706a62445e727b41f10b0883d98fc66f696")
        end

        on_load(function (package)
            if package:config("oneapi") then
                package:add("urls", "https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-linux-oneapi.tar.gz")
                package:add("versions", "1.25.3", "526fe36638e675b9e1bb0618ac30f5286339e7a7e7f5a8441cd7607177292804")
            end
        end)
    end

    on_install("@windows", "@macosx", "@linux", function (package)
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        os.vrun("ispc --version")
    end)
