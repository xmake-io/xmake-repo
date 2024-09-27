package("rttr")
    set_homepage("https://www.rttr.org")
    set_description("rttr: An open source library, which adds reflection to C++.")
    set_license("MIT")
    
    add_urls("https://github.com/rttrorg/rttr/archive/7edbd580cfad509a3253c733e70144e36f02ecd4.tar.gz",
             "https://github.com/rttrorg/rttr.git")
    -- 2021.08.11
    add_versions("0.9.7", "bba4b6fac2349fa6badc701aad5e7afb87504a7089a867b1a7cbed08fb2f3a90")

    add_configs("rtti", {description = "Build with RTTI support.", default = true, type = "boolean"})

    if is_plat("macosx") then
        add_extsources("brew::rttr")
    end

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMake/utility.cmake", "/WX", "", {plain = true})
        io.replace("CMake/utility.cmake", "-Werror", "", {plain = true})

        local configs = {
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_DOCUMENTATION=OFF",
            "-DBUILD_UNIT_TESTS=OFF",
            "-DBUILD_DOCUMENTATION=OFF",
            "-DBUILD_PACKAGE=OFF",
        }
        local shared = package:config("shared")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_RTTR_DYNAMIC=" .. (shared and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC=" .. (shared and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_WITH_RTTI=" .. (package:config("rtti") and "ON" or "OFF"))

        if package:is_plat("windows") then
            os.mkdir(path.join(package:buildir(), "src/rttr/pdb"))
        end
        import("package.tools.cmake").install(package, configs)
        if package:is_plat("windows")then
            if shared then
                package:add("defines", "RTTR_DLL")
            end
            local dir = package:installdir(shared and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "bin/*.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            #include <string>

            #include "rttr/registration.h"
            
            using namespace rttr;

            struct ctor_test {
                ctor_test(){}
                ctor_test(const ctor_test& other) {}
                ctor_test(int, double) {}
                static ctor_test create_object() { return ctor_test(); }
            };

            static ctor_test global_create_object() { return ctor_test(); }

            RTTR_REGISTRATION {
                registration::class_<ctor_test>("ctor_test")
                    .constructor<>()(
                        policy::ctor::as_object
                    )
                    .constructor<const ctor_test&>()(
                        policy::ctor::as_object
                    )
                    .constructor<int, double>()(
                        policy::ctor::as_object
                    )
                    .constructor(&ctor_test::create_object)
                    .constructor(&global_create_object);
            }

            void test() {
                auto t = type::get<ctor_test>();
                assert(t.is_valid());
                {
                    constructor ctor = t.get_constructor();
                    assert(ctor.is_valid());
                }
                {
                    constructor ctor = t.get_constructor({type::get<ctor_test>()});
                    assert(ctor.is_valid());
                }
                {
                    constructor ctor = t.get_constructor({type::get<int>(), type::get<double>()});
                    assert(ctor.is_valid());
                }
            }
        ]]}, { configs = {languages = "c++14"} }))
    end)
