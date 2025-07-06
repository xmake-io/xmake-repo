package("yomm2")
    set_homepage("https://github.com/jll63/yomm2")
    set_description("Fast, orthogonal, open multi-methods. Solve the Expression Problem in C++17.")
    set_license("BSL-1.0")

    add_urls("https://github.com/jll63/yomm2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jll63/yomm2.git", {submodules = false})

    add_versions("v1.6.0", "5d617704755637b863a90129d09b8c3a1d3a06e3be809693c07575e0289cb508")
    add_versions("v1.5.2", "12f3f735b4870606199b889a242ebfed84cf0cd392b04a1c32db11291de684be")
    add_versions("v1.5.1", "323abba27a356555cc3ead3e3e950746ab43f90d97ad21950f2ba3afaf565ecc")
    add_versions("v1.5.0", "daebc9bc56e3f67f1513c40b4b185cf435d8e16fe9936f3e5ed6fbb337a39030")
    add_versions("v1.4.0", "3f1f3a2b6fa5250405986b6cc4dff82299f866e2c6c2db75c7c3f38ecb91360f")

    add_deps("cmake")
    add_deps("boost", {configs = {header_only = true}})

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(yomm2) require ndk version > 22")
        end)
    end

    on_load(function (package)
        if not package:config("shared") then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install("!wasm", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(docs.in)", "", {plain = true})

        local configs =
        {
            "-DYOMM2_ENABLE_TESTS=OFF",
            "-DYOMM2_ENABLE_EXAMPLES=OFF",
            "-DYOMM2_ENABLE_DOC=OFF",
            "-DYOMM2_ENABLE_BENCHMARKS=OFF",
            "-DYOMM2_ENABLE_TRACE=OFF",
            "-DYOMM2_DEBUG_MACROS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DYOMM2_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <yorel/yomm2/keywords.hpp>
            void test() {
                yorel::yomm2::update();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
