package("spdlog")

    set_homepage("https://github.com/gabime/spdlog")
    set_description("Fast C++ logging library.")

    set_urls("https://github.com/gabime/spdlog/archive/$(version).zip",
             "https://github.com/gabime/spdlog.git")
             
    add_versions("v1.8.5", "6e66c8ed4c014b0fb00c74d34eea95b5d34f6e4b51b746b1ea863dc3c2e854fd")
    add_versions("v1.8.2", "f0410b12b526065802b40db01304783550d3d20b4b6fe2f8da55f9d08ed2035d")
    add_versions("v1.8.1", "eed0095a1d52d08a0834feda146d4f9148fa4125620cd04d8ea57e0238fa39cd")
    add_versions("v1.8.0", "3cc41508fcd79e5141a6ef350506ef82982ca42a875e0588c02c19350ac3702e")
    add_versions("v1.5.0", "87e87c989f15d6b9f5379385aec1001c89a42941341ebaa09ec895b98a00efb4")
    add_versions("v1.4.2", "56b90f0bd5b126cf1b623eeb19bf4369516fa68f036bbc22d9729d2da511fb5a")
    add_versions("v1.3.1", "db6986d0141546d4fba5220944cc1f251bd8afdfc434bda173b4b0b6406e3cd0")

    add_patches("v1.8.5", path.join(os.scriptdir(), "patches", "1.8.5", "spdlog-1.8.5-fmt8.patch"), "42c2350ac24b76d49f39bb6f9d8f067ce5f40102c6f62cf81671033b2955be6b")

    add_configs("header_only",  { description = "Use header only", default = true, type = "boolean"})
    add_configs("fmt_external", { description = "Use external fmt library instead of bundled", default = false, type = "boolean"})
    add_configs("noexcept",     { description = "Compile with -fno-exceptions. Call abort() on any spdlog exceptions", default = false, type = "boolean"})

    on_load(function (package)
        if not package:config("header_only") then
            package:add("defines", "SPDLOG_COMPILE_LIB")
        end
        if package:config("fmt_external") then
            package:add("defines", "SPDLOG_FMT_EXTERNAL")
        end
        if package:version():ge("1.4.0") and not package:config("header_only") then
            package:add("deps", "cmake")
        end
        if package:config("fmt_external") then
            package:add("deps", "fmt", {configs = {header_only = true}})
        end
    end)

    on_install(function (package)
        if package:version():lt("1.4.0") or package:config("header_only") then
            os.cp("include", package:installdir())
            return
        end

        local configs = {}
        if package:config("shared") and is_plat("windows") then
            raise("spdlog shared lib is not yet supported under windows!")
        end
        table.insert(configs, "-DSPDLOG_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSPDLOG_FMT_EXTERNAL=" .. (package:config("fmt_external") and "ON" or "OFF"))
        table.insert(configs, "-SPDLOG_NO_EXCEPTIONS=" .. (package:config("noexcept") and "ON" or "OFF"))
        table.insert(configs, "-DSPDLOG_BUILD_TESTS=OFF")
        table.insert(configs, "-DSPDLOG_BUILD_EXAMPLE=OFF")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("spdlog::info(\"\")", {includes = "spdlog/spdlog.h", configs = {languages = "c++11"}}))
    end)
