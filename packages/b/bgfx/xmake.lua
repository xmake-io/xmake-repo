package("bgfx")

    set_homepage("https://bkaradzic.github.io/bgfx/")
    set_description("Cross-platform, graphics API agnostic, “Bring Your Own Engine/Framework” style rendering library")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/bkaradzic/bgfx.git")
    add_versions("7816", "5ecddbf4d51e2dda2a56ae8cafef4810e3a45d87")

    add_resources("7816", "bx", "https://github.com/bkaradzic/bx.git", "51f25ba638b9cb35eb2ac078f842a4bed0746d56")
    add_resources("7816", "bimg", "https://github.com/bkaradzic/bimg.git", "8355d36befc90c1db82fca8e54f38bfb7eeb3530")

    if is_plat("windows") then
        add_syslinks("user32", "gdi32", "psapi")
        add_includedirs("include", "include/compat/msvc")
    elseif is_plat("macosx") then
        add_frameworks("Metal", "QuartzCore", "Cocoa")
    elseif is_plat("linux") then
        add_deps("libx11")
        add_syslinks("GL", "pthread", "dl")
    end

    on_load("windows", "macosx", "linux", function (package)
        local suffix = package:debug() and "Debug" or "Release"
        for _, lib in ipairs({"bgfx", "bimg", "bx"}) do
            package:add("links", lib .. suffix)
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local bxdir = package:resourcefile("bx")
        local bimgdir = package:resourcefile("bimg")
        local genie = path.join(bxdir, "tools", "bin")
        if is_host("windows") then
            genie = path.join(genie, "windows", "genie.exe")
        elseif is_host("macosx") then
            genie = path.join(genie, "darwin", "genie")
        elseif is_host("linux") then
            genie = path.join(genie, "linux", "genie")
        end

        local args = {"--with-tools"}
        if package:config("shared") then
            table.insert(args, "--with-shared-lib")
        end
        os.trycp(path.join("include", "bgfx"), package:installdir("include"))
        os.trycp(path.join(bxdir, "include", "*"), package:installdir("include"))
        os.trycp(path.join(bimgdir, "include", "*"), package:installdir("include"))

        local mode = package:debug() and "Debug" or "Release"
        if package:is_plat("windows") then
            import("package.tools.msbuild")
            import("core.tool.toolchain")

            local msvc = toolchain.load("msvc")
            table.insert(args, "vs" .. msvc:config("vs"))

            local envs = msbuild.buildenvs(package)
            envs.BX_DIR = bxdir
            envs.BIMG_DIR = bimgdir
            os.vrunv(genie, args, {envs = envs})

            local configs = {}
            table.insert(configs, "/p:Configuration=" .. mode)
            table.insert(configs, "/p:Platform=" .. (package:is_arch("x64") and "x64" or "Win32"))
            table.insert(configs, "bgfx.sln")
            os.cd(format(".build/projects/vs%s", msvc:config("vs")))
            msbuild.build(package, configs)

            os.trycp("../../win*_vs*/bin/*.lib|*example*", package:installdir("lib"))
            os.trycp("../../win*_vs*/bin/*.dll", package:installdir("lib"))
            os.trycp("../../win*_vs*/bin/*.lib", package:installdir("lib"))
            os.trycp("../../win*_vs*/bin/*.exe", package:installdir("bin"))
        else
            import("package.tools.make")

            local configs
            local target
            if package:is_plat("macosx") then
                target = (package:is_arch("x86_64") and "osx-x64" or "osx-arm64")
                table.insert(args, "--gcc=" .. target)
                configs = {"-C",
                           ".build/projects/gmake-" .. target,
                           "config=" .. mode:lower()}
            elseif package:is_plat("linux") then
                table.insert(args, "--gcc=linux-gcc")
                target = "linux" .. (package:is_arch("x86_64") and "64" or "32") .. "_gcc"
                configs = {"-C",
                           ".build/projects/gmake-linux",
                           "config=" .. mode:lower() .. (package:is_arch("x86_64") and "64" or "32")}
            end
            table.insert(args, "gmake")

            local envs = make.buildenvs(package)
            envs.BX_DIR = bxdir
            envs.BIMG_DIR = bimgdir
            os.vrunv(genie, args, {envs = envs})
            make.build(package, configs)

            if package:is_plat("macosx") then
                os.trycp(".build/" .. target .. "/bin/*.a|*example*", package:installdir("lib"))
                os.trycp(".build/" .. target .. "/bin/*.so", package:installdir("lib"))
                os.trycp(".build/" .. target .. "/bin/*|.build/*.*", package:installdir("bin"))
            elseif package:is_plat("linux") then
                os.trycp(".build/" .. target .. "/bin/*.a|*example*", package:installdir("lib"))
                os.trycp(".build/" .. target .. "/bin/*.so", package:installdir("lib"))
                os.trycp(".build/" .. target .. "/bin/*|.build/*.*", package:installdir("bin"))
            end
        end
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                bgfx::init();
            }
        ]]}, {configs = {languages = "c++14"}, includes = "bgfx/bgfx.h"}))
    end)
