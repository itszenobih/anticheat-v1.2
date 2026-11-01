#if defined _anticheat_pwn_included
    #endinput
#endif
#define _anticheat_pwn_included

#include <a_samp>

#if !defined AC_ESTE_ADMIN
    #define AC_ESTE_ADMIN(%0) IsPlayerAdmin(%0)
#endif

#define AC_CULOARE_ADMIN 0xFF6A00FF
#define AC_CULOARE_JUCATOR 0xFF4D4DFF
#define AC_INTERVAL 250
#define AC_TIPURI 10
#define AC_MAX_CONTURI_IP 3

#define AC_FLY 0
#define AC_AIRBRK 1
#define AC_TELEPORT 2
#define AC_SPEEDVEH 3
#define AC_JETPACK 4
#define AC_HP 5
#define AC_ARMURA 6
#define AC_ARME 7
#define AC_BANI 8
#define AC_RAPID 9

new const acNume[AC_TIPURI][20] =
{
    "Fly Hack", "Airbreak", "Teleport", "Speed Hack Vehicul", "Jetpack",
    "Health Hack", "Armour Hack", "Arme Hack", "Money Hack", "Rapid Fire"
};

new const acPrag[AC_TIPURI] = {1, 1, 2, 3, 2, 2, 2, 2, 2, 8};

new Float:acPoz[MAX_PLAYERS][2];
new acTickPoz[MAX_PLAYERS];
new acGrace[MAX_PLAYERS];
new acConsec[MAX_PLAYERS][2];
new acStrike[MAX_PLAYERS][AC_TIPURI];
new acStrikeTick[MAX_PLAYERS][AC_TIPURI];
new acUltAlerta[MAX_PLAYERS][AC_TIPURI];
new acTotal[MAX_PLAYERS][AC_TIPURI];
new acArme[MAX_PLAYERS][13];
new Float:acHP[MAX_PLAYERS];
new Float:acArmura[MAX_PLAYERS];
new acBani[MAX_PLAYERS];
new bool:acJet[MAX_PLAYERS];
new acUltimulFoc[MAX_PLAYERS];
new acUltimaArma[MAX_PLAYERS];
new acMesaj[MAX_PLAYERS][128];
new acMesajNr[MAX_PLAYERS];
new acMesajTick[MAX_PLAYERS];
new acMuteLa[MAX_PLAYERS];
new acSpamNr[MAX_PLAYERS];
new acSpamTime[MAX_PLAYERS];

stock AC_Reset(playerid)
{
    acPoz[playerid][0] = 0.0;
    acPoz[playerid][1] = 0.0;
    acTickPoz[playerid] = GetTickCount();
    acGrace[playerid] = GetTickCount() + 3000;
    acConsec[playerid][0] = 0;
    acConsec[playerid][1] = 0;
    for(new t; t < AC_TIPURI; t++)
    {
        acStrike[playerid][t] = 0;
        acStrikeTick[playerid][t] = 0;
        acUltAlerta[playerid][t] = 0;
        acTotal[playerid][t] = 0;
    }
    for(new s; s < 13; s++) acArme[playerid][s] = 0;
    acHP[playerid] = 100.0;
    acArmura[playerid] = 0.0;
    acBani[playerid] = 0;
    acJet[playerid] = false;
    acUltimulFoc[playerid] = 0;
    acUltimaArma[playerid] = 0;
    acMesaj[playerid][0] = 0;
    acMesajNr[playerid] = 0;
    acMesajTick[playerid] = 0;
    acMuteLa[playerid] = 0;
    acSpamNr[playerid] = 0;
    acSpamTime[playerid] = 0;
    return 1;
}

stock AC_Sync(playerid)
{
    GetPlayerHealth(playerid, acHP[playerid]);
    GetPlayerArmour(playerid, acArmura[playerid]);
    for(new s; s < 13; s++)
    {
        new w, a;
        GetPlayerWeaponData(playerid, s, w, a);
        acArme[playerid][s] = (a > 0) ? w : 0;
    }
    acJet[playerid] = (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK);
    return 1;
}

