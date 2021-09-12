package("vtk")

    set_homepage("https://vtk.org/")
    set_description("The Visualization Toolkit (VTK) is open source software for manipulating and displaying scientific data.")
    set_license("BSD-3-Clause")

    add_urls("https://www.vtk.org/files/release/$(version).tar.gz", {version = function (version)
        return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/VTK-" .. version
    end})
    add_versions("9.0.1", "1b39a5e191c282861e7af4101eaa8585969a2de05f5646c9199a161213a622c7")
    add_versions("9.0.3", "bc3eb9625b2b8dbfecb6052a2ab091fc91405de4333b0ec68f3323815154ed8a")

    add_patches("9.0.3", path.join(os.scriptdir(), "patches", "9.0.3", "limits.patch"), "3bebcd1cac52462b0cf84c8232c3426202c75c944784252b215b4416cbe111db")

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("gdi32", "user32", "shell32", "opengl32", "vfw32", "comctl32", "wsock32", "advapi32")
    elseif is_plat("linux") then
        add_syslinks("dl", "pthread")
    end
    on_load("windows", "linux", function (package)
        local ver = package:version():major() .. "." .. package:version():minor()
        package:add("includedirs", "include/vtk-" .. ver)
        local libs = {"vtkViewsInfovis", "vtkCommonColor", "vtkViewsContext2D", "vtkTestingRendering", "vtkTestingCore", "vtkRenderingVolumeOpenGL2", "vtkRenderingOpenGL2", "vtkglew", "vtkopengl", "vtkRenderingLabel", "vtkoctree", "vtkRenderingLOD", "vtkRenderingImage", "vtkIOVeraOut", "vtkhdf5", "vtkIOTecplotTable", "vtkIOSegY", "vtkIOParallelXML", "vtkIOParallel", "vtkjsoncpp", "vtkIOPLY", "vtkIOOggTheora", "vtktheora", "vtkogg", "vtkIONetCDF", "vtknetcdf", "vtkIOMotionFX", "vtkpegtl", "vtkIOMINC", "vtkIOLSDyna", "vtkIOInfovis", "vtklibxml2", "vtkzlib", "vtkIOImport", "vtkIOGeometry", "vtkIOVideo", "vtkIOMovie", "vtkIOExportPDF", "vtklibharu", "vtkIOExportGL2PS", "vtkRenderingGL2PSOpenGL2", "vtkgl2ps", "vtkpng", "vtkIOExport", "vtkRenderingVtkJS", "vtkRenderingSceneGraph", "vtkIOExodus", "vtkexodusII", "vtkIOEnSight", "vtkIOCityGML", "vtkpugixml", "vtkIOAsynchronous", "vtkIOAMR", "vtkInteractionImage", "vtkImagingStencil", "vtkImagingStatistics", "vtkImagingMorphological", "vtkImagingMath", "vtkIOSQL", "vtksqlite", "vtkGeovisCore", "vtklibproj", "vtkInfovisLayout", "vtkViewsCore", "vtkInteractionWidgets", "vtkRenderingVolume", "vtkRenderingAnnotation", "vtkImagingHybrid", "vtkImagingColor", "vtkInteractionStyle", "vtkFiltersTopology", "vtkFiltersSelection", "vtkFiltersSMP", "vtkFiltersProgrammable", "vtkFiltersPoints", "vtkFiltersVerdict", "vtkverdict", "vtkFiltersParallelImaging", "vtkFiltersImaging", "vtkImagingGeneral", "vtkFiltersHyperTree", "vtkFiltersGeneric", "vtkFiltersFlowPaths", "vtkFiltersAMR", "vtkFiltersParallel", "vtkFiltersTexture", "vtkFiltersModeling", "vtkFiltersHybrid", "vtkRenderingUI", "vtkDomainsChemistry", "vtkChartsCore", "vtkInfovisCore", "vtkFiltersExtraction", "vtkParallelDIY", "vtkdiy2", "vtkIOXML", "vtkIOXMLParser", "vtkexpat", "vtkParallelCore", "vtkIOLegacy", "vtkIOCore", "vtkdoubleconversion", "vtklz4", "vtklzma", "vtkutf8", "vtkFiltersStatistics", "vtkeigen", "vtkImagingFourier", "vtkImagingSources", "vtkIOImage", "vtkDICOMParser", "vtkjpeg", "vtkmetaio", "vtktiff", "vtkRenderingContext2D", "vtkRenderingFreeType", "vtkfreetype", "vtkkwiml", "vtkRenderingCore", "vtkFiltersSources", "vtkImagingCore", "vtkFiltersGeometry", "vtkFiltersGeneral", "vtkCommonComputationalGeometry", "vtkFiltersCore", "vtkCommonExecutionModel", "vtkCommonDataModel", "vtkCommonSystem", "vtkCommonMisc", "vtkCommonTransforms", "vtkCommonMath", "vtkCommonCore", "vtkloguru", "vtksys"}
        for _, lib in ipairs(libs) do
            package:add("links", lib .. "-" .. ver)
        end
    end)

    on_install("windows", "linux", function (package)
        local configs = {"-DVTK_BUILD_TESTING=OFF", "-DVTK_BUILD_EXAMPLES=OFF", "-DVTK_ENABLE_WRAPPING=OFF", "-DCMAKE_CXX_STANDARD=14"}
        table.insert(configs, "-DCMAKE_INSTALL_LIBDIR=lib")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
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
