package("fls-float-raylib")
    set_base("raylib")

    on_install("windows", "mingw", function (package)
        local renaming_rules = {
            { "ShowCursor(",  "rlShowCursor(" },
            { "HideCursor(",  "rlHideCursor(" },
            { "PlaySound(",   "rlPlaySound(" },
            { "StopSound(",   "rlStopSound(" },
            { "(Rectangle)",  "(rlRectangle)" },
            { "Rectangle{",   "rlRectangle{" },
            { "Rectangle;",   "rlRectangle;" },
            { "Rectangle ",   "rlRectangle " },
            { "CloseWindow(", "rlCloseWindow(" },
            { "LoadImage(",   "rlLoadImage(" },
            { "DrawText(",    "rlDrawText(" },
            { "DrawTextEx(",  "rlDrawTextEx(" },
        }
        for _, file in ipairs(table.join(os.files("src/**.c"), os.files("src/**.h"))) do
            for _, rule in ipairs(renaming_rules) do
                io.replace(file, rule[1], rule[2], {plain = true})
            end
        end
        package:base():script("install")(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Image image = rlLoadImage("image.png");
            }
        ]]}, {includes = {"raylib.h"}, configs = {languages = "cxx11"}}))
    end)
