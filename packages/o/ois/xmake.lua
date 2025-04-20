package("ois")
    set_homepage("https://wgois.github.io/OIS/")
    set_description("Official OIS repository. Object oriented Input System")
    set_license("zlib")

    add_urls("https://github.com/wgois/OIS/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wgois/OIS.git")

    add_versions("v1.5.1", "614f6ef6d69cf6d84f1b50efff46a6c1acce426933e5f0dcf29862ea8332af73")

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_deps("libx11")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa", "Foundation", "Carbon", "IOKit")
    elseif is_plat("windows", "mingw") then
        add_syslinks("dinput8", "dxguid", "ole32", "oleaut32", "user32", "uuid", "xinput", "winmm")
    end

    on_install("windows", "linux", "macosx", function (package)
        local configs = {
            "-DOIS_BUILD_DEMOS=OFF", 
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DOIS_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include <ois/OIS.h>

        class InputListener : public OIS::KeyListener {
        public:
            bool keyPressed(const OIS::KeyEvent& arg) override { return true; }
            bool keyReleased(const OIS::KeyEvent& arg) override { return true; }
        };

        void test() {
            OIS::InputManager* inputManager = OIS::InputManager::createInputSystem(0);
            OIS::Keyboard* keyboard = static_cast<OIS::Keyboard*>(inputManager->createInputObject(OIS::OISKeyboard, true));

            InputListener inputListener;
            keyboard->setEventCallback(&inputListener);

            keyboard->capture();

            inputManager->destroyInputObject(keyboard);
            OIS::InputManager::destroyInputSystem(inputManager);
        }

        ]]}, {configs = {languages = "cxx11"}}))
    end)