stock AC_Slot(weaponid)
{
    switch(weaponid)
    {
        case 0, 1: return 0;
        case 2, 3, 4, 5, 6, 7, 8, 9: return 1;
        case 22, 23, 24: return 2;
        case 25, 26, 27: return 3;
        case 28, 29, 32: return 4;
        case 30, 31: return 5;
        case 33, 34: return 6;
        case 35, 36, 37, 38: return 7;
        case 16, 17, 18, 39: return 8;
        case 41, 42, 43: return 9;
        case 10, 11, 12, 13, 14, 15: return 10;
        case 44, 45, 46: return 11;
        case 40: return 12;
    }
    return -1;
}

stock AC_IntervalArma(weaponid)
{
    switch(weaponid)
    {
        case 22, 23: return 70;
        case 24: return 150;
        case 25: return 350;
        case 26, 27: return 200;
        case 28, 29, 32: return 30;
        case 30, 31: return 35;
        case 33: return 350;
        case 34: return 450;
    }
    return 0;
}

stock AC_VehiculExceptat(model)
{
    switch(model)
    {
        case 417, 425, 447, 460, 469, 476, 487, 488, 497, 511, 512, 513, 519, 520, 548, 553, 563, 577, 592, 593: return 1;
        case 449, 537, 538, 569, 570, 590: return 1;
    }
    return 0;
}

stock AC_NumarConturiIP(playerid)
{
    new ip[16], altip[16], nr;
    GetPlayerIp(playerid, ip, sizeof(ip));
    for(new i; i < MAX_PLAYERS; i++)
    {
        if(i == playerid || !IsPlayerConnected(i) || IsPlayerNPC(i)) continue;
        GetPlayerIp(i, altip, sizeof(altip));
        if(!strcmp(ip, altip)) nr++;
    }
    return nr;
}

forward AC_KickIP(playerid);
public AC_KickIP(playerid)
{
    if(IsPlayerConnected(playerid)) Kick(playerid);
    return 1;
}

stock AC_TrimiteAdmini(const text[])
{
    for(new i; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && !IsPlayerNPC(i) && AC_ESTE_ADMIN(i)) SendClientMessage(i, AC_CULOARE_ADMIN, text);
    }
    return 1;
}

stock AC_Suspect(playerid, tip, const detalii[])
{
    new acum = GetTickCount();
    if(acum - acStrikeTick[playerid][tip] > 10000) acStrike[playerid][tip] = 0;
    acStrikeTick[playerid][tip] = acum;
    acStrike[playerid][tip]++;
    if(acStrike[playerid][tip] < acPrag[tip]) return 0;
    acStrike[playerid][tip] = 0;
    if(acUltAlerta[playerid][tip] != 0 && acum - acUltAlerta[playerid][tip] < 20000) return 0;
    acUltAlerta[playerid][tip] = acum;
    acTotal[playerid][tip]++;
    new nume[MAX_PLAYER_NAME], msg[144];
    GetPlayerName(playerid, nume, sizeof(nume));
    format(msg, sizeof(msg), "[AntiCheat] %s [%d] suspect de %s (%s) | ping %d | alerte: %d", nume, playerid, acNume[tip], detalii, GetPlayerPing(playerid), acTotal[playerid][tip]);
    AC_TrimiteAdmini(msg);
    return 1;
}

forward AC_Verifica();
public AC_Verifica()
{
    new acum = GetTickCount();
    for(new i; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i) || IsPlayerNPC(i)) continue;
        AC_VerificaJucator(i, acum);
    }
    return 1;
}

