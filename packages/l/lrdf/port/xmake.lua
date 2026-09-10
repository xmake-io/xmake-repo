add_rules("mode.debug", "mode.release")
add_requires("raptor2")

target("lrdf")
    set_kind("$(kind)")

    if is_plat("windows") then
        add_cflags("/D_CRT_SECURE_NO_WARNINGS")
        if is_kind("shared") then
            add_rules("utils.symbols.export_all")
        end
    end

    before_build(function(target)
        local srctypes = path.join("lrdf_types.h")
        local srcmain = path.join("lrdf.h")
        local srclrdf = path.join("src", "lrdf.c")
        local srclmulti = path.join("src", "lrdf_multi.c")

        if is_plat("windows") then
            -- lrdf_types.h: add stdint.h for int64_t
            local content = io.readfile(srctypes)
            content = content:gsub("#include <sys/types.h>",
                "#include <stdint.h>\n#include <sys/types.h>")
            io.writefile(srctypes, content)

            -- lrdf.h: add stdint.h for int64_t
            content = io.readfile(srcmain)
            content = content:gsub("#include <sys/types.h>",
                "#include <stdint.h>\n#include <sys/types.h>")
            io.writefile(srcmain, content)

            -- src/lrdf.c: wrap POSIX headers, add Windows headers, patch functions
            content = io.readfile(srclrdf)

            content = content:gsub("#include <unistd.h>",
                [[#ifndef _WIN32
#include <unistd.h>
#endif]])
            content = content:gsub("#include <sys/time.h>",
                [[#ifndef _WIN32
#include <sys/time.h>
#endif]])
            content = content:gsub('#include "lrdf.h"',
                [[#include "lrdf.h"

#ifdef _WIN32
#include <windows.h>
#include <process.h>
#define strncasecmp _strnicmp
#endif]])
            content = content:gsub(
                [[struct timeval tv;

    world = raptor_new_world%(%);
    lrdf_more_triples%(%d+%);

    /%* A UID to add to genids to make them safer %*/
    gettimeofday%(&tv, NULL%);
    lrdf_uid = %(unsigned int%) getpid%(%);
    lrdf_uid %^= %(unsigned int%) tv%.tv_usec;]],
                [[world = raptor_new_world();
    lrdf_more_triples(256);

    /* A UID to add to genids to make them safer */
#ifdef _WIN32
    lrdf_uid = (unsigned int) _getpid();
    {
        LARGE_INTEGER freq, counter;
        QueryPerformanceFrequency(&freq);
        QueryPerformanceCounter(&counter);
        lrdf_uid ^= (unsigned int)((counter.QuadPart * 1000000 / freq.QuadPart) %% 1000000);
    }
#else
    {
        struct timeval tv;
        gettimeofday(&tv, NULL);
        lrdf_uid = (unsigned int) getpid();
        lrdf_uid ^= (unsigned int) tv.tv_usec;
    }
#endif]])

            io.writefile(srclrdf, content)

            -- src/lrdf_multi.c: wrap unistd.h
            content = io.readfile(srclmulti)
            content = content:gsub("#include <unistd.h>",
                [[#ifndef _WIN32
#include <unistd.h>
#endif]])
            io.writefile(srclmulti, content)
        end
    end)

    add_files("src/lrdf.c", "src/lrdf_multi.c")
    add_includedirs(".", "src")
    add_headerfiles("lrdf.h", "lrdf_types.h")

    add_packages("raptor2")
