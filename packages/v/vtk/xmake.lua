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
    add_versions("9.2.6", "06fc8d49c4e56f498c40fcb38a563ed8d4ec31358d0101e8988f0bb4d539dd12")
    add_versions("9.3.1", "8354ec084ea0d2dc3d23dbe4243823c4bfc270382d0ce8d658939fd50061cab8")
    add_versions("9.4.2", "36c98e0da96bb12a30fe53708097aa9492e7b66d5c3b366e1c8dc251e2856a02")
    add_versions("9.5.1", "14443661c7b095d05b4e376fb3f40613f173e34fc9d4658234e9ec1d624a618f")

    add_patches("9.0.3", "patches/9.0.3/limits.patch", "3bebcd1cac52462b0cf84c8232c3426202c75c944784252b215b4416cbe111db")
    add_patches("9.2.6", "patches/9.2.6/gcc13.patch", "71bcb65197442e053ae2a69079bd2b3b8708a0bedf9f4f9a955e72b15720857c")
    add_patches("9.3.1", "patches/9.3.1/msvc.patch", "619ed4145f3b7c727aee168aac04271e6414d314bf49db470de688acc9f49cb8")
    add_patches("9.5.1", "patches/9.5.1/deps.patch", "6ecbd4a46250bf56e5ef92d362339fd7981176855c0864a2383ff35204c698a5")

    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})

    add_configs("imaging",    {description = "Enable Imaging modules.",    default = "YES", type = "string", values = {"YES", "NO", "WANT", "DONT_WANT", "DEFAULT"}})
    add_configs("rendering",  {description = "Enable Rendering modules.",  default = "YES", type = "string", values = {"YES", "NO", "WANT", "DONT_WANT", "DEFAULT"}})
    add_configs("standalone", {description = "Enable StandAlone modules.", default = "YES", type = "string", values = {"YES", "NO", "WANT", "DONT_WANT", "DEFAULT"}})
    add_configs("views",      {description = "Enable Views modules.",      default = "YES", type = "string", values = {"YES", "NO", "WANT", "DONT_WANT", "DEFAULT"}})

    add_configs("mfc",    {description = "Enable MFC modules.",    default = "DONT_WANT", type = "string", values = {"YES", "NO", "WANT", "DONT_WANT", "DEFAULT"}})
    add_configs("mpi",    {description = "Enable MPI modules.",    default = "DONT_WANT", type = "string", values = {"YES", "NO", "WANT", "DONT_WANT", "DEFAULT"}})
    add_configs("python", {description = "Enable Python modules.", default = "DONT_WANT", type = "string", values = {"YES", "NO", "WANT", "DONT_WANT", "DEFAULT"}})
    add_configs("qt",     {description = "Enable Qt modules.",     default = "DONT_WANT", type = "string", values = {"YES", "NO", "WANT", "DONT_WANT", "DEFAULT"}})
    add_configs("remote", {description = "Enable Remote modules.", default = "DONT_WANT", type = "string", values = {"YES", "NO", "WANT", "DONT_WANT", "DEFAULT"}})
    add_configs("web",    {description = "Enable Web modules.",    default = "DONT_WANT", type = "string", values = {"YES", "NO", "WANT", "DONT_WANT", "DEFAULT"}})

    add_deps("cmake")

    if is_plat("linux") then
        add_extsources("apt::libvtk9-dev","pacman::vtk")
    elseif is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::vtk")
    elseif is_plat("macosx") then
        add_extsources("brew::vtk")
    end

    if is_plat("windows") then
        add_syslinks("gdi32", "user32", "shell32", "opengl32", "vfw32", "comctl32", "wsock32", "advapi32", "ws2_32", "psapi", "dbghelp")
        add_patches("9.5.1", "patches/9.5.1/windows.patch", "7d776c2c5b94c69ae59f38673e0a8eb7cfb4be7176d9f84d0afb58b0eb82f42b")
    elseif is_plat("linux") then
        add_syslinks("dl", "pthread")
    end

    add_defines("kiss_fft_scalar=double", "DIY_NO_THREADS", "VTK_HAS_OGGTHEORA_SUPPORT")

    on_load(function (package)
        local ver = package:version():major() .. "." .. package:version():minor()
        package:add("includedirs", "include/vtk-" .. ver)
        local libs = {"vtkViewsInfovis", "vtkChartsCore", "vtkDomainsChemistryOpenGL2", "vtkViewsContext2D", "vtkTestingRendering", "vtkTestingCore", "vtkRenderingLICOpenGL2", "vtkRenderingContextOpenGL2", "vtkRenderingVolumeOpenGL2", "vtkRenderingOpenGL2", "vtkRenderingLabel", "vtkRenderingLOD", "vtkRenderingImage", "vtkIOVeraOut", "vtkIOTecplotTable", "vtkIOSegY", "vtkIOParallelXML", "vtkIOParallel", "vtkIOPLY", "vtkIOOggTheora", "vtkIONetCDF", "vtkIOMotionFX", "vtkIOMINC", "vtkIOLANLX3D", "vtkIOLSDyna", "vtkIOInfovis", "vtkIOImport", "vtkIOCesium3DTiles", "vtkIOGeometry", "vtkIOVideo", "vtkIOMovie", "vtkIOExportPDF", "vtkIOExportGL2PS", "vtkRenderingGL2PSOpenGL2", "vtkIOExport", "vtkRenderingVtkJS", "vtkRenderingSceneGraph", "vtkIOExodus", "vtkIOEnSight", "vtkIOCityGML", "vtkIOAsynchronous", "vtkIOAMR", "vtkIOCGNSReader", "vtkIOHDF", "vtkIOIOSS", "vtkInteractionImage", "vtkImagingStencil", "vtkImagingStatistics", "vtkImagingMorphological", "vtkImagingMath", "vtkIOSQL", "vtkGeovisCore", "vtkInfovisLayout", "vtkViewsCore", "vtkInteractionWidgets", "vtkRenderingHyperTreeGrid", "vtkRenderingVolume", "vtkRenderingAnnotation", "vtkImagingHybrid", "vtkImagingColor", "vtkInteractionStyle", "vtkFiltersTopology", "vtkFiltersSelection", "vtkFiltersSMP", "vtkFiltersProgrammable", "vtkFiltersPoints", "vtkFiltersVerdict", "vtkFiltersParallelImaging", "vtkFiltersImaging", "vtkImagingGeneral", "vtkFiltersHyperTree", "vtkFiltersGeneric", "vtkFiltersFlowPaths", "vtkFiltersAMR", "vtkFiltersParallel", "vtkFiltersTexture", "vtkFiltersModeling", "vtkFiltersHybrid", "vtkRenderingUI", "vtkDomainsChemistry", "vtkChartsCore", "vtkFiltersExtraction", "vtkParallelDIY", "vtkIOXML", "vtkIOXMLParser", "vtkFiltersStatistics", "vtkImagingFourier", "vtkImagingSources", "vtkIOImage", "vtkDICOMParser", "vtkRenderingContext2D", "vtkRenderingFreeType", "vtkRenderingCore", "vtkFiltersSources", "vtkImagingCore", "vtkFiltersGeometry", "vtkFiltersGeneral", "vtkInfovisCore", "vtkIOLegacy", "vtkIOCore", "vtkCommonColor", "vtkParallelCore", "vtkCommonComputationalGeometry", "vtkFiltersCore", "vtkCommonExecutionModel", "vtkCommonDataModel", "vtkCommonSystem", "vtkCommonMisc", "vtkCommonTransforms", "vtkCommonMath", "vtkCommonCore", "vtkioss", "vtkexodusII", "vtklibharu", "vtkgl2ps", "vtkverdict", "vtklibproj", "vtkoctree", "vtkdiy2", "vtknetcdf", "vtklibxml2", "vtkutf8", "vtkmetaio", "vtkkwiml", "vtktheora", "vtkloguru", "vtksys", "vtkogg", "vtksqlite", "vtkglew", "vtkopengl", "vtkjsoncpp", "vtkpugixml", "vtkcgns", "vtkhdf5_hl", "vtkhdf5", "vtkexpat", "vtktiff", "vtklz4", "vtklzma", "vtkkissfft", "vtkfreetype", "vtkjpeg", "vtkpng", "vtkeigen", "vtkfmt", "vtkpegtl", "vtkdoubleconversion", "vtkzlib", "vtkFiltersCellGrid", "vtkFiltersGeometryPreview", "vtkFiltersReduction", "vtkFiltersTemporal", "vtkFiltersTensor", "vtkglad", "vtkIOCellGrid", "vtkIOChemistry", "vtkIOCONVERGECFD", "vtkIOEngys", "vtkIOERF", "vtkIOFDS", "vtkIOFLUENTCFF", "vtkRenderingCellGrid", "vtktoken", "vtkRenderingGridAxes", "vtkViewsQt", "vtkGUISupportQt", "vtkGUISupportQtQuick", "vtkGUISupportQtSQL", "vtkRenderingQt", "vtkGUISupportMFC", "vtkAcceleratorsVTKmCore", "vtkAcceleratorsVTKmDataModel", "vtkAcceleratorsVTKmFilters", "vtkvtkm", "vtkFiltersParallelMPI", "vtkIOMPIImage", "vtkIOMPIParallel", "vtkParallelMPI", "vtkParallelMPI4Py", "vtkmpi", "vtkCommonPython", "vtkFiltersPython", "vtkPython", "vtkWrappingPythonCore", "vtkWebPython", "vtkPythonContext2D", "vtkPythonInterpreter", "vtkRenderingWebGPU", "vtkWebCore", "vtkWebAssembly", "vtkWebGLExporter", "vtkDICOM", "MomentInvariants", "RenderingLookingGlass"}
        for _, lib in ipairs(libs) do
            package:add("links", lib .. "-" .. ver)
        end
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        package:add("deps", "double-conversion", "eigen", "expat", "exprtk", "fast_float", "fmt", "freetype", "gl2ps", "glew", "jsoncpp", "libharu", "libjpeg-turbo", "libpng", "libtiff", "libxml2", "lz4", "netcdf-c", "pegtl <3.0", "proj", "pugixml", "seacas", "sqlite3", "theora", "token", "utfcpp", "verdict", "xz", "zlib", {configs = {shared = package:config("shared")}})
        package:add("deps", "cgns", {configs = {hdf5 = true, shared = package:config("shared")}})
        package:add("deps", "hdf5", {configs = {zlib = true, shared = package:config("shared")}})
        package:add("deps", "nlohmann_json", {configs = {cmake = true}})
    end)

    on_install("windows|x64", "windows|x86", "macosx", "linux", function (package)
        os.cp(path.join(package:scriptdir(), "patches", "findhdf5.cmake"), "CMake/patches/99/FindHDF5.cmake")
        local configs = {
            "-DVTK_BUILD_TESTING=OFF",
            "-DVTK_BUILD_EXAMPLES=OFF",
            "-DVTK_ENABLE_WRAPPING=OFF",
            "-DCMAKE_CXX_STANDARD=14",
            "-DVTK_USE_EXTERNAL=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DVTK_USE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))

        table.insert(configs, "-DVTK_GROUP_ENABLE_Imaging=" .. package:config("imaging"))
        table.insert(configs, "-DVTK_GROUP_ENABLE_Rendering=" .. package:config("rendering"))
        table.insert(configs, "-DVTK_GROUP_ENABLE_StandAlone=" .. package:config("standalone"))
        table.insert(configs, "-DVTK_GROUP_ENABLE_Views=" .. package:config("views"))

        table.insert(configs, "-DVTK_MODULE_ENABLE_VTK_GUISupportMFC=" .. package:config("mfc"))
        table.insert(configs, "-DVTK_GROUP_ENABLE_MPI=" .. package:config("mpi"))
        table.insert(configs, "-DVTK_MODULE_ENABLE_VTK_Python=" .. package:config("python"))
        table.insert(configs, "-DVTK_GROUP_ENABLE_Qt=" .. package:config("qt"))
        table.insert(configs, "-DVTK_ENABLE_REMOTE_MODULES=" .. package:config("remote"))
        table.insert(configs, "-DVTK_GROUP_ENABLE_Web=" .. package:config("web"))
        if package:config("shared") and package:is_plat("macosx") then
            local opt = {shflags = {"-framework", "OpenGL"}}
            import("package.tools.cmake").install(package, configs, opt)
        else
            import("package.tools.cmake").install(package, configs)
        end
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
