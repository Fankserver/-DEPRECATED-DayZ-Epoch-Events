private [
	"_spawnChance"
	,"_markerRadius"
	,"_debug"
	,"_wait_time"
	
	,"_start_time"
	,"_spawnMarker"
	,"_spawnRadius"
	
	,"_loot_lists"
	
	,"_spawnRoll"
	,"_position_plane"
	,"_position_marker"
	,"_position_supplyBox"
	,"_dir_planeToSupplyBox"
	,"_tmp_x"
	,"_tmp_y"
	,"_supplyBoxModel"
	,"_position"
	,"_event_marker"
	,"_debug_marker"
	,"_supplyBox"
	,"_loot"
];

_spawnChance =  0.35; // Percentage chance of event happening
_markerRadius = 500; // Radius the loot can spawn and used for the marker
_debug = false; // Puts a marker exactly were the loot spawns
_wait_time = 1800;

// Dont mess with theses unless u know what yours doing
_start_time = time;
_spawnMarker = 'center';
_spawnRadius = (HeliCrashArea/2);

// Random loot lists
_loot_lists = [
	[
		[
			"ItemEtool"
			,"ItemEtool"
		]
		,[
			"PartWoodLumber"
			,"PartWoodLumber"
			,"PartWoodLumber"
			,"PartWoodLumber"
			,"PartWoodLumber"
			,"PartWoodLumber"
			
			,"PartWoodPlywood"
			,"PartWoodPlywood"
			,"PartWoodPlywood"
			,"PartWoodPlywood"
			,"PartWoodPlywood"
			,"PartWoodPlywood"
			
			,"ItemPole"
			,"ItemPole"
			,"ItemPole"
			
			,"ItemComboLock"
			
			,"bulk_empty"
			,"bulk_empty"
			,"bulk_empty"
		]
		,[]
	],[
		[
			"ItemToolbox"
			,"ItemToolbox"
		]
		,[
			"ItemTankTrap"
			,"ItemTankTrap"
			,"ItemTankTrap"
			,"ItemTankTrap"
			,"ItemTankTrap"
			,"ItemTankTrap"
			
			,"ItemSandbag"
			,"ItemSandbag"
			,"ItemSandbag"
			,"ItemSandbag"
			,"ItemSandbag"
			,"ItemSandbag"
			
			,"ItemWire"
			,"ItemWire"
			,"ItemWire"
			,"ItemWire"
			,"ItemWire"
			,"ItemWire"
			
			,"bulk_empty"
			,"bulk_empty"
			,"bulk_empty"
		]
		,[]
	],[
		[
			"ItemCrowbar"
			,"ItemCrowbar"
		]
		,[
			"ItemTentDomed"
			,"ItemTentDomed"
			
			,"ItemTentDomed2"
			,"ItemTentDomed2"
			
			,"CinderBlocks"
			,"CinderBlocks"
			,"CinderBlocks"
			,"CinderBlocks"
			,"CinderBlocks"
			,"CinderBlocks"
			
			,"MortarBucket"
			,"MortarBucket"
			,"MortarBucket"
			,"MortarBucket"
			,"MortarBucket"
			,"MortarBucket"
			
			,"bulk_empty"
			,"bulk_empty"
			,"bulk_empty"
		]
		,[]
	],[
		[
			"Sledgehammer"
			,"Sledgehammer"
		]
		,[
			"PartWoodPile"
			,"PartWoodPile"
			,"PartWoodPile"
			,"PartWoodPile"
			,"PartWoodPile"
			,"PartWoodPile"
			
			,"PartGlass"
			,"PartGlass"
			,"PartGlass"
			,"PartGlass"
			,"PartGlass"
			,"PartGlass"
			
			,"ItemLightBulb"
			,"ItemLightBulb"
			,"ItemLightBulb"
			
			,"ItemCanvas"
			,"ItemCanvas"
			,"ItemCanvas"
			
			,"bulk_empty"
			,"bulk_empty"
			,"bulk_empty"
		]
		,[]
	]
];

