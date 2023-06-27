package("rttr")
    set_homepage("https://www.rttr.org")
    set_description("rttr: An open source library, which adds reflection to C++.")
    set_license("MIT")

    if is_plat("macosx") then
        add_extsources("brew::rttr")
    end
    
    add_urls("https://www.rttr.org/releases/rttr-$(version)-src.tar.gz",
             "https://github.com/rttrorg/rttr/releases/download/v$(version)/rttr-$(version)-src.tar.gz",
             "https://github.com/rttrorg/rttr.git")

    add_versions("0.9.6", "f62caee43016489320f8a69145c9208cddd72e451ea95618bc26a49a4cd6c990")
    add_versions("0.9.5", "caa8d404840b0e156f869a947e475b09f7b602ab53c290271f40ce028c8d7d91")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_EXAMPLES=OFF")
        table.insert(configs, "-DBUILD_DOCUMENTATION=OFF")
        table.insert(configs, "-DBUILD_UNIT_TESTS=OFF") -- rttr has problem building unit tests on macosx.
        -- rttr use BUILD_RTTR_DYNAMIC and BUILD_STATIC options to control whether to build dynamic or static libraries.
        table.insert(configs, "-DBUILD_RTTR_DYNAMIC=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        local cxflags
        if package:has_tool("cxx", "gcc", "gxx", "clang", "clangxx") then
            if not package:is_plat("windows") then
                -- Passing this flag to clang-cl may cause errors.
                -- gcc does not seem to support -Wno-error options.
                cxflags = "-Wno-implicit-float-conversion"
            end
        end
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "RTTR_DLL")
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
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
