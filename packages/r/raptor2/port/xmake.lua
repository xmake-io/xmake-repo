option("libxslt", {default = true})

add_rules("mode.debug", "mode.release")

add_requires("libxml2", "libcurl")
if has_config("libxslt") then
    add_requires("libxslt")
end

set_configvar("RAPTOR_VERSION_DECIMAL", 20016)
set_configvar("RAPTOR_VERSION_MAJOR", 2)
set_configvar("RAPTOR_VERSION_MINOR", 0)
set_configvar("RAPTOR_VERSION_RELEASE", 16)
set_configvar("VERSION", "2.0.16")

local defines = {
    HAVE_ERRNO_H = true,
    HAVE_LIMITS_H = true,
    HAVE_SETJMP_H = true,
    HAVE_STDDEF_H = true,
    HAVE_STDLIB_H = true,
    HAVE_STRING_H = true,
    HAVE_XMLCTXTUSEOPTIONS = true,
    HAVE_XMLSAX2INTERNALSUBSET = true,
    RAPTOR_LIBXML_HTML_PARSE_NONET = true,
    RAPTOR_LIBXML_XML_PARSE_NONET = true,
    RAPTOR_LIBXML_XMLSAXHANDLER_EXTERNALSUBSET = true,
    RAPTOR_LIBXML_XMLSAXHANDLER_INITIALIZED = true,
    RAPTOR_LIBXML_ENTITY_ETYPE = true,
    RAPTOR_LIBXML_ENTITY_NAME_LENGTH = true,
    HAVE_RAPTOR_PARSE_DATE = true,
    RAPTOR_PARSER_RDFXML = true,
    RAPTOR_PARSER_NTRIPLES = true,
    RAPTOR_PARSER_TURTLE = true,
    RAPTOR_PARSER_TRIG = true,
    RAPTOR_PARSER_RSS = true,
    RAPTOR_PARSER_GUESS = true,
    RAPTOR_PARSER_RDFA = true,
    RAPTOR_PARSER_NQUADS = true,
    RAPTOR_PARSER_GRDDL = has_config("libxslt"),
    RAPTOR_SERIALIZER_RDFXML = true,
    RAPTOR_SERIALIZER_NTRIPLES = true,
    RAPTOR_SERIALIZER_RDFXML_ABBREV = true,
    RAPTOR_SERIALIZER_TURTLE = true,
    RAPTOR_SERIALIZER_RSS_1_0 = true,
    RAPTOR_SERIALIZER_ATOM = true,
    RAPTOR_SERIALIZER_DOT = true,
    RAPTOR_SERIALIZER_HTML = true,
    RAPTOR_SERIALIZER_JSON = true,
    RAPTOR_SERIALIZER_NQUADS = true,
    SIZEOF_UNSIGNED_CHAR = 1,
    SIZEOF_UNSIGNED_SHORT = 2,
    SIZEOF_UNSIGNED_INT = 4,
    SIZEOF_UNSIGNED_LONG = is_plat("windows") and 4 or (is_arch("x86_64", "arm64", "x64") and 8 or 4),
    SIZEOF_UNSIGNED_LONG_LONG = 8,
    RAPTOR_VERSION_DECIMAL = 20016,
    RAPTOR_MIN_VERSION_DECIMAL = 20016,
    RAPTOR_WWW_DEFINE = "RAPTOR_WWW_LIBCURL",
    RAPTOR_XML_DEFINE = "RAPTOR_XML_LIBXML",
}

if not is_plat("windows") then
    defines.HAVE_UNISTD_H = true
    defines.HAVE_FCNTL_H = true
    defines.HAVE_SYS_PARAM_H = true
    defines.HAVE_SYS_STAT_H = true
    defines.HAVE_SYS_TIME_H = true
    defines.HAVE_TIME_H = true
    defines.TIME_WITH_SYS_TIME = true
    defines.HAVE_GETTIMEOFDAY = true
    defines.HAVE_SETJMP = true
    defines.HAVE_STAT = true
    defines.HAVE_STRCASECMP = true
    defines.HAVE_STRINGS_H = true
    defines.HAVE_STRTOK_R = true
    defines.HAVE_VASPRINTF = true
    defines.HAVE_VSNPRINTF = true
    defines.HAVE_ISASCII = true
