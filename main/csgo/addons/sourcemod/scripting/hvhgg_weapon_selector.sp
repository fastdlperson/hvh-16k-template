#include <sourcemod>
#include <sdktools>
#include <cstrike>


public Plugin:myinfo = 
{ 
	name = "HvH.gg Weapon Selector", 
	author = "imi-tat0r", 
	description = "Allows players to set a preference for weapons after CS:GO inventory services got shut down.", 
	version = "v1.0.0"
};

bool g_bPrefersR8[MAXPLAYERS + 1] = {false};
bool g_bPrefersUSP[MAXPLAYERS + 1] = {false};
bool g_bPrefersCZ[MAXPLAYERS + 1] = {false};
bool g_bPrefersM4A1S[MAXPLAYERS + 1] = {false};
int g_iPlayerNotified[MAXPLAYERS + 1] = {0};
int r8Price = 600;
int deaglePrice = 700;
int p2000UspPrice = 200;
int czTecPrice = 500;
int m4a1sPrice = 2900;
int m4a4Price = 3100;

public void OnPluginStart()
{
	RegConsoleCmd("deagle", Command_Deagle);
	RegConsoleCmd("r8", Command_Revolver);
	RegConsoleCmd("revolver", Command_Revolver);

	RegConsoleCmd("usp", Command_USP);
	RegConsoleCmd("p2000", Command_P2000);
	RegConsoleCmd("p2k", Command_P2000);

	RegConsoleCmd("cz", Command_CZ);
	RegConsoleCmd("tec", Command_NotCZ);
	RegConsoleCmd("tec9", Command_NotCZ);
	RegConsoleCmd("fiveseven", Command_NotCZ);
	RegConsoleCmd("57", Command_NotCZ);

	RegConsoleCmd("m4a1s", Command_M4A1S);
	RegConsoleCmd("m4a4", Command_M4A4);

	HookEvent("player_spawn", Player_Spawn);
}

public void OnClientConnected(int client)
{
	ResetUserPreference(client);
}

public void OnClientDisconnect(int client)
{
	ResetUserPreference(client);
}

void Player_Spawn(Event event, const char[] name, bool dB)
{
	CreateTimer(0.1, HandleSpawn, event.GetInt("userid"));
}

public Action HandleSpawn(Handle timer, any userId)
{
	int client = GetClientOfUserId(view_as<int>(userId));
	if (!client)
		return Plugin_Stop;

	if (GetClientTeam(client) <= CS_TEAM_SPECTATOR)
		return Plugin_Stop;

	if (g_iPlayerNotified[client] >= 1)
		return Plugin_Stop;

	PrintToChat(client, "[\x03nebula\x01] Use \x03!deagle\x01 or \x03!r8\x01 at any time to set your preference.");
	PrintToChat(client, "[\x03nebula\x01] Use \x03!p2000\x01 or \x03!usp\x01 at any time to set your preference.");
	PrintToChat(client, "[\x03nebula\x01] Use \x03!tec9\x01/\x03!fiveseven\x01 or \x03!cz\x01 at any time to set your preference.");

	if (g_bPrefersR8[client])
		PrintToChat(client, "[\x03nebula\x01] Current preference: \x03R8 Revolver");
	else
		PrintToChat(client, "[\x03nebula\x01] Current preference: \x03Desert Eagle");
	
	if (g_bPrefersUSP[client])
		PrintToChat(client, "[\x03nebula\x01] Current preference: \x03USP-S");
	else
		PrintToChat(client, "[\x03nebula\x01] Current preference: \x03P2000");

	if (g_bPrefersCZ[client])
		PrintToChat(client, "[\x03nebula\x01] Current preference: \x03CZ75-Auto");
	else
		PrintToChat(client, "[\x03nebula\x01] Current preference: \x03Tec-9/Five-Seven");

	if (g_bPrefersM4A1S[client])
		PrintToChat(client, "[\x03nebula\x01] Current preference: \x03M4A1-S");
	else
		PrintToChat(client, "[\x03nebula\x01] Current preference: \x03M4A4");

	g_iPlayerNotified[client]++;

	return Plugin_Stop;
}

public Action Command_Deagle(int client, int args)
{
	return Command_Handler("deagle", client, args);
}

public Action Command_Revolver(int client, int args)
{
	return Command_Handler("r8", client, args);
}

public Action Command_USP(int client, int args)
{
	return Command_Handler("usp", client, args);
}

public Action Command_P2000(int client, int args)
{
	return Command_Handler("p2000", client, args);
}

public Action Command_CZ(int client, int args)
{
	return Command_Handler("cz", client, args);
}

public Action Command_NotCZ(int client, int args)
{
	return Command_Handler("tec9", client, args);
}

public Action Command_M4A1S(int client, int args)
{
	return Command_Handler("m4a1s", client, args);
}

public Action Command_M4A4(int client, int args)
{
	return Command_Handler("m4a4", client, args);
}

public Action Command_Handler(const char[] command, int client, int args)
{
	if (args > 1)
	{
		char com[128] = "[\x03nebula\x01] Usage: !";
		StrCat(com, sizeof(com), command);
		
		ReplyToCommand(client, com);
		return Plugin_Handled;
	}
	
	char weapon[32] = "";

	if (StrEqual(command, "deagle"))
	{
		g_bPrefersR8[client] = false;
		weapon = "Desert Eagle";
	}
	else if (StrEqual(command, "r8"))
	{
		g_bPrefersR8[client] = true;
		weapon = "R8 Revolver";
	}
	else if (StrEqual(command, "p2000"))
	{
		g_bPrefersUSP[client] = false;
		weapon = "P2000";
	}
	else if (StrEqual(command, "usp"))
	{
		g_bPrefersUSP[client] = true;
		weapon = "USP-S";
	}
	else if (StrEqual(command, "m4a1s"))
	{
		g_bPrefersM4A1S[client] = true;
		weapon = "M4A1-S";
	}
	else if (StrEqual(command, "m4a4"))
	{
		g_bPrefersM4A1S[client] = false;
		weapon = "M4A4";
	}
	else if (StrEqual(command, "cz"))
	{
		g_bPrefersCZ[client] = true;
		weapon = "CZ75-Auto";
	}
	else
	{
		g_bPrefersCZ[client] = false;
		weapon = "Tec-9/Five-Seven";
	}

	char com[128] = "[\x03nebula\x01] Current preference: \x03";
	StrCat(com, sizeof(com), weapon);
	ReplyToCommand(client, com);

	return Plugin_Handled;
}

