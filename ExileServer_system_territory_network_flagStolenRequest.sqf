/**
 * ExileServer_system_territory_network_flagStolenRequest
 *
 * Exile Mod
 * www.exilemod.com
 * © 2015 Exile Mod Team
 *
 * This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License. 
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/.
 */
 
private["_sessionID", "_parameters", "_flag", "_playerObject", "_databaseID", "_level", "_flagPosition", "_spawnRadius", "_weaponHolderPosition", "_weaponHolder", "_logging", "_territoryLog", "_buildRights", "_moderatorRights", "_owner", "_newUserLevel", "_moderatedPlayerUID"];
_sessionID = _this select 0;
_parameters = _this select 1;
_flag = _parameters select 0;
try
{
	_playerObject = _sessionID call ExileServer_system_session_getPlayerObject;
	if (isNull _playerObject) then
	{
		throw "Player Object NULL";
	};
	if ((_flag getVariable ["ExileFlagStolen", 0]) isEqualTo 1) then 
	{
		throw "Flag already stolen!";
	};
	if ((_playerObject distance2D _flag) > 5) then
	{
		throw "You are too far away!";
	};
	_playerUIDSt = getPlayerUID _playerObject; // Added in
	_territoryID = if (isNull _territoryFlag) then { 'NULL' } else  { _territoryFlag getVariable ["ExileDatabaseID", 'NULL']}; // Added in
	_databaseID = _flag getVariable ["ExileDatabaseID",0];
	_level = _flag getVariable ["ExileTerritoryLevel", 0];
	_flagPosition = getPosATL _flag;
	_flagPosition set[2, 0];
	_spawnRadius = 3;
	_weaponHolderPosition = getPosATL _playerObject;
	_weaponHolder = createVehicle ["GroundWeaponHolder", _weaponHolderPosition, [], 0, "CAN_COLLIDE"];
	_weaponHolder setPosATL _weaponHolderPosition;
	_weaponHolder addMagazineCargoGlobal [format["Exile_Item_FlagStolen%1", _level], 1];
	_flag setVariable ["ExileOwnerUID", _playerUIDSt]; /* Sets Owners */
	
		/* Moderator Rights */
		_moderatedPlayerUID = _this select 1;
		_newUserLevel = _this select 2;
		_moderatorRights = _flag getVariable ["ExileTerritoryModerators",[]];
		switch (_newUserLevel) do 
		{ 
			case 1 :
			{
				if (_moderatedPlayerUID in _moderatorRights) then
				{	
					_moderatorRights deleteAt (_moderatorRights find _moderatedPlayerUID);
				};
			}; 
			case 2 : 
			{
				if !(_moderatedPlayerUID in _moderatorRights) then
				{
					_moderatorRights pushBack _moderatedPlayerUID;
				};
			}; 
			default {};
		};
		_flag setVariable ["ExileTerritoryModerators",_moderatorRights,true];
		format ["updateTerritoryModerators:%1:%2",_moderatorRights,_databaseID] call ExileServer_system_database_query_fireAndForget;
		
		/* Build Rights */
		_buildRights = _flag getVariable ["ExileTerritoryBuildRights",[]];
		switch (_newUserLevel) do 
		{ 
			case 1 :
			{
				if (_moderatedPlayerUID in _buildRights) then
				{	
					_buildRights deleteAt (_buildRights find _moderatedPlayerUID);
				};
			}; 
			case 2 : 
			{
				if !(_moderatedPlayerUID in _buildRights) then
				{
					_buildRights pushBack _moderatedPlayerUID;
				};
			}; 
			default {};
		}
		_flag setVariable ["ExileTerritoryBuildRights",_buildRights,true];
		format ["updateTerritoryModerators:%1:%2",_buildRights,_databaseID] call ExileServer_system_database_query_fireAndForget;
		
	
	_logging = getNumber(configFile >> "CfgSettings" >> "Logging" >> "territoryLogging");
	if (_logging isEqualTo 1) then
	{
		_territoryLog = format ["PLAYER ( %1 ) %2 STOLE A LEVEL %3 FLAG FROM TERRITORY #%4",getPlayerUID _playerObject,_playerObject,_level,_databaseID];
		"extDB2" callExtension format["1:TERRITORY:%1",_territoryLog];
	};
	_flag call ExileServer_system_xm8_sendFlagStolen;
}
catch
{
	[_sessionID, "toastRequest", ["ErrorTitleAndText", ["Failed to steal!", _exception]]] call ExileServer_system_network_send_to;
};
true

/*format["flagStolen:%1:%2",getPlayerUID _playerObject,_databaseID] call ExileServer_object_construction_database_delete;*/