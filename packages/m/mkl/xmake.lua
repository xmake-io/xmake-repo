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
            add_versions("2022.1.0+192", "fd9a529c0caa27ee3068e8d845f07e536970b0cbf713118d1f3daa32fb2b9e8c")
            add_resources("2022.1.0+192", "headers", "https://anaconda.org/intel/mkl-include/2022.1.0/download/win-64/mkl-include-2022.1.0-intel_192.tar.bz2", "b6452e8c4891fcfab452bc23c6adc9c61ab6635fa494bb2b29725473c1013abc")
        elseif is_arch("x86") then
            add_urls("https://anaconda.org/intel/mkl-static/$(version).tar.bz2", {version = function (version)
                local mv = version:split("%+")
                return format("%s/download/win-32/mkl-static-%s-intel_%s", mv[1], mv[1], mv[2])
            end})
            add_versions("2021.2.0+296", "eaf0df027d58c5fd948f86b83dfc4d608855962cbdb04551712c9aeeb7b26eca")
            add_resources("2021.2.0+296", "headers", "https://anaconda.org/intel/mkl-include/2021.2.0/download/win-32/mkl-include-2021.2.0-intel_296.tar.bz2", "8ed173edff75783426de1bbc1d122266047fc84d4cfc5a9b810b1f2792f02c37")
            add_versions("2021.3.0+524", "799a42ab4422d1532be65e40ed4ac5e81692b796ae3de37a7489389f9e10f112")
            add_resources("2021.3.0+524", "headers", "https://anaconda.org/intel/mkl-include/2021.3.0/download/win-32/mkl-include-2021.3.0-intel_524.tar.bz2", "9ff8e58dc98da8ec2fe3b15eac2abfef4eb3335d90feeb498f84126371ccea8c")
            add_versions("2022.0.3+171", "b34d5e5d0dd779b117666c9fc89d008431f6239ad60fc08a52a6b874fdf24517")
            add_resources("2022.0.3+171", "headers", "https://anaconda.org/intel/mkl-include/2022.0.3/download/win-32/mkl-include-2022.0.3-intel_171.tar.bz2", "f696cd98b2f33b2c21bf7b70f57e894a763dad1831c721a348614cfeb17a4541")
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
        add_versions("2022.1.0+208", "06e5dcd7b8f11f9736d4e4d7d5a9972333ee8822cf2263ecccf4cb0e3cc95530")
        add_resources("2022.1.0+208", "headers", "https://anaconda.org/intel/mkl-include/2022.1.0/download/osx-64/mkl-include-2022.1.0-intel_208.tar.bz2", "569ea516148726b2698f17982aba2d9ec1bfb321f0180be938eddbc696addbc5")
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
            add_versions("2022.1.0+223", "9dfb2940447cc8cf7ca3e647e2b62be714e89cbca162998cbf4e05deb69b6bd2")
            add_resources("2022.1.0+223", "headers", "https://anaconda.org/intel/mkl-include/2022.1.0/download/linux-64/mkl-include-2022.1.0-intel_223.tar.bz2", "704e658a9b25a200f8035f3d0a8f2e094736496a2169f87609f1cfed2e2eb0a9")
        elseif is_arch("x86") then
            add_urls("https://anaconda.org/intel/mkl-static/$(version).tar.bz2", {version = function (version)
                local mv = version:split("%+")
                return format("%s/download/linux-32/mkl-static-%s-intel_%s", mv[1], mv[1], mv[2])
            end})
            add_versions("2021.2.0+296", "34a1bc80a4a39ca5a55d29e9fcc803380fbc4d029ae496e60a918e8d12db68c2")
            add_resources("2021.2.0+296", "headers", "https://anaconda.org/intel/mkl-include/2021.2.0/download/linux-32/mkl-include-2021.2.0-intel_296.tar.bz2", "7fcbc945377b486b40d29b170d0b6c39bbc5b430ac7284dae2046bbf610f643d")
            add_versions("2021.3.0+520", "4df801f5806d1934c5f3887e8f2153fb0c929be9545627cf99ce9e72c907653b")
            add_resources("2021.3.0+520", "headers", "https://anaconda.org/intel/mkl-include/2021.3.0/download/linux-32/mkl-include-2021.3.0-intel_520.tar.bz2", "dce1f2a08499f34ed4883b807546754c1547a9cc2424b7b75b9233641cf044c1")
            add_versions("2022.0.2+136", "157c09248cb5e5cbcb28ef8db53d529ab2f049e9269b2a2bc90601c0c420080e")
            add_resources("2022.0.2+136", "headers", "https://anaconda.org/intel/mkl-include/2022.0.2/download/linux-32/mkl-include-2022.0.2-intel_136.tar.bz2", "16882aeddbd33a2dc9210e61c59db6ad0d7d9efdd40ad1544b369b0830683371")
        end
    end

    add_configs("threading", {description = "Choose threading modal for mkl.", default = "tbb", type = "string", values = {"tbb", "openmp", "gomp", "seq"}})
    add_configs("interface", {description = "Choose index integer size for the interface.", default = 32, values = {32, 64}})

    on_fetch("fetch")

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end
    on_load("windows", "macosx", "linux", function (package)
        -- Refer to [oneAPI Math Kernel Library Link Line Advisor](https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl-link-line-advisor.html)
        -- to get the link option for MKL library.
        local suffix = (package:config("interface") == 32 and "lp64" or "ilp64")
        if package:config("interface") == 64 then
            package:add("defines", "MKL_ILP64")
        end
        package:add("links", package:is_arch("x64", "x86_64") and "mkl_blas95_" .. suffix or "mkl_blas95")
        package:add("links", package:is_arch("x64", "x86_64") and "mkl_lapack95_" .. suffix or "mkl_lapack95")

        if package:has_tool("cc", "gcc", "gxx") then
            local flags = {"-Wl,--start-group"}
            table.insert(flags, package:is_arch("x64", "x86_64") and "-lmkl_intel_" .. suffix or "-lmkl_intel")
            local threading = package:config("threading")
            if threading == "tbb" then
                table.insert(flags, "-lmkl_tbb_thread")
                package:add("deps", "tbb")
            elseif threading == "seq" then
                table.insert(flags, "-lmkl_sequential")
            elseif threading == "openmp" then
                table.insert(flags, "-lmkl_intel_thread")
                table.insert(flags, "-lomp")
            elseif threading == "gomp" then
                table.insert(flags, "-lmkl_gnu_thread")
                table.insert(flags, "-lgomp")
            end
            table.insert(flags, "-lmkl_core")
            table.insert(flags, "-Wl,--end-group")
            package:add("ldflags", table.concat(flags, " "))
        else
            package:add("links", package:is_arch("x64", "x86_64") and "mkl_intel_" .. suffix or "mkl_intel_c")
            local threading = package:config("threading")
            if threading == "tbb" then
                package:add("links", "mkl_tbb_thread")
                package:add("deps", "tbb")
            elseif threading == "seq" then
                package:add("links", "mkl_sequential")
            elseif threading == "openmp" then
                package:add("links", "mkl_intel_thread", "omp")
            elseif threading == "gomp" then
                package:add("links", "mkl_gnu_thread", "gomp")
            end
            package:add("links", "mkl_core")
        end
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
