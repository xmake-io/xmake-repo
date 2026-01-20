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

    add_links("glog", "ng-log")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("windows", "mingw") then
        add_syslinks("dbghelp")
    end

    add_deps("cmake")

    on_load(function (package)
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                -- ng-log depends on gflags (latest is 2.2.2), and gflags-2.2.2 has 
                -- cmake min version 3.4, which errors with modern cmake versions.
                -- using master branch can bypass this problem,
                -- once gflags has new versions, this if-clause can be removed
                if config == "gflags" then
                    package:add("deps", "gflags 52e94563eba1968783864942fedf6e87e3c611f4") -- 2025.04.01
                else
                    package:add("deps", dep)
                end
            end
        end

        package:add("defines", "NGLOG_USE_EXPORT")
        if not package:config("shared") then
            package:add("defines", "NGLOG_COMPAT_STATIC_DEFINE")
            package:add("defines", "NGLOG_STATIC_DEFINE")
        end
        if package:is_plat("windows") then
            package:add("defines", "NGLOG_NO_ABBREVIATED_SEVERITIES")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "set (CMAKE_DEBUG_POSTFIX d)", "", {plain = true})

        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DWITH_" .. config:upper() .. "=" .. (package:config(config) and "ON" or "OFF"))
        end
        -- fix cmake try run
        if package:is_plat("mingw") or (package:is_plat("windows") and package:is_arch("arm64")) then
            table.insert(configs, "-DHAVE_SYMBOLIZE_EXITCODE=1")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char* argv[]) {
                nglog::InitializeLogging(argv[0]);
                nglog::InstallFailureSignalHandler();
                int num_cookies = 4;
                LOG(INFO) << "Found " << num_cookies << " cookies";
            }
        ]]}, {includes = "ng-log/logging.h", configs = {languages = "c++14"}}))
    end)
