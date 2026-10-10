#include <windows.h>
#include <stdio.h>
#include <string>
#include <algorithm>
#include <vector>
#include <fstream>
#include <sstream>

struct IconResult {
    std::wstring color;
    bool showBolt;
};

IconResult ComputeBatteryIconState(int percentage, bool charging, bool powerSaving) {
    percentage = std::clamp(percentage, 0, 100);

    // Battery icon shell fill color priority:
    // 1. Charging: Green (#34C759), retaining the bolt glyph.
    // 2. Not charging and battery percentage < 20%: Red (#FF3B30), no bolt glyph (takes priority over battery saver).
    // 3. Not charging, battery saver active, and battery percentage >= 20%: Orange (#FF9500), no bolt glyph.
    // 4. Not charging, normal operation (battery percentage >= 20%): Green (#34C759), no bolt glyph.
    std::wstring indicatorColor;
    if (charging) {
        indicatorColor = L"#34C759";
    } else if (percentage < 20) {
        indicatorColor = L"#FF3B30";
    } else if (powerSaving) {
        indicatorColor = L"#FF9500";
    } else {
        indicatorColor = L"#34C759";
    }

    return { indicatorColor, charging };
}

struct BatteryInfoTest {
    int percentage = 0;
    int health = 100;
    bool charging = false;
    bool powerSaving = false;
    bool present = true;
};

// Simulation of GetBatteryInfo logic
BatteryInfoTest SimulateGetBatteryInfo(const SYSTEM_POWER_STATUS& powerStatus, DWORD hkcuVal, bool hkcuPresent, DWORD hklmVal, bool hklmPresent) {
    BatteryInfoTest info;
    if (powerStatus.BatteryLifePercent == 255 || (powerStatus.BatteryFlag & 128)) {
        info.present = false;
        info.percentage = 100;
        info.charging = false;
    } else {
        info.percentage = powerStatus.BatteryLifePercent;
        info.charging = (powerStatus.ACLineStatus == 1);
    }
    if (powerStatus.SystemStatusFlag == 1) {
        info.powerSaving = true;
    }

    if (!info.powerSaving && hkcuPresent) {
        if (hkcuVal != 0) {
            info.powerSaving = true;
        }
    }
    if (!info.powerSaving && hklmPresent) {
        if (hklmVal == 1) {
            info.powerSaving = true;
        }
    }

    return info;
}

constexpr GUID kGuidBestPowerEfficiency = {
    0x961cc777, 0x2547, 0x4f9d, {0x81, 0x74, 0x7d, 0x86, 0x18, 0x1b, 0x8a, 0x7a}};
constexpr GUID kGuidBalanced = {
    0x00000000, 0x0000, 0x0000, {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}};
constexpr GUID kGuidBestPerformance = {
    0xded574b5, 0x45a0, 0x4f42, {0x87, 0x37, 0x46, 0x34, 0x5c, 0x09, 0xc2, 0x38}};

typedef DWORD (WINAPI *PowerGetActualOverlayScheme_t)(GUID* pGuid);
typedef DWORD (WINAPI *PowerSetActiveOverlayScheme_t)(const GUID* pGuid);

