package("ptex")

    set_homepage("http://ptex.us/")
    set_description("Per-Face Texture Mapping for Production Rendering")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/wdas/ptex/archive/$(version).tar.gz",
             "https://github.com/wdas/ptex.git")
    add_versions("v2.3.2", "30aeb85b965ca542a8945b75285cd67d8e207d23dbb57fcfeaab587bb443402b")
    add_versions("v2.4.1", "664253b84121251fee2961977fe7cf336b71cd846dc235cd0f4e54a0c566084e")
    add_versions("v2.4.2", "c8235fb30c921cfb10848f4ea04d5b662ba46886c5e32ad5137c5086f3979ee1")

    add_deps("zlib")
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load("windows", "mingw@windows", function (package)
        if not package:config("shared") then
            package:add("defines", "PTEX_STATIC")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        io.replace("src/ptex/PtexPlatform.h", "sys/types.h", "unistd.h", {plain = true})
        io.writefile("xmake.lua", format([[
            add_rules("mode.debug", "mode.release")
            set_configvar("PTEX_MAJOR_VERSION", "%s")
            set_configvar("PTEX_MINOR_VERSION", "%s")
            add_requires("zlib")
            target("ptex")
                set_kind("$(kind)")
                add_packages("zlib")
                add_files("src/ptex/*.cpp")
                add_includedirs("src/ptex", {public = true})
                add_headerfiles("src/ptex/(*.h)")
                set_configdir("src/ptex")
                add_configfiles("src/ptex/PtexVersion.h.in", {pattern = "@(.-)@"})
                if is_plat("macosx") or is_plat("linux") then
                    add_syslinks("pthread")
                    add_cxxflags("-fvisibility=default")
                end
                if get_config("kind") == "static" then
                    add_defines("PTEX_STATIC", {public = true})
                else
                    add_defines("PTEX_EXPORTS")
                end
            target("ptxinfo")
                set_kind("binary")
                add_deps("ptex")
                add_packages("zlib")
                add_files("src/utils/ptxinfo.cpp")
        ]], package:version():major(), package:version():minor()))
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        elseif package:is_plat("linux") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Ptex::String error;
                PtexPtr<PtexCache> c(PtexCache::create(0,0));
            }
        ]]}, {includes = "Ptexture.h"}))
    end)
