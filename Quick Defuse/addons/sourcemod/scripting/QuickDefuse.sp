#include <sdktools_functions>
#include <multicolors>
#include <csgo_colors>

#pragma semicolon 1
#pragma newdecls required

bool g_bcvar_Tchoice, g_bcvar_CtNoKit;
int g_iwire;

char wirecolours[5][] =  {
	"Blue", "Yellow", "Red", "Green", "Black"
};
char wirecolours_menu[5][] =  {
	"Blue (Menu)", "Yellow (Menu)", "Red (Menu)", "Green (Menu)", "Black (Menu)"
};

char Engine_Version;

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
	name = "Quick defuse", 
	author = "by pRED, babka68", 
	description = "Выбор провода,для быстрого обезвреживания.", 
	version = "1.3", 
	url = "https://vk.com/zakazserver68"
};

public void OnPluginStart()
{
	Engine_Version = GetCSGame();
	if (Engine_Version == GAME_UNDEFINED)SetFailState("Game is not supported!");
	if (Engine_Version == GAME_CSS_34)LoadTranslations("quick_defuse_cssv34.phrases");
	if (Engine_Version == GAME_CSS)LoadTranslations("quick_defuse_css.phrases");
	if (Engine_Version == GAME_CSGO)LoadTranslations("quick_defuse_csgo.phrases");
	
	ConVar cvar;
	cvar = CreateConVar("sm_qd_t_choice", "1", "Дать возможность террористам выбирать провод при закладке бомбы (1 - вкл, 0 - Выкл)", _, true, 0.0, true, 1.0);
	cvar.AddChangeHook(CVarChanged_TChoice);
	g_bcvar_Tchoice = cvar.BoolValue;
	
	cvar = CreateConVar("sm_qd_ct_no_kit", "1", "Обезвреживания без defuse,если 1 - 100%,если 0 - 50% шанс правильного выбора.", _, true, 0.0, true, 1.0);
	cvar.AddChangeHook(CVarChanged_Ct_No_Kit);
	g_bcvar_CtNoKit = cvar.BoolValue;
	
	HookEvent("bomb_begindefuse", Event_Defuse);
	HookEvent("bomb_beginplant", Event_Plant);
	HookEvent("bomb_planted", Event_Planted);
	HookEvent("bomb_abortdefuse", Event_Abort);
	HookEvent("bomb_abortplant", Event_Abort);
	
	AutoExecConfig(true, "quick_defuse");
}

public void CVarChanged_TChoice(ConVar cvar, const char[] oldValue, const char[] newValue) {
	g_bcvar_Tchoice = cvar.BoolValue;
}

public void CVarChanged_Ct_No_Kit(ConVar cvar, const char[] oldValue, const char[] newValue) {
	g_bcvar_CtNoKit = cvar.BoolValue;
}

public void Event_Plant(Event event, const char[] name, bool dontBroadcast) {
	int clientId = event.GetInt("userid"), client = GetClientOfUserId(clientId);
	char textstring[128];
	
	g_iwire = 0;
	
	if (g_bcvar_Tchoice) {
		SetGlobalTransTarget(client);
		Panel panel = CreatePanel();
		
		FormatEx(textstring, sizeof(textstring), "%t:", "Choose a Wire");
		panel.SetTitle(textstring);
		panel.DrawText(" ");
		
		FormatEx(textstring, sizeof(textstring), "%t", "Choose a Wire1");
		panel.DrawText(textstring);
		FormatEx(textstring, sizeof(textstring), "%t", "Choose a Wire2");
		panel.DrawText(textstring);
		panel.DrawText(" ");
		
		FormatEx(textstring, sizeof(textstring), "%t", wirecolours_menu[0]);
		panel.DrawItem(textstring);
		FormatEx(textstring, sizeof(textstring), "%t", wirecolours_menu[1]);
		panel.DrawItem(textstring);
		FormatEx(textstring, sizeof(textstring), "%t", wirecolours_menu[2]);
		panel.DrawItem(textstring);
		FormatEx(textstring, sizeof(textstring), "%t", wirecolours_menu[3]);
		panel.DrawItem(textstring);
		FormatEx(textstring, sizeof(textstring), "%t", wirecolours_menu[4]);
		panel.DrawItem(textstring);
		
		panel.DrawText(" ");
		FormatEx(textstring, sizeof(textstring), "%t", "Exit");
		panel.DrawItem(textstring);
		SendPanelToClient(panel, client, PanelPlant, 5);
		CloseHandle(panel);
	}
}

public void Event_Planted(Event event, const char[] name, bool dontBroadcast) {
	if (g_iwire == 0)g_iwire = GetRandomInt(1, 4);
}


