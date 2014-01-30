private [
	"_spawnChance"
	,"_debug"
	,"_wait_time"
	
	,"_start_time"
	,"_spawnMarker"
	,"_spawnRadius"
	
	,"_unit_group_pool","_unit_sniper_pool","_unit_gunner_pool","_unit_combat_pool"
	
	,"_spawnRoll"
	,"_car"
	,"_position"
	,"_event_marker"
	,"_vehicle_car"
	,"_vehicle_box_position"
	,"_vehicle_box"
	
	,"_unit_group_count","_unit_sniper_count","_unit_gunner_count","_unit_combat_count"
	
	,"_unit_position"
	,"_unit"
	,"_unit_random_gear"
	
	,"_vehicle_waypoint"
	
	,"_state"
	,"_group_alivecount"
];
_spawnChance =  0.95; // Percentage chance of event happening
_debug = false; // Puts a marker exactly were the loot spawns
_wait_time = 2700; // 45min
_start_time = time;
_spawnMarker = 'center';
_spawnRadius = dayz_MapArea / 2;

// unit/group pool
_unit_group_pool = [];
_unit_sniper_pool = [
	[
		["M110_NVG_EP1",["20Rnd_762x51_B_SCAR","20Rnd_762x51_B_SCAR","20Rnd_762x51_B_SCAR","20Rnd_762x51_B_SCAR","20Rnd_762x51_B_SCAR","20Rnd_762x51_B_SCAR"]]
		,["VSS_Vintorez",["20Rnd_9x39_SP5_VSS","20Rnd_9x39_SP5_VSS","20Rnd_9x39_SP5_VSS","20Rnd_9x39_SP5_VSS","20Rnd_9x39_SP5_VSS","20Rnd_9x39_SP5_VSS"]]
		,["ksvk",["5Rnd_127x108_KSVK","5Rnd_127x108_KSVK","5Rnd_127x108_KSVK","5Rnd_127x108_KSVK","5Rnd_127x108_KSVK","5Rnd_127x108_KSVK","5Rnd_127x108_KSVK","5Rnd_127x108_KSVK","5Rnd_127x108_KSVK"]]
	]
	,[
		["M9",["15Rnd_9x19_M9","15Rnd_9x19_M9","15Rnd_9x19_M9"]]
		,["Colt1911",["7Rnd_45ACP_1911","7Rnd_45ACP_1911","7Rnd_45ACP_1911","7Rnd_45ACP_1911"]]
		,["revolver_EP1",["6Rnd_45ACP","6Rnd_45ACP","6Rnd_45ACP","6Rnd_45ACP"]]
		,["Makarov",["8Rnd_9x18_Makarov","8Rnd_9x18_Makarov","8Rnd_9x18_Makarov","8Rnd_9x18_Makarov"]]
	]
];
_unit_gunner_pool = [
	[
		["M60A4_EP1",["100Rnd_762x51_M240","100Rnd_762x51_M240","100Rnd_762x51_M240","100Rnd_762x51_M240","100Rnd_762x51_M240","100Rnd_762x51_M240"]]
		,["Pecheneg",["100Rnd_762x54_PK","100Rnd_762x54_PK","100Rnd_762x54_PK","100Rnd_762x54_PK","100Rnd_762x54_PK","100Rnd_762x54_PK"]]
		,["Mk_48_DES_EP1",["100Rnd_762x51_M240","100Rnd_762x51_M240","100Rnd_762x51_M240","100Rnd_762x51_M240","100Rnd_762x51_M240","100Rnd_762x51_M240"]]
	]
	,[
		["M9",["15Rnd_9x19_M9","15Rnd_9x19_M9","15Rnd_9x19_M9"]]
		,["Colt1911",["7Rnd_45ACP_1911","7Rnd_45ACP_1911","7Rnd_45ACP_1911","7Rnd_45ACP_1911"]]
		,["revolver_EP1",["6Rnd_45ACP","6Rnd_45ACP","6Rnd_45ACP","6Rnd_45ACP"]]
		,["Makarov",["8Rnd_9x18_Makarov","8Rnd_9x18_Makarov","8Rnd_9x18_Makarov","8Rnd_9x18_Makarov"]]
	]
];
_unit_combat_pool = [
	[
		["SCAR_H_CQC_CCO_SD",["20rnd_762x51_SB_SCAR","20rnd_762x51_SB_SCAR","20rnd_762x51_SB_SCAR","20rnd_762x51_SB_SCAR","20rnd_762x51_SB_SCAR","20rnd_762x51_SB_SCAR"]]
		,["M14_EP1",["20Rnd_762x51_DMR","20Rnd_762x51_DMR","20Rnd_762x51_DMR","20Rnd_762x51_DMR","20Rnd_762x51_DMR","20Rnd_762x51_DMR"]]
		,["Stinger",["Stinger","Stinger"]]
		,["MAAWS",["MAAWS_HEDP","MAAWS_HEDP","MAAWS_HEDP","MAAWS_HEDP"]]
	]
	,[
		["M9",["15Rnd_9x19_M9","15Rnd_9x19_M9","15Rnd_9x19_M9"]]
		,["Colt1911",["7Rnd_45ACP_1911","7Rnd_45ACP_1911","7Rnd_45ACP_1911","7Rnd_45ACP_1911"]]
		,["revolver_EP1",["6Rnd_45ACP","6Rnd_45ACP","6Rnd_45ACP","6Rnd_45ACP"]]
		,["Makarov",["8Rnd_9x18_Makarov","8Rnd_9x18_Makarov","8Rnd_9x18_Makarov","8Rnd_9x18_Makarov"]]
	]
];

