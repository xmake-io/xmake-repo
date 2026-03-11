package("muda")
    set_kind("library", {headeronly = true})
    set_homepage("https://mugdxy.github.io/muda-doc")
    set_description("μ-Cuda, COVER THE LAST MILE OF CUDA. With features: intellisense-friendly, structured launch, automatic cuda graph generation and updating.")
    set_license("Apache-2.0")

    add_urls("https://github.com/MuGdxy/muda.git")

    set_policy("package.install_locally", true)

    add_configs("with_check", {description = "Enable muda check", default = true})
    add_configs("with_compute_graph", {description = "Enable muda compute graph", default = false})

    add_cuflags("--extended-lambda", "--expt-relaxed-constexpr","-rdc=true",{public = true})


    on_install(function (package)
        -- package:add('defines', 'MUDA_CHECK_ON=1', {public = true})
        if package:config("with_check") then
            package:add('defines', 'MUDA_CHECK_ON=1', {public = true})
        else
            package:add('defines', 'MUDA_CHECK_ON=0', {public = true})
        end
        if package:config("with_compute_graph") then
            package:add('defines', 'MUDA_COMPUTE_GRAPH_ON=1', {public = true})
        else
            package:add('defines', 'MUDA_COMPUTE_GRAPH_ON=0', {public = true})
        end
        os.cp("src/muda", package:installdir("include"))
    end)