_spawnRoll = random 1;
if (_spawnRoll <= _spawnChance) then {

	// get positions
	_position_plane = [0, 0, 500];
	switch (round(random 3)) do {
		case 0: { // start north
			_position_plane = [0, (random 14800), (_position_plane select 2)];
		};
		case 1: { // start east
			_position_plane = [(random 14800), 14800, (_position_plane select 2)];
		};
		case 2: { // start south
			_position_plane = [14800, (random 14800), (_position_plane select 2)];
		};
		case 3: { // start west
			_position_plane = [(random 14800), 0, (_position_plane select 2)];
		};
	};
	_position_marker = [(getMarkerPos _spawnMarker), 0, _spawnRadius, 10, 0, 2000, 0] call BIS_fnc_findSafePos;
	_position_supplyBox = [_position_marker, 0, (_markerRadius - 100), 10, 0, 2000, 0] call BIS_fnc_findSafePos;
	_dir_planeToSupplyBox = 0;
	
	// marker x > plane x & marker y < plane y
	if ((_position_marker select 0) > (_position_plane select 0) && (_position_marker select 1) < (_position_plane select 1)) then {
		_tmp_x = (_position_marker select 0) - (_position_plane select 0);
		_tmp_y = (_position_plane select 1) - (_position_marker select 1);
		_dir_planeToSupplyBox = atan ((_tmp_x / _tmp_y) + 0);
	};
	// 90 - 180
	if ((_position_marker select 0) > (_position_plane select 0) && (_position_marker select 1) > (_position_plane select 1)) then {
		_tmp_x = (_position_marker select 0) - (_position_plane select 0);
		_tmp_y = (_position_marker select 1) - (_position_plane select 1);
		_dir_planeToSupplyBox = atan ((_tmp_x / _tmp_y) + 90);
	};
	// 180 - 270
	if ((_position_marker select 0) < (_position_plane select 0) && (_position_marker select 1) > (_position_plane select 1)) then {
		_tmp_x = (_position_plane select 0) - (_position_marker select 0);
		_tmp_y = (_position_marker select 1) - (_position_plane select 1);
		_dir_planeToSupplyBox = atan ((_tmp_x / _tmp_y) + 180);
	};
	// 270 - 360
	if ((_position_marker select 0) < (_position_plane select 0) && (_position_marker select 1) < (_position_plane select 1)) then {
		_tmp_x = (_position_plane select 0) - (_position_marker select 0);
		_tmp_y = (_position_plane select 1) - (_position_marker select 1);
		_dir_planeToSupplyBox = atan ((_tmp_x / _tmp_y) + 270);
	};

	// create transport plane
	//_vehicle = createVehicle ["C130J", _position_plane, [], 0, "FLYING"];
	//_vehicle setDir round(random 360);
	//_vehicle setPos _position_marker;
	
	
	_supplyBoxModel = "USVehicleBox";
	
	
	_event_marker = createMarker [ format ["loot_event_marker_%1", _start_time], _position_marker];
	_event_marker setMarkerShape "ELLIPSE";
	_event_marker setMarkerColor "ColorBlue";
	_event_marker setMarkerAlpha 0.5;
	_event_marker setMarkerSize [(_markerRadius + 50), (_markerRadius + 50)];
	_event_marker setMarkerText "@STR_M_SBD_01";
	
	if (_debug) then {
		_debug_marker = createMarker [ format ["loot_event_debug_marker_%1", _start_time], _position_supplyBox];
		_debug_marker setMarkerShape "ICON";
		_debug_marker setMarkerType "mil_dot";
		_debug_marker setMarkerColor "ColorBlue";
		_debug_marker setMarkerAlpha 1;
	};

	_supplyBox = createVehicle [_supplyBoxModel, _position_supplyBox, [], 0, "CAN_COLLIDE"];
	_supplyBox setDir round(random 360);
	_supplyBox setPos _position_supplyBox;

	// Disable simulation server side
	_supplyBox enableSimulation false;
	
	clearMagazineCargoGlobal _supplyBox;
	clearWeaponCargoGlobal _supplyBox;

	// Choose loot
	_loot = _loot_lists call BIS_fnc_selectRandom;
	
    // Add loot
	{
		_supplyBox addWeaponCargoGlobal [_x, round(random 5)];
	} forEach (_loot select 0);
	{
		_supplyBox addMagazineCargoGlobal [_x, round(random 15)];
	} forEach (_loot select 1);
	{
		_supplyBox addBackpackCargoGlobal [_x, round(random 1)];
	} forEach (_loot select 2);
	
	
	missionNamespace setVariable ["PVDZE_MIS_SBD", ["DROPPED", _supplyBoxModel]];
	publicVariable "PVDZE_MIS_SBD";
	
	sleep _wait_time;
	
	deleteVehicle _supplyBox;
	deleteMarker _event_marker;
	if (_debug) then {
		deleteMarker _debug_marker;
	};
};