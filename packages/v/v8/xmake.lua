package("v8")
    set_homepage("https://chromium.googlesource.com/v8/v8.git")
    set_description("V8 JavaScript Engine")

    add_urls("https://github.com/v8/v8.git")
    add_versions("10.0.58", "d75903764c8547b6fc35c7a3fe4991320be03135")

    add_deps("depot_tools")

    on_install("linux", "macosx", "windows", function (package)
        import("core.base.global")

        -- maybe we need set proxy, e.g. `xmake g --proxy=http://127.0.0.1:xxxx`
        local envs = {}
        local proxy = global.get("proxy")
        if proxy then
            envs.HTTP_PROXY = proxy
            envs.HTTPS_PROXY = proxy
            envs.ALL_PROXY = proxy
        end
        io.writefile(".gclient", [=[solutions = [
  {
    "name": ".",
    "url": "https://github.com/v8/v8.git",
    "deps_file": "DEPS",
    "managed": False,
    "custom_deps": {},
  }]]=])
        local gclient = package:is_plat("windows") and "gclient.bat" or "gclient"
        os.vrunv(gclient, {"sync", "-v"}, {envs = envs})
        os.vrunv("python3", {"./tools/dev/gm.py", "x64.release"})
        print(os.files("out/**.a"))
        print(os.files("out/**.dylib"))
        print(os.files("out/**.so"))
        print(os.files("out/**.lib"))
        print(os.files("out/**.h"))
        print(os.files("out/**.hpp"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("V8::Initialize", {includes = "v8.h"}))
    end)
