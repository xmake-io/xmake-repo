package("duilib_ultimate")

    set_homepage("https://github.com/qdtroy/DuiLib_Ultimate")
    set_description("DuiLib_Ultimate是duilib库的增强拓展版")

    add_urls("https://github.com/qdtroy/DuiLib_Ultimate/archive/refs/tags/$(version).tar.gz")
    add_versions("0.3", "4a650267e98d8b19818bdeb7675dcf1403017732b961620678e1d2d81f81db91")

    add_configs("shared", {description = "Download shared binaries.", default = false, type = "boolean", readonly=true})

    on_install("windows", function (package)
        package:add("defines", "UILIB_STATIC")
        package:add("syslinks", "gdi32")

        io.writefile("add_defines.props", [[
<?xml version="1.0" encoding="utf-8"?> 
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemDefinitionGroup>
    <ClCompile>
      <PreprocessorDefinitions>
          %(PreprocessorDefinitions);UILIB_STATIC
      </PreprocessorDefinitions>
    </ClCompile>
  </ItemDefinitionGroup>
</Project>
        ]])
        local configs = {"DuiLib.sln"}
        table.insert(configs, "/p:Configuration=" .. (package:debug() and "SDebug" or "SRelease"))
        table.insert(configs, "/p:Platform=" .. (package:is_arch("x64") and "x64" or "Win32"))
        table.insert(configs, "-t:DuiLib")
        table.insert(configs, '/p:ForceImportBeforeCppTargets="add_defines.props"')
        import("package.tools.msbuild").build(package, configs, {upgrade = {"DuiLib.sln"}})
        os.cp("Lib/*", package:installdir("lib"))
        os.cp("bin", package:installdir())
        os.cp ("DuiLib/**.h", package:installdir("include"), {rootdir="DuiLib"})
        os.cp ("DuiLib/Utils/Flash11.tlb", package:installdir("include") .. "/Utils/")
        os.cp ("DuiLib/Utils/flash11.tlh", package:installdir("include") .. "/Utils/")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "UIlib.h"
            using namespace DuiLib;
            void test() {
                CButtonUI *pButton = new CButtonUI();
            }
        ]]}))
    end)
