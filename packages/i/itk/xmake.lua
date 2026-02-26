package("itk")
    set_homepage("https://itk.org/")
    set_description("ITK is an open-source, cross-platform library that provides developers with an extensive suite of software tools for image analysis.")
    set_license("Apache-2.0")

    add_urls("https://github.com/InsightSoftwareConsortium/ITK/releases/download/v$(version)/InsightToolkit-$(version).tar.gz")
    add_versions("5.4.5", "ecab9119664e2571b90740ba9ab3ca11cb46942dbd7bb87c0de5bb15309a36c9")
    add_versions("5.2.0", "12c9cf543cbdd929330322f0a704ba6925a13d36d01fc721a74d131c0b82796e")
    add_versions("5.2.1", "192d41bcdd258273d88069094f98c61c38693553fd751b54f8cda308439555db")
    add_versions("5.4.4", "d2092cd018a7b9d88e8c3dda04acb7f9345ab50619b79800688c7bc3afcca82a")

    add_patches(">5.0", "patches/hdf5.patch", "47594e3f5885a11dc214768d6fd6e54c014e1f335d24c7209a837a43f4a22631")

    add_configs("opencv", {description = "Build ITKVideoBridgeOpenCV module.", default = false, type = "boolean"})
    add_configs("vtk", {description = "Build ITKVtkGlue module.", default = false, type = "boolean"})

    add_deps("cmake", "double-conversion", "eigen", "expat", "gdcm", "libjpeg", "libminc", "libpng", "libtiff", "vxl", "zlib")
    add_deps("hdf5", {configs = {cpplib = true}})
    if is_plat("windows") then
        add_syslinks("shell32", "advapi32")
    elseif is_plat("linux") then
        add_extsources("apt::libinsighttoolkit5-dev", "pacman::itk")
        add_syslinks("dl", "pthread")
    elseif is_plat("bsd") then
        add_syslinks("execinfo")
    elseif is_plat("macosx") then
        add_extsources("brew::itk")
    elseif is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::itk")
    end

    on_load(function (package)
        local ver = package:version():major() .. "." .. package:version():minor()
        package:add("includedirs", "include/ITK-" .. ver)
        local libs = { "ITKBiasCorrection", "ITKColormap", "ITKCommon", "ITKConvolution", "ITKDICOMParser", "ITKDeformableMesh", "ITKDenoising", "ITKDiffusionTensorImage", "ITKFFT", "ITKFastMarching", "ITKIOBMP", "ITKIOBioRad", "ITKIOBruker", "ITKIOCSV", "ITKIOGDCM", "ITKIOGE", "ITKIOGIPL", "ITKIOHDF5", "ITKIOIPL", "ITKIOImageBase", "ITKIOJPEG", "ITKIOJPEG2000", "ITKIOLSM", "ITKIOMINC", "ITKIOMRC", "ITKIOMeshBYU", "ITKIOMeshBase", "ITKIOMeshFreeSurfer", "ITKIOMeshGifti", "ITKIOMeshOBJ", "ITKIOMeshOFF", "ITKIOMeshVTK", "ITKIOMeta", "ITKIONIFTI", "ITKIONRRD", "ITKIOPNG", "ITKIOSiemens", "ITKIOSpatialObjects", "ITKIOStimulate", "ITKIOTIFF", "ITKIOTransformBase", "ITKIOTransformHDF5", "ITKIOTransformInsightLegacy", "ITKIOTransformMatlab", "ITKIOVTK", "ITKIOXML", "ITKImageFeature", "ITKImageIntensity", "ITKKLMRegionGrowing", "ITKLabelMap", "ITKMarkovRandomFieldsClassifiers", "ITKMathematicalMorphology", "ITKMesh", "ITKMetaIO", "ITKNrrdIO", "ITKOptimizers", "ITKOptimizersv4", "ITKPDEDeformableRegistration", "ITKPath", "ITKPolynomials", "ITKQuadEdgeMesh", "ITKQuadEdgeMeshFiltering", "ITKRegionGrowing", "ITKRegistrationMethodsv4", "ITKSmoothing", "ITKSpatialObjects", "ITKStatistics", "ITKTestKernel", "ITKTransform", "ITKTransformFactory", "ITKVNLInstantiation", "ITKVTK", "ITKVtkGlue", "ITKVideoCore", "ITKVideoIO", "ITKVideoBridgeOpenCV", "ITKWatersheds", "ITKgiftiio", "ITKniftiio", "ITKznz", "itkNetlibSlatec", "itklbfgs", "itkopenjpeg", "itksys" }
        for _, lib in ipairs(libs) do
            package:add("links", lib .. "-" .. ver)
        end
        if package:config("opencv") then
            package:add("deps", "opencv")
        end
        if package:config("vtk") then
            package:add("deps", "vtk")
        end
    end)

    on_install("windows|!arm64", "linux", "macosx", "bsd", function (package)
        io.replace("Modules/ThirdParty/GoogleTest/itk-module.cmake", "DEPENDS", "DEPENDS\n  EXCLUDE_FROM_DEFAULT", {plain = true})
        local configs = {"-DITK_SKIP_PATH_LENGTH_CHECKS=ON",
                         "-DBUILD_TESTING=OFF",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DITK_WRAPPING=OFF",
                         "-DDO_NOT_BUILD_ITK_TEST_DRIVER=ON",
                         "-DITK_USE_SYSTEM_DOUBLECONVERSION=ON",
                         "-DITK_USE_SYSTEM_EIGEN=ON",
                         "-DITK_USE_SYSTEM_EXPAT=ON",
                         "-DITK_USE_SYSTEM_GDCM=ON",
                         "-DITK_USE_SYSTEM_GOOGLETEST=ON",
                         "-DITK_USE_SYSTEM_HDF5=ON",
                         "-DITK_USE_SYSTEM_JPEG=ON",
                         "-DITK_USE_SYSTEM_MINC=ON",
                         "-DITK_USE_SYSTEM_PNG=ON",
                         "-DITK_USE_SYSTEM_TIFF=ON",
                         "-DITK_USE_SYSTEM_VXL=ON",
                         "-DITK_USE_SYSTEM_ZLIB=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DModule_ITKVideoBridgeOpenCV=" .. (package:config("opencv") and "ON" or "OFF"))
        table.insert(configs, "-DModule_ITKVtkGlue=" .. (package:config("vtk") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_CXX_STANDARD=" .. (package:version():ge("5.4.0") and "17" or "14"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DITK_MSVC_STATIC_RUNTIME_LIBRARY=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using ImageType = itk::Image<unsigned short, 3>;
                ImageType::Pointer image = ImageType::New();
            }
        ]]}, {configs = {languages = (package:version():ge("5.4.0") and "c++17" or "c++14")}, includes = "itkImage.h"}))
    end)
