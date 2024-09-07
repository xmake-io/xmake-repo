package("stdexec")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/NVIDIA/stdexec")
    set_description("`std::execution`, the proposed C++ framework for asynchronous and parallel programming. ")

    add_urls("https://github.com/NVIDIA/stdexec.git")

    add_versions("2024.03.08", "b3ba13a7b8c206371207196e08844fb7bc745438")

    if is_plat("windows") then
        add_cxxflags("/Zc:__cplusplus")
    end

    add_deps("cmake")

    on_install("linux", "macosx", "mingw", function (package)
        local configs = {"-DSTDEXEC_BUILD_EXAMPLES=OFF", "-DSTDEXEC_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
      assert(package:has_cxxincludes("exec/static_thread_pool.hpp", {configs = {languages = "c++20"}}))
  end)
