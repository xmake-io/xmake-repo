package("toomanycooks")
    set_homepage("https://github.com/tzcnt/TooManyCooks/")
    set_description("C++20 concurrency framework with no compromises. Excellent performance, powerful features, and simple syntax.")
    set_license("BSL-1.0")

    add_urls("https://github.com/tzcnt/TooManyCooks/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/tzcnt/TooManyCooks.git")

    add_versions("1.6.0", "bf4c7f92968ca2b268f56582c314c5944d342eed4e72b4cde8240b56e88e64ca")
    add_versions("1.4.0", "5c847cfd73231409301732f3e158c52b694a2bd90d336e90f558811d59ef7f69")

    add_configs("priority_count", {default = 0, type = "number", description = "Allows you to specify the number of priority levels at compile time. 0 = specified at runtime"})
    add_configs("more_threads", {default = false, type = "boolean", description = "Unlimited threads in cpu executor, otherwise fixed to 64 threads"})
    add_configs("hwloc", {default = false, type = "boolean", description = "Build with hwloc"})

    on_load(function (package)
        if package:config("hwloc") then
            package:add("deps", "hwloc")
        end
    end)

    on_install("linux", function (package)
        io.writefile("lib.cpp", [[
            #define TMC_IMPL
            #include "tmc/all_headers.hpp"
        ]])

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")

        import("package.tools.xmake").install(package, {
            more_threads = package:config("more_threads"),
            priority_count = package:config("priority_count"),
            hwloc = package:config("hwloc")
        })
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({ test = [[
            #include <tmc/all_headers.hpp>
            int main(int argc, char **argv) {
                return tmc::async_main([]() -> tmc::task<int> { co_return 0; }());
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
