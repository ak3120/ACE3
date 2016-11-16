/*
 * Author: Ruthberg
 * Changes the twist direction
 *
 * Arguments:
 * twist direction <NUMBER>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * -1 call ace_atragmx_fnc_change_twist_direction
 *
 * Public: No
 */
#include "script_component.hpp"

private _rifleTwist = abs(GVAR(workingMemory) select 14);

if (_this > 0) then {
    GVAR(workingMemory) set [14, +_rifleTwist];
} else {
    GVAR(workingMemory) set [14, -_rifleTwist];
};

call FUNC(update_twist_direction_selection);