stock AC_VerificaJucator(playerid, acum)
{
    new stare = GetPlayerState(playerid);
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new Float:px = acPoz[playerid][0];
    new Float:py = acPoz[playerid][1];
    new dt = acum - acTickPoz[playerid];
    acPoz[playerid][0] = x;
    acPoz[playerid][1] = y;
    acTickPoz[playerid] = acum;
    if(stare != PLAYER_STATE_ONFOOT && stare != PLAYER_STATE_DRIVER && stare != PLAYER_STATE_PASSENGER)
    {
        acConsec[playerid][0] = 0;
        acConsec[playerid][1] = 0;
        return 0;
    }
    if(AC_ESTE_ADMIN(playerid)) return 0;
    if(acum < acGrace[playerid] || dt <= 0 || dt > 1500 || GetPlayerPing(playerid) > 500)
    {
        acConsec[playerid][0] = 0;
        acConsec[playerid][1] = 0;
        return 0;
    }
    new det[64];
    new Float:dist2d = floatsqroot((x - px) * (x - px) + (y - py) * (y - py));
    if(stare == PLAYER_STATE_ONFOOT)
    {
        new bool:surf = (GetPlayerSurfingVehicleID(playerid) != INVALID_VEHICLE_ID || GetPlayerSurfingObjectID(playerid) != INVALID_OBJECT_ID);
        if(!surf && GetPlayerWeapon(playerid) != 46 && GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_USEJETPACK)
        {
            if(dist2d > 50.0)
            {
                format(det, sizeof(det), "%.1f m in %d ms", dist2d, dt);
                AC_Suspect(playerid, AC_TELEPORT, det);
                acConsec[playerid][1] = 0;
            }
            else
            {
                new Float:viteza = dist2d / float(dt) * 1000.0;
                if(viteza > 28.0)
                {
                    acConsec[playerid][1]++;
                    if(acConsec[playerid][1] >= 3)
                    {
                        format(det, sizeof(det), "%.1f m/s pe jos", viteza);
                        AC_Suspect(playerid, AC_AIRBRK, det);
                        acConsec[playerid][1] = 0;
                    }
                }
                else acConsec[playerid][1] = 0;
            }
            new Float:vx, Float:vy, Float:vz;
            GetPlayerVelocity(playerid, vx, vy, vz);
            new anim = GetPlayerAnimationIndex(playerid);
            new Float:hs = floatsqroot(vx * vx + vy * vy);
            if((anim == 958 || anim == 1130 || anim == 1195) && hs > 0.12 && vz > -0.06)
            {
                acConsec[playerid][0]++;
                if(acConsec[playerid][0] >= 6)
                {
                    format(det, sizeof(det), "in aer fara cadere, viteza %.2f", hs);
                    AC_Suspect(playerid, AC_FLY, det);
                    acConsec[playerid][0] = 0;
                }
            }
            else acConsec[playerid][0] = 0;
        }
        else
        {
            acConsec[playerid][0] = 0;
            acConsec[playerid][1] = 0;
        }
    }
    else if(stare == PLAYER_STATE_DRIVER)
    {
        acConsec[playerid][0] = 0;
        acConsec[playerid][1] = 0;
        new vehid = GetPlayerVehicleID(playerid);
        new model = GetVehicleModel(vehid);
        if(dist2d > 150.0)
        {
            format(det, sizeof(det), "%.1f m in %d ms cu vehicul", dist2d, dt);
            AC_Suspect(playerid, AC_TELEPORT, det);
        }
        else if(!AC_VehiculExceptat(model))
        {
            new Float:vx, Float:vy, Float:vz;
            GetVehicleVelocity(vehid, vx, vy, vz);
            new Float:kmh = floatsqroot(vx * vx + vy * vy + vz * vz) * 180.0;
            if(kmh > 340.0)
            {
                format(det, sizeof(det), "%.0f km/h, model %d", kmh, model);
                AC_Suspect(playerid, AC_SPEEDVEH, det);
            }
        }
    }
    else
    {
        acConsec[playerid][0] = 0;
        acConsec[playerid][1] = 0;
    }
    if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
    {
        if(!acJet[playerid]) AC_Suspect(playerid, AC_JETPACK, "jetpack fara permisiune");
    }
    else acJet[playerid] = false;
    new Float:hp, Float:arm;
    GetPlayerHealth(playerid, hp);
    GetPlayerArmour(playerid, arm);
    if(hp > acHP[playerid] + 1.0)
    {
        format(det, sizeof(det), "%.0f -> %.0f hp", acHP[playerid], hp);
        AC_Suspect(playerid, AC_HP, det);
    }
    acHP[playerid] = hp;
    if(arm > acArmura[playerid] + 1.0)
    {
        format(det, sizeof(det), "%.0f -> %.0f armura", acArmura[playerid], arm);
        AC_Suspect(playerid, AC_ARMURA, det);
    }
    acArmura[playerid] = arm;
    new bani = GetPlayerMoney(playerid);
    if(bani > acBani[playerid])
    {
        format(det, sizeof(det), "+%d$ nejustificati", bani - acBani[playerid]);
        AC_Suspect(playerid, AC_BANI, det);
    }
    acBani[playerid] = bani;
    for(new s; s < 13; s++)
    {
        new w, a;
        GetPlayerWeaponData(playerid, s, w, a);
        if(w > 0 && a > 0 && w != acArme[playerid][s])
        {
            format(det, sizeof(det), "arma %d, ammo %d", w, a);
            if(AC_Suspect(playerid, AC_ARME, det)) acArme[playerid][s] = w;
        }
    }
    return 1;
}