public Action CS_OnBuyCommand(int client, const char [] szWeapon)
{
	if(!IsClientInGame(client) || !IsPlayerAlive(client) || GetEntProp(client, Prop_Send, "m_bInBuyZone") == 0)
		return Plugin_Continue;
	
	if(GetClientTeam(client) <= CS_TEAM_SPECTATOR)
		return Plugin_Continue;
	
	char str[128] = "weapon_";
	StrCat(str, sizeof(str), szWeapon);

	if (StrEqual(str, "weapon_deagle"))
		return HandleBuyEvent(client, "weapon_revolver", r8Price, g_bPrefersR8[client]);
	else if (StrEqual(str, "weapon_revolver"))
		return HandleBuyEvent(client, "weapon_deagle", deaglePrice, !g_bPrefersR8[client]);
	else if (StrEqual(str, "weapon_hkp2000"))
		return HandleBuyEvent(client, "weapon_usp_silencer", p2000UspPrice, g_bPrefersUSP[client]);
	else if (StrEqual(str, "weapon_usp_silencer"))
		return HandleBuyEvent(client, "weapon_hkp2000", p2000UspPrice, !g_bPrefersUSP[client]);
	else if (StrEqual(str, "weapon_m4a4"))
		return HandleBuyEvent(client, "weapon_m4a1_silencer", m4a1sPrice, !g_bPrefersM4A1S[client]);
	else if (StrEqual(str, "weapon_m4a1_silencer"))
		return HandleBuyEvent(client, "weapon_m4a4", m4a4Price, g_bPrefersM4A1S[client]);
	else if (StrEqual(str, "weapon_tec9") || StrEqual(str, "weapon_fiveseven"))
		return HandleBuyEvent(client, "weapon_cz75a", czTecPrice, g_bPrefersCZ[client]);
	else if (StrEqual(str, "weapon_cz75a"))
	{
		if (GetClientTeam(client) == CS_TEAM_T)
			return HandleBuyEvent(client, "weapon_tec9", czTecPrice, !g_bPrefersCZ[client]);
		else
			return HandleBuyEvent(client, "weapon_fiveseven", czTecPrice, !g_bPrefersCZ[client]);
	}
	else
		return Plugin_Continue;
}

public Action CS_OnGetWeaponPrice(int client, const char[] weapon, int& price)
{
	// only deagle and r8 differ in price
	if (StrEqual(weapon, "weapon_deagle") || StrEqual(weapon, "weapon_revolver"))
	{
		price = g_bPrefersR8[client] ? r8Price : deaglePrice;
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action HandleBuyEvent(int client, const char[] weapon_replace, int price_replace, bool prefers)
{
	if (!prefers)
		return Plugin_Continue;

	// can we afford the weapon?
	int money = GetClientMoney(client);
	if (money < price_replace)
		return Plugin_Handled;
	// if player already has the weapon, do nothing
	else if (HasPlayerWeapon(client, weapon_replace))
		return Plugin_Handled;
	else
	{
		DropSecondary(client);
		SetClientMoney(client, money - price_replace);
		GivePlayerItem(client, weapon_replace);

		return Plugin_Handled;
	}		
}

public bool HasPlayerWeapon(int client, const char[] weapon)
{
	int m_hMyWeapons = FindSendPropInfo("CBasePlayer", "m_hMyWeapons");
	if(m_hMyWeapons == -1)
		return false;

	for(int offset = 0; offset < 128; offset += 4)
	{
		int weap = GetEntDataEnt2(client, m_hMyWeapons+offset);

		if(IsValidEdict(weap))
		{
			char classname[32];
			GetWeaponClassname(weap, -1, classname, 32);

			if(StrEqual(classname, weapon))
				return true;
		}
	}

	return false;
}

public void DropSecondary(int client)
{
	int slot2 = GetPlayerWeaponSlot(client, 1)

	if (slot2 != -1)
	{
		CS_DropWeapon(client, slot2, false);
	}
}

public int GetClientMoney(int client)
{
	return GetEntProp(client, Prop_Send, "m_iAccount");
}

public void SetClientMoney(int client, int money)
{
	SetEntProp(client, Prop_Send, "m_iAccount", money);
}

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
		ResetUserPreference(i);
}

void ResetUserPreference(int client)
{
	g_bPrefersR8[client] = false;
	g_bPrefersUSP[client] = false;
	g_bPrefersCZ[client] = false;
	g_bPrefersM4A1S[client] = false;
	g_iPlayerNotified[client] = false;	
}

stock void GetWeaponClassname(int weapon, int index = -1, char[] classname, int maxLen)
{
	GetEdictClassname(weapon, classname, maxLen);

	if(index == -1)
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");

	switch(index)
	{
		case 60: strcopy(classname, maxLen, "weapon_m4a1_silencer");
		case 61: strcopy(classname, maxLen, "weapon_usp_silencer");
		case 63: strcopy(classname, maxLen, "weapon_cz75a");
		case 64: strcopy(classname, maxLen, "weapon_revolver");
	}
}