if (isNil "EPOCH_EVENT_RUNNING_KIMT") then {
	EPOCH_EVENT_RUNNING_KIMT = false;
};

// Check for another event running
if (EPOCH_EVENT_RUNNING_KIMT) exitWith {
	diag_log("Event already running");
};

_spawnRoll = random 1;
if (_spawnRoll <= _spawnChance) then {
	EPOCH_EVENT_RUNNING_KIMT = true;
	
	_position = [(getMarkerPos _spawnMarker), 0, _spawnRadius, 10, 0, 2000, 0] call BIS_fnc_findSafePos;
	
	_event_marker = createMarker [(format ["loot_event_marker_%1", _start_time]), _position];
	_event_marker setMarkerType "Warning";
	_event_marker setMarkerBrush "Solid";
	_event_marker setMarkerText "@STR_M_KIMT_01";
	
	_vehicle_car = createVehicle ["UralOpen_INS", _position, [], 0, "CAN_COLLIDE"];
	_vehicle_car setDir round(random 360);
	_vehicle_car setPos _position;
	_vehicle_car setDamage 1;
	
	_vehicle_box_position = [(_position select 0) + 15, (_position select 1) + 15, 0];
	_vehicle_box = createVehicle ["LocalBasicAmmunitionBox", _vehicle_box_position, [], 0, "CAN_COLLIDE"];
	_vehicle_box setDir round(random 360);
	_vehicle_box setPos _vehicle_box_position;
	
	clearMagazineCargoGlobal _vehicle_box;
	clearWeaponCargoGlobal _vehicle_box;
	
	_spawnRoll = random 1;
	if (_spawnRoll <= 0.15) then { // Hard
		_vehicle_box addMagazineCargoGlobal ["ItemBriefcase10oz", (5 + round(random 3))];
		_vehicle_box addMagazineCargoGlobal ["ItemBriefcase50oz", (2 + round(random 1))];
		_vehicle_box addMagazineCargoGlobal ["ItemBriefcase100oz", (1 + round(random 3))];
		
		_vehicle_box addMagazineCargoGlobal ["ItemGoldBar", (5 + round(random 12))];
		_vehicle_box addMagazineCargoGlobal ["ItemGoldBar10oz", (1 + round(random 6))];

		_vehicle_box addMagazineCargoGlobal ["ItemSilverBar", (6 + round(random 26))];
		
		_unit_group_count = 5;
		_unit_sniper_count = [3,2];
		_unit_gunner_count = [7,3];
		_unit_combat_count = [10,5];
	}
	else {
		if (_spawnRoll <= 0.4) then { // Normal
			_vehicle_box addMagazineCargoGlobal ["ItemBriefcaseEmpty", round(random 2)];
			
			_vehicle_box addMagazineCargoGlobal ["ItemGoldBar", (5 + round(random 8))];
			_vehicle_box addMagazineCargoGlobal ["ItemGoldBar10oz", (2 + round(random 3))];

			_vehicle_box addMagazineCargoGlobal ["ItemSilverBar10oz", round(random 24)];
		
			_unit_group_count = 3;
			_unit_sniper_count = [2,1];
			_unit_gunner_count = [2,2];
			_unit_combat_count = [6,2];
		}
		else { // Easy
			_vehicle_box addMagazineCargoGlobal ["ItemBriefcaseEmpty", round(random 1)];
			
			_vehicle_box addMagazineCargoGlobal ["ItemGoldBar", (5 + round(random 5))];

			_vehicle_box addMagazineCargoGlobal ["ItemSilverBar10oz", round(random 12)];
			_vehicle_box addMagazineCargoGlobal ["ItemSilverBar", round(random 6)];
			
			_vehicle_box addMagazineCargoGlobal ["ItemTinBar", round(random 10)];
		
			_unit_group_count = 1;
			_unit_sniper_count = [1,1];
			_unit_gunner_count = [2,1];
			_unit_combat_count = [3,2];
		};
	};
	
	// create group
	for [{_x = 0}, {_x < _unit_group_count}, {_x = _x + 1}] do {
		_this = createGroup east; //non friendly
		_this setVariable ["SAR_protect",true]; //no cleanup
		_this setVariable ["Sarge",1]; //no cleanup
		
		_unit_group_pool = _unit_group_pool + [_this];
	};
	
	
	// create sniper unit
	for [{_x = 0}, {_x < ((_unit_sniper_count select 0) + random (_unit_sniper_count select 1))}, {_x = _x + 1}] do {
		_unit_position = [_position, 10, 50, 5, 0, 20, 0] call BIS_fnc_findSafePos;
		_unitCode = "removeAllWeapons _unit;";
		
		// choose primary weapon and ammo
		_unit_random_gear = (_unit_sniper_pool select 0) call BIS_fnc_selectRandom;
		_unitCode = _unitCode + (format ["_unit addWeapon '%1';", (_unit_random_gear select 0)]);
		{
			_unitCode = _unitCode + format ["_unit addMagazine '%1';", _x];
		} forEach (_unit_random_gear select 1);
		
		// choose second weapon and ammo
		_unit_random_gear = (_unit_sniper_pool select 1) call BIS_fnc_selectRandom;
		_unitCode = _unitCode + (format ["_unit addWeapon '%1';", (_unit_random_gear select 0)]);
		{
			_unitCode = _unitCode + format ["_unit addMagazine '%1';", _x];
		} forEach (_unit_random_gear select 1);
		
		if (HCConnected && !isNil "HCObject") then {
			missionNamespace setVariable ["HC_spawn_unit", [(_unit_group_pool select (_x mod _unit_group_count)), "USMC_SoldierS_SniperH", _unit_position, _unitCode]];
			(owner HCObject) publicVariableClient "HC_spawn_unit";
		}
		else {
			_unit = (_unit_group_pool select (_x mod _unit_group_count)) createUnit ["USMC_SoldierS_SniperH", _unit_position, [], 0, "FORM"];
			call (compile _unitCode);
			[_unit] joinSilent (_unit_group_pool select (_x mod _unit_group_count));
		};
	};
		
	// create gunner unit
	for [{_x = 0}, {_x < ((_unit_gunner_count select 0) + random (_unit_gunner_count select 1))}, {_x = _x + 1}] do {
		_unit_position = [_position, 10, 50, 5, 0, 20, 0] call BIS_fnc_findSafePos;
		_unitCode = "removeAllWeapons _unit;";
		
		// choose primary weapon and ammo
		_unit_random_gear = (_unit_gunner_pool select 0) call BIS_fnc_selectRandom;
		_unitCode = _unitCode + (format ["_unit addWeapon '%1';", (_unit_random_gear select 0)]);
		{
			_unitCode = _unitCode + format ["_unit addMagazine '%1';", _x];
		} forEach (_unit_random_gear select 1);
		
		// choose second weapon and ammo
		_unit_random_gear = (_unit_gunner_pool select 1) call BIS_fnc_selectRandom;
		_unitCode = _unitCode + (format ["_unit addWeapon '%1';", (_unit_random_gear select 0)]);
		{
			_unitCode = _unitCode + format ["_unit addMagazine '%1';", _x];
		} forEach (_unit_random_gear select 1);
		
		if (HCConnected && !isNil "HCObject") then {
			missionNamespace setVariable ["HC_spawn_unit", [(_unit_group_pool select (_x mod _unit_group_count)), "USMC_Soldier_MG", _unit_position, _unitCode]];
			(owner HCObject) publicVariableClient "HC_spawn_unit";
		}
		else {
			_unit = (_unit_group_pool select (_x mod _unit_group_count)) createUnit ["USMC_Soldier_MG", _unit_position, [], 0, "FORM"];
			call (compile _unitCode);
			[_unit] joinSilent (_unit_group_pool select (_x mod _unit_group_count));
		};
	};
	
	// create combat unit
	for [{_x = 0}, {_x < ((_unit_combat_count select 0) + random (_unit_combat_count select 1))}, {_x = _x + 1}] do {
		_unit_position = [_position, 10, 50, 5, 0, 20, 0] call BIS_fnc_findSafePos;
		_unitCode = "removeAllWeapons _unit;";
		
		// choose primary weapon and ammo
		_unit_random_gear = (_unit_combat_pool select 0) call BIS_fnc_selectRandom;
		_unitCode = _unitCode + (format ["_unit addWeapon '%1';", (_unit_random_gear select 0)]);
		{
			_unitCode = _unitCode + format ["_unit addMagazine '%1';", _x];
		} forEach (_unit_random_gear select 1);
		
		// choose second weapon and ammo
		_unit_random_gear = (_unit_combat_pool select 1) call BIS_fnc_selectRandom;
		_unitCode = _unitCode + (format ["_unit addWeapon '%1';", (_unit_random_gear select 0)]);
		{
			_unitCode = _unitCode + format ["_unit addMagazine '%1';", _x];
		} forEach (_unit_random_gear select 1);
		
		if (HCConnected && !isNil "HCObject") then {
			missionNamespace setVariable ["HC_spawn_unit", [(_unit_group_pool select (_x mod _unit_group_count)), "USMC_Soldier_TL", _unit_position, _unitCode]];
			(owner HCObject) publicVariableClient "HC_spawn_unit";
		}
		else {
			_unit = (_unit_group_pool select (_x mod _unit_group_count)) createUnit ["USMC_Soldier_TL", _unit_position, [], 0, "FORM"];
			call (compile _unitCode);
			[_unit] joinSilent (_unit_group_pool select (_x mod _unit_group_count));
		};
	};
	
	sleep 2; // w8 for creating units
	
	{
		{
			_x enableAI "TARGET";
			_x enableAI "AUTOTARGET";
			_x enableAI "MOVE";
			_x enableAI "ANIM";
			_x enableAI "FSM";
			_x allowDammage true;
		 
			_x setCombatMode "RED";
			_x setBehaviour "COMBAT";
			
			_x setSkill ["aimingAccuracy", 0.5];
			_x setSkill ["aimingShake", 0.4];
			_x setSkill ["aimingSpeed", 0.6];
			_x setSkill ["endurance", 1];
			_x setSkill ["spotDistance", 1];
			_x setSkill ["spotTime", 0.9];
			_x setSkill ["courage", 1];
			_x setSkill ["reloadSpeed", 0.2];
			_x setSkill ["commanding", 1];
			_x setSkill ["general", 0.9];
			
			_x addEventHandler ['killed', {
				removeAllWeapons (_this select 0);
				removeAllItems (_this select 0);
			}];
		} forEach (units _x);
	} forEach (_unit_group_pool);
	
	// select group leader and set skill
	{
		_x selectLeader ((units _x) select 0);
		((units _x) select 0) setSkill ["aimingAccuracy", 1];
		((units _x) select 0) setSkill ["aimingShake", 1];
		((units _x) select 0) setSkill ["aimingSpeed", 1];
		((units _x) select 0) setSkill ["endurance", 1];
		((units _x) select 0) setSkill ["spotDistance", 1];
		((units _x) select 0) setSkill ["spotTime", 1];
		((units _x) select 0) setSkill ["courage", 1];
		((units _x) select 0) setSkill ["reloadSpeed", 1];
		((units _x) select 0) setSkill ["commanding", 1];
		((units _x) select 0) setSkill ["general", 1];
	} forEach (_unit_group_pool);
	
	// show message
	missionNamespace setVariable ["PVDZE_MIS_KIMT", ["STARTUP"]];
	publicVariable "PVDZE_MIS_KIMT";
	
	// wait loop
	while {isNil "_state"} do {
		// units dead, success
		_group_alivecount = 0;
		{
			{
				if (alive _x) then {
					_group_alivecount = _group_alivecount + 1;
				};
			} forEach (units _x);
		} forEach (_unit_group_pool);
		if (_group_alivecount == 0) then {
			_state = "complete";
		};
	
		// timeout, fail
		if ((_start_time + _wait_time) <= time) then {
			_state = "timeout";
		};
		
		sleep 1;
	};
	
	deleteMarker _event_marker;
	EPOCH_EVENT_RUNNING_KIMT = false;
	
	if (_state == "timeout") then {
		{
			{
				deleteVehicle _x;
			} forEach (units _x);
			deleteGroup _x;
		} forEach (_unit_group_pool);
		deleteVehicle _vehicle_box;
		missionNamespace setVariable ["PVDZE_MIS_KIMT", ["TIMEOUT"]];
		publicVariable "PVDZE_MIS_KIMT";
	};
	if (_state == "complete") then {
		{
			deleteGroup _x;
		} forEach (_unit_group_pool);
		missionNamespace setVariable ["PVDZE_MIS_KIMT", ["COMPLETE"]];
		publicVariable "PVDZE_MIS_KIMT";
	}
};