package("librime")
    set_homepage("https://rime.im")
    set_description("Rime Input Method Engine, the core library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/rime/librime/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rime/librime.git", {submodules = false})

    add_versions("1.16.0", "9d6469246d3f0c3b94ebc05a5299fb2e65fdd3600179617df15eacafa1085788")
    add_versions("1.15.0", "a6283cb6a9fa9445dbd7fac58f614884edd662486fa79809ca63686c8f59c6da")
    add_versions("1.14.0", "b2b29c3551eec6b45af1ba8fd3fcffb99e2b7451aa974c1c9ce107e69ce3ea68")

    add_deps("cmake")
    add_deps("glog >=0.7", {configs = {gflags = true}})
    add_deps("boost >=1.74", {configs = {regex = true, container = true}})
    add_deps("leveldb", "opencc >=1.0.2", "yaml-cpp >=0.5")

    on_load("windows", "mingw", function (package)
        if package:config("shared") then
            package:add("defines", "RIME_IMPORTS")
        end
    end)

    on_install(function (package)
        -- remove hardcode abi flags
        io.replace("CMakeLists.txt", "set(CMAKE_USER_MAKE_RULES_OVERRIDE_CXX ${CMAKE_CURRENT_SOURCE_DIR}/cmake/cxx_flag_overrides.cmake)", "", {plain = true})
        -- config mode will find gflags automatically
        io.replace("CMakeLists.txt", "find_package(Glog REQUIRED)", "find_package(Glog CONFIG REQUIRED)", {plain = true})
        io.replace("src/CMakeLists.txt", "${Glog_LIBRARY}", "glog::glog", {plain = true})
        io.replace("src/CMakeLists.txt", "${CMAKE_INSTALL_FULL_LIBDIR})", [[
                RUNTIME DESTINATION bin
                LIBRARY DESTINATION lib
                ARCHIVE DESTINATION lib)
        ]], {plain = true})

        local deps = {
            ["Boost_USE_STATIC_LIBS"] = "boost",
            ["Gflags_STATIC"]         = "gflags",
            ["Glog_STATIC"]           = "glog",
            ["LevelDb_STATIC"]        = "leveldb",
            ["Marisa_STATIC"]         = "marisa",
            ["Opencc_STATIC"]         = "opencc",
            ["YamlCpp_STATIC"]        = "yaml-cpp",
        }
        for str, dep in pairs(deps) do
            local value = (package:dep(dep):config("shared") and "0" or "1")
            io.replace("CMakeLists.txt", format("set(%s ${BUILD_STATIC})", str), format("set(%s %s)", str, value), {plain = true})
        end

        local configs = {
            "-DBUILD_TEST=OFF",
            "-DENABLE_LOGGING=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        -- Can't use `extern "C"` in c code
        if package:config("shared") then
            io.replace(path.join(package:installdir("include"), "rime_api.h"), [[extern "C" RIME_DLL]], "RIME_DLL", {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("rime_get_api", {includes = "rime_api.h"}))
    end)
