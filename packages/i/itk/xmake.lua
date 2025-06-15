package("itk")
    set_homepage("https://itk.org/")
    set_description("ITK is an open-source, cross-platform library that provides developers with an extensive suite of software tools for image analysis.")
    set_license("Apache-2.0")

    add_urls("https://github.com/InsightSoftwareConsortium/ITK/releases/download/v$(version)/InsightToolkit-$(version).tar.gz")

    add_versions("5.2.0", "12c9cf543cbdd929330322f0a704ba6925a13d36d01fc721a74d131c0b82796e")
    add_versions("5.2.1", "192d41bcdd258273d88069094f98c61c38693553fd751b54f8cda308439555db")
    add_versions("5.4.3", "dd3f286716ee291221407a67539f2197c184bd80d4a8f53de1fb7d19351c7eca")

    add_patches("5.4.3", "https://github.com/InsightSoftwareConsortium/ITK/commit/4f275769e37fa29754166c7eded2d84c0b33991a.diff", "97149086aa4524a5964f25adcc56b8400a3a413765c9fa986f4cdde474e984c4")

    add_deps("cmake")
    add_deps("eigen", "zlib", "double-conversion")

    if is_plat("windows", "mingw") then
        add_syslinks("shell32", "advapi32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m", "dl", "pthread")
    end
    on_load(function (package)
        local ver = package:version():major() .. "." .. package:version():minor()
        package:add("includedirs", "include/ITK-" .. ver)
        local libs = {"ITKWatersheds", "ITKVideoIO", "ITKVideoCore", "ITKVTK", "ITKTestKernel", "ITKRegistrationMethodsv4", "ITKRegionGrowing", "ITKQuadEdgeMeshFiltering", "ITKOptimizersv4", "ITKMarkovRandomFieldsClassifiers", "itklbfgs", "ITKKLMRegionGrowing", "ITKIOVTK", "ITKIOTransformMatlab", "ITKIOTransformInsightLegacy", "ITKIOTransformHDF5", "ITKIOTransformBase", "ITKTransformFactory", "ITKIOStimulate", "ITKIOSpatialObjects", "ITKIOXML", "ITKIOSiemens", "ITKIOPNG", "itkpng", "ITKIONRRD", "ITKNrrdIO", "ITKIONIFTI", "ITKIOMeta", "ITKIOMeshVTK", "ITKIOMeshOFF", "ITKIOMeshOBJ", "ITKIOMeshGifti", "ITKIOMeshFreeSurfer", "ITKIOMeshBYU", "ITKIOMeshBase", "ITKIOMRC", "ITKIOMINC", "itkminc2", "ITKIOLSM", "ITKIOTIFF", "itktiff", "ITKIOJPEG2000", "itkopenjpeg", "ITKIOJPEG", "itkjpeg", "ITKIOHDF5", "ITKIOGIPL", "ITKIOGE", "ITKIOIPL", "ITKIOGDCM", "ITKIOCSV", "ITKIOBruker", "ITKIOBioRad", "ITKIOBMP", "hdf5-static", "hdf5_cpp-static", "ITKPDEDeformableRegistration", "ITKgiftiio", "ITKniftiio", "ITKznz", "gdcmMSFF", "gdcmDICT", "ITKEXPAT", "ITKDiffusionTensorImage", "ITKDenoising", "ITKDeformableMesh", "ITKDICOMParser", "ITKConvolution", "ITKFFT", "ITKColormap", "ITKBiasCorrection", "ITKPolynomials", "ITKOptimizers", "ITKImageFeature", "ITKSmoothing", "ITKIOImageBase", "ITKFastMarching", "ITKQuadEdgeMesh", "ITKMathematicalMorphology", "ITKLabelMap", "ITKPath", "ITKSpatialObjects", "ITKMetaIO", "itkzlib", "ITKMesh", "ITKTransform", "ITKStatistics", "itkNetlibSlatec", "ITKCommon", "itkvcl", "itkvnl_algo", "itkvnl", "itkv3p_netlib", "itksys", "itkdouble-conversion", "hdf5_hl_cpp-static", "itkgdcmcharls", "itkgdcmCommon", "itkgdcmDICT", "itkgdcmDSED", "itkgdcmIOD", "itkgdcmjpeg12", "itkgdcmjpeg16", "itkgdcmjpeg8", "itkgdcmMEXD", "itkgdcmMSFF", "itkgdcmopenjp2", "itkgdcmsocketxx", "itkhdf5-static", "itkhdf5_cpp-static", "itkhdf5_hl-static", "itkImageIntensity", "itktestlib", "itkVNLInstantiation"}
        for _, lib in ipairs(libs) do
            package:add("links", lib .. "-" .. ver)
        end
    end)

    on_install(function (package)
        local configs = {"-DITK_SKIP_PATH_LENGTH_CHECKS=ON",
                         "-DBUILD_TESTING=OFF",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DITK_WRAPPING=OFF",
                         "-DITK_USE_SYSTEM_EIGEN=ON",
                         "-DITK_USE_SYSTEM_ZLIB=ON",
                         "-DITK_USE_SYSTEM_DOUBLECONVERSION=ON"}
        if package:version():lt("5.4.0") then
            table.insert(configs, "-DCMAKE_CXX_STANDARD=14")
        else
            table.insert(configs, "-DCMAKE_CXX_STANDARD=17")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DITK_MSVC_STATIC_RUNTIME_LIBRARY=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        if package:is_plat("windows") then
            import("package.tools.cmake").install(package, configs, {buildir = path.join(os.tmpdir(), "itk_build")})
        else
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        local cxx_std = "c++14"
        if not package:version():lt("5.4.0") then
            cxx_std = "c++17"
        end
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using ImageType = itk::Image<unsigned short, 3>;
                ImageType::Pointer image = ImageType::New();
            }
        ]]}, {configs = {languages = cxx_std}, includes = "itkImage.h"}))
    end)