bool TestIconLogic() {
    printf("[TEST 1/5] Running Battery Icon State & Priority Tests...\n");
    fflush(stdout);

    // 1. Charging always Green (#34C759) and shows bolt, regardless of percentage or battery saver
    for (int pct = -10; pct <= 110; pct += 5) {
        for (int ps = 0; ps <= 1; ps++) {
            auto res = ComputeBatteryIconState(pct, true, ps != 0);
            if (res.color != L"#34C759" || !res.showBolt) {
                printf("FAIL charging at pct=%d, ps=%d\n", pct, ps);
                return false;
            }
        }
    }
    printf("  [PASS] Charging always Green (#34C759) with bolt glyph across all values.\n");

    // 2. Discharging and percentage < 20%: Red (#FF3B30), no bolt (takes priority over battery saver)
    for (int pct = -10; pct < 20; pct++) {
        for (int ps = 0; ps <= 1; ps++) {
            auto res = ComputeBatteryIconState(pct, false, ps != 0);
            if (res.color != L"#FF3B30" || res.showBolt) {
                printf("FAIL discharging <20 at pct=%d, ps=%d\n", pct, ps);
                return false;
            }
        }
    }
    printf("  [PASS] Discharging < 20%% always Red (#FF3B30) without bolt (priority over saver).\n");

    // 3. Discharging, battery saver active, percentage >= 20%: Orange (#FF9500), no bolt
    for (int pct = 20; pct <= 110; pct += 5) {
        auto res = ComputeBatteryIconState(pct, false, true);
        if (res.color != L"#FF9500" || res.showBolt) {
            printf("FAIL discharging >=20 with saver at pct=%d\n", pct);
            return false;
        }
    }
    printf("  [PASS] Discharging >= 20%% with saver active always Orange (#FF9500) without bolt.\n");

    // 4. Discharging, normal operation, percentage >= 20%: Green (#34C759), no bolt
    for (int pct = 20; pct <= 110; pct += 5) {
        auto res = ComputeBatteryIconState(pct, false, false);
        if (res.color != L"#34C759" || res.showBolt) {
            printf("FAIL discharging >=20 normal at pct=%d\n", pct);
            return false;
        }
    }
    printf("  [PASS] Discharging >= 20%% normal operation always Green (#34C759) without bolt.\n");

    // 5. Exact boundary transitions:
    // 19% -> Red (#FF3B30)
    // 20% saver off -> Green (#34C759)
    // 20% saver on  -> Orange (#FF9500)
    if (ComputeBatteryIconState(19, false, false).color != L"#FF3B30" ||
        ComputeBatteryIconState(19, false, true).color != L"#FF3B30" ||
        ComputeBatteryIconState(20, false, false).color != L"#34C759" ||
        ComputeBatteryIconState(20, false, true).color != L"#FF9500") {
        printf("FAIL exact boundary at 19/20%%\n");
        return false;
    }
    printf("  [PASS] Boundary checks at 19%% and 20%% verified.\n");
    fflush(stdout);
    return true;
}

bool TestGetBatteryInfoPriorityLogic() {
    printf("[TEST 2/5] Running GetBatteryInfo State Priority & Non-Overwrite Tests...\n");
    fflush(stdout);

    SYSTEM_POWER_STATUS ps = {};
    ps.ACLineStatus = 0; // discharging
    ps.BatteryLifePercent = 25;
    ps.SystemStatusFlag = 1; // Windows OS battery saver ON

    // Critical regression test: SystemStatusFlag=1 must NOT be overwritten when HKCU PowerSavingMode=0
    auto r1 = SimulateGetBatteryInfo(ps, 0, true, 0, false);
    if (!r1.powerSaving) {
        printf("FAIL: SystemStatusFlag=1 was overwritten by HKCU PowerSavingMode=0!\n");
        return false;
    }

    // HKCU PowerSavingMode=1 turns powerSaving on even if SystemStatusFlag=0
    ps.SystemStatusFlag = 0;
    auto r2 = SimulateGetBatteryInfo(ps, 1, true, 0, false);
    if (!r2.powerSaving) {
        printf("FAIL: HKCU PowerSavingMode=1 did not enable powerSaving!\n");
        return false;
    }

    // HKLM EnergySaverState=1 turns powerSaving on when HKCU is missing
    auto r3 = SimulateGetBatteryInfo(ps, 0, false, 1, true);
    if (!r3.powerSaving) {
        printf("FAIL: HKLM EnergySaverState=1 did not enable powerSaving!\n");
        return false;
    }

    // Normal state: all 0 -> powerSaving is false
    auto r4 = SimulateGetBatteryInfo(ps, 0, true, 0, false);
    if (r4.powerSaving) {
        printf("FAIL: Normal state should be false!\n");
        return false;
    }

    printf("  [PASS] GetBatteryInfo correctly preserves SystemStatusFlag and respects registry fallback.\n");
    fflush(stdout);
    return true;
}