else
    defines.HAVE___FUNCTION__ = true
    defines.HAVE_STRICMP = true
    defines.HAVE__STRICMP = true
    defines.HAVE_SNPRINTF = true
    defines.HAVE_VSNPRINTF = true
    defines.HAVE__ACCESS = true
end

target("raptor2")
    set_kind("$(kind)")
    set_languages("c99")
    add_defines("RAPTOR_INTERNAL=1", "LIBRDFA_IN_RAPTOR=1", "HAVE_CONFIG_H")
    if not is_kind("shared") then
        add_defines("RAPTOR_STATIC")
    end
    if is_plat("windows") then
        add_defines("WIN32")
    end
    set_configdir("src")
    add_configfiles("src/(raptor2.h.in)", {filename = "raptor2.h", pattern = "@([A-Z_]+)@"})
    add_includedirs("src", "librdfa")
    add_includedirs("include/raptor2", {public = true})
    add_headerfiles("include/(raptor2/*.h)")

    add_files("src/*.c", "librdfa/*.c")
    remove_files("src/raptor_json.c")
    if not has_config("libxslt") then
        remove_files("src/raptor_grddl.c")
    end
    remove_files("src/raptor_nfc_icu.c", "src/raptor_nfc_test.c",
                 "src/raptor_permute_test.c", "src/raptor_www_test.c")

    add_packages("libxml2", "libcurl")
    if has_config("libxslt") then
        add_packages("libxslt")
    end

    before_build(function(target)
        -- Install public headers
        os.mkdir("include/raptor2")
        os.cp("src/raptor.h", "include/raptor2/raptor.h")
        os.cp("src/raptor2.h", "include/raptor2/raptor2.h")

        -- Generate raptor_config.h from cmake template
        local template = io.readfile("src/raptor_config_cmake.h.in")
        template = template:gsub("#cmakedefine (%S+)", function(var)
            if defines[var] then
                return "#define " .. var .. " 1"
            else
                return "#undef " .. var
            end
        end)
        template = template:gsub("@([A-Z_]+)@", function(var)
            local v = defines[var]
            if v == true then return "1"
            elseif v == false then return "0"
            else return tostring(v) end
        end)
        if not is_plat("windows") then
            template = template .. "\n#define HAVE_STRINGS_H 1\n"
        end
        io.writefile("src/raptor_config.h", template)

        -- Windows: add <io.h> and fix access() macro for MSVC
        if is_plat("windows") then
            local cfg = io.readfile("src/raptor_config.h")
            cfg = cfg:gsub("#ifdef WIN32\n", "#ifdef WIN32\n#include <io.h>\n")
            cfg = cfg:gsub("# +define access%(p,m%)%s+_access%(p,m%)",
                "#define access(p,m) _access((const char*)(p),m)")
            io.writefile("src/raptor_config.h", cfg)
        end

        -- Patch raptor_libxml.c: fix build error with libxml2 >= 2.11
        local libxml = io.readfile("src/raptor_libxml.c")
        libxml = libxml:gsub("#if LIBXML_VERSION >= 20627",
            "#if LIBXML_VERSION >= 20627 && LIBXML_VERSION < 21000")
        io.writefile("src/raptor_libxml.c", libxml)

        -- Windows: add missing <windows.h> include
        if is_plat("windows") then
            local win32 = io.readfile("src/raptor_win32.c")
            win32 = win32:gsub("#ifdef WIN32\n", "#ifdef WIN32\n#include <windows.h>\n")
            io.writefile("src/raptor_win32.c", win32)
        end
    end)
