/*
 * Author: Dslyecxi, PabstMirror
 * Pfeh to handle refreshing effects.
 * Updates ui scale on every frame, effects are updated less often.
 *
 * Arguments:
 * 1: PFEH ID <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [[], 1] call ace_nightvision_fnc_pfeh
 *
 * Public: No
 */
#include "script_component.hpp"

if ((currentVisionMode ACE_player) != 1) exitWith {
    GVAR(running) = false;
    [false] call FUNC(setupDisplayEffects);
    [GVAR(PFID)] call CBA_fnc_removePerFrameHandler;
    GVAR(PFID) = -1;
};
if (EGVAR(common,OldIsCamera)) exitWith {
    if (GVAR(running)) then {
        TRACE_2("pausing NVG for scripted camera",alive ACE_player,EGVAR(common,OldIsCamera));
        GVAR(running) = false;
        [false] call FUNC(setupDisplayEffects);
    };
};
if (!GVAR(running)) then {
    TRACE_1("Un-Pausing",GVAR(paused));
    GVAR(running) = true;
    [true] call FUNC(setupDisplayEffects);
    [] call FUNC(refreshGoggleType);
};


// Scale Border / Hex
private _scale = (call FUNC(kkTrueZoom)) * 3.00001;
[(uiNamespace getVariable QGVAR(titleDisplay)) displayCtrl 1000, GVAR(defaultPositionHex), _scale] call FUNC(scaleCtrl);
[(uiNamespace getVariable QGVAR(titleDisplay)) displayCtrl 1001, GVAR(defaultPositionBorder), _scale] call FUNC(scaleCtrl);
// Fade out hexes with high zoom (optics are doing the magnifying, not the player "focusing in")
((uiNamespace getVariable QGVAR(titleDisplay)) displayCtrl 1000) ctrlSetFade (linearConversion [4, 6, _scale, 0.2, 1, true]);

