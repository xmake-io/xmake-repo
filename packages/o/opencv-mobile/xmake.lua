package("opencv-mobile")
    set_homepage("https://github.com/nihui/opencv-mobile")
    set_description("The minimal opencv for Android, iOS, ARM Linux, Windows, Linux, MacOS, WebAssembly")
    set_license("Apache-2.0")

    local version_map = {
        ["4.10.0"] = "v29",
        ["3.4.20"] = "v29"
    }
    add_urls("https://github.com/nihui/opencv-mobile/releases/download/$(version).zip", {version = function (version)
        local v = version_map[tostring(version)]
        if not v then
            return version
        end
        return string.format("%s/opencv-mobile-%s", v, tostring(version))
    end})

    add_versions("4.10.0", "e9209285ad4d682536db4505bc06e46b94b9e56d91896e16c2853c83a870f004")
    add_versions("3.4.20", "85c19b443454d3ae839d8f4f7a6a71c79f9ac38592a8a96e2f806fc0c68b64f4")

    add_patches("*", "patches/msvc.patch", "6fa760ea58c8b90c87129f16c84b128a4447ea11cee7d6568ea4f5e7ae250971")

    add_deps("cmake", "python 3.x", {kind = "binary"})
    add_deps("openmp")

    on_load(function (package)
        if package:is_plat("windows") then
            local arch = "x64"
            if     package:is_arch("x86")   then arch = "x86"
            elseif package:is_arch("arm64") then arch = "ARM64"
            end
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            local vs = package:toolchain("msvc"):config("vs")
            local vc_ver = "vc13"
            if     vs == "2015" then vc_ver = "vc14"
            elseif vs == "2017" then vc_ver = "vc15"
            elseif vs == "2019" then vc_ver = "vc16"
            elseif vs == "2022" then vc_ver = "vc17"
            end
            package:add("linkdirs", linkdir) -- fix path for 4.9.0/vs2022
            package:add("linkdirs", path.join(arch, vc_ver, linkdir))
        elseif package:is_plat("mingw") then
            local arch = (package:is_arch("x86_64") and "x64" or "x86")
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            package:add("linkdirs", path.join(arch, "mingw", linkdir))
        elseif package:version():ge("4.0") then
            package:add("includedirs", "include/opencv4")
        end
    end)

    on_install("linux", "macosx", "windows", "mingw@windows,msys", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBUILD_WITH_STATIC_CRT=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
            if package:is_arch("arm64") then
                table.insert(configs, "-DCMAKE_SYSTEM_NAME=Windows")
                table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=ARM64")
            end
        elseif package:is_plat("mingw") then
            table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. (package:is_arch("x86_64") and "AMD64" or "i686"))
        elseif package:is_plat("macosx") then
            table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. (package:is_arch("x86_64") and "AMD64" or "ARM64"))
        end
        local options = string.split(io.readfile("options.txt"), "\n", {plain = true})
        table.remove_if(options, function (_, option)
            return option:startswith("-DCMAKE_BUILD_TYPE") or option:startswith("-DBUILD_SHARED_LIBS") or option:startswith("-DBUILD_WITH_STATIC_CRT")
        end)
        table.join2(configs, options)
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") then
            local arch = "x64"
            if     package:is_arch("x86")   then arch = "x86"
            elseif package:is_arch("arm64") then arch = "ARM64"
            end
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            local vs = package:toolchain("msvc"):config("vs")
            local vc_ver = "vc13"
            if     vs == "2015" then vc_ver = "vc14"
            elseif vs == "2017" then vc_ver = "vc15"
            elseif vs == "2019" then vc_ver = "vc16"
            elseif vs == "2022" then vc_ver = "vc17"
            end

            local libfiles = {}
            table.join2(libfiles, os.files(package:installdir(linkdir, "*.lib")))
            table.join2(libfiles, os.files(package:installdir(arch, vc_ver, linkdir, "*.lib")))
            for _, f in ipairs(libfiles) do
                if not f:match("opencv_.+") then
                    package:add("links", path.basename(f))
                end
            end
            package:addenv("PATH", "bin") -- fix path for 4.9.0/vs2022
            package:addenv("PATH", path.join(arch, vc_ver, "bin"))
        elseif package:is_plat("mingw") then
            local arch = package:is_arch("x86_64") and "x64" or "x86"
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            for _, f in ipairs(os.files(package:installdir(arch, "mingw", linkdir, "lib*.a"))) do
                if not f:match("libopencv_.+") then
                    package:add("links", path.basename(f):match("lib(.+)"))
                end
            end
            package:addenv("PATH", path.join(arch, "mingw", "bin"))
        else
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            void test(int argc, char** argv) {
                cv::CommandLineParser parser(argc, argv, "{help h||show help message}");
                if (parser.has("help")) {
                    parser.printMessage();
                }
                cv::Mat image(3, 3, CV_8UC1);
                std::cout << CV_VERSION << std::endl;
            }
        ]]}, {configs = {languages = "c++11"},
              includes = package:version():ge("3.0") and "opencv2/opencv.hpp" or "opencv/cv.h"}))
    end)
