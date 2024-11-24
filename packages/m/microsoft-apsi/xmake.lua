package("microsoft-apsi")
    set_homepage("https://github.com/microsoft/APSI")
    set_description("APSI is a C++ library for Asymmetric (unlabeled or labeled) Private Set Intersection.")
    set_license("MIT")

    add_urls("https://github.com/microsoft/APSI.git")

    add_versions("v0.12.0", "b967a126b4e1c682b039afc2d76a98ea2c993230")

    add_configs("log4cplus", {description = "Use Log4cplus for logging", default = false, type = "boolean"})
    add_configs("cppzmq", {description = "Use ZeroMQ for networking", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    add_deps("microsoft-seal", {configs = {ms_gsl = true, zstd = true, throw_tran = false}})
    add_deps("microsoft-kuku", "flatbuffers", "jsoncpp")

    if on_check then
        on_check(function (package)
            -- TODO: To support cross-compilation, need host flatc tool and target flatbuffers library
            -- Remove cmake try_run, replace check_cxx_source_runs to check_cxx_source_compiles
            if not package:is_arch64() or package:is_cross() then
                raise("package(microsoft-apsi) unsupported cross-compilation")
            end
        end)
    end

    on_load(function (package)
        if package:config("log4cplus") then
            package:add("deps", "log4cplus", {configs = {unicode = false}})
        end
        if package:config("cppzmq") then
            package:add("deps", "cppzmq")
        end

        local version = package:version()
        if version then
            package:add("includedirs", format("include/APSI-%s.%s", version:major(), version:minor()))
        else
            package:add("includedirs", "include/APSI-0.12")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
        end

        table.insert(configs, "-DAPSI_USE_LOG4CPLUS=" .. (package:config("log4cplus") and "ON" or "OFF"))
        table.insert(configs, "-DAPSI_USE_ZMQ=" .. (package:config("cppzmq") and "ON" or "OFF"))

        local opt = {}
        if package:has_tool("cxx", "cl") then
            opt.cxflags = {"/utf-8", "/EHsc"}
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace apsi;
            void test() {
                ThreadPoolMgr::SetThreadCount(4);
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"apsi/sender.h"}}))
    end)
