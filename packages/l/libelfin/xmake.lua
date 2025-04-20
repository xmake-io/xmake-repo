package("libelfin")
    set_homepage("https://github.com/aclements/libelfin")
    set_description("C++11 ELF/DWARF parser")
    set_license("MIT")

    add_urls("https://github.com/aclements/libelfin/archive/e0172767b79b76373044118ef0272b49b02a0894.tar.gz",
             "https://github.com/aclements/libelfin.git")
    -- 2024.03.11
    add_versions("v0.3", "0fb80f8a36b9b2563bd193ace5866972e739af306955e539310dc9dd870aef6c")

    add_deps("python 3.x", {kind = "binary"})

    on_install("!windows and !mingw", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <libelfin/elf/elf++.hh>
            void test() {
                int fd = 0;
                elf::elf ef(elf::create_mmap_loader(fd));
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
