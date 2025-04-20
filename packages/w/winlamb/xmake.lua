package("winlamb")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/rodrigocfd/winlamb")
    set_description("A lightweight modern C++11 library for Win32 API, using lambdas to handle Windows messages.")
    set_license("MIT")

    add_urls("https://github.com/rodrigocfd/winlamb.git")
    add_versions("2023.07.07", "3db0753b91074be6e0097ebb8f719dc4045510de")

    on_install("windows", function (package)
        os.cp("*", path.join(package:installdir("include"), "winlamb"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            class My_Window : public wl::window_main {
            public:
                My_Window();
            };
            RUN(My_Window)
            My_Window::My_Window() {
                setup.wndClassEx.lpszClassName = L"SOME_CLASS_NAME"; // class name to be registered
                setup.title = L"This is my window";
                setup.style |= WS_MINIMIZEBOX;

                on_message(WM_CREATE, [this](wl::wm::create p) -> LRESULT
                {
                    set_text(L"A new title for the window");
                    return 0;
                });
            }
        ]]}, {configs = {languages = "cxx11"}, includes = "winlamb/window_main.h"}))
    end)
