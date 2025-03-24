package("xdl")
    set_homepage("https://github.com/hexhacking/xDL")
    set_description("xDL is an enhanced implementation of the Android DL series functions.")
    set_license("MIT")

    add_urls("https://github.com/hexhacking/xDL/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hexhacking/xDL.git")

    add_versions("v2.2.0", "fb28fe2805b3101ae85119bd1d5f78c9c519030ed8c7e2df0921532a673aae17")

    on_install("android", function (package)
        os.cd("xdl/src/main/cpp")
        io.writefile("xmake.lua", [[
            add_rules("mode.asan", "mode.release", "mode.debug")
            target("xDL")
                set_kind("$(kind)")
                set_languages("c17")

                add_files("*.c")

                add_includedirs("include", ".")
                add_headerfiles("include/(**.h)")

                if is_mode("asan") then
                    add_cflags("-fno-omit-frame-pointer")
                else
                    set_optimize("smallest")
                    add_cflags("-ffunction-sections", "-fdata-sections")
                    add_ldflags("-Wl,--exclude-libs,ALL", "-Wl,--gc-sections", "-Wl,--version-script=]] .. path.unix(path.join(os.curdir(), "xdl.map.txt")) .. [[")]] .. [[
                
                end

                if is_arch("x64", "x86_64", "arm64.*", "aarch64") then
                    add_ldflags("-Wl,-z,max-page-size=16384")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xdl_open", {includes = "xdl.h"}))
    end)
