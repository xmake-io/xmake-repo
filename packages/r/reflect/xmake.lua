package("reflect")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/qlibs/reflect")
    set_description("C++20 Static Reflection library")
    set_license("MIT")

    add_urls("https://github.com/qlibs/reflect/archive/refs/tags/$(version).tar.gz",
             "https://github.com/qlibs/reflect.git", {submodules = false})

    add_versions("v1.2.6", "2991391d326886a20522ee376c04dceb4ad200ffba909bbce9a4cbe655b61ab8")
    add_versions("v1.2.5", "59d069877c4a6996c5f1785da03d8adbc7e70642a9957712a928706fff2b4e59")
    add_versions("v1.2.4", "8844faf7e282d9b9841fdee89b3ccfa80a800d7c35b6575c5f64cfa5946e0854")
    add_versions("v1.2.3", "583fe281c3b83f403b7fb18389e64bacc3ca0b30683d550f2ad6159cc0ebb6be")
    add_versions("v1.2.2", "c4450edfb004ce1b8eeede2d07f4e43cd0a9af355706be95941466fab0e7e3a2")
    add_versions("v1.2.1", "e24d5765b9a85ee99c494f1ce5827428220c69a6cac97817abbeef0f6b0b4ba9")
    add_versions("v1.2.0", "46ab12433e36fcf104503b80afd1f5c8ff33e9858c4d9632657e9f7d248da9ec")
    add_versions("v1.1.1", "49b20cbc0e5d9f94bcdc96056f8c5d91ee2e45d8642e02cb37e511079671ad48")
    add_versions("v1.1.0", "b906c1f1d08d3cc1af9cd95f3e363e7f725d2c1357b4ae06ccb9071401cb6b7f")

    on_load(function (package)
        local tc = package:is_plat("windows") and package:toolchain("msvc")
        if not tc then return end

        local toolset = tc:config("vs_toolset")
        if not toolset then return end

        local major, minor = toolset:match("^(%d+)%.(%d+)")
        if not major or not minor then return end

        if tonumber(major) == 14 and tonumber(minor) >= 50 then
            package:add("patches", "*", "patches/msvc-1950-fix-constexpr.patch", "20c69e79ca868d90fb6d8dddd10d9ed0dab63cc72691e97d30a3fe5dd2466559")
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
