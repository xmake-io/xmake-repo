package("glog")

    set_homepage("https://github.com/google/glog/")
    set_description("C++ implementation of the Google logging module")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/google/glog/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/glog.git")
    add_versions("v0.4.0", "f28359aeba12f30d73d9e4711ef356dc842886968112162bc73002645139c39c")

    add_deps("cmake")
    add_deps("gflags", "gtest", "libunwind", {optional = true})
    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "GOOGLE_GLOG_DLL_DECL=")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_GTEST=" .. (package:dep("gtest"):exists() and "ON" or "OFF"))
        table.insert(configs, "-DWITH_GFLAGS=" .. (package:dep("gflags"):exists() and "ON" or "OFF"))
        table.insert(configs, "-DWITH_UNWIND=" .. (package:dep("libunwind"):exists() and "ON" or "OFF"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("google::InitGoogleLogging(\"glog\")", {includes = "glog/logging.h"}))
    end)
