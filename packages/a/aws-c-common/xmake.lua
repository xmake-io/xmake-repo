package("aws-c-common")
    set_homepage("https://github.com/awslabs/aws-c-common")
    set_description("Core c99 package for AWS SDK for C")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-common/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-common.git")

    add_versions("v0.10.6", "d0acbabc786035d41791c3a2f45dbeda31d9693521ee746dc1375d6380eb912b")
    add_versions("v0.10.3", "15cc7282cfe4837fdaf1c3bb44105247da712ae97706a8717866f8e73e1d4fd9")
    add_versions("v0.10.0", "1fc7dea83f1d5a4b6fa86e3c8458200ed6e7f69c65707aa7b246900701874ad1")
    add_versions("v0.9.28", "bf265e9e409d563b0eddcb66e1cb00ff6b371170db3e119348478d911d054317")
    add_versions("v0.9.27", "0c0eecbd7aa04f85b1bdddf6342789bc8052737c6e9aa2ca35e26caed41d06ba")
    add_versions("v0.9.25", "443f3268387715e6e2c417a87114a6b42873aeeebc793d3f6f631323e7c48a80")
    add_versions("v0.9.24", "715a15399fe6dce2971c222ecabea4276e42ba3465a63c175724fc0c80d7a888")
    add_versions("v0.9.23", "adf838daf6a60aa31268522105b03262d745f529bc981d3ac665424133d6f91b")
    add_versions("v0.9.19", "196430fda1bca2c77df7d9199232956d371a92f49ee48fd6c29ff969410ca0ed")
    add_versions("v0.9.17", "82f1a88494c5563892f0e048f0f56acfe7e10e5aa3fe9267b956dbabcc043440")
    add_versions("v0.9.15", "8f36c7a6a5d2e17365759d15591f800d3e76dcaa34a226389b92647cbd92393a")
    add_versions("v0.9.14", "70b10ebbf40e3b6c1b36d81d5e4b63fe430414a81f76293a65e42dfa5def571e")
    add_versions("v0.9.13", "6d2044fc58e5d7611610976602f3fc2173676726b00eed026526962c599ece1d")
    add_versions("v0.9.3", "389eaac7f64d7d5a91ca3decad6810429eb5a65bbba54798b9beffcb4d1d1ed6")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows", "mingw") then
        add_syslinks("bcrypt", "ws2_32", "shlwapi")
    elseif is_plat("linux", "bsd") then
        add_syslinks("dl", "m", "pthread", "rt")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation")
    end

    add_deps("cmake")

    on_install("!mingw or mingw|!i386", function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "AWS_COMMON_USE_IMPORT_EXPORT")
        end

        local configs = {"-DBUILD_TESTING=OFF", "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SANITIZERS=" .. (package:config("asan") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DAWS_STATIC_MSVC_RUNTIME_LIBRARY=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "*.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aws_common_library_init", {includes = "aws/common/common.h"}))
        assert(package:has_cfuncs("aws_common_library_clean_up", {includes = "aws/common/common.h"}))
        assert(package:has_cfuncs("aws_ring_buffer_init", {includes = "aws/common/ring_buffer.h"}))
        assert(package:has_cfuncs("aws_uuid_init", {includes = "aws/common/uuid.h"}))
    end)
