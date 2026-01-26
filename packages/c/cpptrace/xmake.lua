package("cpptrace")
    set_homepage("https://github.com/jeremy-rifkin/cpptrace")
    set_description("Lightweight, zero-configuration-required, and cross-platform stacktrace library for C++")
    set_license("MIT")

    add_urls("https://github.com/jeremy-rifkin/cpptrace/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jeremy-rifkin/cpptrace.git")

    add_versions("v1.0.4", "5c9f5b301e903714a4d01f1057b9543fa540f7bfcc5e3f8bd1748e652e24f9ea")
    add_versions("v1.0.3", "d9145f3ca2b828a984477fbfb49616b1541aa249af945615f9c2abad573a71cc")
    add_versions("v1.0.2", "f92825b3c839c3af851204c79ea2a63871f9060f016e7c0411cfdc1727978feb")
    add_versions("v1.0.1", "bdc1d1ebc3f0e72c384aba6982cdfc08788d85f9ea2228e5621a6ff536df4900")
    add_versions("v1.0.0", "0e11aebb6b9b98ce9134a58532b63982365aadc76533a4fbb7f6fb6edb32de2e")
    add_versions("v0.8.3", "34f186741a84716edc1b64b372aa1a5b9ec2629d38ab97e5c2a5284b58a8dee8")
    add_versions("v0.8.2", "618fb746174f76eb03c7ece059ebdcfe39b7b6adca6a5da0c9f9bc6a4764d7f9")
    add_versions("v0.7.5", "7df0cae3d7da9be2dc82616292cc86a4a08a8209898716231aef80477a8ca35d")
    add_versions("v0.7.4", "1241790cace5d59ddf21ce5d046f71cd26448a3c8c15d123157498ba81e3543d")
    add_versions("v0.7.3", "8b83200860db148a7fd0b2594e7affc6a55809da256e132d6f0d5b202b2e26dd")
    add_versions("v0.7.1", "63df54339feb0c68542232229777df057e1848fc8294528613971bbf42889e83")
    add_versions("v0.7.0", "b5c1fbd162f32b8995d9b1fefb1b57fac8b1a0e790f897b81cdafe3625d12001")
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

    add_configs("libunwind", {description = "Enable libunwind for stack unwinding", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("dbghelp")
    elseif is_plat("linux", "cross") then
        add_syslinks("dl")
    end

    add_deps("cmake")
    if not is_plat("windows") then
        add_deps("libdwarf")
    end

    on_load(function (package)
        if package:config("libunwind") then
            package:add("deps", "libunwind")
        end
    end)

    on_install("linux", "macosx", "windows", "mingw", "cross", function (package)
        if not package:config("shared") then
            package:add("defines", "CPPTRACE_STATIC_DEFINE")
        end

        io.replace("CMakeLists.txt", "/WX", "", {plain = true})

        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DCPPTRACE_USE_EXTERNAL_LIBDWARF=ON",
            "-DCPPTRACE_FIND_LIBDWARF_WITH_PKGCONFIG=ON",
            "-DCPPTRACE_USE_EXTERNAL_ZSTD=ON",
            "-DCPPTRACE_VCPKG=ON",
        }
        table.insert(configs, "-DCPPTRACE_UNWIND_WITH_LIBUNWIND=" .. (package:config("libunwind") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local code
        if package:gitref() or package:version():gt("0.1") then
            code = [[
                void test() {
                    cpptrace::generate_trace().print();
                }
            ]]
        else
            code = [[
                void test() {
                    cpptrace::print_trace();
                }
            ]]
        end

        local languages = "c++11"
        if package:is_plat("windows") and package:has_tool("cxx", "clang", "clangxx") then
            languages = "c++14"
        end
        assert(package:check_cxxsnippets({test = code}, {configs = {languages = languages}, includes = {"cpptrace/cpptrace.hpp"}}))
    end)
