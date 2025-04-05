constants = {}

--- configure

-- only options listed here are yes/no configurations, underscores will be replaced with hyphens.
function constants.get_yn_features()
    return {
        "wasm_dynamic_linking", -- 3.11
        "wasm_pthreads", -- 3.11
        "shared",
        "profiling",
        "gil", -- 3.13
        "pystats", -- 3.11
        "optimizations", -- 3.6
        "bolt", -- 3.12
        "loadable_sqlite_extensions", -- 3.6
        "ipv6",
        "test_modules" -- 3.10
    }
end

function constants.get_all_features()
    return table.join(
        constants.get_yn_features(),
        {
            "universalsdk",
            "framework",
            "experimental_jit", -- 3.13
            "big_digits"
        }
    )
end

function constants.get_supported_packages()
    return {
        "framework_name",
        "app_store_compliance",
        "hash_algorithm",
        "builtin_hashlib_hashes",
        "ssl_default_suites",
        "lto",
        "ensurepip",
        "emscripten_target"
    }
end

--- module

function main()
    return constants
end
