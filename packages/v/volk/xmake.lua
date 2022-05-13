package("volk")

    set_homepage("https://github.com/zeux/volk")
    set_description("volk is a meta-loader for Vulkan")
    set_license("MIT")

    add_urls("https://github.com/zeux/volk/archive/$(version).tar.gz",
            "https://github.com/zeux/volk.git")
    add_versions("1.2.190", "07f03720b8c70a626c98cc9545350538122bca9f853e6ed20ccad5a25d55fa4b")
    add_versions("1.2.162", "ac4d9d6e88dee5a83ad176e2da57f1989ca2c6df155a0aeb5e18e9471aa4d777")
    add_versions("1.3.204", "7776e7f3c70f199579da33d2ccd7152ca8b96182fa98c31fbe80880cef0fdf70")

    add_deps("vulkan-headers")

    add_configs("header_only", {description = "Header only.", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_syslinks("dl")
    end

    on_install("windows", "linux", "macosx", "iphoneos", "android", function (package)
        if not package:config("header_only") then
            io.writefile("xmake.lua", [[
                add_rules("mode.debug", "mode.release")
                add_requires("vulkan-headers")
                target("volk")
                    set_kind("static")
                    add_files("volk.c")
                    add_headerfiles("volk.h")
                    add_packages("vulkan-headers")
                    if is_plat("linux") then
                        add_syslinks("dl")
                    end
            ]])
        else
            io.writefile("xmake.lua", [[
                add_requires("vulkan-headers")
                target("volk")
                    set_kind("headeronly")
                    add_headerfiles("volk.h")
                    add_packages("vulkan-headers")
                    if is_plat("linux") then
                        add_syslinks("dl")
                    end
            ]])

            os.cp("volk.c", package:installdir("include"))
        end
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        local defines
        if package:config("header_only") then 
            defines = "VOLK_IMPLEMENTATION"
        end

        assert(package:check_csnippets({test = format([[
            #include <volk.h>
            void test() {
                volkInitialize();
            }
        ]], {configs = {defines = defines}})}))
    end)