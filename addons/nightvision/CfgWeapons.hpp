class CfgWeapons {
    class Binocular;
    class NVGoggles: Binocular {
        displayName = CSTRING(NVG_Gen3_brown);
    };
    class NVGoggles_OPFOR: NVGoggles {
        displayName = CSTRING(NVG_Gen3_black);
    };
    class NVGoggles_INDEP: NVGoggles {
        displayName = CSTRING(NVG_Gen3_green);
    };
    class ACE_NVG_Gen1: NVGoggles_OPFOR {
        author = ECSTRING(common,ACETeam);
        displayName = CSTRING(NVG_Gen1);
    };
    class ACE_NVG_Gen2: NVGoggles_INDEP {
        author = ECSTRING(common,ACETeam);
        displayName = CSTRING(NVG_Gen2);
    };
    class ACE_NVG_Gen4: NVGoggles {
        author = ECSTRING(common,ACETeam);
        displayName = CSTRING(NVG_Gen4);
    };
    class ACE_NVG_Wide: NVGoggles {
        author = ECSTRING(common,ACETeam);
        modelOptics = QPATHTOF(models\ACE_nvg_wide_optics);
        displayName = CSTRING(NVG_FullScreen);
    };


    class ACE_NVG_Biocular: NVGoggles {
        scope = 1;
        author = ECSTRING(common,ACETeam);
        displayName = CSTRING(NVG_Gen1);
        modelOptics = "";
        GVAR(border) = QPATHTOF(data\nvg_mask_4096.paa);
        GVAR(bluRadius) = 0.13;
        GVAR(eyeCups) = 1;
    };
    class ACE_NVG_Monocular: NVGoggles {
        scope = 1;
        modelOptics = "";
        author = ECSTRING(common,ACETeam);
        descriptionShort = "Monocular nightvision goggles";
        displayName = "NV Goggles (Mono)";
        GVAR(border) = QPATHTOF(data\nvg_mask_4096.paa);
        GVAR(bluRadius) = 0.13;
    };
    class ACE_NVG_Binocular: NVGoggles {
        scope = 1;
        modelOptics = "";
        author = ECSTRING(common,ACETeam);
        descriptionShort = "Binocular nightvision goggles";
        displayName = "NV Goggles (Bino)";
        GVAR(border) = QPATHTOF(data\nvg_mask_binos_4096.paa);
        GVAR(bluRadius) = 0.15;
    };
    class ACE_NVG_Quadocular: NVGoggles {
        scope = 1;
        modelOptics = "";
        author = ECSTRING(common,ACETeam);
        descriptionShort = "Quadocular nightvision goggles";
        displayName = "NV Goggles (Quad)";
        GVAR(border) = QPATHTOF(data\nvg_mask_quad_4096.paa);
        GVAR(bluRadius) = 0.26;
    };
};
