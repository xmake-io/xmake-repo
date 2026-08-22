package("range-v3")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ericniebler/range-v3/")
    set_description("Range library for C++14/17/20, basis for C++20's std::ranges")
    set_license("BSL-1.0")

    add_urls("https://github.com/ericniebler/range-v3/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ericniebler/range-v3.git")

    add_versions("0.11.0", "376376615dbba43d3bef75aa590931431ecb49eb36d07bb726a19f680c75e20c")
    add_versions("0.12.0", "015adb2300a98edfceaf0725beec3337f542af4915cec4d0b89fa0886f4ba9cb")

    if is_plat("linux") then
        add_extsources("apt::librange-v3-dev")
    end

    add_deps("cmake")

    on_load("windows", function (package)
        package:add("cxxflags", "/permissive-")
    end)

    on_install(function (package)
        local configs = {"-DRANGE_V3_DOCS=OFF", "-DRANGE_V3_TESTS=OFF", "-DRANGE_V3_EXAMPLES=OFF", "-DRANGE_V3_PERF=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                for (auto i : ranges::views::iota(1,10)) std::cout << i << " ";
            }
        ]]}, {configs = {languages = "c++17"}, includes = { "iostream", "range/v3/all.hpp" }}))
    end)
