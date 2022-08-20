package("cumem")
    set_kind("library", { headeronly = true })
    set_description("CUDA Memory Management Wrapper with Type Safety")
    set_homepage("https://github.com/BinhaoQin/cuMem")
    add_urls("https://github.com/BinhaoQin/cuMem/archive/refs/tags/$(version).tar.gz")
    add_versions("1.0.0", "1c7956c840f7aa3940756c8d09a2ae44ce53681ae01f3378cf4501d81bf0638c")
    add_deps("cuda", { system = true })

    on_install(function(package)
        os.mkdir("cuMem")
        os.cp("include/*.h", "cuMem")
        os.cp("cuMem", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <cuMem/cuConstant.h>
            #include <cassert>

            class Int {
            public:
                int value;
                DEVICE_INDEPENDENT Int() : value(0) {}
            };

            void test() {
               static_assert(sizeof(Segment<Int>) == sizeof(Int));
            }
        ]]}, {configs = {languages = "c++17"}}))        
    end)
