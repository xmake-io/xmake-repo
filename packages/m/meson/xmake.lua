package("meson")

    set_kind("binary")
    set_homepage("https://mesonbuild.com/")
    set_description("Fast and user friendly build system.")

    add_urls("https://github.com/mesonbuild/meson/releases/download/$(version)/meson-$(version).tar.gz",
             "https://github.com/mesonbuild/meson.git")
    add_versions("0.50.1", "f68f56d60c80a77df8fc08fa1016bc5831605d4717b622c96212573271e14ecc")

    add_deps("ninja", "python 3.x", {kind = "binary"})
  
    on_install("@macosx", "@linux", "@windows", function (package)
        local version = package:dep("python"):version()
        local envs = {}
        if is_host("windows") then
            package:addenv("PATH", "Scripts")
            envs.PYTHONPATH = package:installdir("Lib", "site-packages")
        else
            envs.PYTHONPATH = package:installdir("lib", "python" .. version:major() .. "." .. version:minor(), "site-packages")
        end
        os.vrunv("python3", {"setup.py", "install", "--prefix=" .. package:installdir()}, {envs = envs})
        package:addenv("PYTHONPATH", envs.PYTHONPATH)
    end)

    on_test(function (package)
        os.vrun("meson --version")
    end)
