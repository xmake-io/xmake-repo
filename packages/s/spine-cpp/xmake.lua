package("spine-cpp")
    set_homepage("https://github.com/EsotericSoftware/spine-runtimes")
    set_description("Spine runtimes for C++")
    set_license("Spine Runtimes")

    if is_plat("windows") then
        set_policy("platform.longpaths", true)
    end

    add_urls("https://github.com/EsotericSoftware/spine-runtimes.git")

    add_versions("3.8","d33c10f85634d01efbe4a3ab31dabaeaca41230c")
    add_patches("3.8","./patches/3.8/fix.patch")

    add_deps("cmake")
    on_install(function(package)
        local configs={}
        table.insert(configs,"-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package,configs)
    end)
    on_test(function (package)
        assert(package:check_cxxsnippets({test=[[
            #include <spine/spine.h>

            namespace spine
            {
                SpineExtension *getDefaultExtension()
                {
                    return new DefaultSpineExtension();
                }
            }

            static void test()
            {
                assert(spine::SpineExtension::getInstance() != nullptr);
            }
        ]]},{configs={languages="c++17"}}))
    end)
