package("spine-runtimes")
    set_homepage("http://esotericsoftware.com")
    set_description("2D skeletal animation runtimes for Spine.")
    set_license("Spine Runtimes")

    add_urls("https://github.com/EsotericSoftware/spine-runtimes.git")

    add_versions("3.8", "d33c10f85634d01efbe4a3ab31dabaeaca41230c")

    add_patches("3.8", "patches/3.8/cmake.patch", "bbfa70e3e36f8b3beefbc84d8047eb6735e1e75f4dce643d8916e231b13b992c")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_host("windows") then
        set_policy("platform.longpaths", true)
    end

    add_deps("cmake")

    on_install(function(package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            namespace spine {
                SpineExtension *getDefaultExtension() {
                    return new DefaultSpineExtension();
                }
            }
            void test() {
                assert(spine::SpineExtension::getInstance() != nullptr);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "spine/spine.h"}))
    end)
