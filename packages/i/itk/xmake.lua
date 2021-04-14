package("itk")

    set_homepage("https://itk.org/")
    set_description("ITK is an open-source, cross-platform library that provides developers with an extensive suite of software tools for image analysis.")
    set_license("Apache-2.0")

    add_urls("https://github.com/InsightSoftwareConsortium/ITK/archive/refs/tags/$(version).tar.gz")
    add_versions("v5.2.0", "e53961cd78df8bcfaf8bd8b813ae2cafdde984c7650a2ddf7dcf808df463ea74")

    add_deps("cmake", "eigen")
    if is_plat("windows") then
        add_syslinks("shell32", "advapi32")
    elseif is_plat("linux") then
        add_syslinks("dl", "pthread")
    end
    on_load("windows", "linux", "macosx", function (package)
        local ver = package:version():major() .. "." .. package:version():minor()
        package:add("includedirs", "include/ITK-" .. ver)
        local libs = {"ITKWatersheds", "ITKVideoIO", "ITKVideoCore", "ITKVTK", "ITKTestKernel", "ITKRegistrationMethodsv4", "ITKRegionGrowing", "ITKQuadEdgeMeshFiltering", "ITKOptimizersv4", "ITKMarkovRandomFieldsClassifiers", "itklbfgs", "ITKKLMRegionGrowing", "ITKIOVTK", "ITKIOTransformMatlab", "ITKIOTransformInsightLegacy", "ITKIOTransformHDF5", "ITKIOTransformBase", "ITKTransformFactory", "ITKIOStimulate", "ITKIOSpatialObjects", "ITKIOXML", "ITKIOSiemens", "ITKIOPNG", "itkpng", "ITKIONRRD", "ITKNrrdIO", "ITKIONIFTI", "ITKIOMeta", "ITKIOMeshVTK", "ITKIOMeshOFF", "ITKIOMeshOBJ", "ITKIOMeshGifti", "ITKIOMeshFreeSurfer", "ITKIOMeshBYU", "ITKIOMeshBase", "ITKIOMRC", "ITKIOMINC", "itkminc2", "ITKIOLSM", "ITKIOTIFF", "itktiff", "ITKIOJPEG2000", "itkopenjpeg", "ITKIOJPEG", "itkjpeg", "ITKIOHDF5", "ITKIOGIPL", "ITKIOGE", "ITKIOIPL", "ITKIOGDCM", "ITKIOCSV", "ITKIOBruker", "ITKIOBioRad", "ITKIOBMP", "hdf5-static", "hdf5_cpp-static", "ITKPDEDeformableRegistration", "ITKgiftiio", "ITKniftiio", "ITKznz", "gdcmMSFF", "gdcmDICT", "ITKEXPAT", "ITKDiffusionTensorImage", "ITKDenoising", "ITKDeformableMesh", "ITKDICOMParser", "ITKConvolution", "ITKFFT", "ITKColormap", "ITKBiasCorrection", "ITKPolynomials", "ITKOptimizers", "ITKImageFeature", "ITKSmoothing", "ITKIOImageBase", "ITKFastMarching", "ITKQuadEdgeMesh", "ITKMathematicalMorphology", "ITKLabelMap", "ITKPath", "ITKSpatialObjects", "ITKMetaIO", "itkzlib", "ITKMesh", "ITKTransform", "ITKStatistics", "itkNetlibSlatec", "ITKCommon", "itkvcl", "itkvnl_algo", "itkvnl", "itkv3p_netlib", "itksys", "itkdouble-conversion"}
        for _, lib in ipairs(libs) do
            package:add("links", lib .. "-" .. ver)
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DITK_SKIP_PATH_LENGTH_CHECKS=ON",
                         "-DBUILD_TESTING=OFF",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DITK_WRAPPING=OFF",
                         "-DITK_USE_SYSTEM_EIGEN=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        if package:is_plat("windows") then
            import("package.tools.cmake").install(package, configs, {buildir = os.tmpdir()})
        else
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using ImageType = itk::Image<unsigned short, 3>;
                ImageType::Pointer image = ImageType::New();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "itkImage.h"}))
    end)
