package("volk")
    set_homepage("https://github.com/zeux/volk")
    set_description("volk is a meta-loader for Vulkan")
    set_license("MIT")

    add_urls("https://github.com/zeux/volk/archive/refs/tags/$(version).tar.gz", {alias = "archive", version = function (version)
        local prefix = ""
        if version:gt("1.3.261+1") then
            prefix = "vulkan-sdk-"
        elseif version:ge("1.3.226") then
            prefix = "sdk-"
        end
        return prefix .. version:gsub("%+", ".")
    end})
    add_urls("https://github.com/zeux/volk.git", {alias = "git"})

    add_versions("archive:1.3.290+0", "bb6a6d616c0f2bbd5d180da982a6d92a0948581cec937de69f17883980c6ca06")
    add_versions("archive:1.3.283+0", "872035f1f26c53b218632a3a8dbccbd276710aaabafb9bb1bc1a6c0633ee6aab")
    add_versions("archive:1.3.280+0", "af9c98d09284eef29f6826bb1620bfe551a91a864fce707416b83c255efe3c25")
    add_versions("archive:1.3.275+0", "b68d24e139190e49e5eafd72894f6e85c80472b8745bddc6ef91d6bf339df813")
    add_versions("archive:1.3.268+0", "f1d30fac1cdc17a8fdc8c69f371663547f92db99cfd612962190bb1e2c8ce74d")
    add_versions("archive:1.3.261+1", "052866c6cbff9efdf1e73e71c1d65070c36863730c95a4e93833500b4d894d69")
    add_versions("archive:1.3.250+1", "673241c6561fb4965f873d7fcdece17d950b24c77d6cf41466e47bdc2af67b81")
    add_versions("archive:1.3.231+1", "fac8d3d295e88bcc6bfb2b729d2c4babb2ea04ccb39fd918a3471b2d756789b9")

    add_versions("git:1.3.290+0", "vulkan-sdk-1.3.290.0")
    add_versions("git:1.3.283+0", "vulkan-sdk-1.3.283.0")
    add_versions("git:1.3.280+0", "vulkan-sdk-1.3.280.0")
    add_versions("git:1.3.275+0", "vulkan-sdk-1.3.275.0")
    add_versions("git:1.3.268+0", "vulkan-sdk-1.3.268.0")
    add_versions("git:1.3.261+1", "sdk-1.3.261.1")
    add_versions("git:1.3.250+1", "sdk-1.3.250.1")
    add_versions("git:1.3.231+1", "sdk-1.3.231.1")

    add_versions("1.3.204", "7776e7f3c70f199579da33d2ccd7152ca8b96182fa98c31fbe80880cef0fdf70")
    add_versions("1.2.190", "07f03720b8c70a626c98cc9545350538122bca9f853e6ed20ccad5a25d55fa4b")

    add_deps("vulkan-headers")

    add_configs("header_only", {description = "Header only.", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_syslinks("dl")
    end

    on_install("windows", "linux", "macosx", "mingw", "iphoneos", "android", function (package)
        if package:config("header_only") then
            io.replace("CMakeLists.txt", "if(NOT VOLK_HEADERS_ONLY OR VOLK_INSTALL)", "if(NOT VOLK_HEADERS_ONLY)", {plain = true})
            io.replace("CMakeLists.txt", "install(TARGETS volk volk_headers", "install(TARGETS volk_headers", {plain = true})
        end
        local vulkanheaders = package:dep("vulkan-headers")
        local configs = {}
        if package:is_plat("android") and (package:gitref() or package:version():lt("1.3.261")) then
            table.insert(configs, "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW")
        end
        table.insert(configs, "-DVOLK_PULL_IN_VULKAN=ON")
        table.insert(configs, "-DVOLK_INSTALL=ON")
        table.insert(configs, "-DVULKAN_HEADERS_INSTALL_DIR=" .. vulkanheaders:installdir())
        table.insert(configs, "-DVOLK_HEADERS_ONLY=" .. (package:config("header_only") and "ON" or "OFF"))
        local opt
        if package:gitref() or package:version():lt("1.3.250") then
            opt = {}
            opt.packagedeps = {"vulkan-headers"}
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_load(function (package)
        if package:config("header_only") then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_test(function (package)
        local defines
        if package:config("header_only") then 
            defines = "VOLK_IMPLEMENTATION"
        end

        assert(package:check_csnippets({test = [[
            #include <volk.h>
            void test() {
                volkInitialize();
            }
        ]]}, {configs = {defines = defines}}))
    end)
