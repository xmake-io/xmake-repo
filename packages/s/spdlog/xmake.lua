package("spdlog")
    set_homepage("https://github.com/gabime/spdlog")
    set_description("Fast C++ logging library.")
    set_license("MIT")

    add_urls("https://github.com/gabime/spdlog/archive/refs/tags/$(version).zip",
             "https://github.com/gabime/spdlog.git")

    add_versions("v1.17.0", "b11912a82d149792fef33fabd0503b13d54aeac25c1464755461d4108ea71fc2")
    add_versions("v1.16.0", "3d25808d2fc4db86621a46855800c99ab5734999b61c4cbf9470edf631555397")
    add_versions("v1.15.3", "b74274c32c8be5dba70b7006c1d41b7d3e5ff0dff8390c8b6390c1189424e094")
    add_versions("v1.15.2", "d91ab0e16964cedb826e65ba1bed5ed4851d15c7b9453609a52056a94068c020")
    add_versions("v1.15.1", "322c144e24abee5d0326ddbe5bbc0e0c39c85ac8c2cb3c90d10290a85428327a")
    add_versions("v1.15.0", "076f3b4d452b95433083bcc66d07f79addba2d3fcb2b9177abeb7367d47aefbb")
    add_versions("v1.14.1", "429dfdf3afc1984feb59e414353c21c110bc79609f6d7899d52f6aa388646f6d")
    add_versions("v1.14.0", "2cd8a65885e7937fdd046b181eed7e95d61bab7006bd0fb7b9c766185ed3e0ae")
    add_versions("v1.13.0", "9f6763bb76fff7db371f5733626c83352edd7c57899501ab00248fafad9cc504")
    add_versions("v1.12.0", "6174bf8885287422a6c6a0312eb8a30e8d22bcfcee7c48a6d02d1835d7769232")
    add_versions("v1.11.0", "33f83c6b86ec0fbbd0eb0f4e980da6767494dc0ad063900bcfae8bc3e9c75f21")
    add_versions("v1.10.0", "7be28ff05d32a8a11cfba94381e820dd2842835f7f319f843993101bcab44b66")
    add_versions("v1.9.2", "130bd593c33e2e2abba095b551db6a05f5e4a5a19c03ab31256c38fa218aa0a6")
    add_versions("v1.9.1", "1a383a1d6bf604759c310a0b464a83afc54cc3147192d61c3d0c59695b38ff79")
    add_versions("v1.9.0", "61f751265cfce8fb17f67e18fa1ad00077280c080008252d9e8f0fbab5c30662")
    add_versions("v1.8.5", "6e66c8ed4c014b0fb00c74d34eea95b5d34f6e4b51b746b1ea863dc3c2e854fd")
    add_versions("v1.8.2", "f0410b12b526065802b40db01304783550d3d20b4b6fe2f8da55f9d08ed2035d")
    add_versions("v1.8.1", "eed0095a1d52d08a0834feda146d4f9148fa4125620cd04d8ea57e0238fa39cd")
    add_versions("v1.8.0", "3cc41508fcd79e5141a6ef350506ef82982ca42a875e0588c02c19350ac3702e")
    add_versions("v1.5.0", "87e87c989f15d6b9f5379385aec1001c89a42941341ebaa09ec895b98a00efb4")
    add_versions("v1.4.2", "56b90f0bd5b126cf1b623eeb19bf4369516fa68f036bbc22d9729d2da511fb5a")
    add_versions("v1.3.1", "db6986d0141546d4fba5220944cc1f251bd8afdfc434bda173b4b0b6406e3cd0")
    add_versions("v1.2.1", "ff69568eee595693f26b921c7b0fc7de1096a36cf57f51a6eda8ce022aebc7ff")

    add_patches("v1.11.0", path.join(os.scriptdir(), "patches", "v1.11.0", "fmt10.patch"), "61efa804845141ffa86532d9be7103d4dc8185e96de69d5efca42ebd7058e13d")

    add_configs("header_only",     {description = "Use header only version.", default = true, type = "boolean"})
    add_configs("std_format",      {description = "Use std::format instead of fmt library.", default = false, type = "boolean"})
    add_configs("fmt_external",    {description = "Use external fmt library instead of bundled.", default = false, type = "boolean"})
    add_configs("fmt_external_ho", {description = "Use external fmt header-only library instead of bundled.", default = false, type = "boolean"})
    add_configs("noexcept",        {description = "Compile with -fno-exceptions. Call abort() on any spdlog exceptions.", default = false, type = "boolean"})
    add_configs("tls",             {description = "Allow spdlog to using thread local storage.", default = true, type = "boolean"})
    add_configs("thread_id",       {description = "Allow spdlog to querying the thread id on each log call if thread id is not needed.", default = true, type = "boolean"})

    if is_plat("windows") then
        add_configs("wchar",  {description = "Support wchar api.", default = false, type = "boolean"})
        add_configs("wchar_filenames",  {description = "Support wchar filenames.", default = false, type = "boolean"})
        add_configs("wchar_console",  {description = "Support wchar output to console.", default = false, type = "boolean"})
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("header_only") then
            package:set("kind", "library", {headeronly = true})
        else
            package:add("defines", "SPDLOG_COMPILED_LIB")
            package:add("deps", "cmake")
        end
        assert(not (package:config("fmt_external") and package:config("fmt_external_ho")), "fmt_external and fmt_external_ho are mutually exclusive")
        if package:config("std_format") then
            package:add("defines", "SPDLOG_USE_STD_FORMAT")
        elseif package:config("fmt_external") or package:config("fmt_external_ho") then
            package:add("defines", "SPDLOG_FMT_EXTERNAL")
            package:add("deps", "fmt", {configs = {header_only = package:config("header_only")}})
        end
        if not package:config("header_only") and package:config("fmt_external_ho") then
            package:add("defines", "FMT_HEADER_ONLY=1")
        end
        if package:config("noexcept") then
            package:add("defines", "SPDLOG_NO_EXCEPTIONS")
        end
        if package:config("wchar") then
            package:add("defines", "SPDLOG_WCHAR_TO_UTF8_SUPPORT")
        end
        if package:config("wchar_filenames") then
            package:add("defines", "SPDLOG_WCHAR_FILENAMES")
        end
        if package:config("wchar_console") then
            package:add("defines", "SPDLOG_UTF8_TO_WCHAR_CONSOLE")
        end
        if not package:config("tls") then
            package:add("defines", "SPDLOG_NO_TLS")
        end
        if not package:config("thread_id") then
            package:add("defines", "SPDLOG_NO_THREAD_ID")
        end
    end)

    on_install(function (package)
        if package:has_tool("cxx", "cl") and not package:config("std_format") and not (package:config("fmt_external") or package:config("fmt_external_ho")) then
            package:add("cxxflags", "/utf-8")
        end

        if (not package:gitref() and package:version():lt("1.4.0")) or package:config("header_only") then
            os.cp("include", package:installdir())
            return
        end

        local configs = {"-DSPDLOG_BUILD_TESTS=OFF", "-DSPDLOG_BUILD_EXAMPLE=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSPDLOG_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSPDLOG_USE_STD_FORMAT=" .. (package:config("std_format") and "ON" or "OFF"))
        table.insert(configs, "-DSPDLOG_FMT_EXTERNAL=" .. (package:config("fmt_external") and "ON" or "OFF"))
        table.insert(configs, "-DSPDLOG_FMT_EXTERNAL_HO=" .. (package:config("fmt_external_ho") and "ON" or "OFF"))
        table.insert(configs, "-DSPDLOG_NO_EXCEPTIONS=" .. (package:config("noexcept") and "ON" or "OFF"))
        table.insert(configs, "-DSPDLOG_WCHAR_SUPPORT=" .. (package:config("wchar") and "ON" or "OFF"))
        table.insert(configs, "-DSPDLOG_WCHAR_FILENAMES=" .. (package:config("wchar_filenames") and "ON" or "OFF"))
        table.insert(configs, "-DSPDLOG_UTF8_TO_WCHAR_CONSOLE=" .. (package:config("wchar_console") and "ON" or "OFF"))
        table.insert(configs, "-DSPDLOG_WCHAR_CONSOLE=" .. (package:config("wchar_console") and "ON" or "OFF"))
        table.insert(configs, "-DSPDLOG_NO_TLS=" .. (package:config("tls") and "OFF" or "ON"))
        table.insert(configs, "-DSPDLOG_NO_THREAD_ID=" .. (package:config("thread_id") and "OFF" or "ON"))

        local opt = {}
        if not package:config("noexcept") and package:has_tool("cxx", "clang_cl")  then
            opt.cxflags = {"/EHsc"}
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        local version = package:version()
        local cpp_version = package:config("std_format") and "c++20" or "c++14"
        if version and version:le("1.2.1") then
            assert(package:has_cxxfuncs("spdlog::get(\"default\")->info(\"\")", {includes = "spdlog/spdlog.h", configs = {languages = cpp_version}}))
        else
            if package:config("std_format") then
                assert(package:has_cxxfuncs("spdlog::info(\"\")", {includes = "spdlog/spdlog.h", configs = {languages = cpp_version}}))
            else
                assert(package:has_cxxfuncs("spdlog::info(\"\")", {includes = "spdlog/spdlog.h", configs = {languages = cpp_version}}))
            end
        end
    end)
