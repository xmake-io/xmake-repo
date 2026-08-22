package("macdylibbundler")
    set_homepage("https://github.com/auriamg/macdylibbundler")
    set_description("dylibbundler is a small command-line programs that aims to make bundling")
    set_license("MIT")

    add_urls("https://github.com/auriamg/macdylibbundler/archive/refs/tags/$(version).zip",
             "https://github.com/auriamg/macdylibbundler.git")

    add_versions("1.0.5", "d48138fd6766c70097b702d179a657127f9aed3d083051c2d4fce145881a316e")

    on_load(function (package)
        if not package:is_cross() then
            package:addenv("PATH", "bin")
        end
    end)

    on_install("!windows and !iphoneos", function (package)
        if package:is_plat("mingw") then
            io.replace("src/Dependency.cpp",
            [[else if (realpath(rtrim(path).c_str(), original_file_buffer))]],
            [[else if (_fullpath(original_file_buffer, rtrim(path).c_str(), _MAX_PATH))]], {plain = true})
            io.replace("src/DylibBundler.cpp",
            [[if (realpath(path_to_check.c_str(), buffer))]],
            [[if (_fullpath(buffer, path_to_check.c_str(), _MAX_PATH))]], {plain = true})
            io.replace("src/DylibBundler.cpp",
            [[if (realpath(fullpath.c_str(), buffer))]],
            [[if (_fullpath(buffer, fullpath.c_str(), _MAX_PATH))]], {plain = true})            
        end
        io.replace("src/Utils.cpp", [[using namespace std;]], [[using namespace std;
#ifdef __MINGW32__
#include <cstdlib>
#include <cstring>
#include <direct.h>
#include <cerrno>
#include <ctime>
#include <climits>
char * __cdecl mkdtemp(char *template_name)
{
    int j, ret, len, index;
    unsigned int i, r;

    static const char letters[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    if (template_name == NULL || (len = strlen (template_name)) < 6
            || memcmp (template_name + (len - 6), "XXXXXX", 6)) {
        errno = EINVAL;
        return NULL;
    }

    for (index = len - 6; index > 0 && template_name[index - 1] == 'X'; index--);

    for (i = 0; i <= INT_MAX; i++) {
        for(j = index; j < len; j++) {
            if (rand_s(&r))
                r = rand() ^ _time32(NULL);
            template_name[j] = letters[r % 62];
        }
        ret = _mkdir(template_name);
        if (ret == 0) return template_name;
        if (ret != 0 && errno != EEXIST) return NULL;
    }

    return NULL;
}
#endif]], {plain = true})
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")

            target("macdylibbundler")
                set_kind("$(kind)")
                add_files("src/*.cpp")
                remove_files("src/main.cpp")
                add_includedirs("src")
                add_headerfiles("src/*.h")
                if is_plat("mingw") then
                    add_defines("_CRT_RAND_S")
                end

            target("macdylibbundler-cli")
                set_basename("macdylibbundler")
                set_kind("binary")
                add_files("src/main.cpp")
                add_deps("macdylibbundler")]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("macdylibbundler --help")
        end
        assert(package:check_cxxsnippets({test = [[
            void test() {
                collectSubDependencies();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "DylibBundler.h"}))
    end)
