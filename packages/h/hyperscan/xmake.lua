package("hyperscan")
    set_homepage("https://www.hyperscan.io")
    set_description("High-performance regular expression matching library")
    set_license("BSD-3")

    add_urls("https://github.com/intel/hyperscan/archive/refs/tags/$(version).tar.gz",
             "https://github.com/intel/hyperscan.git")

    add_versions("v5.4.2", "32b0f24b3113bbc46b6bfaa05cf7cf45840b6b59333d078cc1f624e4c40b2b99")

    add_deps("cmake", "ragel", "python 3.x", {kind = "binary"})
    add_deps("boost", {configs = {thread = true, graph = true}})

    on_check(function (package)
        if not package:is_arch("x64", "x86", "x86_64", "i386") then
            raise("package(hyperscan) only support x86 arch")
        end
    end)

    -- mingw require this patch: https://github.com/intel/hyperscan/pull/36
    on_install("!mingw", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(tools)", "", {plain = true})
        if not package:config("pic") then
            io.replace("CMakeLists.txt", "POSITION_INDEPENDENT_CODE TRUE", "POSITION_INDEPENDENT_CODE FALSE", {plain = true})
        end

        local configs = {"-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("hs_compile", {includes = "hs/hs.h"}))
    end)
