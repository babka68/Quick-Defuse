#pragma semicolon 1

#include <sdktools_functions>
#include <multicolors>
#include <csgo_colors>

#pragma newdecls required

int
		iwire;

Handle
		hcvar_tchoice,
		hcvar_ctnokit;

char	wirecolours[5][] = 
{
	"Blue", "Yellow", "Red", "Green", "Black"
};
char	wirecolours_menu[5][] = 
{
	"Blue (Menu)", "Yellow (Menu)", "Red (Menu)", "Green (Menu)", "Black (Menu)"
};

char	Engine_Version;

#define GAME_UNDEFINED 0
#define GAME_CSS_34 1
#define GAME_CSS 2
#define GAME_CSGO 3

int GetCSGame()
{
	if (GetFeatureStatus(FeatureType_Native, "GetEngineVersion") == FeatureStatus_Available)
	{
		switch (GetEngineVersion())
		{
			case Engine_SourceSDK2006:return GAME_CSS_34;
			case Engine_CSS:return GAME_CSS;
			case Engine_CSGO:return GAME_CSGO;
		}
	}
	return GAME_UNDEFINED;
}

public Plugin myinfo = 
{
	name = "Quick Defuse", 
	author = "by pRED, babka68", 
	description = "Выбор провода,для быстрого обезвреживания.", 
	version = "1.3", 
	url = "tmb-css.ru"
};

public void OnPluginStart()
{
	Engine_Version = GetCSGame();
	if (Engine_Version == GAME_UNDEFINED)SetFailState("Game is not supported!");
	if (Engine_Version == GAME_CSS_34)LoadTranslations("quick_defuse_cssv34.phrases");
	if (Engine_Version == GAME_CSS)LoadTranslations("quick_defuse_css.phrases");
	if (Engine_Version == GAME_CSGO)LoadTranslations("quick_defuse_csgo.phrases");
	
	HookEvent("bomb_begindefuse", Event_Defuse);
	HookEvent("bomb_beginplant", Event_Plant);
	HookEvent("bomb_planted", Event_Planted);
	HookEvent("bomb_abortdefuse", Event_Abort);
	HookEvent("bomb_abortplant", Event_Abort);
	
	hcvar_tchoice = CreateConVar("qd_tchoice", "1", "Устанавливает, могут ли террористы выбирать цвет провода Быстрая разрядка", _, true, 0.0, true, 1.0);
	hcvar_ctnokit = CreateConVar("qd_ctnokit", "1", "Обезвреживания без defuse,если 1 - 100%,если 0 - 50% шанс правильного выбора. ", _, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "quick_defuse");
}

public void Event_Plant(Handle event, const char[] name, bool dontBroadcast)
{
	int clientId = GetEventInt(event, "userid"), client = GetClientOfUserId(clientId);
	char textstring[128];
	
	iwire = 0;
	
	if (GetConVarInt(hcvar_tchoice))
	{
		SetGlobalTransTarget(client);
		Handle panel = CreatePanel();
		
		Format(textstring, sizeof(textstring), "%t:", "Choose a Wire");
		SetPanelTitle(panel, textstring);
		
		DrawPanelText(panel, " ");
		
		Format(textstring, sizeof(textstring), "%t", "Choose a Wire1");
		DrawPanelText(panel, textstring);
		Format(textstring, sizeof(textstring), "%t", "Choose a Wire2");
		DrawPanelText(panel, textstring);
		
		DrawPanelText(panel, " ");
		
		Format(textstring, sizeof(textstring), "%t", wirecolours_menu[0]);
		DrawPanelItem(panel, textstring);
		Format(textstring, sizeof(textstring), "%t", wirecolours_menu[1]);
		DrawPanelItem(panel, textstring);
		Format(textstring, sizeof(textstring), "%t", wirecolours_menu[2]);
		DrawPanelItem(panel, textstring);
		Format(textstring, sizeof(textstring), "%t", wirecolours_menu[3]);
		DrawPanelItem(panel, textstring);
		Format(textstring, sizeof(textstring), "%t", wirecolours_menu[4]);
		DrawPanelItem(panel, textstring);
		
		
		DrawPanelText(panel, " ");
		Format(textstring, sizeof(textstring), "%t", "Exit");
		DrawPanelItem(panel, textstring);
		
		SendPanelToClient(panel, client, PanelPlant, 5);
		
		CloseHandle(panel);
	}
}

public void Event_Planted(Handle event, const char[] name, bool dontBroadcast)
{
	if (iwire == 0)	iwire = GetRandomInt(1, 4);
}