// Redo full effects less often
if (CBA_missionTime < GVAR(nextEffectsUpdate)) then {
    // Update radial blur as it depends on zoom level, so should be changed each frame like the border/hex
    if (GVAR(ppeffectRadialBlur) != -1) then {
        GVAR(ppeffectRadialBlur) ppEffectAdjust [.005, .005, _scale * GVAR(hmdBlurRadius), _scale * .16];
        GVAR(ppeffectRadialBlur) ppEffectCommit 0;
    };
    // Need to rapidly update fog or it will try to resync from the server
    if (missionNamespace getVariable [QGVAR(enableChangingFog), true]) then {
        0 setFog GVAR(nvgFog)
    };
} else {
    GVAR(nextEffectsUpdate) = CBA_missionTime + 1;

    // Detecting the efficiency of the nightvision. TODO, break this into its own thing that runs less frequently. Doing it this way just to expedite for testing.
    private _overcastMod = overcast * .8;
    private _rainMod = rain * .5;
    private _efficiencyLevel = 0.0; // Gen3. Gen2 could be .4, Gen1 .8
    private _lightFinal = 0 max (moonIntensity - (_overcastMod min .275) - _rainMod + _efficiencyLevel);
    private _aceAmbient = [] call EFUNC(common,ambientBrightness);
    // This has become a little weird. Basically means that lightfinal is unlikely to reach zero with any moon in the sky, buuut it just so happens that setting it like this means that the lighting progression from clear -> cloudy -> rainy works particularly well.

    // TODO: Less of a flash issue when efficiency is high
    private _grainFinal = linearConversion [1,0,_lightFinal,st_nvg_Grain_Min,st_nvg_Grain_Max,true];
    private _blurFinal = linearConversion [1,0,_lightFinal,st_nvg_Blur_Min,st_nvg_Blur_Max,true];
    private _brightFinal = linearConversion [0,1,_lightFinal,st_nvg_Bright_Min,st_nvg_Bright_Max,true];
    private _contrastFinal = linearConversion [0,1,_lightFinal,st_nvg_Contrast_Min,st_nvg_Contrast_Max,true];
    private _grainIntensityFinal = linearConversion [1,0,_lightFinal,st_nvg_NoiseIntensity_Min,st_nvg_NoiseIntensity_Max,true];
    private _noiseSharpnessFinal = linearConversion [1,0,_lightFinal,st_nvg_NoiseSharpness_Min,st_nvg_NoiseSharpness_Max,true];

    private _playerBrightSetting = ACE_player getVariable [QGVAR(NVGBrightness), 0];
    _brightFinal = _brightFinal + (_playerBrightSetting / 20);
    
    private _fogApply = linearConversion [0,1,_lightFinal,st_nvg_MaxFog,st_nvg_MinFog,true];

    // Modify blur if looking down scope
    if ((cameraView == "GUNNER") && {[ACE_player] call CBA_fnc_canUseWeapon}) then {
        if (currentWeapon ACE_player == primaryWeapon ACE_player) exitWith {_blurFinal = _blurFinal * st_nvg_CameraBlurSights_MaxBlur}; // Rifles are bad (impossible)
        if (currentWeapon ACE_player == handgunWeapon ACE_player) exitWith {_blurFinal = _blurFinal * ((st_nvg_CameraBlurSights_MaxBlur / 3) max 1)}; // Pistols aren't so bad
    };

    // Setup all effects
    // This is hacky but... works. This prevents the effects from being cancelled by various things - alt-tabbing, resizing, going into AT sights, etc. A nicer method would be welcome but I don't have time to spend on it. TODO.

    // FilmGrain - Electronic Noise
    // Params: [intensity(0..1), sharpness(0..20), grainsize(1..8), intensityX0, intensityX1, monochromatic(bool)]
    GVAR(ppeffectGrain) = ppEffectCreate ["FilmGrain", 200];
    GVAR(ppeffectGrain) ppEffectAdjust [_grainIntensityFinal, _noiseSharpnessFinal, _grainFinal, 0.3, 0.3];
    // OldNVG:  [0.25, 2.5, 2.5, _grainSetting, _grainSetting, false]
    GVAR(ppeffectGrain) ppEffectCommit 0;
    GVAR(ppeffectGrain) ppEffectForceInNVG true;
    GVAR(ppeffectGrain) ppEffectEnable true;


    // RadialBlur - Blurs closer to the edge nvg border (radius based on GVAR(bluRadius) config; e.g. larger for quadtube)
    // Note: "Will not do anything if RADIAL BLUR is disabled in Video Options." - So should try to keep this effect to a minimum to prevent balance issues
    // Params: [powerX, powerY, offsetX, offsetY]
    if (GVAR(hmdBlurRadius) != -1) then {
        GVAR(ppeffectRadialBlur) = ppEffectCreate ["RadialBlur", 451];
        GVAR(ppeffectRadialBlur) ppEffectAdjust [.004, .004, _scale * GVAR(hmdBlurRadius), _scale * .16];
        GVAR(ppeffectRadialBlur) ppEffectCommit 0;
        GVAR(ppeffectRadialBlur) ppEffectForceInNVG true;
        GVAR(ppeffectRadialBlur) ppEffectEnable true;
    };

    // ColorCorrections - Changes brightness, contrast and "green" color of nvg
    // Params: [brightness(0..2), contrast(0..inf),offset(-x..+x), blendArray, colorizeArray, weightArray]
    GVAR(ppeffectColorCorrect) = ppEffectCreate ["ColorCorrections", 2003];
    GVAR(ppeffectColorCorrect) ppEffectAdjust [_brightFinal, _contrastFinal, 0, [0.0, 0.0, 0.0, 0.0], [1.3, 1.2, 0.0, 0.9], [6, 1, 1, 0.0]];
    GVAR(ppeffectColorCorrect) ppEffectCommit 0;
    GVAR(ppeffectColorCorrect) ppEffectForceInNVG true;
    GVAR(ppeffectColorCorrect) ppEffectEnable true;


    // DynamicBlur - Increases overall screen blur when aiming down sights (which would be hard/impossible with NVG)
    // Params: [value(0..inf)]
    GVAR(ppeffectBlur) = ppEffectCreate ["DynamicBlur", 190];
    GVAR(ppeffectBlur) ppEffectAdjust [_blurFinal];
    GVAR(ppeffectBlur) ppEffectCommit 0;
    GVAR(ppeffectBlur) ppEffectForceInNVG true;
    GVAR(ppeffectBlur) ppEffectEnable true;

    // Modify local fog:
    if (missionNamespace getVariable [QGVAR(enableChangingFog), true]) then {
        if ((vehicle ACE_player) != ACE_player) then {  // For flying in particular, can refine nicer later.
            _fogApply = _fogApply * st_nvg_AirFogMultiplier
        };
        GVAR(nvgFog) = [_fogApply, 0, 0];
        0 setFog GVAR(nvgFog)
    };

    hintSilent format ["Time %1\nLight: %2\nACE Ambient: %3\nBrightness: %4\nContrast: %5\nGrain: %6\nBlur: %7\nFog: %8",time,_lightFinal,_aceAmbient,_brightFinal,_contrastFinal,[_grainIntensityFinal, _noiseSharpnessFinal, _grainFinal], _blurFinal, _fogApply];
};
