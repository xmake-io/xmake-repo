package("stdexec")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/NVIDIA/stdexec")
    set_description("`std::execution`, the proposed C++ framework for asynchronous and parallel programming. ")
    set_license("Apache-2.0")

    add_urls("https://github.com/NVIDIA/stdexec.git")

    -- https://github.com/NVIDIA/stdexec/tags
    add_versions("nvhpc-25.09", "1f6379682dd1598c9b48313fa6dfdae620bc8535")
    add_versions("nvhpc-25.03.rc1", "9514e7bdf4b5d16d8ee4b5ad0e9c8733c3539f37")
    add_versions("nvhpc-24.09", "cddcd5a17dbec59d8502c0c6108553a20e74d2da")
    add_versions("nvhpc-24.09.rc1", "cddcd5a17dbec59d8502c0c6108553a20e74d2da") -- same as above
    add_versions("nvhpc-23.09.rc4", "dc90c30ff4968d5043299f97a8294d3f4a6c62e4")

    add_versions("2024.12.08", "26d8565bc7660b4fb8b504e00cac6b0419ffa939")
    add_versions("2024.03.08", "b3ba13a7b8c206371207196e08844fb7bc745438")

    set_policy("package.cmake_generator.ninja", false)

    add_deps("cmake")

    if on_check then
        on_check("windows", function (package)
            import("core.base.semver")

            local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
            assert(vs_toolset and semver.new(vs_toolset):minor() >= 30, "package(stdexec): need vs_toolset >= v143")
        end)
    end

    on_install("windows", "linux", "macosx", "mingw", "msys", function (package)
        if package:has_tool("cxx", "cl") then
            package:add("cxxflags", "/Zc:__cplusplus", "/Zc:preprocessor")
        end

        local configs = {"-DSTDEXEC_BUILD_EXAMPLES=OFF", "-DSTDEXEC_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
      assert(package:has_cxxincludes("exec/static_thread_pool.hpp", {configs = {languages = "c++20"}}))
  end)
