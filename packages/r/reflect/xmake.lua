package("reflect")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/qlibs/reflect")
    set_description("C++20 Static Reflection library")
    set_license("MIT")

    add_urls("https://github.com/qlibs/reflect/archive/refs/tags/$(version).tar.gz",
             "https://github.com/qlibs/reflect.git", {submodules = false})

    add_versions("v1.2.6", "2991391d326886a20522ee376c04dceb4ad200ffba909bbce9a4cbe655b61ab8")

    on_load(function (package)
        local tc = package:is_plat("windows") and package:toolchain("msvc")
        if not tc then return end

        local toolset = tc:config("vs_toolset")
        if not toolset then return end

        local major, minor = toolset:match("^(%d+)%.(%d+)")
        if not major or not minor then return end

        if tonumber(major) == 14 and tonumber(minor) >= 50 then
            package:add("patches", "*", "patches/msvc-1950-fix-constexpr.patch", "5c71efaebc24736d7100a0f971fefb14b48a98cb80420b982dd2b0a9870400df")
        end
    end)

    on_install(function (package)
        os.cp("reflect", package:installdir("include"))
        os.cp("reflect.cppm", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <reflect>
            struct foo { int a; };
            void test() {
                foo f{42};
                (void)reflect::size(f);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
