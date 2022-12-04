package("vtk")

    set_homepage("https://vtk.org/")
    set_description("The Visualization Toolkit (VTK) is open source software for manipulating and displaying scientific data.")
    set_license("BSD-3-Clause")

    add_urls("https://www.vtk.org/files/release/$(version).tar.gz", {version = function (version)
        return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/VTK-" .. version
    end})
    add_versions("9.0.1", "1b39a5e191c282861e7af4101eaa8585969a2de05f5646c9199a161213a622c7")
    add_versions("9.0.3", "bc3eb9625b2b8dbfecb6052a2ab091fc91405de4333b0ec68f3323815154ed8a")
    add_versions("9.1.0", "8fed42f4f8f1eb8083107b68eaa9ad71da07110161a3116ad807f43e5ca5ce96")
    add_versions("9.2.2", "1c5b0a2be71fac96ff4831af69e350f7a0ea3168981f790c000709dcf9121075")

    add_patches("9.0.3", path.join(os.scriptdir(), "patches", "9.0.3", "limits.patch"), "3bebcd1cac52462b0cf84c8232c3426202c75c944784252b215b4416cbe111db")

    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("gdi32", "user32", "shell32", "opengl32", "vfw32", "comctl32", "wsock32", "advapi32")
    elseif is_plat("linux") then
        add_syslinks("dl", "pthread")
    end
    on_load("windows", "macosx", "linux", function (package)
        local ver = package:version():major() .. "." .. package:version():minor()
        package:add("includedirs", "include/vtk-" .. ver)
        local libs = {"vtkViewsInfovis", "vtkViewsContext2D", "vtkTestingRendering", "vtkTestingCore", "vtkRenderingVolumeOpenGL2", "vtkRenderingOpenGL2", "vtkRenderingLabel", "vtkRenderingLOD", "vtkRenderingImage", "vtkIOVeraOut", "vtkIOTecplotTable", "vtkIOSegY", "vtkIOParallelXML", "vtkIOParallel", "vtkIOPLY", "vtkIOOggTheora", "vtkIONetCDF", "vtkIOMotionFX", "vtkIOMINC", "vtkIOLSDyna", "vtkIOInfovis", "vtkIOImport", "vtkIOGeometry", "vtkIOVideo", "vtkIOMovie", "vtkIOExportPDF", "vtkIOExportGL2PS", "vtkRenderingGL2PSOpenGL2", "vtkIOExport", "vtkRenderingVtkJS", "vtkRenderingSceneGraph", "vtkIOExodus", "vtkIOEnSight", "vtkIOCityGML", "vtkIOAsynchronous", "vtkIOAMR", "vtkInteractionImage", "vtkImagingStencil", "vtkImagingStatistics", "vtkImagingMorphological", "vtkImagingMath", "vtkIOSQL", "vtkGeovisCore", "vtkInfovisLayout", "vtkViewsCore", "vtkInteractionWidgets", "vtkRenderingVolume", "vtkRenderingAnnotation", "vtkImagingHybrid", "vtkImagingColor", "vtkInteractionStyle", "vtkFiltersTopology", "vtkFiltersSelection", "vtkFiltersSMP", "vtkFiltersProgrammable", "vtkFiltersPoints", "vtkFiltersVerdict", "vtkFiltersParallelImaging", "vtkFiltersImaging", "vtkImagingGeneral", "vtkFiltersHyperTree", "vtkFiltersGeneric", "vtkFiltersFlowPaths", "vtkFiltersAMR", "vtkFiltersParallel", "vtkFiltersTexture", "vtkFiltersModeling", "vtkFiltersHybrid", "vtkRenderingUI", "vtkDomainsChemistry", "vtkChartsCore", "vtkFiltersExtraction", "vtkParallelDIY", "vtkIOXML", "vtkIOXMLParser", "vtkFiltersStatistics", "vtkImagingFourier", "vtkImagingSources", "vtkIOImage", "vtkDICOMParser", "vtkRenderingContext2D", "vtkRenderingFreeType", "vtkRenderingCore", "vtkFiltersSources", "vtkImagingCore", "vtkFiltersGeometry", "vtkFiltersGeneral", "vtkInfovisCore", "vtkIOLegacy", "vtkIOCore", "vtkCommonColor", "vtkParallelCore", "vtkCommonComputationalGeometry", "vtkFiltersCore", "vtkCommonExecutionModel", "vtkCommonDataModel", "vtkCommonSystem", "vtkCommonMisc", "vtkCommonTransforms", "vtkCommonMath", "vtkCommonCore", "vtkexodusII", "vtklibharu", "vtkgl2ps", "vtkverdict", "vtklibproj", "vtkoctree", "vtkdiy2", "vtknetcdf", "vtklibxml2", "vtkutf8", "vtkmetaio", "vtkkwiml", "vtktheora", "vtkloguru", "vtksys", "vtkogg", "vtksqlite", "vtkglew", "vtkopengl", "vtkjsoncpp", "vtkpugixml", "vtkhdf5", "vtkexpat", "vtktiff", "vtklz4", "vtklzma", "vtkfreetype", "vtkjpeg", "vtkpng", "vtkeigen", "vtkpegtl", "vtkdoubleconversion", "vtkzlib"}
        for _, lib in ipairs(libs) do
            package:add("links", lib .. "-" .. ver)
        end
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DVTK_BUILD_TESTING=OFF", "-DVTK_BUILD_EXAMPLES=OFF", "-DVTK_ENABLE_WRAPPING=OFF", "-DCMAKE_CXX_STANDARD=14"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DVTK_USE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                vtkCompositeDataPipeline* exec = vtkCompositeDataPipeline::New();
                vtkAlgorithm::SetDefaultExecutivePrototype(exec);
                exec->Delete();
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"vtkAlgorithm.h", "vtkCompositeDataPipeline.h"}}))
    end)
