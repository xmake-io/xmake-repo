package("mir")
    set_homepage("https://github.com/vnmakarov/mir")
    set_description("A lightweight JIT compiler framework based on a medium-level internal representation")
    set_license("MIT")

    set_urls("https://github.com/vnmakarov/mir/archive/refs/tags/$(version).zip")
    add_versions("v1.0.0", "08d27e8bd46ddded8567cb17dc384f817044ca0058285ecda22f8ce99ebd80ba")

    add_links("mir")
    if is_plat("linux", "bsd") then
        add_syslinks("m", "dl", "pthread")
    elseif is_plat("macosx") then
        add_syslinks("m", "pthread")
    end
    
    add_deps("curl" , "libcurl")
        
    on_install("linux", "macosx", "android|arm64-v8a", function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DCMAKE_INSTALL_PREFIX=" .. package:installdir()
        }
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
        end

        io.writefile("mir-run.c", "int main(void) { return 0; }\n")
        
        local target = package:config("shared") and "mir_shared" or "mir_static"
        import("package.tools.cmake").build(package, configs, {target = target})

        local libdir = package:installdir("lib")
        os.mkdir(libdir)
        if package:config("shared") then
            if package:is_plat("windows") then
                os.cp(path.join(package:builddir(), "libmir_shared.dll"), path.join(package:installdir("bin"), "mir.dll"))
                os.cp(path.join(package:builddir(), "libmir_shared.lib"), path.join(libdir, "mir.lib"))
            elseif package:is_plat("macosx") then
                os.cp(path.join(package:builddir(), "libmir_shared.dylib"), path.join(libdir, "libmir.dylib"))
            else
                os.cp(path.join(package:builddir(), "libmir_shared.so"), path.join(libdir, "libmir.so"))
            end
        else
            os.cp(path.join(package:builddir(), "libmir_static.a"), path.join(libdir, "libmir.a"))
        end

        local includedir = package:installdir("include")
        os.cp("mir*.h", includedir)
        os.cp("c2mir/c2mir.h", includedir)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MIR_init", {includes = "mir.h"}))
    end)
