package("ng-log")
    set_homepage("https://github.com/ng-log/ng-log/")
    set_description("C++ library for application-level logging")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ng-log/ng-log/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ng-log/ng-log.git")

    add_versions("v0.8.2", "4d7467025b800828d3b2eb87eb506b310d090171788857601a708a46825953a8")

    local configdeps = {gtest = "gtest", gflags = "gflags", unwind = "libunwind"}
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable " .. dep .. " support.", default = (config == "gflags"), type = "boolean"})
    end

    add_deps("cmake")

    if is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("windows") then
        add_syslinks("dbghelp")
    end


    on_load(function (package)
        if package:is_plat("windows") then
            package:add("defines", "NGLOG_NO_ABBREVIATED_SEVERITIES")
        end
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                -- ng-log depends on gflags (latest is 2.2.2), and gflags-2.2.2 has 
                -- cmake min version 3.4, which errors with modern cmake versions.
                -- using master branch can bypass this problem,
                -- once gflags has new versions, this if-clause can be removed
                if config == "gflags" then
                    package:add("deps", "gflags master")
                else
                    package:add("deps", dep)
                end
            end
        end
    end)

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DCMAKE_INSTALL_LIBDIR=lib"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DWITH_" .. config:upper() .. "=" .. (package:config(config) and "ON" or "OFF"))
        end

        -- fix cmake try run
        if package:is_plat("mingw") or (package:is_plat("windows") and package:is_arch("arm64")) then
            table.insert(configs, "-DHAVE_SYMBOLIZE_EXITCODE=1")
        end

        import("package.tools.cmake").install(package, configs)

        -- ng-log has similar mechanism as glog
        -- refer to https://github.com/xmake-io/xmake-repo/discussions/4221
        if package:version() and package:version():ge("0.7.0") then
            io.replace(path.join(package:installdir("include"), "ng-log/logging.h"),
                "#define NGLOG_LOGGING_H", "#define NGLOG_LOGGING_H\n#ifndef NGLOG_USE_EXPORT\n#define NGLOG_USE_EXPORT\n#endif", {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets([[
        #include <ng-log/logging.h>

        int main(int argc, char* argv[]) {
            nglog::InitializeLogging(argv[0]);
            nglog::InstallFailureSignalHandler();
            int num_cookies = 4;
            LOG(INFO) << "Found " << num_cookies << " cookies";
        }
        ]], {includes = "ng-log/logging.h", configs = {languages = "c++14"}}))
    end)