public void Event_Defuse(Event event, const char[] name, bool dontBroadcast) {
	int clientId = event.GetInt("userid"), client = GetClientOfUserId(clientId);
	bool kit = event.GetBool("haskit");
	char textstring[128];
	
	SetGlobalTransTarget(client);
	Panel panel = CreatePanel();
	
	FormatEx(textstring, sizeof(textstring), "%t:", "Choose a Wire");
	panel.SetTitle(textstring);
	FormatEx(textstring, sizeof(textstring), "%t", "Choose a Wire3");
	panel.DrawText(textstring);
	
	panel.DrawText(" ");
	
	FormatEx(textstring, sizeof(textstring), "%t", "Choose a Wire4");
	panel.SetTitle(textstring);
	FormatEx(textstring, sizeof(textstring), "%t", "Choose a Wire5");
	panel.SetTitle(textstring);
	
	panel.SetTitle("");
	
	FormatEx(textstring, sizeof(textstring), "%t", wirecolours_menu[0]);
	panel.DrawItem(textstring);
	FormatEx(textstring, sizeof(textstring), "%t", wirecolours_menu[1]);
	panel.DrawItem(textstring);
	FormatEx(textstring, sizeof(textstring), "%t", wirecolours_menu[2]);
	panel.DrawItem(textstring);
	FormatEx(textstring, sizeof(textstring), "%t", wirecolours_menu[3]);
	panel.DrawItem(textstring);
	FormatEx(textstring, sizeof(textstring), "%t", wirecolours_menu[4]);
	panel.DrawItem(textstring);
	
	DrawPanelText(panel, " ");
	FormatEx(textstring, sizeof(textstring), "%t", "Exit");
	DrawPanelItem(panel, textstring);
	
	if (kit)SendPanelToClient(panel, client, PanelDefuseKit, 5);
	else SendPanelToClient(panel, client, PanelNoKit, 5);
	
	CloseHandle(panel);
}

public int PanelPlant(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select && param2 > 0 && param2 < 6) {
		g_iwire = param2;
		if (Engine_Version == GAME_CSGO)
			CGOPrintToChat(param1, "%t %t %t", "T Choosen1", wirecolours[param2 - 1], "T Choosen2");
		else
			CPrintToChat(param1, "%t %t %t", "T Choosen1", wirecolours[param2 - 1], "T Choosen2");
	}
}

public int PanelDefuseKit(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select && param2 > 0 && param2 < 6) {
		int bombent = FindEntityByClassname(-1, "planted_c4");
		
		if (bombent > 0) {
			char name[32];
			GetClientName(param1, name, sizeof(name));
			
			if (param2 == g_iwire) {
				SetEntPropFloat(bombent, Prop_Send, "m_flDefuseCountDown", 1.0);
				if (Engine_Version == GAME_CSGO)
					CGOPrintToChatAll("{lime} %s %t %t %t", name,"CT Done1", wirecolours[param2 - 1], "CT Done2");
				else
					CPrintToChatAll("{lime} %s %t %t %t", name,"CT Done1", wirecolours[param2 - 1], "CT Done2");
			}
			else {
				SetEntPropFloat(bombent, Prop_Send, "m_flC4Blow", 1.0);
				if (Engine_Version == GAME_CSGO)
					CGOPrintToChatAll("{red} %s %t %t %t %t", name,"CT Fail1", wirecolours[param2 - 1], "CT Fail2", wirecolours[g_iwire - 1]);
				else
					CPrintToChatAll("{fullred} %s %t %t %t %t", name,"CT Fail1", wirecolours[param2 - 1], "CT Fail2", wirecolours[g_iwire - 1]);
			}
		}
	}
}

public int PanelNoKit(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select && param2 > 0 && param2 < 6) {
		int bombent = FindEntityByClassname(-1, "planted_c4");
		
		if (bombent > 0) {
			char name[32];
			GetClientName(param1, name, sizeof(name));
			
			if (param2 == g_iwire && (GetRandomInt(0, 1) || g_bcvar_CtNoKit)) {
				SetEntPropFloat(bombent, Prop_Send, "m_flDefuseCountDown", 1.0);
				if (Engine_Version == GAME_CSGO)
					CGOPrintToChatAll("{lime} %s %t %t %t", name,"CT Done No Kit1", wirecolours[param2 - 1], "CT Done No Kit2");
				else
					CPrintToChatAll("{lime} %s %t %t %t", name, "CT Done No Kit1", wirecolours[param2 - 1], "CT Done No Kit2");
			}
			
			else {
				SetEntPropFloat(bombent, Prop_Send, "m_flC4Blow", 1.0);
				if (param2 != g_iwire) {
					if (Engine_Version == GAME_CSGO)
						CGOPrintToChatAll("{red} %s %t %t %t %t", name,"CT Fail No Kit1a", wirecolours[param2 - 1], "CT Fail No Kit2a", wirecolours[g_iwire - 1]);
					else
						CPrintToChatAll("{fullred} %s %t %t %t %t", name,"CT Fail No Kit1a", wirecolours[param2 - 1], "CT Fail No Kit2a", wirecolours[g_iwire - 1]);
				}
				
				else {
					if (Engine_Version == GAME_CSGO)
						CGOPrintToChatAll("{red} %s %t %t %t!", name,"CT Fail No Kit1b", wirecolours[param2 - 1], "CT Fail No Kit2b");
					else
						CPrintToChatAll("{fullred} %s %t %t %t!", name,"CT Fail No Kit1b", wirecolours[param2 - 1], "CT Fail No Kit2b");
				}
			}
		}
	}
}

public void Event_Abort(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	CancelClientMenu(client);
}