public void Event_Defuse(Handle event, const char[] name, bool dontBroadcast)
{
	int clientId = GetEventInt(event, "userid"), client = GetClientOfUserId(clientId);
	bool kit = GetEventBool(event, "haskit");
	char textstring[128];
	
	SetGlobalTransTarget(client);
	Handle panel = CreatePanel();
	
	Format(textstring, sizeof(textstring), "%t:", "Choose a Wire");
	SetPanelTitle(panel, textstring);
	Format(textstring, sizeof(textstring), "%t", "Choose a Wire3");
	DrawPanelText(panel, textstring);
	
	DrawPanelText(panel, " ");
	
	
	Format(textstring, sizeof(textstring), "%t", "Choose a Wire4");
	DrawPanelText(panel, textstring);
	Format(textstring, sizeof(textstring), "%t", "Choose a Wire5");
	DrawPanelText(panel, textstring);
	
	DrawPanelText(panel, " ");
	
	Format(textstring, sizeof(textstring), "%t", wirecolours_menu[0]);
	DrawPanelItem(panel, textstring);
	Format(textstring, sizeof(textstring), "%t", wirecolours_menu[1]);
	DrawPanelItem(panel, textstring);
	Format(textstring, sizeof(textstring), "%t", wirecolours_menu[2]);
	DrawPanelItem(panel, textstring);
	Format(textstring, sizeof(textstring), "%t", wirecolours_menu[3]);
	DrawPanelItem(panel, textstring);
	Format(textstring, sizeof(textstring), "%t", wirecolours_menu[4]);
	DrawPanelItem(panel, textstring);
	
	
	DrawPanelText(panel, " ");
	Format(textstring, sizeof(textstring), "%t", "Exit");
	DrawPanelItem(panel, textstring);
	
	if(kit) SendPanelToClient(panel, client, PanelDefuseKit, 5);
	else SendPanelToClient(panel, client, PanelNoKit, 5);
	
	CloseHandle(panel);
}

public int PanelPlant(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select && param2 > 0 && param2 < 6)
	{
		iwire = param2;
		if(Engine_Version == GAME_CSGO)CGOPrintToChat(param1, "%t %t %t", "T Choosen1", wirecolours[param2 - 1], "T Choosen2");
		else CPrintToChat(param1, "%t %t %t", "T Choosen1", wirecolours[param2 - 1], "T Choosen2");
	}
}

public int PanelDefuseKit(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select && param2 > 0 && param2 < 6)
	{
		int bombent = FindEntityByClassname(-1, "planted_c4");
		
		if (bombent > 0)
		{
			char name[32];
			GetClientName(param1, name, sizeof(name));
			
			if (param2 == iwire)
			{
				SetEntPropFloat(bombent, Prop_Send, "m_flDefuseCountDown", 1.0);
				if (Engine_Version == GAME_CSGO)CGOPrintToChatAll("{lime} %s %t %t %t", name, "CT Done1", wirecolours[param2 - 1], "CT Done2");
				else CPrintToChatAll("{lime} %s %t %t %t", name, "CT Done1", wirecolours[param2 - 1], "CT Done2");
			}
			else
			{
				SetEntPropFloat(bombent, Prop_Send, "m_flC4Blow", 1.0);
				if(Engine_Version == GAME_CSGO)CGOPrintToChatAll("{red} %s %t %t %t %t", name, "CT Fail1", wirecolours[param2 - 1], "CT Fail2", wirecolours[iwire - 1]);
				else CPrintToChatAll("{fullred} %s %t %t %t %t", name, "CT Fail1", wirecolours[param2 - 1], "CT Fail2", wirecolours[iwire - 1]);
			}
		}
	}
}

public int PanelNoKit(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select && param2 > 0 && param2 < 6)
	{
		int bombent = FindEntityByClassname(-1, "planted_c4");
		
		if (bombent > 0)
		{
			char name[32];
			GetClientName(param1, name, sizeof(name));
			
			if (param2 == iwire && (GetRandomInt(0, 1) || GetConVarBool(hcvar_ctnokit)))
			{
				SetEntPropFloat(bombent, Prop_Send, "m_flDefuseCountDown", 1.0);
				if(Engine_Version == GAME_CSGO) CGOPrintToChatAll("{lime} %s %t %t %t", name, "CT Done No Kit1", wirecolours[param2 - 1], "CT Done No Kit2");
				else CPrintToChatAll("{lime} %s %t %t %t", name, "CT Done No Kit1", wirecolours[param2 - 1], "CT Done No Kit2");
			}
			else
			{
				SetEntPropFloat(bombent, Prop_Send, "m_flC4Blow", 1.0);
				if (param2 != iwire)
				{
					if(Engine_Version == GAME_CSGO) CGOPrintToChatAll("{red} %s %t %t %t %t", name, "CT Fail No Kit1a", wirecolours[param2 - 1], "CT Fail No Kit2a", wirecolours[iwire - 1]);
					else CPrintToChatAll("{fullred} %s %t %t %t %t", name, "CT Fail No Kit1a", wirecolours[param2 - 1], "CT Fail No Kit2a", wirecolours[iwire - 1]);
				}
				else
				{
					if (Engine_Version == GAME_CSGO)CGOPrintToChatAll("{red} %s %t %t %t!", name, "CT Fail No Kit1b", wirecolours[param2 - 1], "CT Fail No Kit2b");
					else CPrintToChatAll("{fullred} %s %t %t %t!", name, "CT Fail No Kit1b", wirecolours[param2 - 1], "CT Fail No Kit2b");
				}
			}
		}
	}
}

public void Event_Abort(Handle event, const char[] name, bool dontBroadcast)
{
	int clientId = GetEventInt(event, "userid");
	int client = GetClientOfUserId(clientId);
	
	CancelClientMenu(client);
}
