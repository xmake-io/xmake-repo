package("glog")

    set_homepage("https://github.com/google/glog/")
    set_description("C++ implementation of the Google logging module")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/google/glog/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/glog.git")
    add_versions("v0.4.0", "f28359aeba12f30d73d9e4711ef356dc842886968112162bc73002645139c39c")
    add_versions("v0.5.0", "eede71f28371bf39aa69b45de23b329d37214016e2055269b3b5e7cfd40b59f5")
    add_versions("v0.6.0", "8a83bf982f37bb70825df71a9709fa90ea9f4447fb3c099e1d720a439d88bad6")

    local configdeps = {gtest = "gtest", gflags = "gflags", unwind = "libunwind"}
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable " .. dep .. " support.", default = (config == "gflags"), type = "boolean"})
    end

    add_deps("cmake")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load("windows", "linux", "macosx", "android", "iphoneos", "cross", function (package)
        if package:is_plat("windows") then
            if package:version():le("0.4") and not package:config("shared") then
                package:add("defines", "GOOGLE_GLOG_DLL_DECL=")
            end
            package:add("defines", "GLOG_NO_ABBREVIATED_SEVERITIES")
        end
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("windows", "linux", "macosx", "android", "iphoneos", "cross", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DCMAKE_INSTALL_LIBDIR=lib"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-DWITH_" .. config:upper() .. "=" .. (package:config(config) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("google::InitGoogleLogging(\"glog\")", {includes = "glog/logging.h"}))
    end)
