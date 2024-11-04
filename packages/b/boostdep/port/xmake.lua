-- Boost Root build

add_rules("mode.debug", "mode.release")

set_languages("c++17")

target("filesystem")
    set_kind("static")
    add_files("libs/filesystem/src/*.cpp|windows_file_codecvt.cpp")

    add_defines("BOOST_FILESYSTEM_NO_CXX20_ATOMIC_REF")
    add_defines("BOOST_FILESYSTEM_STATIC_LINK=1", {public = true})

    for _, dir in ipairs(os.dirs("libs/*")) do
        add_includedirs(path.join(dir, "include"), {public = true})
    end

    if is_plat("windows", "mingw", "msys2") then
        add_files("libs/filesystem/src/*.cpp")
        add_defines("BOOST_USE_WINDOWS_H", "WIN32_LEAN_AND_MEAN", "NOMINMAX")
        add_syslinks("bcrypt")
        if is_plat("windows") then
            add_defines("BOOST_ALL_NO_LIB", {public = true})
        end
    end

target("boostdep")
    set_kind("binary")
    add_files("tools/boostdep/src/*.cpp")
    add_deps("filesystem")