stock AC_SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
    acGrace[playerid] = GetTickCount() + 3000;
    return SetPlayerPos(playerid, x, y, z);
}

stock AC_SetPlayerPosFindZ(playerid, Float:x, Float:y, Float:z)
{
    acGrace[playerid] = GetTickCount() + 3000;
    return SetPlayerPosFindZ(playerid, x, y, z);
}

stock AC_SetVehiclePos(vehicleid, Float:x, Float:y, Float:z)
{
    for(new i; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && GetPlayerVehicleID(i) == vehicleid) acGrace[i] = GetTickCount() + 3000;
    }
    return SetVehiclePos(vehicleid, x, y, z);
}

stock AC_PutPlayerInVehicle(playerid, vehicleid, seatid)
{
    acGrace[playerid] = GetTickCount() + 3000;
    return PutPlayerInVehicle(playerid, vehicleid, seatid);
}

stock AC_SetPlayerInterior(playerid, interiorid)
{
    acGrace[playerid] = GetTickCount() + 2000;
    return SetPlayerInterior(playerid, interiorid);
}

stock AC_SetPlayerHealth(playerid, Float:health)
{
    acHP[playerid] = health;
    return SetPlayerHealth(playerid, health);
}

stock AC_SetPlayerArmour(playerid, Float:armour)
{
    acArmura[playerid] = armour;
    return SetPlayerArmour(playerid, armour);
}

stock AC_GivePlayerWeapon(playerid, weaponid, ammo)
{
    new slot = AC_Slot(weaponid);
    if(slot >= 0) acArme[playerid][slot] = weaponid;
    return GivePlayerWeapon(playerid, weaponid, ammo);
}

stock AC_ResetPlayerWeapons(playerid)
{
    for(new s; s < 13; s++) acArme[playerid][s] = 0;
    return ResetPlayerWeapons(playerid);
}

stock AC_GivePlayerMoney(playerid, money)
{
    acBani[playerid] += money;
    return GivePlayerMoney(playerid, money);
}

stock AC_ResetPlayerMoney(playerid)
{
    acBani[playerid] = 0;
    return ResetPlayerMoney(playerid);
}

stock AC_SetPlayerSpecialAction(playerid, actionid)
{
    acJet[playerid] = (actionid == SPECIAL_ACTION_USEJETPACK);
    return SetPlayerSpecialAction(playerid, actionid);
}

#define SetPlayerPos AC_SetPlayerPos
#define SetPlayerPosFindZ AC_SetPlayerPosFindZ
#define SetVehiclePos AC_SetVehiclePos
#define PutPlayerInVehicle AC_PutPlayerInVehicle
#define SetPlayerInterior AC_SetPlayerInterior
#define SetPlayerHealth AC_SetPlayerHealth
#define SetPlayerArmour AC_SetPlayerArmour
#define GivePlayerWeapon AC_GivePlayerWeapon
#define ResetPlayerWeapons AC_ResetPlayerWeapons
#define GivePlayerMoney AC_GivePlayerMoney
#define ResetPlayerMoney AC_ResetPlayerMoney
#define SetPlayerSpecialAction AC_SetPlayerSpecialAction

public OnGameModeInit()
{
    SetTimer("AC_Verifica", AC_INTERVAL, true);
    for(new i; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        AC_Reset(i);
        AC_Sync(i);
        acBani[i] = GetPlayerMoney(i);
    }
    #if defined AC_OnGameModeInit
        return AC_OnGameModeInit();
    #else
        return 1;
    #endif
}
#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit AC_OnGameModeInit
#if defined AC_OnGameModeInit
    forward AC_OnGameModeInit();
#endif

