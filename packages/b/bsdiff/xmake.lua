package("bsdiff")

set_homepage("https://android.googlesource.com/platform/external/bsdiff/")
set_description("BSDIFF is a binary diffing/patching library")

add_urls("https://android.googlesource.com/platform/external/bsdiff.git")

add_versions("2021.11.16", "78b6bd03de79240c228e4b0754c43c44204c7c6a")

add_deps("bzip2", "brotli", "libdivsufsort")
add_deps("libdivsufsort", {configs = {use_64 = true}})

on_install("linux", "macosx", function(package)
    os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
    os.mkdir("include/utils")
    os.cp(path.join(package:scriptdir(), "port", "Compat.h"), "include/utils/Compat.h")

    local configs = {}
    if package:config("shared") then
        configs.kind = "shared"
    end
    import("package.tools.xmake").install(package, configs)
end)

on_test(function(package)
    assert(package:check_cxxsnippets({
        test = [[
        #include <bsdiff/bsdiff.h>
        void test() {
            bsdiff::bsdiff(nullptr, 0, nullptr, 0, "", nullptr);
        }
    ]]
    }))
end)
