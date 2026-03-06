function _fix_ninja_pdb(package)
    if package:is_debug() and package:has_tool("cxx", "cl") then
        os.mkdir(path.join(package:buildir(), "src/tint/pdb"))
        os.mkdir(path.join(package:buildir(), "src/dawn/pdb"))
        os.mkdir(path.join(package:buildir(), "src/dawn/wire/pdb"))
        os.mkdir(path.join(package:buildir(), "src/dawn/utils/pdb"))
        os.mkdir(path.join(package:buildir(), "src/dawn/native/pdb"))
        os.mkdir(path.join(package:buildir(), "src/dawn/common/pdb"))
        os.mkdir(path.join(package:buildir(), "src/dawn/platform/pdb"))
    end
end

function _cmake(package)
    io.replace("CMakeLists.txt", "enable_testing()",
        "find_package(absl CONFIG REQUIRED)\nfind_package(SPIRV-Headers CONFIG REQUIRED)\nfind_package(SPIRV-Tools CONFIG REQUIRED)"
    , {plain = true})

    io.replace("third_party/CMakeLists.txt", "SPIRV-Headers", "SPIRV-Headers::SPIRV-Headers", {plain = true})
end

function main(package)
    _fix_ninja_pdb(package)
    _cmake(package)
end
