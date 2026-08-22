package("ispc")
    set_kind("toolchain")
    set_homepage("https://ispc.github.io/")
    set_description("Intel® Implicit SPMD Program Compiler")
    set_license("BSD-3-Clause")

    if is_host("windows") then
        add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-windows.zip")

        add_versions("1.17.0", "e9a7cc98f69357482985bcbf69fa006632cee7b3606069b4d5e16dc62092d660")
        add_versions("1.25.3", "3a97e325f236c34a68013bf56fcb4e23c811b404207a60c010dc38fa24e60c55")
        add_versions("1.26.0", "cffe9904d32260994fa264f8fca60eac7be9f8995c122bacf456a1c66ac72987")
        add_versions("1.27.0", "3cb34c0713e587ef33f0c52578df9e02154a577d053f2ba3326819e2bfc24728")
        add_versions("1.28.2", "25966868d97a6f9bc38501b864883558994189446476584e5e491476d540de17")
    elseif is_host("macosx") then
        if os.arch() == "x86_64" then
            add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-macOS.x86_64.tar.gz")

            add_versions("1.25.3", "6f35c5aec01a607c98d5661ef0f9e4d13665011247b17dfbc2f6a326120cb2aa")
            add_versions("1.26.0", "6c171c7aa85f5237a8c72091754a76c8b9d95119ec4c8cfe444c7c9a264eec5f")
            add_versions("1.27.0", "bcb43ef21a25c3b6e89e71cf7024211c4f53c300ad840d051d9b19920248c94c")
            add_versions("1.28.2", "c3b613fb0250a4d2f89a08969068a294f5d1271fc8d0bd379529468e45ad49fb")
        elseif os.arch() == "arm64" then
            add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-macOS.arm64.tar.gz")

            add_versions("1.25.3", "a2bc150402bb9523261063d45a0f0deae50900c62238ae031cf9b9530393a4ac")
            add_versions("1.26.0", "02f29de79643875fa4ba42eb46fc27bf6f36d931c8f11d6e9ae18a013388ab5d")
            add_versions("1.27.0", "7a34c6c6406785748c95ba74e68d76557afd26ee513c327fcacc89eba588e690")
            add_versions("1.28.2", "45b5b16b1c24a65fc704cb8bf3f76f166b1dab733532c9ad60b4a024f9526414")
        else
            add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-macOS.universal.tar.gz")

            add_versions("1.25.3", "c6a83d1d0c37698f3bba7fd1a44835af0236248efdaf2b4a32b768e9cbd04163")
            add_versions("1.26.0", "fbe99daaade7baac941dd593aa0e442b8f2ed453b21a3d54bd8c9dbe46bc693")
            add_versions("1.27.0", "3803b91a787f5520e7296ad96d7905ce75396dfd1f0f870e1adb039795797b2d")
            add_versions("1.28.2", "14ea495a2e3725438bdaa0bf26e4e16082872069d3d5567901af3e25403e5f1f")
        end
    elseif is_host("linux") then
        if os.arch() == "arm64" then
            add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-linux.aarch64.tar.gz")

            add_versions("1.25.3", "990c509244f32189c7b6e4ea49793706a62445e727b41f10b0883d98fc66f696")
            add_versions("1.26.0", "c24347e95f504d44f17395b5e6df591c14c40762ad59e4fa130b9a56f2c85da7")
            add_versions("1.27.0", "76d3ec07d60818065ccf714244a1edfc48b91e7b3341b71b4e6ec3d52a06b984")
            add_versions("1.28.2", "c42267566b8c17a2a00668e168f56087b41e55cf1cea047dd0631cf512d011f7")
        else
            add_urls("https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-linux.tar.gz")

            add_versions("1.17.0", "6acc5df75efdce437f79b1b6489be8567c6d009e19dcc4851b9b37012afce1f7")
            add_versions("1.25.3", "4a89260cc1d216881735db4e60be72ca4630b8453f352b159867e215c85e1dbd")
            add_versions("1.26.0", "a50e1d504a6e9bd719188ee57257d76475c8abee957ff9160307756c2a1bbe17")
            add_versions("1.27.0", "e9c3c653ff3241fce8e2f5c2f26fc1d8e80b8dd73a135bc59627221c00f4d30a")
            add_versions("1.28.2", "32e611de1252cf1e09a6a13327f5746b8477f99e15ffa4cbd1b422386776688c")
        end
    end

    -- add_configs("oneapi", {description = "Use the OneAPI version on Linux", default = false, type = "boolean"})

    -- on_load(function (package)
    --     if package:config("oneapi") then
    --        package:add("urls", "https://github.com/ispc/ispc/releases/download/v$(version)/ispc-v$(version)-linux-oneapi.tar.gz")
    --        package:add("versions", "1.25.3", "526fe36638e675b9e1bb0618ac30f5286339e7a7e7f5a8441cd7607177292804")
    --     else
    --     end
    -- end)

    on_install("@windows", "@macosx", "@linux", "@msys", "@cygwin", function (package)
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        os.vrun("ispc --version")
    end)