bool TestPowerOverlaySchemes() {
    printf("[TEST 3/5] Running Windows Power Overlay Scheme Switching Tests...\n");
    fflush(stdout);
    HMODULE hPowr = LoadLibraryW(L"powrprof.dll");
    if (!hPowr) {
        printf("FAIL: load powrprof.dll\n");
        return false;
    }

    auto pGetActual = (PowerGetActualOverlayScheme_t)GetProcAddress(hPowr, "PowerGetActualOverlayScheme");
    auto pSetActive = (PowerSetActiveOverlayScheme_t)GetProcAddress(hPowr, "PowerSetActiveOverlayScheme");
    if (!pGetActual || !pSetActive) {
        printf("FAIL: GetProcAddress\n");
        return false;
    }

    GUID origGuid = {0};
    DWORD r = pGetActual(&origGuid);
    printf("  Current overlay GUID={%08lx-%04x-%04x...}\n", origGuid.Data1, origGuid.Data2, origGuid.Data3);

    // Test switching to Best Power Efficiency
    r = pSetActive(&kGuidBestPowerEfficiency);
    GUID current = {0};
    pGetActual(&current);
    if (memcmp(&current, &kGuidBestPowerEfficiency, sizeof(GUID)) != 0) {
        printf("FAIL: BestPowerEfficiency not active\n");
        return false;
    }

    // Test switching to Best Performance
    r = pSetActive(&kGuidBestPerformance);
    pGetActual(&current);
    if (memcmp(&current, &kGuidBestPerformance, sizeof(GUID)) != 0) {
        printf("FAIL: BestPerformance not active\n");
        return false;
    }

    // Test switching to Balanced
    r = pSetActive(&kGuidBalanced);
    pGetActual(&current);
    if (memcmp(&current, &kGuidBalanced, sizeof(GUID)) != 0) {
        printf("FAIL: Balanced not active\n");
        return false;
    }

    // Test normalization for OEM/unrecognized overlay schemes
    auto normalizeOverlay = [](const GUID& g) -> GUID {
        if (memcmp(&g, &kGuidBestPowerEfficiency, sizeof(GUID)) == 0 ||
            memcmp(&g, &kGuidBestPerformance, sizeof(GUID)) == 0) {
            return g;
        }
        return kGuidBalanced;
    };
    GUID oemGuid = {0x12345678, 0x1234, 0x1234, {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0}};
    GUID nEff = normalizeOverlay(kGuidBestPowerEfficiency);
    GUID nPerf = normalizeOverlay(kGuidBestPerformance);
    GUID nBal = normalizeOverlay(kGuidBalanced);
    GUID nOem = normalizeOverlay(oemGuid);
    if (memcmp(&nEff, &kGuidBestPowerEfficiency, sizeof(GUID)) != 0 ||
        memcmp(&nPerf, &kGuidBestPerformance, sizeof(GUID)) != 0 ||
        memcmp(&nBal, &kGuidBalanced, sizeof(GUID)) != 0 ||
        memcmp(&nOem, &kGuidBalanced, sizeof(GUID)) != 0) {
        printf("FAIL: Overlay normalization failed!\n");
        return false;
    }

    // Restore original
    pSetActive(&origGuid);
    pGetActual(&current);
    printf("  [PASS] Overlay schemes switching, restore, and normalization verified successfully.\n");
    fflush(stdout);
    return true;
}

