package("opencv-prebuilts")
    set_homepage("https://github.com/thommyho/Cpp-OpenCV-Windows-PreBuilts")
    set_description("OpenCV prebuilt windows binaries and libs | x64 and x86 | MSVC143, MSVC142, legacy (MSVC141,MSVC140) | Debug, Release, RelWithDebInfo")

    -- local vs_ver = nil

    -- on_fetch(function (package)
    --     vs_ver = import("core.tool.toolchain").load("msvc"):config("vs")
    -- end)

    -- if vs_ver == "2019" then
    --     if os.arch() == "x86" then
    --         set_urls("https://github.com/thommyho/Cpp-OpenCV-Windows-PreBuilts/releases/download/$(version)/MSVC142_32.zip")
    --     elseif os.arch() == "x64" then
    --         set_urls("https://github.com/thommyho/Cpp-OpenCV-Windows-PreBuilts/releases/download/$(version)/MSVC142_64.zip")
    --     end
    -- elseif vs_ver == "2022" then
    --     if os.arch() == "x86" then
    --         set_urls("https://github.com/thommyho/Cpp-OpenCV-Windows-PreBuilts/releases/download/$(version)/MSVC143_32.zip")
    --     elseif os.arch() == "x64" then
    --         set_urls("https://github.com/thommyho/Cpp-OpenCV-Windows-PreBuilts/releases/download/$(version)/MSVC143_64.zip")
    --         add_versions("v4.9.0", "0637b2c0334b767879bcf6e6d5e0c4f978d7105fc882cfe58d712f52819602bf")
    --     end
    -- end

    if on_source then
        on_source(function (package)
            local vs_ver = import("core.tool.toolchain").load("msvc"):config("vs")
            if package:is_plat("windows") and package:is_arch("x86") then
                if vs_ver == "2019" then
                    package:set("urls", "https://github.com/thommyho/Cpp-OpenCV-Windows-PreBuilts/releases/download/$(version)/MSVC142_32.zip")
                    package:add("versions", "v4.9.0", "c7acd0ca408e141bf64f0e890f5ef390d22e0dc9c2ae09ada2452ef003838487")
                elseif vs_ver == "2022" then
                    package:set("urls", "https://github.com/thommyho/Cpp-OpenCV-Windows-PreBuilts/releases/download/$(version)/MSVC143_32.zip")
                    package:add("versions", "v4.9.0", "d5c70ffab3321f35b5e7d03a5e8238cc3d1c37dc18454b1ca0c6823282bbcedd")
                end
            elseif package:is_plat("windows") and package:is_arch("x64") then
                if vs_ver == "2019" then
                    package:set("urls", "https://github.com/thommyho/Cpp-OpenCV-Windows-PreBuilts/releases/download/$(version)/MSVC142_64.zip")
                    package:add("versions", "v4.9.0", "77bf3c0efbfedfcc2c48373ae6f8637938b7d39c453c57c68036bff760a89286")
                elseif vs_ver == "2022" then
                    package:set("urls", "https://github.com/thommyho/Cpp-OpenCV-Windows-PreBuilts/releases/download/$(version)/MSVC143_64.zip")
                    package:add("versions", "v4.9.0", "0637b2c0334b767879bcf6e6d5e0c4f978d7105fc882cfe58d712f52819602bf")
                end
            end
        end)
    end

    add_configs("runtimes", {description = "Set compiler runtimes.", default = "MD", readonly = true})

    on_install("windows", function (package)    
        if package:is_debug() then
            os.cp("Debug/include/*", package:installdir("include"))
            os.cp("Debug/lib/*", package:installdir("lib"))
        else
            os.cp("Release/include/*", package:installdir("include"))
            os.cp("Release/lib/*", package:installdir("lib"))
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
              includes = package:version():ge("v4.9.0") and "opencv2/opencv.hpp"}))
    end)
