package("tiltedcore")
    set_homepage("https://github.com/tiltedphoques/TiltedCore")
    set_description("Core library from Tilted Phoques")

    add_urls("https://github.com/tiltedphoques/TiltedCore/archive/$(version).zip")
    add_urls("https://github.com/tiltedphoques/TiltedCore.git")

    add_versions("v0.2.8", "d805c58c9f2f1b093e6523b196da6f14e1048082b9111c68fb604ef4dc795379")
    add_versions("v0.2.7", "dbc9fcee3706e91a9fbe00648c3593c8b8f0ae9208fb510e756ae6bee8931b93")
    add_versions("v0.2.6", "b5e323c579395689cabccd24b87ef0ff74e448a4d3088f25596334ccbcd634ba")
    add_versions("v0.2.5", "60cffe615bc5817b85ce6dbef92d08a80f76347464f8604a0b344bc3417aa3d6")
    add_versions("v0.2.4", "7c229b1a23a4a4c19a7871b0a43eae98a12064b2cd4894c31f7189da1729d3c0")
    add_versions("v0.2.3", "228d2d48a01ab0166a586cd1daa9809db457bbbd9d8773a94be8e572af0bd260")
    add_versions("v0.2.2", "5b6b9fd4c9c3e46f7af7fdefb0b004f2106b2da3f2b7e068fd594730d4c41eaa")
    add_versions("v0.2.1", "5cf7aab7f548c7dc49349af321d4e96286cea83177a4b779a2b8504e86f1ff3b")
    add_versions("v0.2.0", "c08096df42542add9ced163de4784a998fa08e343da3fcd9ffa42fc5393f8f93")
    add_versions("v0.1.6", "d29ee14db2015644fecf6410d28f823151986f15bea1dc9ec4251e605ab8461b")
    add_versions("v0.1.5", "8bd6826ba63ddb16137e54383f95997377409d2a7263acdbdf94bed05b50c9c9")
    add_versions("v0.1.4", "c50213b6814267ccfa24212ca0fbc922c162ac97d234ff50de2e05463115e9b4")
    add_versions("v0.1.3", "e6bc279a436e32c187341af9a47a64977d00d354eda66237804aada51d1884e3")

    add_patches("v0.2.8", "patches/0.2.8/include-mutex.patch", "3d9b87a95f9bafea72758507027ea737668eb8efa05e8dea98dc4f101701e810")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("mimalloc", {configs = {rltgenrandom = true}})

    on_check("windows", function (package)
        local msvc = package:toolchain("msvc")
        local vs = msvc:config("vs")
        if vs and tonumber(vs) < 2019 then
            raise("package(tiltedcore): VS2019 or newer is required.")
        end
    end)

    on_install("windows", "mingw", "linux", "cross", "android", "macosx|!arm*", function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                TiltedPhoques::Outcome<int, float> outcome;
            }
        ]]}, {includes = {"TiltedCore/Outcome.hpp"}}))
    end)
