package("geant4")

    set_homepage("https://geant4.web.cern.ch/")
    set_description("Geant4 is a toolkit for the simulation of the passage of particles through matter.")

    add_urls("https://geant4-data.web.cern.ch/releases/geant4$(version).zip", {version = function (version)
        if version:ge("11.0") then
            return "-v" .. version
        else
            return format("_%02d_%02d_p%02d", version:major(), version:minor(), version:patch())
        end
    end})
    add_versions("10.7.2", "c07b358c30b5930afcc32b44e899cf901083539f350f4333d65784c2aaa4af38")
    add_versions("11.1.0", "8d7df33a4b692493f01a05b82047134a8291d00f113b6a23bdb5253a6527f5a1")

    add_deps("cmake")
    add_deps("zlib", "expat", "clhep")
    add_includedirs("include/Geant4")
    if is_plat("windows") then
        add_defines("WIN32")
    end
    on_install("windows", "macosx", "linux", function (package)
        if package:is_plat("windows") then
            local vs = import("core.tool.toolchain").load("msvc"):config("vs")
            if tonumber(vs) < 2019 then
                raise("Your compiler is too old to use this library.")
            end
        end
        local configs = {"-DCMAKE_INSTALL_LIBDIR=lib",
                         "-DGEANT4_ENABLE_TESTING=OFF",
                         "-DGEANT4_INSTALL_EXAMPLES=OFF",
                         "-DGEANT4_USE_SYSTEM_CLHEP=ON",
                         "-DGEANT4_USE_SYSTEM_EXPAT=ON",
                         "-DGEANT4_USE_SYSTEM_ZLIB=ON",
                         "-DGEANT4_USE_SYSTEM_PTL=OFF",
                         "-DGEANT4_USE_TBB=OFF",
                         "-DGEANT4_USE_GDML=OFF",
                         "-DGEANT4_USE_TIMEMORY=OFF",
                         "-DGEANT4_USE_USOLIDS=OFF",
                         "-DGEANT4_USE_FREETYPE=OFF",
                         "-DGEANT4_USE_HDF5=OFF"}
        io.replace("cmake/Modules/G4OptionalComponents.cmake", "if(WIN32)", "if(FALSE)", {plain = true})
        io.replace("cmake/Modules/G4OptionalComponents.cmake", "EXPAT REQUIRED", "EXPAT CONFIG REQUIRED", {plain = true})
        io.replace("cmake/Modules/G4OptionalComponents.cmake", "EXPAT::EXPAT", "expat::expat", {plain = true})
        io.replace("cmake/Modules/G4OptionalComponents.cmake", "${EXPAT_VERSION_STRING} VERSION_LESS \"2.0.1\"", "FALSE", {plain = true})
        if package:is_plat("windows") then
            io.replace("cmake/Modules/G4MakeRules_cxx.cmake", "-MD", "-" .. package:config("vs_runtime"), {plain = true})
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")

        local suffix = ""
        if package:is_plat("windows") and not package:config("shared") then
            suffix = "-static"
        end
        local expected_links = {"G4physicslists", "G4parmodels", "G4persistency", "G4GMocren", "G4error_propagation", "G4visXXX", "G4VRML", "G4RayTracer", "G4Tree", "G4visHepRep", "G4FR", "G4vis_management", "G4modeling", "G4tasking", "G4readout", "G4run", "G4tracking", "G4event", "G4processes", "G4digits_hits", "G4track", "G4particles", "G4geometry", "G4graphics_reps", "G4materials", "G4analysis", "G4interfaces", "G4intercoms", "G4global", "G4ptl"}
        for _, libname in ipairs(expected_links) do
            package:add("links", libname .. suffix)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <G4NistManager.hh>
            void test() {
                using CLHEP::cm;
                G4NistManager* nist = G4NistManager::Instance();
                G4double env_sizeXY = 20*cm, env_sizeZ = 30*cm;
                G4Material* env_mat = nist->FindOrBuildMaterial("G4_WATER");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
