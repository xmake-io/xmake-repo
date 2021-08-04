package("mkl")

    set_homepage("https://software.intel.com/content/www/us/en/develop/tools/oneapi/components/onemkl.html")
    set_description("Intel® oneAPI Math Kernel Library")

    if is_plat("windows") then
        if is_arch("x64") then
            add_urls("https://anaconda.org/intel/mkl-static/$(version).tar.bz2", {version = function (version)
                local mv = version:split("%+")
                return format("%s/download/win-64/mkl-static-%s-intel_%s", mv[1], mv[1], mv[2])
            end})
            add_versions("2021.2.0+296", "54209e5d9c4778381f08b9a90e900c001494db020cda426441cd624cb0f7ebdc")
            add_resources("2021.2.0+296", "headers", "https://anaconda.org/intel/mkl-include/2021.2.0/download/win-64/mkl-include-2021.2.0-intel_296.tar.bz2", "ba222ea4ceb9e09976f23a3df39176148b4469b297275f3d05c1ad411b3d54c3")
            add_versions("2021.3.0+524", "842628a8621f2ca19d7f1809e50420e311edf20b9bea18404dd1c20af798f5e6")
            add_resources("2021.3.0+524", "headers", "https://anaconda.org/intel/mkl-include/2021.3.0/download/win-64/mkl-include-2021.3.0-intel_524.tar.bz2", "8ca8f77d0c57a434541d62a9c61781aa37225f5e669de01b8cc98488b3f9e82f")
        elseif is_arch("x86") then
            add_urls("https://anaconda.org/intel/mkl-static/$(version).tar.bz2", {version = function (version)
                local mv = version:split("%+")
                return format("%s/download/win-32/mkl-static-%s-intel_%s", mv[1], mv[1], mv[2])
            end})
            add_versions("2021.2.0+296", "eaf0df027d58c5fd948f86b83dfc4d608855962cbdb04551712c9aeeb7b26eca")
            add_resources("2021.2.0+296", "headers", "https://anaconda.org/intel/mkl-include/2021.2.0/download/win-32/mkl-include-2021.2.0-intel_296.tar.bz2", "8ed173edff75783426de1bbc1d122266047fc84d4cfc5a9b810b1f2792f02c37")
            add_versions("2021.3.0+524", "799a42ab4422d1532be65e40ed4ac5e81692b796ae3de37a7489389f9e10f112")
            add_resources("2021.3.0+524", "headers", "https://anaconda.org/intel/mkl-include/2021.3.0/download/win-32/mkl-include-2021.3.0-intel_524.tar.bz2", "9ff8e58dc98da8ec2fe3b15eac2abfef4eb3335d90feeb498f84126371ccea8c")
        end
    elseif is_plat("macosx") and is_arch("x86_64") then
        add_urls("https://anaconda.org/intel/mkl-static/$(version).tar.bz2", {version = function (version)
            local mv = version:split("%+")
            return format("%s/download/osx-64/mkl-static-%s-intel_%s", mv[1], mv[1], mv[2])
        end})
        add_versions("2021.2.0+269", "b7af248f01799873333cbd388b5efa19601cf6815dc38713509974783f4b1ccd")
        add_resources("2021.2.0+269", "headers", "https://anaconda.org/intel/mkl-include/2021.2.0/download/osx-64/mkl-include-2021.2.0-intel_269.tar.bz2", "5215d62cadeb3f8021230163dc35ad38259e3688aa0f39d7da69ebe54ab45624")
        add_versions("2021.3.0+517", "85a636642ee4f76fba50d16c45099cd22082eb1f8b835a4a0b455ec4796ebf8f")
        add_resources("2021.3.0+517", "headers", "https://anaconda.org/intel/mkl-include/2021.3.0/download/osx-64/mkl-include-2021.3.0-intel_517.tar.bz2", "db9896e667b31908b398d515108433d8df95e6429ebfb9d493a463f25886019c")
    elseif is_plat("linux") then
        if is_arch("x86_64") then
            add_urls("https://anaconda.org/intel/mkl-static/$(version).tar.bz2", {version = function (version)
                local mv = version:split("%+")
                return format("%s/download/linux-64/mkl-static-%s-intel_%s", mv[1], mv[1], mv[2])
            end})
            add_versions("2021.2.0+296", "2bcaefefd593e4fb521e1fc88715f672ae5b9d1706babf10e3a10ef43ea0f983")
            add_resources("2021.2.0+296", "headers", "https://anaconda.org/intel/mkl-include/2021.2.0/download/linux-64/mkl-include-2021.2.0-intel_296.tar.bz2", "13721fead8a3eddee15b914fd3ae9cf2095966af79bbc2f086462eda9fff4d62")
            add_versions("2021.3.0+520", "c1e21988bbf05b455077a512cb719ef59ec6e06a6807cfefb892945ec19de5d0")
            add_resources("2021.3.0+520", "headers", "https://anaconda.org/intel/mkl-include/2021.3.0/download/linux-64/mkl-include-2021.3.0-intel_520.tar.bz2", "b0df7fb4c2071fdec87b567913715a2e47dca05e8c3ac4e5bcf072d7804085af")
        elseif is_arch("x86") then
            add_urls("https://anaconda.org/intel/mkl-static/$(version).tar.bz2", {version = function (version)
                local mv = version:split("%+")
                return format("%s/download/linux-32/mkl-static-%s-intel_%s", mv[1], mv[1], mv[2])
            end})
            add_versions("2021.2.0+296", "34a1bc80a4a39ca5a55d29e9fcc803380fbc4d029ae496e60a918e8d12db68c2")
            add_resources("2021.2.0+296", "headers", "https://anaconda.org/intel/mkl-include/2021.2.0/download/linux-32/mkl-include-2021.2.0-intel_296.tar.bz2", "7fcbc945377b486b40d29b170d0b6c39bbc5b430ac7284dae2046bbf610f643d")
            add_versions("2021.3.0+520", "4df801f5806d1934c5f3887e8f2153fb0c929be9545627cf99ce9e72c907653b")
            add_resources("2021.3.0+520", "headers", "https://anaconda.org/intel/mkl-include/2021.3.0/download/linux-32/mkl-include-2021.3.0-intel_520.tar.bz2", "dce1f2a08499f34ed4883b807546754c1547a9cc2424b7b75b9233641cf044c1")
        end
    end

    add_configs("threading", {description = "Choose threading modal for mkl.", default = "tbb", type = "string", values = {"tbb", "openmp", "seq"}})

    on_fetch("fetch")

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end
    on_load("windows", "macosx", "linux", function (package)
        package:add("links", package:is_arch("x64", "x86_64") and "mkl_lapack95_ilp64" or "mkl_lapack95")
        package:add("links", package:is_arch("x64", "x86_64") and "mkl_blas95_ilp64" or "mkl_blas95")
        if package:is_plat("windows") then
            package:add("links", package:is_arch("x64", "x86_64") and "mkl_intel_ilp64" or "mkl_intel_c")
        else
            package:add("links", package:is_arch("x64", "x86_64") and "mkl_intel_ilp64" or "mkl_intel")
        end

        local threading = package:config("threading")
        if threading == "tbb" then
            package:add("links", "mkl_tbb_thread")
            package:add("deps", "tbb")
        elseif threading == "seq" then
            package:add("links", "mkl_sequential")
        elseif threading == "openmp" then
            package:add("links", "mkl_intel_thread")
        end
        package:add("links", "mkl_core")
    end)

    on_install("windows", "macosx", "linux", function (package)
        local headerdir = package:resourcedir("headers")
        if package:is_plat("windows") then
            os.trymv(path.join("Library", "lib"), package:installdir())
            os.trymv(path.join(headerdir, "Library", "include"), package:installdir())
        else
            os.trymv(path.join("lib"), package:installdir())
            os.trymv(path.join(headerdir, "include"), package:installdir())
        end
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                double A[6] = {1.0,2.0,1.0,-3.0,4.0,-1.0};
                double B[6] = {1.0,2.0,1.0,-3.0,4.0,-1.0};
                double C[9] = {.5,.5,.5,.5,.5,.5,.5,.5,.5};
                cblas_dgemm(CblasColMajor,CblasNoTrans,CblasTrans,3,3,2,1,A,3,B,3,2,C,3);
            }
        ]]}, {includes = "mkl_cblas.h"}))
    end)
