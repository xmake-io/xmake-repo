package("caudio")

    set_homepage("https://github.com/R4stl1n/cAudio")
    set_description("3D Audio Engine Based on Openal")

    add_urls("https://github.com/R4stl1n/cAudio/archive/refs/tags/$(version).zip",
             "https://github.com/R4stl1n/cAudio.git")
    add_versions("2.3.1", "10f36cd7e1583405ade9001c3782fdf04be09f0f74e56cba23fac3a2b3ed5ae5")

    add_patches("2.3.1", path.join(os.scriptdir(), "patches", "2.3.1", "win32_fix.patch"), "da276f877d7d058f0b4bfcce18c8b9189ba4556c5d9f16f799e3e4afee0bf244")

    add_deps("openal-soft")
    add_links("cAudio", "Vorbis", "Ogg")

    on_install("windows", "linux", function (package)
        local dep_dir = (package:is_arch("x64", "x86_64") and "Dependencies64" or "Dependencies")
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"),
            "-DCAUDIO_STATIC=" .. (package:config("shared") and "FALSE" or "TRUE"),
            "-DCAUDIO_DEPENDENCIES_DIR=" .. dep_dir,
            "-DCAUDIO_BUILD_SAMPLES=FALSE"
        }

        import("package.tools.cmake").install(package, configs, {buildir = "CMake", packagedeps = "openal-soft"})

        os.cp("cAudio/include/*.h", package:installdir("include"))
        os.cp("cAudio/Headers/*.h", package:installdir("include"))
        os.cp(path.join(dep_dir, "include/*"), package:installdir("include"))
        os.cp("CMake/include/*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        void test(int argc, char* argv[]) {
            cAudio::IAudioManager* audioMgr = cAudio::createAudioManager(false);
            if(audioMgr)
            {
                cAudio::IAudioDeviceList* pDeviceList = cAudio::createAudioDeviceList();
                unsigned int deviceCount = pDeviceList->getDeviceCount();
                cAudio::cAudioString defaultDeviceName = pDeviceList->getDefaultDeviceName();
                for(unsigned int i=0; i<deviceCount; ++i)
                {
                    cAudio::cAudioString deviceName = pDeviceList->getDeviceName(i);
                    if(deviceName.compare(defaultDeviceName) == 0);
                }
                unsigned int deviceSelection = 0;

                audioMgr->initialize(pDeviceList->getDeviceName(deviceSelection).c_str());
                CAUDIO_DELETE pDeviceList;
                pDeviceList = 0;

                cAudio::IAudioSource* mysound = audioMgr->create("song", "../Media/cAudioTheme1.ogg",true);

                for (size_t i=0; i<10; i++)
                {
                    audioMgr->play2D("../Media/bling.ogg");
                }
                if(mysound)
                {
                    mysound->setVolume(0.5);
                    mysound->play2d(false);

                    while(mysound->isPlaying())
                        cAudio::cAudioSleep(10);

                }

                cAudio::destroyAudioManager(audioMgr);
            }
        }
        ]]}, {configs = {languages = "cxx11"}, includes = "cAudio.h"}))
    end)
