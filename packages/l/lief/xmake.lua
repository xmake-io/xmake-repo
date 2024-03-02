package("lief")

    set_homepage("https://lief.quarkslab.com")
    set_description("Library to Instrument Executable Formats.")
    set_license("Apache-2.0")

    set_urls("https://github.com/lief-project/LIEF/archive/$(version).tar.gz",
             "https://github.com/lief-project/LIEF.git")
    add_versions("0.10.1", "6f30c98a559f137e08b25bcbb376c0259914b33c307b8b901e01ca952241d00a")
    add_versions("0.11.5", "6d6d57304a56850958e4ce54f3da2ea2b9eb856ccbab61c6cde9cba15d7c9da5")
    add_versions("0.14.0", "400804e38cb5ce8d15fb52a4db6345f02da7b2e5cb773665712283001482b808")
    add_versions("0.14.1", "92916dcb3178353d863aef4f409186889983c56e025b774741d5316a72ec3a7d")

    add_deps("cmake")

    add_configs("elf",    {description = "Enable ELF module.", default = true, type = "boolean"})
    add_configs("pe",     {description = "Enable PE module.", default = true, type = "boolean"})
    add_configs("macho",  {description = "Enable MachO module.", default = true, type = "boolean"})

    add_configs("dex",    {description = "Enable Dex module.", default = false, type = "boolean"})
    add_configs("vdex",   {description = "Enable Vdex module.", default = false, type = "boolean"})
    add_configs("oat",    {description = "Enable Oat module.", default = false, type = "boolean"})
    add_configs("art",    {description = "Enable Art module.", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    on_install("macosx", "linux", "windows", function (package)
        local configs = {"-DLIEF_PYTHON_API=OFF", "-DLIEF_DOC=OFF", "-DLIEF_TESTS=OFF", "-DLIEF_EXAMPLES=OFF", "-DLIEF_INSTALL_PYTHON=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DLIEF_" .. name:upper() .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local parse_entry
        if package:config("elf") then
            parse_entry = "elf_parse"
        elseif package:config("pe") then
            parse_entry = "pe_parse"
        elseif package:config("macho") then
            parse_entry = "macho_parse"
        end
        if parse_entry then
            assert(package:check_cxxsnippets({test = [[
                #include <LIEF/LIEF.h>
                void test() {
                    ]] .. parse_entry .. [[("");
                }
            ]]}, {configs = {languages = "c"}}))
        end
    end)
