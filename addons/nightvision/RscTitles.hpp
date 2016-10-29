class RscPicture;

class RscTitles {
    class GVAR(title) {
        idd = 10777;
        movingEnable = 1;
        enableSimulation = 1;
        enableDisplay = 1;

        onLoad = QUOTE(with uiNamespace do {GVAR(titleDisplay) = _this select 0};);
        onunLoad = "";

        duration = 999999;
        fadein = 0;
        fadeout = 0;

        class controls {
            class Hexes: RscPicture {
                idc = 1000; 
            };
            class Mask: RscPicture {
                idc = 1001;
            };
        };
    };
};
