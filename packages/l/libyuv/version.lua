-- Versions from LIBYUV_VERSION definition in include/libyuv/version.h
-- Pay attention to package commits incrementing this definition
local table = {
    ["1891"] = "611806a1559b92c97961f51c78805d8d9d528c08",
}

function main(version)
    return table[tostring(version)]
end