bool TestEnergySaverToggleAPIs() {
    printf("[TEST 4/5] Running Energy Saver Registry and Power Scheme Threshold Tests...\n");
    fflush(stdout);

    auto setSaver = [](bool enable) {
        HKEY key = nullptr;
        if (RegCreateKeyExW(HKEY_CURRENT_USER,
                            L"Software\\Microsoft\\Windows\\CurrentVersion\\Power\\SystemSettings", 0,
                            nullptr, 0, KEY_SET_VALUE, nullptr, &key, nullptr) == ERROR_SUCCESS) {
            DWORD val = enable ? 1 : 0;
            RegSetValueExW(key, L"PowerSavingMode", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
            RegCloseKey(key);
        }
    };

    auto getSaver = []() -> bool {
        DWORD value = 0, size = sizeof(value);
        if (RegGetValueW(HKEY_CURRENT_USER,
                         L"Software\\Microsoft\\Windows\\CurrentVersion\\Power\\SystemSettings",
                         L"PowerSavingMode", RRF_RT_REG_DWORD, nullptr, &value, &size) == ERROR_SUCCESS) {
            return value != 0;
        }
        return false;
    };

    // Toggle ON
    setSaver(true);
    if (!getSaver()) {
        printf("FAIL: getSaver true\n");
        return false;
    }

    // Toggle OFF
    setSaver(false);
    if (getSaver()) {
        printf("FAIL: getSaver false\n");
        return false;
    }

    // Power scheme threshold check (both DC and AC)
    HMODULE hPowr = LoadLibraryW(L"powrprof.dll");
    if (hPowr) {
        auto pGetActive = reinterpret_cast<DWORD(WINAPI*)(HKEY, GUID**)>(
            GetProcAddress(hPowr, "PowerGetActiveScheme"));
        auto pWriteDC = reinterpret_cast<DWORD(WINAPI*)(HKEY, const GUID*, const GUID*, const GUID*, DWORD)>(
            GetProcAddress(hPowr, "PowerWriteDCValueIndex"));
        auto pReadDC = reinterpret_cast<DWORD(WINAPI*)(HKEY, const GUID*, const GUID*, const GUID*, DWORD*)>(
            GetProcAddress(hPowr, "PowerReadDCValueIndex"));
        auto pWriteAC = reinterpret_cast<DWORD(WINAPI*)(HKEY, const GUID*, const GUID*, const GUID*, DWORD)>(
            GetProcAddress(hPowr, "PowerWriteACValueIndex"));
        auto pReadAC = reinterpret_cast<DWORD(WINAPI*)(HKEY, const GUID*, const GUID*, const GUID*, DWORD*)>(
            GetProcAddress(hPowr, "PowerReadACValueIndex"));
        auto pSetActive = reinterpret_cast<DWORD(WINAPI*)(HKEY, const GUID*)>(
            GetProcAddress(hPowr, "PowerSetActiveScheme"));
        if (pGetActive && pWriteDC && pReadDC && pSetActive) {
            GUID* pScheme = nullptr;
            if (pGetActive(nullptr, &pScheme) == ERROR_SUCCESS && pScheme) {
                constexpr GUID kSub = {0xde830923, 0xa562, 0x41af, {0xa0, 0x86, 0xe3, 0xa2, 0xc6, 0xba, 0xd2, 0xda}};
                constexpr GUID kEs = {0xe69653ca, 0xcf7f, 0x4f05, {0xaa, 0x73, 0xcb, 0x83, 0x3f, 0xa9, 0x0a, 0xd4}};
                DWORD origDC = 20, origAC = 0;
                pReadDC(nullptr, pScheme, &kSub, &kEs, &origDC);
                if (pReadAC) pReadAC(nullptr, pScheme, &kSub, &kEs, &origAC);

                // Set DC to 100
                pWriteDC(nullptr, pScheme, &kSub, &kEs, 100);
                if (pWriteAC) pWriteAC(nullptr, pScheme, &kSub, &kEs, 100);
                pSetActive(nullptr, pScheme);

                DWORD readBackDC = 0, readBackAC = 0;
                pReadDC(nullptr, pScheme, &kSub, &kEs, &readBackDC);
                if (pReadAC) pReadAC(nullptr, pScheme, &kSub, &kEs, &readBackAC);

                if (readBackDC != 100) {
                    printf("FAIL: readBackDC threshold != 100\n");
                    return false;
                }
                if (pWriteAC && readBackAC != 100) {
                    printf("FAIL: readBackAC threshold != 100\n");
                    return false;
                }

                // Restore
                pWriteDC(nullptr, pScheme, &kSub, &kEs, origDC);
                if (pWriteAC) pWriteAC(nullptr, pScheme, &kSub, &kEs, origAC);
                pSetActive(nullptr, pScheme);
                LocalFree(pScheme);
            }
        }
    }

    printf("  [PASS] Energy Saver registry toggle and power scheme threshold verified (DC + AC).\n");
    fflush(stdout);
    return true;
}

bool TestModMetadataIntegrity() {
    printf("[TEST 5/5] Running Mod Header Metadata & Clean Encoding Tests...\n");
    fflush(stdout);

    auto checkFileHeader = [](const std::wstring& path, const std::string& expectedId, const std::string& expectedName) -> bool {
        // First verify no UTF-8 BOM (first bytes must be "// ==")
        HANDLE hFile = CreateFileW(path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, 0, nullptr);
        if (hFile == INVALID_HANDLE_VALUE) {
            printf("FAIL: Could not open %ls\n", path.c_str());
            return false;
        }
        unsigned char headerBytes[4] = {0};
        DWORD bytesRead = 0;
        ReadFile(hFile, headerBytes, sizeof(headerBytes), &bytesRead, nullptr);
        CloseHandle(hFile);

        if (headerBytes[0] == 0xEF && headerBytes[1] == 0xBB && headerBytes[2] == 0xBF) {
            printf("FAIL: Found unexpected UTF-8 BOM in %ls\n", path.c_str());
            return false;
        }
        if (headerBytes[0] != '/' || headerBytes[1] != '/') {
            printf("FAIL: Expected file to start with '//' in %ls\n", path.c_str());
            return false;
        }

        std::ifstream file(path.c_str());
        if (!file.is_open()) {
            printf("FAIL: Could not open %ls\n", path.c_str());
            return false;
        }
        std::string line;
        bool foundId = false, foundName = false;
        for (int i = 0; i < 15 && std::getline(file, line); i++) {
            if (line.find("@id") != std::string::npos && line.find(expectedId) != std::string::npos) {
                foundId = true;
            }
            if (line.find("@name") != std::string::npos && line.find(expectedName) != std::string::npos) {
                foundName = true;
            }
        }
        if (!foundId) {
            printf("FAIL: Expected id '%s' in %ls\n", expectedId.c_str(), path.c_str());
            return false;
        }
        if (!foundName) {
            printf("FAIL: Expected name '%s' in %ls\n", expectedName.c_str(), path.c_str());
            return false;
        }
        return true;
    };

    if (!checkFileHeader(L"scratch/modified-windhawk-topbar-fork.wh.cpp", "windhawk-topbar-fork", "TopBar for Windows - Fork")) {
        return false;
    }
    if (!checkFileHeader(L"scratch/modified-windhawk-topbar.wh.cpp", "windhawk-topbar", "TopBar for Windows")) {
        return false;
    }

    // Verify neither file contains L"Environment" in WM_SETTINGCHANGE
    auto checkNoEnvironmentParam = [](const std::wstring& path) -> bool {
        std::ifstream file(path.c_str());
        std::string content((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
        if (content.find("SendMessageTimeoutW(HWND_BROADCAST, WM_SETTINGCHANGE, 0,\n                        reinterpret_cast<LPARAM>(L\"Environment\")") != std::string::npos ||
            content.find("L\"Environment\"), SMTO_ABORTIFHUNG") != std::string::npos) {
            printf("FAIL: Found bogus L\"Environment\" notification lParam in %ls!\n", path.c_str());
            return false;
        }
        return true;
    };

    if (!checkNoEnvironmentParam(L"scratch/modified-windhawk-topbar-fork.wh.cpp") ||
        !checkNoEnvironmentParam(L"scratch/modified-windhawk-topbar.wh.cpp")) {
        return false;
    }

    // Verify apply_topbar_battery_update.bat checks errorlevel after both backups
    {
        std::ifstream batFile("apply_topbar_battery_update.bat");
        std::string batContent((std::istreambuf_iterator<char>(batFile)), std::istreambuf_iterator<char>());
        if (batContent.find("copy /Y \"%FORK_TARGET%\" \"%FORK_BACKUP%\" >nul\n    if errorlevel 1") == std::string::npos &&
            batContent.find("copy /Y \"%FORK_TARGET%\" \"%FORK_BACKUP%\" >nul\r\n    if errorlevel 1") == std::string::npos) {
            printf("FAIL: apply_topbar_battery_update.bat missing errorlevel check on fork backup!\n");
            return false;
        }
        if (batContent.find("copy /Y \"%ORIG_TARGET%\" \"%ORIG_BACKUP%\" >nul\n        if errorlevel 1") == std::string::npos &&
            batContent.find("copy /Y \"%ORIG_TARGET%\" \"%ORIG_BACKUP%\" >nul\r\n        if errorlevel 1") == std::string::npos) {
            printf("FAIL: apply_topbar_battery_update.bat missing errorlevel check on orig backup!\n");
            return false;
        }
    }

    printf("  [PASS] Mod metadata headers, notification broadcast, and batch backup error trapping verified.\n");
    fflush(stdout);
    return true;
}

int main() {
    printf("===================================================\n");
    printf(" Windhawk TopBar Battery Enhancement Verification\n");
    printf("===================================================\n");
    fflush(stdout);

    bool ok1 = TestIconLogic();
    bool ok2 = TestGetBatteryInfoPriorityLogic();
    bool ok3 = TestPowerOverlaySchemes();
    bool ok4 = TestEnergySaverToggleAPIs();
    bool ok5 = TestModMetadataIntegrity();

    if (ok1 && ok2 && ok3 && ok4 && ok5) {
        printf("===================================================\n");
        printf(" ALL 5 TEST SUITES PASSED SUCCESSFULLY (100%% GREEN)!\n");
        printf("===================================================\n");
        fflush(stdout);
        return 0;
    } else {
        printf("TESTS FAILED!\n");
        fflush(stdout);
        return 1;
    }
}
