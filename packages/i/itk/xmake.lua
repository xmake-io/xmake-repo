package("itk")

    set_homepage("https://itk.org/")
    set_description("ITK is an open-source, cross-platform library that provides developers with an extensive suite of software tools for image analysis.")
    set_license("Apache-2.0")

    add_urls("https://github.com/InsightSoftwareConsortium/ITK/releases/download/v$(version)/InsightToolkit-$(version).tar.gz")
    add_versions("5.2.0", "12c9cf543cbdd929330322f0a704ba6925a13d36d01fc721a74d131c0b82796e")
    add_versions("5.2.1", "192d41bcdd258273d88069094f98c61c38693553fd751b54f8cda308439555db")
    add_versions("5.4.4", "d2092cd018a7b9d88e8c3dda04acb7f9345ab50619b79800688c7bc3afcca82a")

    add_deps("cmake", "eigen", "hdf5[cpplib]")
    if is_plat("windows") then
        add_syslinks("shell32", "advapi32")
    elseif is_plat("linux") then
        add_extsources("apt::libinsighttoolkit5-dev", "pacman::itk")
        add_patches("5.4.4", "patch/linux.patch", "e3971fb669bc20135310d912dd7272ce038a4745f35e21dec6e1e676a5045b94")
        add_syslinks("dl", "pthread")
    elseif is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::itk")
    end
    on_load("windows", "linux", "macosx", function (package)
        local ver = package:version():major() .. "." .. package:version():minor()
        package:add("includedirs", "include/ITK-" .. ver)
        local libs = {"ITKWatersheds", "ITKVideoIO", "ITKVideoCore", "ITKVTK", "ITKTestKernel", "ITKRegistrationMethodsv4", "ITKRegionGrowing", "ITKQuadEdgeMeshFiltering", "ITKOptimizersv4", "ITKMarkovRandomFieldsClassifiers", "itklbfgs", "ITKKLMRegionGrowing", "ITKIOVTK", "ITKIOTransformMatlab", "ITKIOTransformInsightLegacy", "ITKIOTransformHDF5", "ITKIOTransformBase", "ITKTransformFactory", "ITKIOStimulate", "ITKIOSpatialObjects", "ITKIOXML", "ITKIOSiemens", "ITKIOPNG", "itkpng", "ITKIONRRD", "ITKNrrdIO", "ITKIONIFTI", "ITKIOMeta", "ITKIOMeshVTK", "ITKIOMeshOFF", "ITKIOMeshOBJ", "ITKIOMeshGifti", "ITKIOMeshFreeSurfer", "ITKIOMeshBYU", "ITKIOMeshBase", "ITKIOMRC", "ITKIOMINC", "itkminc2", "ITKIOLSM", "ITKIOTIFF", "itktiff", "ITKIOJPEG2000", "itkopenjpeg", "ITKIOJPEG", "itkjpeg", "ITKIOHDF5", "ITKIOGIPL", "ITKIOGE", "ITKIOIPL", "ITKIOGDCM", "ITKIOCSV", "ITKIOBruker", "ITKIOBioRad", "ITKIOBMP", "ITKPDEDeformableRegistration", "ITKgiftiio", "ITKniftiio", "ITKznz", "gdcmMSFF", "gdcmDICT", "ITKEXPAT", "ITKDiffusionTensorImage", "ITKDenoising", "ITKDeformableMesh", "ITKDICOMParser", "ITKConvolution", "ITKFFT", "ITKColormap", "ITKBiasCorrection", "ITKPolynomials", "ITKOptimizers", "ITKImageFeature", "ITKSmoothing", "ITKIOImageBase", "ITKFastMarching", "ITKQuadEdgeMesh", "ITKMathematicalMorphology", "ITKLabelMap", "ITKPath", "ITKSpatialObjects", "ITKMetaIO", "itkzlib", "ITKMesh", "ITKTransform", "ITKStatistics", "itkNetlibSlatec", "ITKCommon", "itkvcl", "itkvnl_algo", "itkvnl", "itkv3p_netlib", "itksys", "itkdouble-conversion"}
        for _, lib in ipairs(libs) do
            package:add("links", lib .. "-" .. ver)
        end
    end)

    on_install("windows|!arm64", "linux", "macosx", function (package)
        local configs = {"-DITK_SKIP_PATH_LENGTH_CHECKS=ON",
                         "-DBUILD_TESTING=OFF",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DITK_WRAPPING=OFF",
                         "-DITK_USE_SYSTEM_EIGEN=ON",
                         "-DITK_USE_SYSTEM_HDF5=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_CXX_STANDARD=" .. (package:version():ge("5.4.0") and "17" or "14"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DITK_MSVC_STATIC_RUNTIME_LIBRARY=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
            if package:is_arch("arm64") then
                table.insert(configs, "-DQNANHIBIT_VALUE=1")
                table.insert(configs, "-DQNANHIBIT_VALUE__TRYRUN_OUTPUT=1")
                table.insert(configs, "-DHDF_NO_IOEO_TEST=1")
            end
            import("package.tools.cmake").install(package, configs, {builddir = path.join(os.tmpdir(), "itk_build")})
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
        ]]}, {configs = {languages = (package:version():ge("5.4.0") and "c++17" or "c++14")}, includes = "itkImage.h"}))
    end)
