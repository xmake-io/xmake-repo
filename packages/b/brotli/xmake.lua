package("brotli")
    set_homepage("https://github.com/google/brotli")
    set_description("Brotli compression format.")
    set_license("MIT")

    set_urls("https://github.com/google/brotli/archive/$(version).tar.gz",
             "https://github.com/google/brotli.git")

    add_versions("v1.2.0", "816c96e8e8f193b40151dad7e8ff37b1221d019dbcb9c35cd3fadbfe6477dfec")
    add_versions("v1.1.0", "e720a6ca29428b803f4ad165371771f5398faba397edf6778837a18599ea13ff")
    add_versions("v1.0.9", "f9e8d81d0405ba66d181529af42a3354f838c939095ff99930da6aa9cdf6fe46")

    -- Fix VC C++ 12.0 BROTLI_MSVC_VERSION_CHECK calls
    -- VC <= 2012 build failed
    if is_plat("windows") then
        add_patches("v1.0.9", path.join(os.scriptdir(), "patches", "1.0.9", "common_platform.patch"),
                    "5d7363a6ed1f9a504dc7af08920cd184f0d04d1ad12d25d657364cf0a2dae6bb")
        add_patches("v1.0.9", path.join(os.scriptdir(), "patches", "1.0.9", "tool_brotli.patch"),
                    "333e2a0306cf33f2fac381aa6b81afd3d1237e7511e5cc8fe7fb760d16d01ca1")
    end

    add_links("brotlienc", "brotlidec", "brotlicommon")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::brotli")
    elseif is_plat("linux") then
        add_extsources("pacman::brotli", "apt::libbrotli-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::brotli")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    if on_fetch then
        on_fetch("linux", "macosx", function (package, opt)
            if opt.system then
                local result
                for _, name in ipairs({"libbrotlidec", "libbrotlienc", "libbrotlicommon"}) do
                    local pkginfo = package.find_package and package:find_package("pkgconfig::" .. name, opt)
                    if pkginfo then
                        if not result then
                            result = table.copy(pkginfo)
                        else
                            local includedirs = pkginfo.sysincludedirs or pkginfo.includedirs
                            result.links = table.wrap(result.links)
                            result.linkdirs = table.wrap(result.linkdirs)
                            result.includedirs = table.wrap(result.includedirs)
                            table.join2(result.includedirs, includedirs)
                            table.join2(result.linkdirs, pkginfo.linkdirs)
                            table.join2(result.links, pkginfo.links)
                        end
                    end
                end
                return result
            end
        end)
    end

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {buildir = "xbuild", vers = package:version_str()}
        if package:config("shared") then
            configs.kind = "shared"
        end
        if package:is_plat("linux") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function(package)
        if not package:is_cross() then
            os.vrun("brotli --version")
        end
        assert(package:check_csnippets([[
            void test() {
                BrotliEncoderState* s = BrotliEncoderCreateInstance(NULL, NULL, NULL);
                BrotliEncoderDestroyInstance(s);
            }
        ]], {includes = "brotli/encode.h"}))
    end)
