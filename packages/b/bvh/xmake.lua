package("bvh")

    set_homepage("https://github.com/madmann91/bvh")
    set_description("A modern C++ BVH construction and traversal library")
    set_license("MIT")

    add_urls("https://github.com/madmann91/bvh.git")
    add_versions("2023.6.30", "578b1e8035743d0a97fcac802de81622c54f28e3")
    add_versions("2024.7.8", "77a08cac234bae46abbb5e78c73e8f3c158051d0")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})
    add_configs("c_api",  {description = "Builds the C API library wrapper", default = true, type = "boolean"})

    if is_plat("bsd") then
        add_syslinks("pthread")
    end
    on_load(function (package)
        if not package:config("c_api") then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install(function (package)
        os.cp("src/bvh", package:installdir("include"))
        if package:config("c_api") then
            io.writefile("xmake.lua", [[
                add_rules("mode.debug", "mode.release")
                set_languages("c++20")
                target("bvh_c")
                    set_kind("shared")
                    add_defines("BVH_BUILD_API")
                    add_files("src/bvh/v2/c_api/bvh.cpp")
                    add_includedirs("src")
            ]])
            import("package.tools.xmake").install(package)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <bvh/v2/thread_pool.h>
            void test() {
                bvh::v2::ThreadPool thread_pool;
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
