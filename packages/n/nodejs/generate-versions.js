import fs from 'node:fs';
import path from 'node:path';
import { BatchQueue } from "https://deno.land/x/batch_queue/mod.ts";

const PLATFORM_MAPPINGS = {
    'windows-x64': { name: 'win-x64.zip', xmake_os: 'windows', xmake_arch: 'x64' },
    'windows-x86': { name: 'win-x86.zip', xmake_os: 'windows', xmake_arch: 'x86' },
    'windows-arm64': { name: 'win-arm64.zip', xmake_os: 'windows', xmake_arch: 'arm64' },
    'linux-x64': { name: 'linux-x64.tar.gz', xmake_os: 'linux', xmake_arch: 'x64' },
    'linux-arm64': { name: 'linux-arm64.tar.gz', xmake_os: 'linux', xmake_arch: 'arm64' },
    'linux-armv7l': { name: 'linux-armv7l.tar.gz', xmake_os: 'linux', xmake_arch: 'armv7l' },
    'macosx-x64': { name: 'darwin-x64.tar.gz', xmake_os: 'macosx', xmake_arch: 'x64' },
    'macosx-arm64': { name: 'darwin-arm64.tar.gz', xmake_os: 'macosx', xmake_arch: 'arm64' },
    'aix-ppc64': { name: 'aix-ppc64.tar.gz', xmake_os: 'aix', xmake_arch: 'ppc64' },
    'linux-ppc64le': { name: 'linux-ppc64le.tar.gz', xmake_os: 'linux', xmake_arch: 'ppc64le' },
    'linux-s390x': { name: 'linux-s390x.tar.gz', xmake_os: 'linux', xmake_arch: 's390x' },
};

const SOURCES = [
    { name: 'release', url: 'https://nodejs.org/download/release/index.json', baseUrl: 'https://nodejs.org/dist/' },
    // { name: 'nightly', url: 'https://nodejs.org/download/nightly/index.json', baseUrl: 'https://nodejs.org/dist/nightly/' },
    // { name: 'unofficial', url: 'https://unofficial-builds.node/js.org/download/release/index.json', baseUrl: 'https://unofficial-builds.nodejs.org/download/release/' },
];

const OUTPUT_DIR = 'versions';

function parseShasums(text) {
    const lines = text.split('\n');
    const checksums = new Map();
    for (const line of lines) {
        const parts = line.split(/\s+/);
        if (parts.length >= 2) {
            const sha = parts[0];
            const filename = parts[1];
            checksums.set(filename, sha);
        }
    }
    return checksums;
}

async function main() {
    if (!fs.existsSync(OUTPUT_DIR)) {
        fs.mkdirSync(OUTPUT_DIR);
    }

    const allProcessedVersions = new Set();
    const results = {};
    for (const key in PLATFORM_MAPPINGS) {
        results[key] = [];
    }

    for (const source of SOURCES) {
        console.log(`[INFO] Fetching version list from: ${source.name} (${source.url})`);
        let versions;
        try {
            versions = await fetch(source.url).then(v => v.json());
        } catch (error) {
            console.error(`[ERROR] Failed to fetch from ${source.name}:`, error.message);
            continue;
        }

        const queue = new BatchQueue(100);

        const processVersion = async (v) => {
            const versionStr = v.version;
            if (allProcessedVersions.has(versionStr)) {
                return;
            }
            allProcessedVersions.add(versionStr);

            console.log(` -> Processing ${versionStr}`);

            const shasumsUrl = `${source.baseUrl}${versionStr}/SHASUMS256.txt`;
            let shasums;
            try {
                const shasumsText = await fetch(shasumsUrl).then(v => v.text());
                shasums = parseShasums(shasumsText);
            } catch (error) {
                console.warn(`[WARN] Could not fetch SHASUMS256.txt for ${versionStr}, skipping.`);
                return;
            }

            for (const [key, mapping] of Object.entries(PLATFORM_MAPPINGS)) {
                const filename = `node-${versionStr}-${mapping.name}`;
                if (shasums.has(filename)) {
                    results[key].push({ version: versionStr.replace('v', ''), sha: shasums.get(filename) });
                }
            }

            console.log(` √ Processed ${versionStr} (${Object.keys(PLATFORM_MAPPINGS).length} platforms)`);
        };

        for (const v of versions) {
            queue.queue(() => processVersion(v));
        }

        await queue.run();
        await queue.allSettled
    }

    console.log('\n[INFO] Writing version files...');
    let res = 'function add_nodejs_versions()'
    for (const [key, versionData] of Object.entries(results)) {
        versionData.sort((a, b) => b.version.localeCompare(a.version, undefined, { numeric: true }));

        const map = PLATFORM_MAPPINGS[key];
        const content =
            `
    if is_plat("${map.xmake_os}") and is_arch("${map.xmake_arch}") then
        add_urls("https://nodejs.org/download/release/v$(version)/node-v$(version)-${map.name}")
${versionData.map(item => `\t\tadd_versions("${item.version}", "${item.sha}")`).join('\n')}
    end
`;

        res += content;
    }

    res += '\nend\n';
    fs.writeFileSync('nodejs-versions.lua', res);
    console.log('\n[SUCCESS] All version files have been generated.');
}

main().catch(console.error);
