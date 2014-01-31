private [
	"_spawnChance"
	,"_debug"
	,"_wait_time"
	
	,"_start_time"
	,"_spawnMarker"
	,"_spawnRadius"
	
	,"_unit_sniper_pool"
	,"_unit_gunner_pool"
	,"_unit_combat_pool"
	,"_car_pool"
	
	,"_spawnRoll"
	,"_car"
	,"_position"
	,"_event_marker"
	,"_vehicle"
	
	,"_car_group"
	,"_unit_position"
	,"_unit"
	,"_unit_random_gear"
	
	,"_state"
];

_spawnChance =  0.35; // Percentage chance of event happening
_debug = true; // Puts a marker exactly were the loot spawns
_wait_time = 1800;

// Dont mess with theses unless you know what yours doing
_start_time = time;
_spawnMarker = 'center';
_spawnRadius = (HeliCrashArea/2);

// Random loot lists
_unit_sniper_pool = [
	[
		["M24",["5Rnd_762x51_M24","5Rnd_762x51_M24","5Rnd_762x51_M24","5Rnd_762x51_M24","5Rnd_762x51_M24","5Rnd_762x51_M24"]]
		,["SVD",["10Rnd_762x54_SVD","10Rnd_762x54_SVD","10Rnd_762x54_SVD"]]
		,["m8_sharpshooter",["30Rnd_556x45_Stanag","30Rnd_556x45_Stanag","30Rnd_556x45_Stanag"]]
	]
	,[
		["M9",["15Rnd_9x19_M9","15Rnd_9x19_M9","15Rnd_9x19_M9"]]
		,["Colt1911",["7Rnd_45ACP_1911","7Rnd_45ACP_1911","7Rnd_45ACP_1911","7Rnd_45ACP_1911"]]
		,["revolver_EP1",["6Rnd_45ACP","6Rnd_45ACP","6Rnd_45ACP","6Rnd_45ACP"]]
		,["Makarov",["8Rnd_9x18_Makarov","8Rnd_9x18_Makarov","8Rnd_9x18_Makarov","8Rnd_9x18_Makarov"]]
	]
	,[]
	,[]
	,["ItemBandage","ItemBandage"]
];
_unit_gunner_pool = [
	[
		["RPK_74",["75Rnd_545x39_RPK","75Rnd_545x39_RPK","75Rnd_545x39_RPK","75Rnd_545x39_RPK"]]
		,["M249_DZ",["100Rnd_556x45_M249","100Rnd_556x45_M249","100Rnd_556x45_M249"]]
		,["M240_DZ",["100Rnd_762x51_M240","100Rnd_762x51_M240","100Rnd_762x51_M240"]]
	]
	,[
		["M9",["15Rnd_9x19_M9","15Rnd_9x19_M9","15Rnd_9x19_M9"]]
		,["Colt1911",["7Rnd_45ACP_1911","7Rnd_45ACP_1911","7Rnd_45ACP_1911","7Rnd_45ACP_1911"]]
		,["revolver_EP1",["6Rnd_45ACP","6Rnd_45ACP","6Rnd_45ACP","6Rnd_45ACP"]]
		,["Makarov",["8Rnd_9x18_Makarov","8Rnd_9x18_Makarov","8Rnd_9x18_Makarov","8Rnd_9x18_Makarov"]]
	]
	,[nil,"DZ_British_ACU"]
	,["ItemGPS"]
	,["ItemBandage","ItemBandage"]
];
_unit_combat_pool = [
	[
		["m8_compact",["30Rnd_556x45_Stanag","30Rnd_556x45_Stanag","30Rnd_556x45_Stanag","30Rnd_556x45_Stanag"]]
		,["Saiga12K",["8Rnd_B_Saiga12_74Slug","8Rnd_B_Saiga12_74Slug","8Rnd_B_Saiga12_74Slug","8Rnd_B_Saiga12_74Slug"]]
		,["M16A2",["30Rnd_556x45_Stanag","30Rnd_556x45_Stanag","30Rnd_556x45_Stanag","30Rnd_556x45_Stanag"]]
		,["G36C",["30Rnd_556x45_G36","30Rnd_556x45_G36","30Rnd_556x45_G36","30Rnd_556x45_G36"]]
	]
	,[
		["M9",["15Rnd_9x19_M9","15Rnd_9x19_M9","15Rnd_9x19_M9"]]
		,["Colt1911",["7Rnd_45ACP_1911","7Rnd_45ACP_1911","7Rnd_45ACP_1911","7Rnd_45ACP_1911"]]
		,["revolver_EP1",["6Rnd_45ACP","6Rnd_45ACP","6Rnd_45ACP","6Rnd_45ACP"]]
		,["Makarov",["8Rnd_9x18_Makarov","8Rnd_9x18_Makarov","8Rnd_9x18_Makarov","8Rnd_9x18_Makarov"]]
	]
	,["CZ_VestPouch_EP1"]
	,[]
	,["ItemBandage","ItemBandage"]
];
_car_pool = [
	["Ural_CDF",[4,4,8],"MilitarySpecial"]
	,["V3S_Open_TK_EP1",[4,4,6],"MilitarySpecial"]
	,["Kamaz",[2,2,6],"MilitarySpecial"]
	,["HMMWV_DES_EP1",[2,2,4],"Military"]
	,["HMMWV_M1035_DES_EP1",[2,2,4],"Military"]
	,["HMMWV_Ambulance_CZ_DES_EP1",[2,2,4],"Military"]
];

