package("lief")
    set_homepage("https://lief.quarkslab.com")
    set_description("Library to Instrument Executable Formats.")
    set_license("Apache-2.0")

    set_urls("https://github.com/lief-project/LIEF/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lief-project/LIEF.git")

    add_versions("0.17.3", "00158beac9432b350fb528d571457a0bea8de154633a31735524a74fa69ea196")
    add_versions("0.17.2", "bece1be25aa657b94d1c97ddf88c47e0b94faa1d971c42532c4eb59fbb507fc2")
    add_versions("0.17.1", "9dea0f09c7b98e8d0c9a47f8629fbd1646ddc9bf1cae7c2f4ce42fe8934dc315")
    add_versions("0.17.0", "bcc5f1e0dcfbf6de07d8a666bf742cda6467cd08d4b5a9679dfdbaafe08563e2")
    add_versions("0.16.6", "20bae0130c98d6b29a8a7853f6a0f270398b277f12c3673164b08563cbd18e0c")
    add_versions("0.16.5", "10ef46bc958d7936feb155040c874504ab0bd40dc59b4678f807691ccd0d138f")
    add_versions("0.16.4", "311fff5ea9ecbe57b8d02e68739b97673cb14763129ce53af3eac8fee6bf845e")
    add_versions("0.16.3", "465121937c0b7885e9ceb0f6fc452a0b06b8cf2b3aabb454bfa9d4cb985d33d3")
    add_versions("0.16.2", "895ce0321b233a6d610ed89ccbe8dc4aa2cf0bb959919a1db0693ba264f3d29a")
    add_versions("0.16.1", "9fb3d18bd2182170f65c63b577c680de53605e92d18a22d49b535ca61349c5db")
    add_versions("0.16.0", "532be16c49539aa98156a9f59c0cd8e7ad6f6b93afbfc6346ad6cb95edf246c2")
    add_versions("0.15.1", "28653b59afc8b8b255251f21a0f3cbfbdec05dd988fb3f473e22dde28f427ad8")
    add_versions("0.10.1", "6f30c98a559f137e08b25bcbb376c0259914b33c307b8b901e01ca952241d00a")
    add_versions("0.11.5", "6d6d57304a56850958e4ce54f3da2ea2b9eb856ccbab61c6cde9cba15d7c9da5")
    add_versions("0.14.0", "400804e38cb5ce8d15fb52a4db6345f02da7b2e5cb773665712283001482b808")
    add_versions("0.14.1", "92916dcb3178353d863aef4f409186889983c56e025b774741d5316a72ec3a7d")

    add_patches("0.15.1", "patches/0.15.1/algorithm.patch", "3e110539c3db037b2b24cd32f97ad8cc6241b1f69d4a65dab9fd6c84e482bbd9")
    add_patches("0.16.0", "https://github.com/lief-project/LIEF/commit/41166332a2435fdb7d2bdc5c73f9ff9b442c5459.patch", "e42e5dd7e4c7a24bf712c1a7c9efa19c9daf835fc85dd35c8ab4b81d1807d833")
    add_patches("0.16.5", "patches/0.16.5/cstdint.patch", "67956ae49cc529e2b9f98b20544a721bc539ac500da5358c8357751bfcf9b5bc")
    add_patches("0.16.5", "https://github.com/lief-project/LIEF/commit/649baec7db4190944b0f4b4b5d5c995e85f46d39.patch", "981866391db64f5bfc18a24c9974fac6e5957c63e09f5af1950e87b9dbac10fc")

    add_configs("elf",    {description = "Enable ELF module.", default = true, type = "boolean"})
    add_configs("pe",     {description = "Enable PE module.", default = true, type = "boolean"})
    add_configs("macho",  {description = "Enable MachO module.", default = true, type = "boolean"})

    add_configs("dex",    {description = "Enable Dex module.", default = false, type = "boolean"})
    add_configs("vdex",   {description = "Enable Vdex module.", default = false, type = "boolean"})
    add_configs("oat",    {description = "Enable Oat module.", default = false, type = "boolean"})
    add_configs("art",    {description = "Enable Art module.", default = false, type = "boolean"})

    add_configs("exceptions", {description = "Build with exception support.", default = true, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    add_deps("cmake")
    add_deps("spdlog", {configs = {header_only = false, noexcept = true}})
    add_deps("nlohmann_json", {configs = {cmake = true}})
    add_deps("tl_expected", "utfcpp", "mbedtls <3.6.0", "tcb-span", "frozen")

    if on_check then
        on_check(function (package)
            if package:is_plat("windows") then
                local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
                if vs_toolset then
                    local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                    local minor = vs_toolset_ver:minor()
                    assert(minor and minor >= 30, "package(lief) require vs_toolset >= 14.3")
                end
            end
            if package:is_arch("arm.*") then
                raise("package(lief) dep(mbedtls <3.6.0) unsupported arm arch")
            end
        end)
    end

    on_install(function (package)
        if package:config("shared") then
            package:add("defines", "LIEF_IMPORT")
        end

        if package:gitref() and package:version():ge("0.15.0") then
            os.rm("third-party")
        end

        io.replace("CMakeLists.txt", "target_link_libraries(LIB_LIEF PRIVATE utf8cpp)", "target_link_libraries(LIB_LIEF PRIVATE utf8cpp::utf8cpp)", {plain = true})

        io.replace("CMakeLists.txt", "target_link_libraries(LIB_LIEF PRIVATE lief_spdlog)", "find_package(spdlog CONFIG REQUIRED)\ntarget_link_libraries(LIB_LIEF PRIVATE spdlog::spdlog)", {plain = true})
        io.replace("CMakeLists.txt", "TARGETS LIB_LIEF lief_spdlog", "TARGETS LIB_LIEF", {plain = true})

        local configs = {
            "-DLIEF_C_API=ON",
            "-DLIEF_PYTHON_API=OFF",
            "-DLIEF_DOC=OFF",
            "-DLIEF_TESTS=OFF",
            "-DLIEF_EXAMPLES=OFF",
            "-DLIEF_INSTALL_PYTHON=OFF",
            "-DLIEF_EXTERNAL_SPDLOG=ON",
            "-DLIEF_OPT_EXTERNAL_EXPECTED=ON",
            "-DLIEF_OPT_UTFCPP_EXTERNAL=ON",
            "-DLIEF_OPT_MBEDTLS_EXTERNAL=ON",
            "-DLIEF_OPT_EXTERNAL_SPAN=ON",
            "-DLIEF_ENABLE_JSON=ON",
            "-DLIEF_OPT_NLOHMANN_JSON_EXTERNAL=ON",
            "-DLIEF_OPT_FROZEN_EXTERNAL=ON",
            "-DLIEF_DISABLE_FROZEN=OFF",
        }
        table.insert(configs, "-DLIEF_EXTERNAL_SPAN_DIR=" .. package:dep("tcb-span"):installdir("include"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIEF_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DLIEF_DISABLE_EXCEPTIONS=" .. (package:config("exceptions") and "OFF" or "ON"))

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
            assert(package:has_cfuncs(parse_entry, {includes = "LIEF/LIEF.h"}))
        end
    end)
