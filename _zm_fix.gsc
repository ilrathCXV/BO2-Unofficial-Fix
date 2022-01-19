#include common_scripts/utility;
#include maps/mp/_demo;
#include maps/mp/_utility;
#include maps/mp/_visionset_mgr;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_ai_dogs;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm_bot;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_clone;
#include maps/mp/zombies/_zm_devgui;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_ffotd;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_gump;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_pers_upgrades;
#include maps/mp/zombies/_zm_pers_upgrades_system;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_playerhealth;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_power;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_timer;
#include maps/mp/zombies/_zm_tombstone;
#include maps/mp/zombies/_zm_traps;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_zonemgr;

init()
{
	setDvar("player_backSpeedScale", 1);
	setDvar("player_strafeSpeedScale", 1);
	setDvar("player_sprintStrafeSpeedScale", 1);
	level thread zombie_health();
	level thread onPlayerConnect();
}

zombie_health()
{ 
	for (;;)
	{
		level waittill("start_of_round");
		if(level.zombie_health > maps/mp/zombies/_zm::ai_zombie_health(155))
		{
			level.zombie_health = maps/mp/zombies/_zm::ai_zombie_health(155);
		}
	}
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	self.initial_spawn = 1;
	for(;;)
	{
		self waittill("spawned_player");
		if (self.initial_spawn == 1)
		{
			self.initial_spawn = 0;
			self thread give_bank_locker_upgrades();
			self thread rapid_fire();
		}
	}
}

give_bank_locker_upgrades()
{
	flag_wait("initial_blackscreen_passed");
	self.account_value = 250000;
	if ( level.script == "zm_highrise" )
	{
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "name", "an94_upgraded_zm+reflex" );
	}
	else
	{
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "name", "m32_upgraded_zm" );
	}
	self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "clip", 1023 );
	self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "stock", 1023 );
	self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "lh_clip", 1023 );
	self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "alt_clip", 1023 );
	self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "alt_stock", 1023 );
	self increment_client_stat( "pers_boarding", 0 );
	self increment_client_stat( "pers_revivenoperk", 0 );
	self increment_client_stat( "pers_multikill_headshots", 0 );
	self increment_client_stat( "pers_cash_back_bought", 0 );
	self increment_client_stat( "pers_cash_back_prone", 0 );
	self increment_client_stat( "pers_insta_kill", 0 );
	self increment_client_stat( "pers_jugg", 0 );
	self increment_client_stat( "pers_flopper_counter", 0 );
	self increment_client_stat( "pers_pistol_points_counter", 0 );
	self increment_client_stat( "pers_double_points_counter", 0 );
	self increment_client_stat( "pers_perk_lose_counter", 0 );
	self increment_client_stat( "pers_sniper_counter", 0 );
	self increment_client_stat( "pers_box_weapon_counter", 0 );
	self increment_client_stat( "pers_nube_counter", 0 );
}

rapid_fire()
{
	if( getDvar( "rapid_fire" ) == "" )
	setDvar( "rapid_fire", 0 );
	
	self endon("disconnect");
	for(;;)
	{
		if( getDvarInt( "rapid_fire" ) == 0 )
		{
			wait 0.05;
		}
		if( getDvarInt( "rapid_fire" ) == 1 )
		{
			self waittill("weapon_fired", weap);
			primaries = self GetWeaponsListPrimaries();
			if(primaries.size > 1)
			{
				foreach(weapon in primaries)
				{
					if(weapon != weap)
					{
						self SwitchToWeapon(weapon);
						wait 0.05;
						self SwitchToWeapon(weap);
						self SetSpawnWeapon(weap);
						break;
					}
				}
			}
		}
	}
}