if (isNil "EPOCH_EVENT_RUNNING_KIIT") then {
	EPOCH_EVENT_RUNNING_KIIT = false;
};

// Check for another event running
if (EPOCH_EVENT_RUNNING_KIIT) exitWith {
	diag_log("Event already running");
};

_spawnRoll = random 1;
if (_spawnRoll <= _spawnChance) then {
	EPOCH_EVENT_RUNNING_KIIT = true;
	
	_car = _car_pool call BIS_fnc_selectRandom;
	_position = [(getMarkerPos _spawnMarker), 0, _spawnRadius, 10, 0, 2000, 0] call BIS_fnc_findSafePos;
	
	_event_marker = createMarker [(format ["loot_event_marker_%1", _start_time]), _position];
	_event_marker setMarkerType "Destroy";
	_event_marker setMarkerBrush "Solid";
	_event_marker setMarkerText "@STR_M_KIIT_01";
	
	_vehicle = createVehicle [(_car select 0), _position, [], 0, "CAN_COLLIDE"];
	_vehicle setDir round(random 360);
	_vehicle setPos _position;
	[_vehicle, [(getDir _vehicle), (getPos _vehicle)], (_car select 0), true, "0"] call server_publishVeh;
	
	clearMagazineCargoGlobal _vehicle;
	clearWeaponCargoGlobal _vehicle;
	
	// create vehicle loot
	_vehicle addWeaponCargoGlobal ["MAAWS", 1];
	_vehicle addWeaponCargoGlobal ["MakarovSD", 1];

	_vehicle addMagazineCargoGlobal ["8Rnd_9x18_MakarovSD", 4];

	_vehicle addWeaponCargoGlobal ["SCAR_L_CQC_EGLM_Holo", 1];
	_vehicle addWeaponCargoGlobal ["SCAR_H_LNG_Sniper", 1];
	_vehicle addWeaponCargoGlobal ["SCAR_H_CQC_CCO", 1];

	_vehicle addMagazineCargoGlobal ["30Rnd_556x45_Stanag", 10];
	_vehicle addMagazineCargoGlobal ["30Rnd_556x45_StanagSD", 10];
	_vehicle addMagazineCargoGlobal ["20Rnd_762x51_B_SCAR", 10];

	_vehicle addMagazineCargoGlobal ["1Rnd_SmokeRed_M203", 10];
	_vehicle addMagazineCargoGlobal ["1Rnd_SmokeGreen_M203", 10];
	_vehicle addMagazineCargoGlobal ["1Rnd_Smoke_M203", 10];

	// create group
	_car_group = createGroup east; //non friendly
	_car_group setVariable ["Sarge",1]; //no cleanup
	//_car_group allowfleeing 0;
	
	// create sniper unit
	for [{_x = 0}, {_x < ((_car select 1) select 0)}, {_x = _x + 1}] do {
		_unit_position = [_position, 10, 50, 5, 0, 20, 0] call BIS_fnc_findSafePos;
		_unit = _car_group createUnit ["USMC_SoldierS_SniperH", _unit_position, [], 0, "FORM"];
		_unit setSkill 1;
		_unit setUnitAbility 1;
		removeAllWeapons _unit;
		removeAllItems _unit;
		
		// choose primary weapon and ammo
		_unit_random_gear = (_unit_sniper_pool select 0) call BIS_fnc_selectRandom;
		_unit addWeapon (_unit_random_gear select 0);
		{
			_unit addMagazine _x;
		} forEach (_unit_random_gear select 1);
		
		// choose second weapon and ammo
		_unit_random_gear = (_unit_sniper_pool select 1) call BIS_fnc_selectRandom;
		_unit addWeapon (_unit_random_gear select 0);
		{
			_unit addMagazine _x;
		} forEach (_unit_random_gear select 1);
		
		// add backpack
		//_unit addBackpack (_unit_sniper_pool select 2);
		
		// add item
		//{
		//	_unit addItem _x;
		//	_unit assignItem _x;
		//} forEach (_unit_sniper_pool select 3);
		
		// add magazine
		{
			_unit addMagazine _x;
		} forEach (_unit_sniper_pool select 4);
		
		if (count (units _car_group) == 1) then {
			_car_group selectLeader _unit;
		};
		
		[_unit] joinSilent _car_group;
	};
		
	// create gunner unit
	for [{_x = 0}, {_x < ((_car select 1) select 1)}, {_x = _x + 1}] do {
		_unit_position = [_position, 10, 50, 5, 0, 20, 0] call BIS_fnc_findSafePos;
		_unit = _car_group createUnit ["USMC_Soldier_MG", _unit_position, [], 0, "FORM"];
		_unit setSkill 1;
		_unit setUnitAbility 1;
		removeAllWeapons _unit;
		removeAllItems _unit;
		
		// choose primary weapon and ammo
		_unit_random_gear = (_unit_gunner_pool select 0) call BIS_fnc_selectRandom;
		_unit addWeapon (_unit_random_gear select 0);
		{
			_unit addMagazine _x;
		} forEach (_unit_random_gear select 1);
		
		// choose second weapon and ammo
		_unit_random_gear = (_unit_gunner_pool select 1) call BIS_fnc_selectRandom;
		_unit addWeapon (_unit_random_gear select 0);
		{
			_unit addMagazine _x;
		} forEach (_unit_random_gear select 1);
		
		// add backpack
		//_unit addBackpack (_unit_gunner_pool select 2);
		
		// add item
		//{
		//	_unit addItem _x;
		//	_unit assignItem _x;
		//} forEach (_unit_gunner_pool select 3);
		
		// add magazine
		{
			_unit addMagazine _x;
		} forEach (_unit_gunner_pool select 4);
		
		if (count (units _car_group) == 1) then {
			_car_group selectLeader _unit;
		};
		
		[_unit] joinSilent _car_group;
	};
	
	// create combat unit
	for [{_x = 0}, {_x < ((_car select 1) select 2)}, {_x = _x + 1}] do {
		_unit_position = [_position, 10, 50, 5, 0, 20, 0] call BIS_fnc_findSafePos;
		_unit = _car_group createUnit ["USMC_Soldier_TL", _unit_position, [], 0, "FORM"];
		_unit setSkill 1;
		_unit setUnitAbility 1;
		removeAllWeapons _unit;
		removeAllItems _unit;
		
		// choose primary weapon and ammo
		_unit_random_gear = (_unit_combat_pool select 0) call BIS_fnc_selectRandom;
		_unit addWeapon (_unit_random_gear select 0);
		{
			_unit addMagazine _x;
		} forEach (_unit_random_gear select 1);
		
		// choose second weapon and ammo
		_unit_random_gear = (_unit_combat_pool select 1) call BIS_fnc_selectRandom;
		_unit addWeapon (_unit_random_gear select 0);
		{
			_unit addMagazine _x;
		} forEach (_unit_random_gear select 1);
		
		// add backpack
		//_unit addBackpack (_unit_combat_pool select 2);
		
		// add item
		//{
		//	_unit addItem _x;
		//	_unit assignItem _x;
		//} forEach (_unit_combat_pool select 3);
		
		// add magazine
		{
			_unit addMagazine _x;
		} forEach (_unit_combat_pool select 4);
		
		if (count (units _car_group) == 1) then {
			_car_group selectLeader _unit;
		};
		
		[_unit] joinSilent _car_group;
	};
	
	{
		_x setSkill ["aimingspeed", 1];
		_x setSkill ["spotdistance", 1];
		_x setSkill ["aimingaccuracy", 1];
		_x setSkill ["aimingshake", 1];
		_x setSkill ["spottime", 1];
		_x setSkill ["spotdistance", 1];
		_x setSkill ["commanding", 1];
		_x setSkill ["general", 1];
	} forEach (units _car_group); 
	
	// show message
	missionNamespace setVariable ["PVDZE_MIS_KIIT", ["STARTUP", (_car select 0)]];
	publicVariable "PVDZE_MIS_KIIT";
	
	// wait loop
	while {isNil "_state"} do {
	
		// car destroyed, failed
		if (not alive _vehicle) then {
			_state = "destroyed";
		};
		
		// units dead, success
		_car_group_alivecount = 0;
		{
			if (alive _x) then {
				_car_group_alivecount = _car_group_alivecount + 1;
			};
		} forEach (units _car_group);
		if (_car_group_alivecount == 0) then {
			_state = "complete";
		};
	
		// timeout, fail
		if ((_start_time + _wait_time) <= time) then {
			_state = "timeout";
		};
		
		sleep 2;
	};
	
	if (_state == "timeout") then {
		{
			deleteVehicle _x;
		} forEach (units _car_group);
		deleteGroup _car_group;
		_vehicle setDamage 1;
		sleep 1;
		missionNamespace setVariable ["PVDZE_MIS_KIIT", ["TIMEOUT", (_car select 0)]];
		publicVariable "PVDZE_MIS_KIIT";
	};
	if (_state == "destroyed") then {
		{
			deleteVehicle _x;
		} forEach (units _car_group);
		deleteGroup _car_group;
		missionNamespace setVariable ["PVDZE_MIS_KIIT", ["DESTROYED", (_car select 0)]];
		publicVariable "PVDZE_MIS_KIIT";
	};
	if (_state == "complete") then {
		missionNamespace setVariable ["PVDZE_MIS_KIIT", ["COMPLETE", (_car select 0)]];
		publicVariable "PVDZE_MIS_KIIT";
	};
	
	deleteMarker _event_marker;
	EPOCH_EVENT_RUNNING_KIIT = false;
};