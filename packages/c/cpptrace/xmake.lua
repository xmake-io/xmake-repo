package("cpptrace")
    set_homepage("https://github.com/jeremy-rifkin/cpptrace")
    set_description("Lightweight, zero-configuration-required, and cross-platform stacktrace library for C++")
    set_license("MIT")

    add_urls("https://github.com/jeremy-rifkin/cpptrace/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jeremy-rifkin/cpptrace.git")

    add_versions("v0.6.3", "665bf76645ec7b9e6d785a934616f0138862c36cdb58b0d1c9dd18dd4c57395a")
    add_versions("v0.6.2", "02a0540b5b1be0788565f48b065b456d3eab81ae2323a50e75ed36449a0143ed")
    add_versions("v0.6.1", "4bb478eedbe4b2c0093ef7af4f64795304850e03312e658076b25ef8d6019c75")
    add_versions("v0.6.0", "7c2996f03d15f61016bc81fe7fa5220b1cc42498333c5c0e699ad2f96b918b96")
    add_versions("v0.5.4", "bab0f76330f90c445216ccade1a3ff29c9c4bbd44805be34d52095cd95b02df4")
    add_versions("v0.5.2", "d148998e175b9c69ffb4383ab321a0d27487392e4eee3f39441d35b6856c8f78")
    add_versions("v0.5.1", "27b9f862ec6185f570ee59c07fdd12bebb55a986191518e896621317d2654f26")
    add_versions("v0.4.0", "eef368f5bed2d85c976ea90b325e4c9bfc1b9618cbbfa15bf088adc8fa98ff89")
    add_versions("v0.3.1", "3c4c5b3406c2b598e5cd2a8cb97f9e8e1f54d6df087a0e62564e6fb68fed852d")
    add_versions("v0.1", "244bdf092ba7b9493102b8bb926be4ab355c40d773d4f3ee2774ccb761eb1dda")

    add_patches("0.5.2", "https://github.com/jeremy-rifkin/cpptrace/commit/599d6abd6cc74e80e8429fc309247be5f7edd5d7.patch", "977e6c17400ff2f85362ca1d6959038fdb5d9e5b402cfdd705b422c566e8e87a")

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("dbghelp")
    elseif is_plat("macosx") then
        add_deps("libdwarf")
    elseif is_plat("linux") then
        add_deps("libdwarf")
        add_syslinks("dl")
    elseif is_plat("mingw") then
        add_deps("libdwarf")
        add_syslinks("dbghelp")
    end

    on_install("linux", "macosx", "windows", "mingw", function (package)
        io.replace("CMakeLists.txt", "/WX", "", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        package:add("links", "cpptrace")
        if not package:config("shared") then
            package:add("defines", "CPPTRACE_STATIC_DEFINE")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local code
        if package:version():le("0.1") then
            code = [[
                void test() {
                    cpptrace::print_trace();
                }
            ]]
        else
            code = [[
                void test() {
                    cpptrace::generate_trace().print();
                }
            ]]
        end

        assert(package:check_cxxsnippets({test = code}, {configs = {languages = "c++11"}, includes = {"cpptrace/cpptrace.hpp"}}))
    end)
