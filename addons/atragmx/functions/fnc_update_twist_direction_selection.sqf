/*
 * Author: Ruthberg
 * Updates the twist direction input selectors
 *
 * Arguments:
 * Nothing
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * call ace_atragmx_fnc_update_target_selection
 *
 * Public: No
 */
#include "script_component.hpp"

#define __dsp (uiNamespace getVariable "ATragMX_Display")

private _rifleTwist = GVAR(workingMemory) select 14;

if (_rifleTwist > 0) then {
    (__dsp displayCtrl 120041) ctrlEnable false;
    (__dsp displayCtrl 120042) ctrlEnable true;
} else {
    (__dsp displayCtrl 120041) ctrlEnable true;
    (__dsp displayCtrl 120042) ctrlEnable false;
};