public OnPlayerConnect(playerid)
{
    AC_Reset(playerid);
    acBani[playerid] = GetPlayerMoney(playerid);
    if(!IsPlayerNPC(playerid) && AC_NumarConturiIP(playerid) >= AC_MAX_CONTURI_IP)
    {
        new nume[MAX_PLAYER_NAME], ip[16], msg[144];
        GetPlayerName(playerid, nume, sizeof(nume));
        GetPlayerIp(playerid, ip, sizeof(ip));
        SendClientMessage(playerid, AC_CULOARE_JUCATOR, "[AntiCheat] Maxim 3 conturi conectate de pe acelasi IP. Ai primit kick.");
        format(msg, sizeof(msg), "[AntiCheat] %s [%d] a primit kick: peste %d conturi pe IP-ul %s.", nume, playerid, AC_MAX_CONTURI_IP, ip);
        AC_TrimiteAdmini(msg);
        SetTimerEx("AC_KickIP", 500, false, "i", playerid);
        return 1;
    }
    #if defined AC_OnPlayerConnect
        return AC_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect AC_OnPlayerConnect
#if defined AC_OnPlayerConnect
    forward AC_OnPlayerConnect(playerid);
#endif

public OnPlayerSpawn(playerid)
{
    acGrace[playerid] = GetTickCount() + 3000;
    AC_Sync(playerid);
    #if defined AC_OnPlayerSpawn
        return AC_OnPlayerSpawn(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn AC_OnPlayerSpawn
#if defined AC_OnPlayerSpawn
    forward AC_OnPlayerSpawn(playerid);
#endif

public OnPlayerDeath(playerid, killerid, reason)
{
    acGrace[playerid] = GetTickCount() + 6000;
    for(new s; s < 13; s++) acArme[playerid][s] = 0;
    #if defined AC_OnPlayerDeath
        return AC_OnPlayerDeath(playerid, killerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDeath
    #undef OnPlayerDeath
#else
    #define _ALS_OnPlayerDeath
#endif
#define OnPlayerDeath AC_OnPlayerDeath
#if defined AC_OnPlayerDeath
    forward AC_OnPlayerDeath(playerid, killerid, reason);
#endif

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    acGrace[playerid] = GetTickCount() + 1500;
    #if defined AC_OnPlayerStateChange
        return AC_OnPlayerStateChange(playerid, newstate, oldstate);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerStateChange
    #undef OnPlayerStateChange
#else
    #define _ALS_OnPlayerStateChange
#endif
#define OnPlayerStateChange AC_OnPlayerStateChange
#if defined AC_OnPlayerStateChange
    forward AC_OnPlayerStateChange(playerid, newstate, oldstate);
#endif

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
    acGrace[playerid] = GetTickCount() + 2000;
    #if defined AC_OnPlayerInteriorChange
        return AC_OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerInteriorChange
    #undef OnPlayerInteriorChange
#else
    #define _ALS_OnPlayerInteriorChange
#endif
#define OnPlayerInteriorChange AC_OnPlayerInteriorChange
#if defined AC_OnPlayerInteriorChange
    forward AC_OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid);
#endif

public OnPlayerPickUpPickup(playerid, pickupid)
{
    acGrace[playerid] = GetTickCount() + 3000;
    #if defined AC_OnPlayerPickUpPickup
        return AC_OnPlayerPickUpPickup(playerid, pickupid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerPickUpPickup
    #undef OnPlayerPickUpPickup
#else
    #define _ALS_OnPlayerPickUpPickup
#endif
#define OnPlayerPickUpPickup AC_OnPlayerPickUpPickup
#if defined AC_OnPlayerPickUpPickup
    forward AC_OnPlayerPickUpPickup(playerid, pickupid);
#endif

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
    if(!AC_ESTE_ADMIN(playerid))
    {
        new acum = GetTickCount();
        new minim = AC_IntervalArma(weaponid);
        if(minim > 0 && weaponid == acUltimaArma[playerid] && acum - acUltimulFoc[playerid] < minim)
        {
            new det[48];
            format(det, sizeof(det), "arma %d, %d ms intre focuri", weaponid, acum - acUltimulFoc[playerid]);
            AC_Suspect(playerid, AC_RAPID, det);
        }
        acUltimulFoc[playerid] = acum;
        acUltimaArma[playerid] = weaponid;
    }
    #if defined AC_OnPlayerWeaponShot
        return AC_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, fX, fY, fZ);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerWeaponShot
    #undef OnPlayerWeaponShot
#else
    #define _ALS_OnPlayerWeaponShot
#endif
#define OnPlayerWeaponShot AC_OnPlayerWeaponShot
#if defined AC_OnPlayerWeaponShot
    forward AC_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
#endif

public OnPlayerText(playerid, text[])
{
    if(!AC_ESTE_ADMIN(playerid))
    {
        new acum = gettime();
        new msg[144];
        if(acum < acMuteLa[playerid])
        {
            format(msg, sizeof(msg), "[AntiSpam] Ai mute inca %d secunde.", acMuteLa[playerid] - acum);
            SendClientMessage(playerid, AC_CULOARE_JUCATOR, msg);
            return 0;
        }
        new tick = GetTickCount();
        if(!strcmp(text, acMesaj[playerid], true) && tick - acMesajTick[playerid] < 10000) acMesajNr[playerid]++;
        else
        {
            acMesajNr[playerid] = 1;
            strmid(acMesaj[playerid], text, 0, strlen(text), 128);
        }
        acMesajTick[playerid] = tick;
        if(acMesajNr[playerid] >= 3)
        {
            acMesajNr[playerid] = 0;
            acMesaj[playerid][0] = 0;
            if(acum - acSpamTime[playerid] > 1800) acSpamNr[playerid] = 0;
            acSpamNr[playerid]++;
            acSpamTime[playerid] = acum;
            new durata = (acSpamNr[playerid] == 1) ? 30 : 600;
            acMuteLa[playerid] = acum + durata;
            new nume[MAX_PLAYER_NAME];
            GetPlayerName(playerid, nume, sizeof(nume));
            if(durata == 30) format(msg, sizeof(msg), "[AntiSpam] Ai primit mute 30 de secunde pentru spam.");
            else format(msg, sizeof(msg), "[AntiSpam] Ai primit mute 10 minute pentru spam repetat.");
            SendClientMessage(playerid, AC_CULOARE_JUCATOR, msg);
            format(msg, sizeof(msg), "[AntiSpam] %s [%d] a primit mute %s pentru mesaje identice.", nume, playerid, (durata == 30) ? ("30 secunde") : ("10 minute"));
            AC_TrimiteAdmini(msg);
            return 0;
        }
    }
    #if defined AC_OnPlayerText
        return AC_OnPlayerText(playerid, text);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerText
    #undef OnPlayerText
#else
    #define _ALS_OnPlayerText
#endif
#define OnPlayerText AC_OnPlayerText
#if defined AC_OnPlayerText
    forward AC_OnPlayerText(playerid, text[]);
#endif

public OnPlayerCommandText(playerid, cmdtext[])
{
    if(!strcmp(cmdtext, "/acinfo", true, 7) && (cmdtext[7] == 0 || cmdtext[7] == ' ') && AC_ESTE_ADMIN(playerid))
    {
        new tinta = (cmdtext[7] == ' ') ? strval(cmdtext[8]) : -1;
        if(cmdtext[7] != ' ' || tinta < 0 || tinta >= MAX_PLAYERS || !IsPlayerConnected(tinta))
        {
            SendClientMessage(playerid, AC_CULOARE_ADMIN, "Folosire: /acinfo [id]");
            return 1;
        }
        new nume[MAX_PLAYER_NAME], msg[144];
        GetPlayerName(tinta, nume, sizeof(nume));
        format(msg, sizeof(msg), "[AntiCheat] Alerte pentru %s [%d]:", nume, tinta);
        SendClientMessage(playerid, AC_CULOARE_ADMIN, msg);
        for(new t; t < AC_TIPURI; t++)
        {
            if(acTotal[tinta][t] == 0) continue;
            format(msg, sizeof(msg), "%s: %d", acNume[t], acTotal[tinta][t]);
            SendClientMessage(playerid, AC_CULOARE_ADMIN, msg);
        }
        return 1;
    }
    #if defined AC_OnPlayerCommandText
        return AC_OnPlayerCommandText(playerid, cmdtext);
    #else
        return 0;
    #endif
}
#if defined _ALS_OnPlayerCommandText
    #undef OnPlayerCommandText
#else
    #define _ALS_OnPlayerCommandText
#endif
#define OnPlayerCommandText AC_OnPlayerCommandText
#if defined AC_OnPlayerCommandText
    forward AC_OnPlayerCommandText(playerid, cmdtext[]);
#endif
