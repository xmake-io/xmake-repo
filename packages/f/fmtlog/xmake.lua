package("fmtlog")
    set_homepage("https://github.com/MengRao/fmtlog")
    set_description("fmtlog is a performant fmtlib-style logging library with latency in nanoseconds.")
    set_license("MIT")

    add_urls("https://github.com/MengRao/fmtlog/archive/refs/tags/$(version).tar.gz",
             "https://github.com/MengRao/fmtlog.git")
    add_versions("v2.2.2", "31e8341093e45fc999dbeeecfe9cdc118cc8f1e64a184cc3f194f5701d5eaec9")
    add_versions("v2.2.1", "9bc2f1ea37eece0f4807689962b529d2d4fa07654baef184f051319b4eac9304")
    add_versions("v2.1.2", "d286184e04c3c3286417873dd2feac524c53babc6cd60f10179aa5b10416ead7")

    add_deps("cmake")
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        local fmtver = ""
        local packagever = package:version()
        if packagever then
            local version_mapping = {
                {pkgver = "2.2.2", fmtver = " 10.2.1"},
                {pkgver = "2.2.1", fmtver = " 9.1.0"},
                {pkgver = "2.1.2", fmtver = " 8.1.0"}
            }
            -- find lowest matching version (or exact match)
            for _, ver in ipairs(version_mapping) do
                if packagever:lt(ver.pkgver) then
                    fmtver = ver.fmtver
                else
                    if packagever:eq(ver.pkgver) then
                        fmtver = ver.fmtver
                    end
                    break
                end
            end
        end
        package:add("deps", "fmt" .. fmtver)
    end)

    on_install("linux", "macosx", "windows|!arm64", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        io.replace("CMakeLists.txt", "add_subdirectory(fmt)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(test)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(bench)", "", {plain = true})
        import("package.tools.cmake").install(package, configs, {packagedeps = "fmt"})
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"),  "*.a"))
        else
            os.tryrm(path.join(package:installdir("lib"),  "*.dll"))
            os.tryrm(path.join(package:installdir("lib"),  "*.dylib"))
            os.tryrm(path.join(package:installdir("lib"),  "*.so"))
        end
        os.cp("*.h", package:installdir("include/fmtlog"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                logi("A info msg");
            }
        ]]}, {configs = {languages = "c++17"}, includes = "fmtlog/fmtlog.h"}))
    end)
