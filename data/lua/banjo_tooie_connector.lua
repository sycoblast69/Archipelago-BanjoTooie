-- Banjo Tooie Connector Lua
-- Created by Mike Jackson (jjjj12212) 
-- with the help of Rose (Oktorose), the OOT Archipelago team, ScriptHawk BT.lua
-- modifications from Unalive, HemiJackson & fhnnhf 

-- local RDRAMBase = 0x80000000;
-- local RDRAMSize = 0x800000;
-- local character_state = 0x136F63;
-- local camera_pointer_pointer = 0x127728;
-- local global_flag_pointer = 0x12C780;

local socket = require("socket")
local json = require('json')
local math = require('math')
require('common')

local SCRIPT_VERSION = 4
local BT_VERSION = "V3.4"
local PLAYER = ""
local SEED = 0

local BT_SOCK = nil

local STATE_OK = "Ok"
local STATE_TENTATIVELY_CONNECTED = "Tentatively Connected"
local STATE_INITIAL_CONNECTION_MADE = "Initial Connection Made"
local STATE_UNINITIALIZED = "Uninitialized"
local PREV_STATE = ""
local CUR_STATE =  STATE_UNINITIALIZED
local FRAME = 0
local VERROR = false
local CLIENT_VERSION = 0


local DEBUG = false
local DEBUG_SILO = false
local DEBUG_JIGGY = false
local DEBUG_TREBLE = false
local DEBUG_NOTES = false
local DEBUG_HONEY = false
local DEBUG_GLOWBO = false
local DEBUG_ROYSTEN = false
local DEBUG_CHUFFY = false
local DEBUG_STOPNSWAP = false
local DEBUG_STATION = false
local DEBUG_PAGES = false
local DEBUG_CHEATO = false
local DEBUG_LEVEL = false
local DEBUG_HONEYCOMB = false
local DEBUG_DOUBLOON = false
local DEBUG_AMAZE = false
local DEBUGLVL2 = false
local DEBUGLVL3 = false

local BTMODELOBJ = nil;
local BTRAMOBJ = nil;
local BTCONSUMEOBJ = nil;

local DEMO_MODE = true;
local SKIP_TOT = ""
local MINIGAMES = ""
local INIT_COMPLETE = false
local PAUSED = false;
local TOTALS_MENU = false;
local OBJ_TOTALS_MENU = false;
local SAVE_GAME = false;
local TOKEN_ANNOUNCE = false;

-------- DPAD Vars -----------
local SNEAK = false;

local CHECK_MOVES_R = false;
local CHECK_MOVES_L = false;
local CHECK_MOVES_D = false;

local AIMASSIST = false;
local AIMASSIST_HOLD = false;

local SUPERBANJO = false;
local SUPERBANJO_HOLD = false;

local REFILL_HOLD = false;

local REGEN = false;
local REGEN_HOLD = false;

local FPS = false;
local FPS_HOLD = false;
------------------------------
local TEXT_TIMER = 2;
local TEXT_START = false;

local ENABLE_AP_BK_MOVES = 0; -- 0: disable 1: Talon Trot + Full Jump 2: ALL REMOVED
local ENABLE_AP_CHEATO_REWARDS = false;
local ENABLE_AP_HONEYB_REWARDS = false;
local ENABLE_AP_CHUFFY = false;
local ENABLE_AP_WORLDS = false;
local ENABLE_AP_MYSTERY = false;
local ACTIVATE_TEXT_OVERLAY = false;
local AP_MESSAGES = {};
local TEXT_COLOUR = 0;

local GAME_LOADED = false;

-------------- MAP VARS -------------
local CURRENT_MAP = nil;


-------------- TRANSFORM VARS -----
local FAKE_MUMBO = false;
local REVERTING_MUMBO = false
local LOGIC = ""
local GOLIATH = false
local VAN = false
local SPLITUP = false
local TALONTROT = false
local TALLJUMP = false
local TURBOTRAINERS = false
local SPRINGYSTEPSHOES = false
local FLAPFLIP = false
local LEGSPRING = false
local GRIPGRAB = false
local CLIMB = false
local AIRRATATATRAP = false
local FLUTTER = false

-------------- TOTALS VARS -----------
local TOTAL_HONEYCOMBS = 0;
local TOTAL_JIGGY = 0;
local TOTAL_MUMBO_TOKENS = 0;
local TOTAL_TREBLE = 0;
local TOTAL_PAGES = 0;
local TOTAL_DOUBLOONS = 0;
local TOTAL_NOTES = 0;


-------------- NOTES VARS -----------
local BMM_BACKUP_NOTES = false;
local AGI_NOTES_SET = false;

-------------- JINJO VARS -----------
local BMM_BACKUP_JINJO = false;

-------------- SILO VARS ------------
local SILO_TIMER = 0;
local LOAD_BMK_MOVES = false; -- If close to Silo
local SILOS_LOADED = false; -- Handles if learned a move at Silo
local LOAD_SILO_NOTES = false;
local TEMP_EGGS = false; -- set if close to Silo IF no other eggs are given

-------------- SKIP VARS ------------
local OPEN_HAG1 = false;
local SKIP_PUZZLES = false;
local SKIP_KLUNGO = false;
local SKIP_KING = true;
local TOT_SET_COMPLETE = false;

-------------- MYSTERY VARS -----------
local EGGS_CLEARED = true;
local KEY_DROPPED = false;
local KEY_GRABBED = false;
local WAIT_FOR_HATCH = false;

-------------- STATION VARS -----------
local STATION_BTN_TIMER = 0;

-------------- PROGRESSIVES -----------
local BEAK_BUST = false
local BILL_DRILL = false;
local FIR_EGGS = false;
local GRE_EGGS = false;
local ICE_EGGS = false;
local CLK_EGGS = false;
local WADE_SHOE = false;
local TURB_SHOE = false;
local SPRG_SHOE = false;
local CLAW_SHOE = false
-------------- CHUFFY VARS ------------
DEAD_COAL_CHECK = 0;
CHUFFY_MAP_TRANS = false;
CHUFFY_STOP_WATCH = true;
LEVI_PAD_MOVED = false;

local BATH_PADS_QOL = false

-------------- GOAL TYPE VARS ------------
local GOAL_TYPE = nil;
local MGH_LENGTH = nil;
local BH_LENGTH = nil;
local JFR_LENGTH = nil;
local TH_LENGTH = nil;

--------------- ROYSTEN VARS --------------------
local FAST_SWIM = false
local DOUBLE_AIR = false

--------------- DEATH LINK ----------------------
local KILL_BANJO = false
local DEATH_LINK = false
local DETECT_DEATH = false;
local CHECK_DEATH = false;

---------------- AMAZE-O-GAZE VARS ---------------
local GOGGLES = false;

---------------- ROAR VARS ---------------
local ROAR = false;

---------------- IOH SILO VARS -------------
local OPEN_SILO = "NONE"


-------------- ENCOURAGEMENT MESSAGES ------------
local ENCOURAGEMENT = {
         [1]  = {message = " GUH-HUH!"},
         [2]  = {message = " BREEE!"},
         [3]  = {message = " EEKUM BOKUM!"},
         [4]  = {message = " YEEHAW!"},
         [5]  = {message = " JINJOO!!"},
         [6]  = {message = " WAHEY!!!"},
         [7]  = {message = " ROOOOO!!!"},
         [8]  = {message = " OOMANAKA!!!"}
}


local receive_map = { -- [ap_id] = item_id; --  Required for Async Items
    ["NA"] = "NA"
}


BTHACK = {
    RDRAMBase = 0x80000000,
    RDRAMSize = 0x800000,
    base_index = 0x400000,
    version = 0x0,
    pc = 0x4,
    pc_settings = 0x8,
        setting_seed = 0x0,
        setting_chuffy = 0x4,
        setting_puzzle = 0x5,
        setting_klungo = 0x6,
        setting_tot = 0x7,
        setting_minigames = 0x8,
        setting_jiggy_requirements = 0x9,
        setting_open_silos = 0x14,
    pc_items = 0xC,
    pc_exit_map = 0x10,
        exit_on_map = 0x0,
        exit_og_map = 0x2,
        exit_to_map = 0x4,
        exit_og_exit = 0x6,
        exit_to_exit = 0x7,
        exit_map_struct_size = 0x8,
        world_index = 0,
    n64 = 0x14,
    real_flags = 0x18,
    fake_flags = 0x1C
}

function BTHACK:new(t)
    t = t or {}
    setmetatable(t, self)
    self.__index = self
   return self
end

function BTHACK:isPointer(value)
    return type(value) == "number" and value >= self.RDRAMBase and value < self.RDRAMBase + self.RDRAMSize;
end

function BTHACK:dereferencePointer(addr)
    if type(addr) == "number" and addr >= 0 and addr < (self.RDRAMSize - 4) then
        local address = mainmemory.read_u32_be(addr);
        if BTRAM:isPointer(address) then
            return address - self.RDRAMBase;
        else
            if DEBUGLVL3 == true
            then
                print("Failed to Defref:")
                print(address)
            end
            return nil;
        end
    else
        if DEBUGLVL3 == true
        then
            print("Number too big or not number:")
            print(tostring(addr))
        end
    end
end

function BTHACK:checkFakeFlag(offset, byte)
    local hackPointerIndex = BTHACK:dereferencePointer(self.base_index);
	local fakeptr = BTHACK:dereferencePointer(self.fake_flags + hackPointerIndex);
    if fakeptr == nil
    then
        return false
    end
    local currentValue = mainmemory.readbyte(fakeptr + offset);
    if bit.check(currentValue, byte) then
        return true;
    end
    return false;
end

function BTHACK:checkRealFlag(offset, byte)
    local hackPointerIndex = BTHACK:dereferencePointer(self.base_index);
	local realptr = BTHACK:dereferencePointer(self.real_flags + hackPointerIndex);
    -- if realptr == nil
    -- then
    --     return false
    -- end
    local currentValue = mainmemory.readbyte(realptr + offset);
    if bit.check(currentValue, byte) then
        return true;
    end
    return false;
end

function BTHACK:getSettingPointer()
    local hackPointerIndex = BTHACK:dereferencePointer(self.base_index);
	return BTHACK:dereferencePointer(self.pc_settings + hackPointerIndex);
end

function BTHACK:setSettingSeed(seed)
    mainmemory.write_u32_be(self.setting_seed + BTHACK:getSettingPointer(), seed);
end

function BTHACK:setSettingChuffy(chuffy)
    mainmemory.writebyte(self.setting_chuffy + BTHACK:getSettingPointer(), chuffy);
end

function BTHACK:setSettingPuzzle(puzzle)
    mainmemory.writebyte(self.setting_puzzle + BTHACK:getSettingPointer(), puzzle);
end

function BTHACK:setSettingKlungo(klungo)
    mainmemory.writebyte(self.setting_klungo + BTHACK:getSettingPointer(), klungo);
end

function BTHACK:setSettingToT(tot)
    mainmemory.writebyte(self.setting_tot + BTHACK:getSettingPointer(), tot);
end

function BTHACK:setSettingMinigames(minigames)
    mainmemory.writebyte(self.setting_minigames + BTHACK:getSettingPointer(), minigames);
end

function BTHACK:setSettingJiggyRequirements(index, jiggy_requirements)
    mainmemory.writebyte(self.setting_jiggy_requirements + index + BTHACK:getSettingPointer() , jiggy_requirements);
end

function BTHACK:setSettingOpenSilos(index, open)
    mainmemory.writebyte(self.setting_open_silos + index + BTHACK:getSettingPointer(), open);
end

function BTHACK:getItemsPointer()
    local hackPointerIndex = BTHACK:dereferencePointer(self.base_index);
	return BTHACK:dereferencePointer(self.pc_items + hackPointerIndex);
end

function BTHACK:getItem(index)
    mainmemory.readbyte(index + self:getItemsPointer());
end

function BTHACK:setItem(index, value)
    mainmemory.writebyte(index + self:getItemsPointer(), value);
end

function BTHACK:getMap()
    local hackPointerIndex = BTHACK:dereferencePointer(self.base_index);
    if hackPointerIndex == nil
    then
        return 0x0
    end
	local n64_ptr = BTHACK:dereferencePointer(self.n64 + hackPointerIndex);
    return mainmemory.read_u16_be(n64_ptr + 4)
end

function BTHACK:setWorldEntrance(currentWorldId, newWorldId, entranceId, currentMap, newEntanceId)
    local hackPointerIndex = BTHACK:dereferencePointer(self.base_index);
    if hackPointerIndex == nil
    then
        return false
    end
    local exit_maps_ptr = BTHACK:dereferencePointer(self.pc_exit_map + hackPointerIndex);
    if exit_maps_ptr == nil
    then
        return false
    end
    local world_index = self.world_index * self.exit_map_struct_size
    self.world_index = self.world_index + 1
    mainmemory.write_u16_be(exit_maps_ptr + world_index + self.exit_on_map, currentMap)
    mainmemory.write_u16_be(exit_maps_ptr + world_index + self.exit_og_map, currentWorldId)
    mainmemory.write_u16_be(exit_maps_ptr + world_index + self.exit_to_map, newWorldId)
    mainmemory.writebyte(exit_maps_ptr + world_index + self.exit_to_exit, newEntanceId)
    mainmemory.writebyte(exit_maps_ptr + world_index + self.exit_og_exit, entranceId)
    return true
end


-- Class that requires RAM reading and writing
BTRAM = {
    RDRAMBase = 0x80000000;
    RDRAMSize = 0x800000;
    player_ptr = 0x135490;
    player_index = 0x1354DF;
    flag_block_ptr = 0x12C770;
    map_addr = 0x132DC2;
    next_map = 0x127640;
    entrance_id = 0x127643;
    player_pos_ptr = 0xE4,
    animationPointer = 0x136E70,
    movement_ptr = 0x120,
    current_state = 0x4,
    map_dest = 0x045702,
    character_state = 0x136F63,
    character_change = 0x12704C,
    tmp_flg_ptr = 0x12C774,
}

function BTRAM:new(t)
    t = t or {}
    setmetatable(t, self)
    self.__index = self
   return self
end

function BTRAM:isPointer(value)
    return type(value) == "number" and value >= self.RDRAMBase and value < self.RDRAMBase + self.RDRAMSize;
end

function BTRAM:dereferencePointer(addr)
    if type(addr) == "number" and addr >= 0 and addr < (self.RDRAMSize - 4) then
        local address = mainmemory.read_u32_be(addr);
        if BTRAM:isPointer(address) then
            return address - self.RDRAMBase;
        else
            if DEBUGLVL3 == true
            then
                print("Failed to Defref:")
                print(address)
            end
            return nil;
        end
    else
        if DEBUGLVL3 == true
        then
            print("Number too big or not number:")
            print(tostring(addr))
        end
    end
end

function BTRAM:banjoPTR()
    local playerPointerIndex = mainmemory.readbyte(self.player_index);
	local addressSpace = BTRAM:dereferencePointer(self.player_ptr + 4 * playerPointerIndex);
    return addressSpace;
end

function BTRAM:getBanjoPos()
    local pos = { 
        ["Xpos"] = 0,
        ["Ypos"] = 0,
        ["Zpos"] = 0
    };
    local banjo = BTRAM:banjoPTR()
    if banjo == nil
    then
        return false;
    end
    local plptr = BTRAM:dereferencePointer(banjo + self.player_pos_ptr);
    if plptr == nil
    then
        return false;
    end
    
    pos["Xpos"] = mainmemory.readfloat(plptr + 0x0, true);
    pos["Ypos"] = mainmemory.readfloat(plptr + 0x4, true);
    pos["Zpos"] = mainmemory.readfloat(plptr + 0x8, true);
    return pos;
end

function BTRAM:getBanjoSelectedEgg()
    local banjo = BTRAM:banjoPTR()
    if banjo == nil
    then
        return false;
    end
    return mainmemory.read_u16_be(banjo + 0x554)
end

function BTRAM:setBanjoSelectedEgg(egg)
    local banjo = BTRAM:banjoPTR()
    if banjo == nil
    then
        return false;
    end
    return mainmemory.write_u16_be(banjo + 0x554, egg)
end

function BTRAM:setBanjoPos(Xnew, Ynew, Znew, Yvel)
    local banjo = BTRAM:banjoPTR()
    if banjo == nil
    then
        return false;
    end
    local plptr = BTRAM:dereferencePointer(banjo + self.player_pos_ptr);
    if plptr == nil
    then
        return false;
    end
	if Ynew ~= nil and Yvel ~= nil
    then
        mainmemory.writefloat(plptr + 0x04, Ynew, true);
        mainmemory.writefloat(plptr + 0x04 + 12, Ynew, true);
        mainmemory.writefloat(plptr + 0x04 + 24, Ynew, true);
        mainmemory.writefloat(plptr + 0xC8 + 0x14, Yvel, true);
    end
    if Xnew ~= nil
    then
        mainmemory.writefloat(plptr + 0x00, Xnew, true);
        mainmemory.writefloat(plptr + 0x00 + 12, Xnew, true);
        mainmemory.writefloat(plptr + 0x00 + 24, Xnew, true);
    end
    if Znew ~= nil
    then
        mainmemory.writefloat(plptr + 0x08, Znew, true);
        mainmemory.writefloat(plptr + 0x08 + 12, Znew, true);
        mainmemory.writefloat(plptr + 0x08 + 24, Znew, true);
    end
end

function BTRAM:getBanjoTState()
    return mainmemory.readbyte(self.character_state);
end

function BTRAM:setBanjoTState(Tstate)
    return mainmemory.writebyte(self.character_state, Tstate);
end

function BTRAM:getTransformation()
    return mainmemory.read_u8(self.character_change);
end

function BTRAM:setTransformation(Tstate)
    mainmemory.write_u8(self.character_change, Tstate)
end

function BTRAM:getBanjoMovementState()
    local player = BTRAM:banjoPTR()
    if player ~= nil
    then
        local movestate = BTRAM:dereferencePointer(player + self.movement_ptr)
        if movestate == nil
        then
            return nil
        end
        return mainmemory.read_u32_be(movestate + self.current_state)
    end
    return nil
end

function BTRAM:getMap(nextmap)
    if nextmap == false
    then
        local map = mainmemory.read_u16_be(self.map_addr);
        return map;
    else
        local map = mainmemory.read_u16_be(self.next_map);
        return map;
    end
end

function BTRAM:setNextMap(nextmap)
    mainmemory.write_u16_be(self.next_map, nextmap);
end

function BTRAM:getEntranceId()
    return mainmemory.read_u8(self.entrance_id);
end

function BTRAM:setEntranceId(entranceId)
    mainmemory.write_u8(self.entrance_id, entranceId);
end

function BTRAM:checkFlag(byte, _bit, fromfuncDebug)
    local address = self:dereferencePointer(self.flag_block_ptr);
    if address == nil
    then
        if DEBUG == true
        then
            print("can't defef Flag Ptr")
        end
        return false
    end
    if byte == nil then
        print("Null found in byte " .. tostring(byte) .. " bit: " ..tostring(_bit))
    end
    local currentValue = mainmemory.readbyte(address + byte);
    if bit.check(currentValue, _bit) then
        return true;
    else
        return false;
    end
end

function BTRAM:clearFlag(byte, _bit, fromfuncDebug)
    if DEBUGLVL2 == true then
        print(fromfuncDebug)
    end
	if type(byte) == "number" and type(_bit) == "number" and _bit >= 0 and _bit < 8 then
		local flags = self:dereferencePointer(self.flag_block_ptr);
        local currentValue = mainmemory.readbyte(flags + byte);
        mainmemory.writebyte(flags + byte, bit.clear(currentValue, _bit));
	end
end

function BTRAM:setFlag(byte, _bit)
	if type(byte) == "number" and type(_bit) == "number" and _bit >= 0 and _bit < 8 then
		local address = self:dereferencePointer(self.flag_block_ptr);
        local currentValue = mainmemory.readbyte(address + byte);
        mainmemory.writebyte(address + byte, bit.set(currentValue, _bit));
	end
end

function BTRAM:setMultipleFlags(byte, mask, flags)
	if type(byte) == "number" and type(mask) == "number" and mask >= 0 and mask < 0xFF then
		local address = self:dereferencePointer(self.flag_block_ptr);
        local currentValue = mainmemory.readbyte(address + byte);
        mainmemory.writebyte(address + byte, (currentValue & mask) | flags);
	end
end



-- Moves that needs to be checked Per Map. some silos NEEDS other moves as well to get to.
local ASSET_MAP_CHECK = {
    ["ALL"] = {
        ["JIGGIES"] = { --Jinjo Jiggies
            -- Jinjos are part of JinjoFAM
            -- "1230676", --Jinjo
            -- "1230677", --Jinjo
            -- "1230678", --Jinjo
            -- "1230679", --Jinjo
            -- "1230680", --Jinjo
            -- "1230681", --Jinjo
            -- "1230682", --Jinjo
            -- "1230683", --Jinjo
            -- "1230684", --Jinjo
            "1230685", --Jingaling
            "1230638", -- Scrotty
--                "1230629", -- Pig Pool
--                "1230637" -- Dippy
        }
    },
    --SPIRAL MOUNTAIN
    [0xAF]  = { --SM - Spiral Mountain
        ["STOPNSWAP"] = {"1230956"},
        ["JINJOS"] = {
            "1230595" -- SM Jinjo
        },
        ["PAGES"] = {
            "1230752" -- SM
        },
        ["ROYSTEN"] = {
            "1230777",
            "1230778"
        }
    },
    [0xAE]  =	{ --SM - Behind the waterfall
        ["STOPNSWAP"] = {"1230957"}
    },
    [0xAD]  =	{ --SM - Grunty's Lair
        ["CHEATOR"] = {
            "1230992",
            "1230993",
            "1230994",
            "1230995",
            "1230996"
        }
    },
    --JINJO VILLAGE
    [0x142] = { -- JV
        ["TREBLE"] = {
            "1230789"
        },
        ["STOPNSWAP"] = {"1230958"}
    },
    [0x143] = { --JV - Bottles' House
        ["AMAZE"] = {"1231005"}
    },
    --ISLE O' HAGS
    [0x155] = { --IoH - Cliff Top
        ["JINJOS"] = {
            "1230593" -- Clifftop Jinjo
        },
        ["GLOWBO"] = {
            "1230702"
        },
        ["NOTES"] = {
            "1230936",
            "1230937",
            "1230938",
            "1230939",
        },
        ["SILO"] = {
            "1230763",
            ["Exceptions"] = {}
        },
        ["STATIONBTN"] = "1230794"
    },
    [0x150] = { --IoH - Heggy's Egg Shed
        ["STOPNSWAP"] = {
            "1230953", -- Yellow Egg Hatch
            "1230954", -- Pink Egg Hatch
            "1230955" -- Blue Egg Hatch
        }
    },
    [0x154] = { --IoH - Pine Grove
        ["NOTES"] = {
            "1230932",
            "1230933",
            "1230934", -- underwater 1
            "1230935", -- underwater 2

        },
        ["SILO"] = {
            "1230759",
            ["Exceptions"] = {}
        },
    },
    [0x152] = { --IoH - Plateau
        ["JINJOS"] = {
            "1230594" -- Plateau Jinjo
        },
        ["HONEYCOMB"] = {
            "1230727" -- honey
        },
        ["NOTES"] = {
            "1230928", -- GGM Sign 1
            "1230929", -- GGM Sign 2
            "1230930", -- Bee 1
            "1230931", -- Bee 2
        },
        ["SILO"] = {
            "1230756",
            ["Exceptions"] = {
                "1230755"
            }
        },
    },
    [0x153] = { --IoH - Plateau - Honey B's Hive
        "1230997",
        "1230998",
        "1230999",
        "1231000",
        "1231001"
    },
    
    [0x15A] = { --IoH - Wasteland
        ["JINJOS"] = {
            "1230592" -- Wasteland Jinjo
        },
        ["NOTES"] = {
            "1230940",
            "1230941",
            "1230942",
            "1230943",

        },
        ["SILO"] = {
            "1230767",
            ["Exceptions"] = {}
        },
    },
    [0x14F] = { --IoH - Wooded Hollow
        ["JINJOS"] = {
            "1230591" -- Wooded Hollow Jinjo
        }
    },
    --MAYAHEM TEMPLE
    [0xB8] = { --MT
        ["JIGGIES"] = {
            "1230599",
            "1230604"
        },
        ["JINJOS"] = {
            "1230552", -- Stadium
            "1230554", -- Pool
            "1230555", -- Bridge
        },
        ["PAGES"] = {
            "1230728" -- Top of Treasure Chamber
        },
        ["HONEYCOMB"] = {
            "1230703", -- Entrance
            "1230704", -- Bovina
        },
        ["NOTES"] = {
            "1230800", -- MT: First Stairs (1)
            "1230801", -- MT: First Stairs (2)
            "1230802", -- MT: First Stairs (3)
            "1230803", -- MT: First Stairs (4)
            "1230804", -- MT: Second Stairs (1)
            "1230805", -- MT: Second Stairs (2)
            "1230806", -- MT: Second Stairs (3)
            "1230807", -- MT: Second Stairs (4)
            "1230808", -- MT: Third Stairs (1)
            "1230809", -- MT: Third Stairs (2)
            "1230810", -- MT: Third Stairs (3)
            "1230811", -- MT: Third Stairs (4)
            "1230812", -- MT: Top Stairs (1)
            "1230813", -- MT: Top Stairs (2)
            "1230814", -- MT: Top Stairs (3)
            "1230815", -- MT: Top Stairs (4)
        },
        ["TREBLE"] = {
            "1230781"
        },
        ["SILO"] = {
            "1230754",
            "1230755",
            ["Exceptions"] = {}
        },
    },
    [0xC4] = { --MT - Jade Snake Grove
        ["JIGGIES"] = {
            "1230601", -- Golden Goliath
            "1230605"  -- Ssslumber
        },
        ["JINJOS"] = {
            "1230551" -- Snake Grove
        },
        ["PAGES"] = {
            "1230730" -- Snake Grove
        },
        ["GLOWBO"] = {
            "1230687"
        },
        ["SILO"] = {
            "1230753",
            ["Exceptions"] = {}
        },
    },
    [0xBB] = { --MT - Mayan Kickball Stadium (Lobby)
        ["JIGGIES"] = {
            "1230598", -- Kickball
        }
    },
    [0xB7] = { --MT - Mumbo's Skull
        ["GLOWBO"] = {
            "1230686"
        }
    },
    [0xB9] = { --MT - Prison Compound
        ["JIGGIES"] = {
            "1230602", --quicksand
            "1230603", --pillars
        },
        ["PAGES"] = {
            "1230729" -- Prison
        }
    },
    [0x17A] =	{ --MT - Targitzan's Really Sacred Chamber
        ["JIGGIES"] = {
            "1230596" --Targitzan
        }
    },
    [0x177] =	{ --MT - Targitzan's Slightly Sacred Chamber
        ["JIGGIES"] = {
            "1230597" --Slightly Sacred Chamber
        }
    },
    [0xC5] = { --MT - Treasure Chamber
        ["JIGGIES"] = {
            "1230600" --Treasure Chamber
        },
        ["HONEYCOMB"] = {
            "1230705", -- Treasure
        }
    },
    [0x178] = { --MT - Inside Tatgitzan's Temple
        ["JINJOS"] = {
            "1230553" -- Temple Jiggy
        }
    },
    --GLITTER GULCH MINE
    
    [0xC7] ={ --GGM
        ["JIGGIES"] = {
            "1230607", -- Canary Mary
            "1230612", -- Crushing Shed
            "1230613" -- Waterfall
        },
        ["JINJOS"] = {
            "1230559", -- Boulder
            "1230560", -- Tracks
        },
        ["PAGES"] = {
            "1230731", -- Canary
            "1230732", -- Entrance
        },
        ["HONEYCOMB"] = {
            "1230707", -- boulder
        },
        ["GLOWBO"] = {
            "1230688", -- Entrance
            "1230689" -- near mumbo
        },
        ["NOTES"] = {
            "1230816", -- by Crushing Shed (1)
            "1230817", -- by Crushing Shed (2)
            "1230818", -- by Crushing Shed (3)
            "1230819", -- by Crushing Shed (4)
            "1230820", -- Hut Bottom-Left Note
            "1230821", -- Hut Top-Left Note
            "1230822", -- Hut Top-Right Note
            "1230823", -- Hut Mid-Right Note
            "1230824", -- Hut Bottom-Right Note
            "1230825", -- Mumbo (1)
            "1230826", -- Mumbo (2)
            "1230827", -- Mumbo (3)
        },
        ["SILO"] = {
            "1230757",
            ["Exceptions"] = {}
        },
        ["JCHUNKS"] = {
            "1231002",
            "1231003",
            "1231004"
        }
    },
    [0xCC] ={ --GGM - Flooded Caves
        ["JIGGIES"] = {
            "1230615" -- Flooded Cave
        }
    },
    [0xCA] ={ --GGM - Fuel Depot
        ["NOTES"] = {
            "1230828", -- Front-left
            "1230829", -- Back-left
            "1230830", -- Back-Right
            "1230831", -- Front-Right
        }
    },
    [0xD3] = { --GGM - Generator Cavern
        ["JIGGIES"] = {
            "1230608" -- Generator Cavern
        }
    },
    [0xD2] = { --GGM - Gloomy Caverns
        ["JINJOS"] = {
            "1230557" -- Jail
        }
    },
    [0xD1] = { --GGM - Inside Chuffy's Boiler
        ["JIGGIES"] = {
            "1230606" -- King Coal
        },
    },
    [0x163] =	{ --GGM - Ordnance Storage Entrance
        ["JIGGIES"] = {
            "1230610" -- Ordnance Storage
        },
        ["SILO"] = {
            "1230758",
            ["Exceptions"] = {}
        },
    },
    [0xCF] = { --GGM - Power Hut Basement
        ["JIGGIES"] = {
            "1230614" -- Power Hut Basement
        },
    },
    [0xD8] = { --GGM - Prospector's Hut
        ["JIGGIES"] = {
            "1230611" -- Dilberta
        },
    },
    [0xDA] = { --GGM - Toxic Gas Cave
        ["JINJOS"] = {
            "1230558" -- Toxic
        },
        ["HONEYCOMB"] = {
            "1230706", -- boulder
        }
    },
    [0xD7] = { --GGM - Train Station
        ["HONEYCOMB"] = {
            "1230708", -- Train
        }
    },
    [0xCD] = { --GGM - Water Storage
        ["JINJOS"] = {
            "1230556" -- Water Storage
        },
        ["PAGES"] = {
            "1230733" -- Water Tower
        },
        ["TREBLE"] = {
            "1230782"
        }
    },
    [0xCE] = { --GGM - Waterfall Cavern
        ["JIGGIES"] = {
            "1230609" -- Waterfall Cavern
        },
    },
    [0xD0] = {}, -- GGM - Chuffy Cabin
    --WITCHYWORLD
    [0xD6] = { --WW
        ["JIGGIES"] = {
            "1230619", -- Saucer of Peril
            "1230621", -- Dive of Death
            "1230622", -- Mrs Boggy
            "1230625", -- Cactus of Strength
        },
        ["JINJOS"] = {
            "1230561", -- Top of Tent
            "1230563", -- Van door
            "1230564", -- dogdem dome
            "1230565", -- Cactus of Strength
        },
        ["PAGES"] = {
            "1230736" -- Saucer 
        },
        ["HONEYCOMB"] = {
            "1230709", -- Space Zone
        },
        ["NOTES"] = {
            "1230832", -- Around the Tent (1)
            "1230833", -- Around the Tent (2)
            "1230834", -- Around the Tent (3)
            "1230835", -- Around the Tent (4)
            "1230836", -- Around the Tent (5)
            "1230837", -- Around the Tent (6)
            "1230838", -- Around the Tent (7)
            "1230839", -- Around the Tent (8)
            "1230840", -- Area 51 Gate (1)
            "1230841", -- Area 51 Gate (2)
            "1230842", -- Outside Dodgem Dome (1)
            "1230843", -- Outside Dodgem Dome (2)
            "1230844", -- Dive of Death (1)
            "1230845", -- Dive of Death (2)
            "1230846", -- Crazy Castle Entrance (1)
            "1230847", -- Crazy Castle Entrance (2)
        },
        ["TREBLE"] = {
            "1230783"
        },
        ["SILO"] = {
            "1230761",
            "1230760",
            ["Exceptions"] = {}
        },
    },
    [0xEA] = { --WW - Cave of Horrors
        ["JINJOS"] = {
            "1230562", -- Cave of Horrors
        }
    },
    [0xE1] = { --WW - Crazy Castle Stockade
        ["JIGGIES"] = {
            "1230616", -- Hoop Hurry
            "1230620", -- Balloon Burst
        },
        ["HONEYCOMB"] = {
            "1230711", -- Crazy Castle
        },
        ["SILO"] = {
            "1230762",
            ["Exceptions"] = {}
        },
    },
    [0xDD] = { --WW - Dodgem Dome Lobby
        ["JIGGIES"] = {
            "1230617", -- Dodgem
        },
    },
    [0xEB] = { --WW - Haunted Cavern
        ["PAGES"] = {
            "1230734" -- Alcove
        }
    },
    [0xF9] = { --WW - Mr. Patch
        ["JIGGIES"] = {
            "1230618", -- Patches
        },
    },
    [0xE6] = { --WW - Star Spinner
        ["JIGGIES"] = {
            "1230623", -- Star Spinner
        },
    },
    [0xE7] = { --WW - The Inferno
        ["JIGGIES"] = {
            "1230624", -- The Inferno
        },
        ["PAGES"] = {
            "1230735" -- Inferno
        },
        ["GLOWBO"] = {
            "1230690" -- near mumbo
        }
    },
    [0x176] = { -- WW - Mumbo Skull
        ["HONEYCOMB"] = {
            "1230710" -- Inferno
        }
    },
    [0xD5] = { --WW - Wumba's Wigwam
        ["GLOWBO"] = {
            "1230691"
        }
    },
    [0xEC] = { -- WW - Train Station
        ["STATIONBTN"] = "1230795"
    },
    --JOLLY ROGER'S LAGOON
    [0x1A7] = { --JRL
        ["JIGGIES"] = {
            "1230627", -- Tiptup
            "1230635", -- UFO
            "1230629", -- Pig Pool
        },
        ["JINJOS"] = {
            "1230566", -- alcove
        },
        ["HONEYCOMB"] = {
            "1230714" -- Pipe
        },
        ["DOUBLOON"] = {
            "1230521", -- Town Center Pole 1
            "1230522", -- Town Center Pole 2
            "1230523", -- Town Center Pole 3
            "1230524", -- Town Center Pole 4
            "1230525", -- Town Center Pole 5
            "1230526", -- Town Center Pole 6
            "1230527", -- Silo 1
            "1230528", -- Silo 2
            "1230529", -- Silo 3
            "1230530", -- Silo 4
            "1230531", -- Toxic Pool 1
            "1230532", -- Toxic Pool 2
            "1230533", -- Toxic Pool 3
            "1230534", -- Toxic Pool 4
            "1230539", -- Underground 1
            "1230540", -- Underground 2
            "1230541", -- Underground 3
            "1230542", -- Alcove 1
            "1230543", -- Alcove 2
            "1230544", -- Alcove 3
            "1230547", -- Jinjo 1
            "1230548", -- Jinjo 2
            "1230549", -- Jinjo 3
            "1230550", -- Jinjo 4
        },
        ["NOTES"] = {
            "1230848", -- Outside Jollys
            "1230849", -- Outside Pawno
            "1230850", -- Outside Blubber
            "1230851", -- Blubbul 1
            "1230852", -- Blubbul 2
        },
        ["SILO"] = {
            "1230764",
            ["Exceptions"] = {}
        },
    },
    [0xF4] = { --JRL - Ancient Swimming Baths
        ["PAGES"] = {
            "1230739" -- Baths
        }
    },
    [0x1A8] =	{ --JRL - Atlantis
        ["JIGGIES"] = {
            "1230633", -- SEEMEE
        },
        ["JINJOS"] = {
            "1230570", -- Sunken Ship
        },
        ["PAGES"] = {
            "1230738" -- SEEMEE
        },
        ["HONEYCOMB"] = {
            "1230713", -- Atlantis
            "1230712", -- SEEMEE
        },
        ["GLOWBO"] = {
            "1230693" -- near humba
        },
        ["NOTES"] = {
            "1230853", -- Eel 1
            "1230854", -- Eel 2
        },
        ["TREBLE"] = {
            "1230784"
        }
    },
    [0xFF] = { --JRL - Blubber's Wave Race Hire
        ["JINJOS"] = {
            "1230567", -- Blubber
        },
        ["NOTES"] = {
            "1230855",
            "1230856",
            "1230857",
        }
    },
    [0xF6] = {  --JRL - Electric Eel's lair
        ["SILO"] = {
            "1230765",
            ["Exceptions"] = {}
        },
    },
    [0xF8] = { --JRL - Inside the Big Fish
        ["JINJOS"] = {
            "1230568", -- Big Fish
        }
    },
    [0xED] =	{ --JRL - Jolly's
        ["JIGGIES"] = {
            "1230631", -- Merry Maggie
        },
        ["DOUBLOON"] = {
            "1230545", -- Blackeye 1
            "1230546" -- Blackeye 2
        },
        ["NOTES"] = {
            "1230861",
            "1230862",
            "1230863",
        },
        ["SILO"] = {
            "1230766",
            ["Exceptions"] = {}
        },
    },
    [0xFC] =	{ --JRL - Lord Woo Fak Fak
        ["JIGGIES"] = {
            "1230632", -- Lord Woo
        },
    },      
    [0xEE] =	{ --JRL - Pawno's Emporium
        ["JIGGIES"] = {
            "1230634", -- Pawno
        },
        ["PAGES"] = {
            "1230737" -- Pawno
        },
        ["GLOWBO"] = {
            "1230692"
        },
        ["NOTES"] = {
            "1230858",
            "1230859",
            "1230860",
        }
    },
    [0x1A9] =	{ --JRL - Sea Bottom
        ["JIGGIES"] = {
            "1230633", -- SEEMEE
        },
        ["PAGES"] = {
            "1230738" -- SEEMEE
        },
        ["HONEYCOMB"] = {
            "1230712", -- SEEMEE
        }
    },
    [0x181] =	{ --JRL - Sea Botom Cavern
        ["JIGGIES"] = {
            "1230626", -- Mini-Sub Challenge
        },
    },
    [0xF7] = { --JRL - Seaweed Sanctum
        ["JINJOS"] = {
            "1230569", -- Seaweed
        }
    },
    [0x1A6] =	{ --JRL - Smuggler's cavern
        ["JIGGIES"] = {
            "1230633", -- SEEMEE
            "1230630", -- Smuggler
        },
        ["PAGES"] = {
            "1230738" -- SEEMEE
        },
        ["HONEYCOMB"] = {
            "1230712", -- SEEMEE
        }
    },
    [0xFA] = { --JRL - Temple of the Fishes
        ["JIGGIES"] = {
            "1230628", -- Chris P. Bacon
        },
    },
    [0xEF] = { --JRL - Mumbo's Skull
        ["DOUBLOON"] = {
            "1230535", -- Mumbo 1
            "1230536", -- Mumbo 2
            "1230537", -- Mumbo 3
            "1230538" -- Mumbo 4
        }
    },
    --TERRYDACTYLAND
    [0x112] =	{ --TDL
        ["JIGGIES"] = {
            "1230637", -- Dippy
            "1230644", -- Rocknut
            "1230645", -- Dino Code
        },
        ["JINJOS"] = {
            "1230571", -- Talon Torp
            "1230572", -- Entrance
            "1230573", -- Maze Cave
            "1230574", -- T-rex
        },
        ["PAGES"] = {
            "1230740", -- Dippy
            "1230742" -- Boulder
        },
        ["HONEYCOMB"] = {
            "1230715" -- Lakeside
        },
        ["GLOWBO"] = {
            "1230694", -- near unga bunga
            "1230695" -- near mumbo
        },
        ["NOTES"] = {
            "1230864", -- train 1
            "1230865", -- train 2
            "1230866", -- train 3
            "1230867", -- lakeside 1
            "1230868", -- lakeside 2
            "1230869", -- lakeside 3
            "1230870", -- zigzag 1
            "1230871", -- zigzag 2
            "1230872", -- zigzag 3
            "1230873", -- roarpath 1
            "1230874", -- roarpath 2
            "1230875", -- roarpath 3
        },
        ["TREBLE"] = {
            "1230785"
        },
        ["SILO"] = {
            "1230768",
            ["Exceptions"] = {}
        },
        ["STATIONBTN"] = "1230791",
        ["ROAR"] = {"1231009"}
    },
    [0x123] = { --TDL - Inside Chompa's Belly
        ["JIGGIES"] = {
            "1230641", -- Chompa
        },
    },
    [0x116] = { --TDL - Inside the Mountain
        ["JIGGIES"] = {
            "1230636", -- Under Terry Nest
        },
        ["PAGES"] = {
            "1230741", -- Mountain
        }
    },
    [0x115] = { --TDL - Oogle Boogles' Cave
        ["JIGGIES"] = {
            "1230640", -- Oogle Boogle Tribe
        },
    },
    [0x117] = { --TDL - River Passage
        ["HONEYCOMB"] = {
            "1230717" -- Riverside
        },
        ["NOTES"] = {
            "1230876",
            "1230877",
            "1230878",
            "1230879",
        },
        ["SILO"] = {
            "1230769",
            ["Exceptions"] = {}
        },
    },
    [0x119] = { -- Unga Bunga Cave
        ["SILO"] = {
            "1230770",
            ["Exceptions"] = {}
        },
    },
    [0x11A] = { --TDL - Stomping Plains
        ["JIGGIES"] = {
            "1230643", -- Stomping
        },
        ["JINJOS"] = {
            "1230575", -- Stomping
        }
    },
    [0x118] =	{ --TDL - Styracosaurus Family Cave
        ["HONEYCOMB"] = {
            "1230716" -- Cave
        }
    },
    [0x113] =	{ --TDL - Terry's Nest
        ["JIGGIES"] = {
            "1230639", -- Terry
            "1230642", -- Terry's Kids
        },
    },
    [0x114] =	{ --TDL - Train Station
        ["JIGGIES"] = {
            "1230644", -- Rocknut
        }
    },
    --GRUNTY INDUSTRIES
    [0x100] =	{ --GI
        ["JIGGIES"] = {
            "1230649", -- Skivvy
        },
        ["JINJOS"] = {
            "1230580" -- Outside
        },
        ["HONEYCOMB"] = {
            "1230720" -- Chimney
        },
        ["TREBLE"] = {
            "1230786"
        },
        ["STATIONBTN"] = "1230790"
    },
    [0x10F] = { --GI - Basement
        ["JIGGIES"] = {
            "1230647", -- Weldar
        },
        ["NOTES"] = {
            "1230892",
            "1230893",
        }
    },
    [0x110] =	{ --GI - Basement (Repair Depot)
        ["PAGES"] = {
            "1230745" -- Repair Depot
        }
    },
    [0x111] =	{ --GI - Basement (Waste Disposal)
        ["JIGGIES"] = {
            "1230646", -- Underwater Waste Disposal
            "1230655", -- Plant Box
            "1230661", -- HFP Oil Drill
            "1230629", -- Pig Pool
        },
        ["JINJOS"] = {
            "1230578" -- Waste Disposal
        },
        ["NOTES"] = {
            "1230890",
            "1230891",
        },
        ["SILO"] = {
            "1230771",
            ["Exceptions"] = {}
        },
    },
    [0x101] =	{ --GI - Floor 1
        ["JIGGIES"] = {
            "1230649", -- Skivvy
            "1230652", -- Floor 1 Guarded
        },
        ["NOTES"] = {
            "1230883",
            "1230884",
        },
        ["SILO"] = {
            "1230773",
            ["Exceptions"] = {}
        },
    },
    [0x106] =	{ --GI - Floor 2
        ["JIGGIES"] = {
            "1230649", -- Skivvy
        },
        ["JINJOS"] = {
            "1230577" -- leg spring
        },
        ["PAGES"] = {
            "1230744" -- Floor 2
        },
        ["GLOWBO"] = {
            "1230696" -- near humba
        },
        ["NOTES"] = {
            "1230885",
            "1230886",
            "1230887",
            "1230888",
            "1230889"
        },
        ["SILO"] = {
            "1230772",
            ["Exceptions"] = {}
        },
    },
    [0x108] =	{ --GI - Floor 3
        ["JIGGIES"] = {
            "1230649", -- Skivvy
        },
        ["HONEYCOMB"] = {
            "1230718" -- Floor 3
        },
        ["GLOWBO"] = {
            "1230697" -- on boxes
        },
        ["NOTES"] = {
            "1230894",
            "1230895"
        }
    },
    [0x109] =	{ --GI - Floor 3 (Boiler Plant)
        ["JINJOS"] = {
            "1230579" -- Top of Boiler
        }
    },
    [0x10A] =	{ --GI - Floor 3 (Packing Room)
        ["JIGGIES"] = {
            "1230654", -- Twinkly Packing
        },
    },
    [0x10B] =	{ --GI - Floor 4

    },
    [0x10D] =	{ --GI - Floor 4 (Quality Control)
        ["JIGGIES"] = {
            "1230651", -- Quality Control
        },
    },
    [0x10E] =	{ --GI - Floor 5
        ["JIGGIES"] = {
            "1230649", -- Skivvy
            "1230650", -- Floor 5
        },
        ["JINJOS"] = {
            "1230576" -- 5 floor
        }
    },
    [0x187] =	{ --GI - Sewer Entrance
        ["JIGGIES"] = {
            "1230648", -- Clinker
        },
    },
    [0x102] =	{ --GI - Train Station
        ["HONEYCOMB"] = {
            "1230719" -- Train
        },
        ["NOTES"] = {
            "1230880",
            "1230881",
            "1230882",
        }
    },
    [0x104] =	{ --GI - Trash Compactor
        ["JIGGIES"] = {
            "1230653", -- Trash Compactor
        },
    },
    [0x103] =	{ --GI - Workers' Quarters
        ["JIGGIES"] = {
            "1230649", -- Skivvy
        },
        ["PAGES"] = {
            "1230743" -- Loggo
        }
    },
    --HAILFIRE PEAKS
    [0x131] =	{ --HFP - Boggy's Igloo
        ["JIGGIES"] = {
            "1230659", -- Boggy
        },
    },
    [0x12B] =	{ --HFP - Chilli Billi
        ["JIGGIES"] = {
            "1230656", -- Brothers
        },
    },
    [0x12C] =	{ --HFP - Chilly Willy
        ["JIGGIES"] = {
            "1230656", -- Brothers
        },
    },
    [0x132] =	{ --HFP - Icicle Grotto
        ["JINJOS"] = {
            "1230584", -- Grotto
        },
        ["PAGES"] = {
            "1230747" -- Icicle
        },
        ["TREBLE"] = {
            "1230787"
        }
    },
    [0x128] =	{ --HFP - Icy Side
        ["JIGGIES"] = {
            "1230660", -- Icy Train Station
            "1230662", -- Stomping
            "1230664", -- Aliens
        },
        ["JINJOS"] = {
            "1230585", -- Mildred
            "1230583" -- Windy Hole
        },
        ["PAGES"] = {
            "1230748" -- Ice Pillar
        },
        ["GLOWBO"] = {
            "1230699",
            "1230046" -- Mega Glowbo
        },
        ["NOTES"] = {
            "1230904",
            "1230905",
            "1230906",
            "1230907",
            "1230908",
            "1230909",
            "1230910",
            "1230911",
        },
        ["SILO"] = {
            "1230775",
            ["Exceptions"] = {}
        },
        ["STATIONBTN"] = "1230793"
    },
    [0x133] =	{ --HFP - Inside the Volcano
        ["JIGGIES"] = {
            "1230657", -- Volcano
        },
        ["HONEYCOMB"] = {
            "1230721" -- Volcano
        }
    },
    [0x12D] =	{ --HFP - Kickball Stadium lobby
        ["JIGGIES"] = {
            "1230663", -- Kickball
        },
    },
    [0x127] =	{ --HFP - Lava Side
        ["JIGGIES"] = {
            "1230658", -- Sabreman
            "1230665", -- Lava waterfall
            "1230629", -- Pig Pool
        },
        ["JINJOS"] = {
            "1230581", -- Lava waterfall
            "1230582" -- Boiling Pool
        },
        ["PAGES"] = {
            "1230746" -- Lava Side
        },
        ["HONEYCOMB"] = {
            "1230723" -- Lava Side
        },
        ["GLOWBO"] = {
            "1230698"
        },
        ["NOTES"] = {
            "1230896",
            "1230897",
            "1230898",
            "1230899",
            "1230900",
            "1230901",
            "1230902",
            "1230903",
        },
        ["SILO"] = {
            "1230774",
            ["Exceptions"] = {}
        },
        ["STATIONBTN"] = "1230792"
    },
    [0x129] =	{ --HFP - Lava Train Station
        ["HONEYCOMB"] = {
            "1230722" -- Train Station
        }
    },
    [0x12A] = { -- HFP - Icy Side Station

    },
    --CLOUD CUCKOOLAND
    [0x136] =	{ --CCL
        ["JIGGIES"] = {
            "1230667", -- Mr Fit
            "1230669", -- Canary Mary 3
            "1230671", -- Jiggium Plant
            "1230675", -- Jelly Castle
            "1230637", -- Dippy
        },
        ["PAGES"] = {
            "1230749" -- Canary Mary
        },
        ["HONEYCOMB"] = {
            "1230724", -- Dirt Patch
            "1230726", -- Pot O Gold
            "1230725" -- Trash
        },
        ["GLOWBO"] = {
            "1230700"
        }

    },
    [0x13A] =	{ --CCL - Central Cavern
        ["JIGGIES"] = {
            "1230674", -- Superstash
        },
        ["JINJOS"] = {
            "1230588" -- Central
        },
        ["GLOWBO"] = {
            "1230701"
        },
        ["NOTES"] = {
            "1230912",
            "1230913",
            "1230914",
            "1230915",
            "1230916",
            "1230917",
            "1230918",
            "1230919",
            "1230920",
            "1230921",
            "1230922",
            "1230923",
            "1230924",
            "1230925",
            "1230926",
            "1230927",
        },
        ["TREBLE"] = {
            "1230788"
        },
        ["SILO"] = {
            "1230776",
            ["Exceptions"] = {}
        }
    },
    [0x138] =	{ --CCL - Inside the Cheese Wedge
        ["JIGGIES"] = {
            "1230672", -- Cheese Wedge
        },
        ["JINJOS"] = {
            "1230587" -- Cheese
        }
    },
    [0x13D] =	{ --CCL - Inside the Pot o' Gold
        ["JIGGIES"] = {
            "1230668", -- pot o gold
        },
        ["PAGES"] = {
            "1230750" -- O Gold
        }
    },
    [0x137] =	{ --CCL - Inside the Trash Can
        ["JIGGIES"] = {
            "1230673", -- Trash Can
        },
        ["JINJOS"] = {
            "1230586" -- Trash
        }
    },
    [0x13F] =	{ --CCL - Mingy Jongo's Skull
        ["JIGGIES"] = {
            "1230666", -- Mingy Jongo
        },
        ["JINJOS"] = {
            "1230589" -- Mumbo
        }
    },
    [0x13E] =	{ --CCL - Mumbo's Skull
        ["JIGGIES"] = {
            "1230666", -- Mingy Jongo
        },
        ["JINJOS"] = {
            "1230589" -- Mumbo
        }
    },
    [0x140] =	{ --CCL - Wumba's Wigwam
        ["JINJOS"] = {
            "1230590" -- Balasters
        }
    },
    [0x139] =	{ --CCL - Zubbas' Nest
        ["JIGGIES"] = {
            "1230670", -- Zubba
        },
        ["PAGES"] = {
            "1230751" -- Zubba
        }
    }
}

-- Pattern 1 Map
local JINJO_PATTER_MAP = {
    ["1230501"] = {
        ["0"] = "1230570"
    },
    ["1230502"] = {
        ["0"] = "1230564",
        ["1"] = "1230582"
    },
    ["1230503"] = {
        ["0"] = "1230563",
        ["1"] =  "1230584",
        ["2"] = "1230583"
    },
    ["1230504"] = {
        ["0"] = "1230556",
        ["1"] =  "1230567",
        ["2"] = "1230572",
        ["3"] = "1230575"
    },
    ["1230505"] = {
        ["0"] = "1230565",
        ["1"] = "1230566",
        ["2"] =  "1230574",
        ["3"] = "1230577",
        ["4"] = "1230581",
    },
    ["1230506"] = {
        ["0"] = "1230552",
        ["1"] = "1230553",
        ["2"] = "1230555",
        ["3"] = "1230568",
        ["4"] = "1230569",
        ["5"] = "1230562",
    },
    ["1230507"] = {
        ["0"] = "1230558",
        ["1"] = "1230571",
        ["2"] = "1230585",
        ["3"] = "1230587",
        ["4"] = "1230591",
        ["5"] = "1230594",
        ["6"] = "1230595"
    },
    ["1230508"] = {
        ["0"] = "1230551",
        ["1"] = "1230560",
        ["2"] = "1230586",
        ["3"] = "1230588",
        ["4"] = "1230590",
        ["5"] = "1230592",
        ["6"] = "1230593",
        ["7"] = "1230579",
    },
    ["1230509"] = {
        ["0"] = "1230554",
        ["1"] = "1230557",
        ["2"] = "1230559",
        ["3"] = "1230561",
        ["4"] = "1230573",
        ["5"] = "1230576",
        ["6"] = "1230580",
        ["7"] = "1230589",
        ["8"] = "1230578",
    },
}

-- AGI - Archipelago given items
local AGI_MOVES = {};
local AGI_NOTES = {};
local AGI_TREBLE = {};
local AGI_STATIONS = {};
local AGI_CHUFFY = {};
local AGI_MYSTERY = {};
local AGI_JINJOS = {
    ["1230501"] = 0, -- white
    ["1230502"] = 0, -- orange
    ["1230503"] = 0, -- yellow
    ["1230504"] = 0, -- brown
    ["1230505"] = 0, -- green
    ["1230506"] = 0, -- red
    ["1230507"] = 0, -- blue
    ["1230508"] = 0, -- purple
    ["1230509"] = 0, -- black
};
local ITEM_TABLE = {}; -- reverses ROM_ITEM so the key is the Item
local ROM_ITEM_TABLE = {
    "AP_ITEM_PAGES",
    "AP_ITEM_HONEY",
    "AP_ITEM_WJINJO",
    "AP_ITEM_OJINJO",
    "AP_ITEM_YJINJO",
    "AP_ITEM_BRJINJO",
    "AP_ITEM_GJINJO",
    "AP_ITEM_RJINJO",
    "AP_ITEM_BLJINJO",
    "AP_ITEM_PJINJO",
    "AP_ITEM_BKJINJO",
    "AP_ITEM_DOUBLOON",
    "AP_ITEM_JIGGY",
    "AP_ITEM_TREBLE",
    "AP_ITEM_NOTE",
    "AP_ITEM_MUMBOTOKEN",
    "AP_ITEM_IKEY",
    "AP_ITEM_PMEGG",
    "AP_ITEM_BMEGG",
    "AP_ITEM_GGRAB",
    "AP_ITEM_BBLASTER",
    "AP_ITEM_EGGAIM",
    "AP_ITEM_BDRILL",
    "AP_ITEM_BBAYONET",
    "AP_ITEM_AIREAIM",
    "AP_ITEM_SPLITUP",
    "AP_ITEM_WWHACK",
    "AP_ITEM_TTORP",
    "AP_ITEM_AUQAIM",
    "AP_ITEM_SHPACK",
    "AP_ITEM_GLIDE",
    "AP_ITEM_SNPACK",
    "AP_ITEM_LSPRING",
    "AP_ITEM_CLAWBTS",
    "AP_ITEM_SPRINGB",
    "AP_ITEM_TAXPACK",
    "AP_ITEM_HATCH",
    "AP_ITEM_PACKWH",
    "AP_ITEM_SAPACK",
    "AP_ITEM_FEGGS",
    "AP_ITEM_GEGGS",
    "AP_ITEM_CEGGS",
    "AP_ITEM_IEGGS",
    "AP_ITEM_FSWIM",
    "AP_ITEM_DAIR",
    "AP_ITEM_BBASH",
    "AP_ITEM_HOMINGEGGS",
    "AP_ITEM_AMAZEOGAZE",
    "AP_ITEM_ROAR",
    "AP_ITEM_DIVE",
    "AP_ITEM_FPAD",
    "AP_ITEM_GRAT",
    "AP_ITEM_ROLL",
    "AP_ITEM_ARAT",
    "AP_ITEM_BBARGE",
    "AP_ITEM_TJUMP",
    "AP_ITEM_FLUTTER",
    "AP_ITEM_FFLIP",
    "AP_ITEM_CLIMB",
    "AP_ITEM_BEGGS",
    "AP_ITEM_TTROT",
    "AP_ITEM_BBUST",
    "AP_ITEM_WWING",
    "AP_ITEM_SSTRIDE",
    "AP_ITEM_TTRAIN",
    "AP_ITEM_BBOMB",
    "AP_ITEM_EGGSHOOT",
    "AP_ITEM_MUMBOMT",
    "AP_ITEM_MUMBOGM",
    "AP_ITEM_MUMBOWW",
    "AP_ITEM_MUMBOJR",
    "AP_ITEM_MUMBOTD",
    "AP_ITEM_MUMBOGI",
    "AP_ITEM_MUMBOHP",
    "AP_ITEM_MUMBOCC",
    "AP_ITEM_MUMBOIH",
    "AP_ITEM_HUMBAMT",
    "AP_ITEM_HUMBAGM",
    "AP_ITEM_HUMBAWW",
    "AP_ITEM_HUMBAJR",
    "AP_ITEM_HUMBATD",
    "AP_ITEM_HUMBAGI",
    "AP_ITEM_HUMBAHP",
    "AP_ITEM_HUMBACC",
    "AP_ITEM_HUMBAIH",
    "AP_ITEM_TRAINSWIH",
    "AP_ITEM_TRAINSWTD",
    "AP_ITEM_TRAINSWGI",
    "AP_ITEM_TRAINSWHP1",
    "AP_ITEM_TRAINSWHP2",
    "AP_ITEM_TRAINSWWW",
    "AP_ITEM_CHUFFY",
    "AP_ITEM_MTA",
    "AP_ITEM_GGA",
    "AP_ITEM_WWA",
    "AP_ITEM_JRA",
    "AP_ITEM_TDA",
    "AP_ITEM_GIA",
    "AP_ITEM_HFA",
    "AP_ITEM_CCA",
    "AP_ITEM_CKA",
    "AP_ITEM_H1A",
};


local BMM_JIGGIES = {}; -- BMM JIGGIES
local BMM_NOTES = {}; -- BMM Notes
local BMM_JINJOS = {}; -- BMM JINJOS
local BKM = {}; -- Banjo Tooie Movelist Table
local BMM_STATIONS = {} -- Stations
local BMM_CHUFFY = {} -- King Coal Progress Flag
local BKJINJOFAM = {} -- Jinjo Family check 
local UNLOCKED_WORLDS = {} -- Worlds unlocked
local BMM_MYSTERY = {} -- Stop n Swap 


-- Address Map for Banjo-Tooie
local ADDRESS_MAP = {
    ["MOVES"] = {
        ["1230753"] = {
            ['addr'] = 0x1B,
            ['bit'] = 1,
            ['name'] = 'Grip Grab'
        },
        ["1230754"] = {
            ['addr'] = 0x1B,
            ['bit'] = 2,
            ['name'] = 'Breegull Blaster'
        },
        ["1230755"] = {
            ['addr'] = 0x1B,
            ['bit'] = 3,
            ['name'] = 'Egg Aim'
        },
        ["1230756"] = {
            ['addr'] = 0x1E,
            ['bit'] = 1,
            ['name'] = 'Fire Eggs'
        },
        ["1230757"] = {
            ['addr'] = 0x1B,
            ['bit'] = 6,
            ['name'] = 'Bill Drill'
        },
        ["1230758"] = {
            ['addr'] = 0x1B,
            ['bit'] = 7,
            ['name'] = 'Beak Bayonet'
        },
        ["1230759"] = {
            ['addr'] = 0x1E,
            ['bit'] = 2,
            ['name'] = 'Grenade Eggs'
        },
        ["1230760"] = {
            ['addr'] = 0x1C,
            ['bit'] = 0,
            ['name'] = 'Airborne Egg Aiming'
        },
        ["1230761"] = {
            ['addr'] = 0x1C,
            ['bit'] = 1,
            ['name'] = 'Split Up'
        },
        ["1230762"] = {
            ['addr'] = 0x1D,
            ['bit'] = 6,
            ['name'] = 'Pack Whack'
        },
        ["1230763"] = {
            ['addr'] = 0x1E,
            ['bit'] = 4,
            ['name'] = 'Ice Eggs'
        },
        ["1230764"] = {
            ['addr'] = 0x1C,
            ['bit'] = 2,
            ['name'] = 'Wing Whack'
        },
        ["1230765"] = {
            ['addr'] = 0x1C,
            ['bit'] = 3,
            ['name'] = 'Talon Torpedo'
        },
        ["1230766"] = {
            ['addr'] = 0x1C,
            ['bit'] = 4,
            ['name'] = 'Sub-Aqua Egg Aiming'
        },
        ["1230767"] = {
            ['addr'] = 0x1E,
            ['bit'] = 3,
            ['name'] = 'Clockwork Kazooie Eggs'
        },
        ["1230768"] = {
            ['addr'] = 0x1D,
            ['bit'] = 3,
            ['name'] = 'Springy Step Shoes'
        },
        ["1230769"] = {
            ['addr'] = 0x1D,
            ['bit'] = 4,
            ['name'] = 'Taxi Pack'
        },
        ["1230770"] = {
            ['addr'] = 0x1D,
            ['bit'] = 5,
            ['name'] = 'Hatch'
        },
        ["1230771"] = {
            ['addr'] = 0x1D,
            ['bit'] = 0,
            ['name'] = 'Snooze Pack'
        },
        ["1230772"] = {
            ['addr'] = 0x1D,
            ['bit'] = 1,
            ['name'] = 'Leg Spring'
        },
        ["1230773"] = {
            ['addr'] = 0x1D,
            ['bit'] = 2,
            ['name'] = 'Claw Clamber Boots'
        },
        ["1230774"] = {
            ['addr'] = 0x1C,
            ['bit'] = 6,
            ['name'] = 'Shack Pack'
        },
        ["1230775"] = {
            ['addr'] = 0x1C,
            ['bit'] = 7,
            ['name'] = 'Glide'
        },
        ["1230776"] = {
            ['addr'] = 0x1D,
            ['bit'] = 7,
            ['name'] = 'Sack Pack'
        },
	},
	["SKIP"] = {
		['CUTSCENE'] = {
			['Klungo Flyover'] = {
				['addr'] = 0x02,
				['bit'] = 4
			},
			['Jiggywiggy Flyover'] = {
				['addr'] = 0x67,
				['bit'] = 7
			},
			['Jinjo First Time'] = {
				['addr'] = 0x6E,
				['bit'] = 6
			},
            ['Dodgems 1v1 Flyover'] = {
				['addr'] = 0x7E,
				['bit'] = 1
			},
            ['Dodgems 2v1 Flyover'] = {
				['addr'] = 0x7E,
				['bit'] = 2
			},
            ['Dodgems 3v1 Flyover'] = {
				['addr'] = 0x7E,
				['bit'] = 3
			},
            ['MT Kickball Quarterfinal Flyover'] = {
				['addr'] = 0x7E,
				['bit'] = 4
			},
            ['MT Kickball Semifinal Flyover'] = {
				['addr'] = 0x7E,
				['bit'] = 5
			},
            ['MT Kickball Final Flyover'] = {
				['addr'] = 0x7E,
				['bit'] = 6
			},
            ['HFP Kickball Quarterfinal Flyover'] = {
				['addr'] = 0x7E,
				['bit'] = 7
			},
            ['HFP Kickball Semifinal Flyover'] = {
				['addr'] = 0x7F,
				['bit'] = 0
			},
            ['HFP Kickball Final Flyover'] = {
				['addr'] = 0x7F,
				['bit'] = 1
			},
			['Jinjo Flyover'] = {
				['addr'] = 0x82,
				['bit'] = 4
			},
			['Jinjo Flyover - Jiggy'] = {
				['addr'] = 0x82,
				['bit'] = 5
			},
			['Jamjars Flyover'] = {
				['addr'] = 0x9B,
				['bit'] = 6
			},
			['Jiggywiggy Laser'] = {
				['addr'] = 0xAC,
				['bit'] = 2
			},
            ['Targitzan'] = {
                ['addr'] = 0x0C,
                ['bit'] = 7
            },
            ['Klungo 3'] = {
                ['addr'] = 0x11,
                ['bit'] = 7
            },
            ['Klungo 2'] = {
                ['addr'] = 0x32,
                ['bit'] = 2
            },
            ['Klungo 1'] = {
                ['addr'] = 0x13,
                ['bit'] = 1
            },
            ['Terry'] = {
                ['addr'] = 0x29,
                ['bit'] = 2
            },
            ['Weldar'] = {
                ['addr'] = 0x29,
                ['bit'] = 4
            },
            ['King Coal'] = {
                ['addr'] = 0x2A,
                ['bit'] = 1
            },
            -- ['Patches'] = {
            --     ['addr'] = 0x2A,
            --     ['bit'] = 7
            -- },
            ['Woo Fak Fak'] = {
                ['addr'] = 0x30,
                ['bit'] = 7
            },
            ['Chilly Willy'] = {
                ['addr'] = 0x35,
                ['bit'] = 3
            },
            ['Chilly Billi'] = {
                ['addr'] = 0x35,
                ['bit'] = 4
            },
            ['HAG1'] = {
                ['addr'] = 0x03,
                ['bit'] = 4
            }
		},
		['INTRO'] = {
			['Bovina'] = {
				['addr'] = 0x04,
				['bit'] = 5
			},
			['Unogopaz'] = {
				['addr'] = 0x06,
				['bit'] = 1
			},
			['Unogopaz - Stony'] = {
				['addr'] = 0x06,
				['bit'] = 1
			},
			['Dilberta'] = {
				['addr'] = 0x06,
				['bit'] = 3
			},
			['Kickball Coach'] = {
				['addr'] = 0x07,
				['bit'] = 4
			},
			['Cheato'] = {
				['addr'] = 0x08,
				['bit'] = 0
			},
			['Mumbo'] = {
				['addr'] = 0x0A,
				['bit'] = 5
			},
			['Bullion Bill'] = {
				['addr'] = 0x0B,
				['bit'] = 2
			},
			['Mrs. Boggy'] = {
				['addr'] = 0x0C,
				['bit'] = 3
			},
			['Humba Wumba'] = {
				['addr'] = 0x0C,
				['bit'] = 7
			},
			['Big Al'] = {
				['addr'] = 0x0E,
				['bit'] = 5
			},
			['Salty Joe'] = {
				['addr'] = 0x0E,
				['bit'] = 6
			},
			['Conga'] = {
				['addr'] = 0x0F,
				['bit'] = 1
			},
			['Moggy'] = {
				['addr'] = 0x12,
				['bit'] = 0
			},
			['Soggy'] = {
				['addr'] = 0x12,
				['bit'] = 1
			},
			['Groggy'] = {
				['addr'] = 0x12,
				['bit'] = 2
			},
			['Tiptup'] = {
				['addr'] = 0x12,
				['bit'] = 4
			},
			['Jolly'] = {
				['addr'] = 0x13,
				['bit'] = 3
			},
			['Maggie - After Rescue'] = {
				['addr'] = 0x13,
				['bit'] = 4
			},
			['Blubber'] = {
				['addr'] = 0x16,
				['bit'] = 7
			},
			['Scrotty'] = {
				['addr'] = 0x26,
				['bit'] = 5
			},
			['Floatie Pig'] = {
				['addr'] = 0x28,
				['bit'] = 0
			},
			['Loggo'] = {
				['addr'] = 0x28,
				['bit'] = 1
			},
			['Oogle Boogle'] = {
				['addr'] = 0x28,
				['bit'] = 7
			},
			-- ['King Jingaling'] = {
			-- 	 ['addr'] = 0x2F,
			--	 ['bit'] = 5
			-- },
			['Mrs. Bottles'] = {
				['addr'] = 0x2F,
				['bit'] = 7
			},
			['Speccy'] = {
				['addr'] = 0x30,
				['bit'] = 0
			},
			['Dingpot'] = {
				['addr'] = 0x30,
				['bit'] = 4
			},
			['Mildred'] = {
				['addr'] = 0x33,
				['bit'] = 5
			},
			['Biggafoot'] = {
				['addr'] = 0x33,
				['bit'] = 7
			},
			['George'] = {
				['addr'] = 0x34,
				['bit'] = 1
			},
			-- ['Three-Armed Pig'] = {
			-- 	['addr'] = 0x34,
			-- 	['bit'] = 6
			-- },
			['Oogle Boogle Guard'] = {
				['addr'] = 0x5F,
				['bit'] = 3
			},
			['Dippy'] = {
				['addr'] = 0x60,
				['bit'] = 0
			},
			['Roysten'] = {
				['addr'] = 0x62,
				['bit'] = 7
			},
			['Jiggywiggy'] = {
				['addr'] = 0x66,
				['bit'] = 3
			},
			['Colosseum Kickball Coach'] = {
				['addr'] = 0x68,
				['bit'] = 6
			},
			['Gamette'] = {
				['addr'] = 0x69,
				['bit'] = 1
			},
			['Superstash'] = {
				['addr'] = 0x6C,
				['bit'] = 0
			},
			['Mr. Fit'] = {
				['addr'] = 0x76,
				['bit'] = 1
			},
			['Heggy'] = {
				['addr'] = 0x78,
				['bit'] = 0
			},
			['Jiggywiggy Disciple'] = {
				['addr'] = 0x78,
				['bit'] = 5
			},
			['Jamjars'] = {
				['addr'] = 0x7C,
				['bit'] = 4
			},
			['Canary Mary - GGM'] = {
				['addr'] = 0x80,
				['bit'] = 2
			},
			['Canary Mary - CCL'] = {
				['addr'] = 0x80,
				['bit'] = 3
			},
			['Honey B'] = {
				['addr'] = 0x98,
				['bit'] = 1
			},
		},
		['TUTORIAL'] = {
			['Sign'] = {
				['addr'] = 0x02,
				['bit'] = 2
			},
			['Springy-Step Shoes Not Learned'] = {
				['addr'] = 0x04,
				['bit'] = 6
			},
			['Claw Clamber Boots Not Learned'] = {
				['addr'] = 0x04,
				['bit'] = 7
			},
			['Golden Goliath'] = {
				['addr'] = 0x05,
				['bit'] = 0
			},
			['Golden Goliath - Time Up'] = {
				['addr'] = 0x05,
				['bit'] = 1
			},
			['Wumba - Pine Grove'] = {
				['addr'] = 0x05,
				['bit'] = 5
			},
			['Minjo'] = {
				['addr'] = 0x05,
				['bit'] = 7
			},
			['Cheato Code List'] = {
				['addr'] = 0x08,
				['bit'] = 1
			},
			['Code Chamber'] = {
				['addr'] = 0x08,
				['bit'] = 2
			},
			['Code Entry'] = {
				['addr'] = 0x08,
				['bit'] = 3
			},
			['Mumbo Pad'] = {
				['addr'] = 0x0E,
				['bit'] = 2
			},
			['Use Mumbo Pad'] = {
				['addr'] = 0x0E,
				['bit'] = 3
			},
			['Cheat Menu'] = {
				['addr'] = 0x15,
				['bit'] = 3
			},
			['Detransform'] = {
				['addr'] = 0x17,
				['bit'] = 2
			},
			['Clockwork Kazooie'] = {
				['addr'] = 0x18,
				['bit'] = 0
			},
			['Hoop Hurry'] = {
				['addr'] = 0x30,
				['bit'] = 5
			},
			['Balloon Burst'] = {
				['addr'] = 0x30,
				['bit'] = 6
			},
			['Twinkly Packing'] = {
				['addr'] = 0x34,
				['bit'] = 0
			},
			['Glowbo Paid'] = {
				['addr'] = 0x35,
				['bit'] = 1
			},
			['Chilly Willy - Wrong Egg'] = {
				['addr'] = 0x35,
				['bit'] = 7
			},
			['Chilli Billi - Wrong Egg'] = {
				['addr'] = 0x36,
				['bit'] = 0
			},
			['Pot O Gold'] = {
				['addr'] = 0x37,
				['bit'] = 2
			},
			['Warp Silo'] = {
				['addr'] = 0x61,
				['bit'] = 4
			},
			['Floatus Floatium'] = {
				['addr'] = 0x63,
				['bit'] = 0
			},
			['BK Game Pak'] = {
				['addr'] = 0x63,
				['bit'] = 2
			},
			['GI Battery Door'] = {
				['addr'] = 0x63,
				['bit'] = 3
			},
			['Broken Jukebox'] = {
				['addr'] = 0x63,
				['bit'] = 4
			},
			['Daddy T-Rex'] = {
				['addr'] = 0x63,
				['bit'] = 6
			},
			['Stony'] = {
				['addr'] = 0x63,
				['bit'] = 7
			},
			['Detonator'] = {
				['addr'] = 0x64,
				['bit'] = 0
			},
			['Van'] = {
				['addr'] = 0x64,
				['bit'] = 1
			},
			['Sub'] = {
				['addr'] = 0x64,
				['bit'] = 2
			},
			['T-Rex'] = {
				['addr'] = 0x64,
				['bit'] = 3
			},
			['Washing Machine'] = {
				['addr'] = 0x64,
				['bit'] = 4
			},
			['Snowball'] = {
				['addr'] = 0x64,
				['bit'] = 5
			},
			['Bee'] = {
				['addr'] = 0x64,
				['bit'] = 6
			},
			['Dragon Kazooie'] = {
				['addr'] = 0x64,
				['bit'] = 7
			},
			['Puzzle Complete'] = {
				['addr'] = 0x78,
				['bit'] = 1
			},
			['Warp Pad'] = {
				['addr'] = 0x78,
				['bit'] = 6
			},
			['Random Stop Honeycomb'] = {
				['addr'] = 0x7C,
				['bit'] = 5
			},
			['Skill Stop Honeycomb'] = {
				['addr'] = 0x7C,
				['bit'] = 6
			},
			['Saucer of Peril Fixed'] = {
				['addr'] = 0x7D,
				['bit'] = 4
			},
			['Saucer of Peril'] = {
				['addr'] = 0x7D,
				['bit'] = 7
			},
			['Mumbo'] = {
				['addr'] = 0x80,
				['bit'] = 1
			},
			['Jiggywiggy Altar'] = {
				['addr'] = 0x98,
				['bit'] = 0
			},
			['Split Up Not Learned'] = {
				['addr'] = 0x99,
				['bit'] = 4
			},
			['Split Up'] = {
				['addr'] = 0x99,
				['bit'] = 5
			},
			['Canary Mary Race'] = {
				['addr'] = 0x9C,
				['bit'] = 0
			},
			['Puzzle'] = {
				['addr'] = 0xA1,
				['bit'] = 3
			},
		}
    },
    ["TREBLE"] = {
        ["1230781"] = {
            ['addr'] = 0x86,
            ['bit'] = 7,
            ['name'] = 'MT: Treble Clef'
        },
        ["1230782"] = {
            ['addr'] = 0x89,
            ['bit'] = 0,
            ['name'] = 'GGM: Treble Clef'
        },
        ["1230783"] = {
            ['addr'] = 0x8B,
            ['bit'] = 1,
            ['name'] = 'WW: Treble Clef'
        },
        ["1230784"] = {
            ['addr'] = 0x8D,
            ['bit'] = 2,
            ['name'] = 'JRL: Treble Clef'
        },
        ["1230785"] = {
            ['addr'] = 0x8F,
            ['bit'] = 3,
            ['name'] = 'TDL: Treble Clef'
        },
        ["1230786"] = {
            ['addr'] = 0x91,
            ['bit'] = 4,
            ['name'] = 'GI: Treble Clef'
        },
        ["1230787"] = {
            ['addr'] = 0x93,
            ['bit'] = 5,
            ['name'] = 'HFP: Treble Clef'
        },
        ["1230788"] = {
            ['addr'] = 0x95,
            ['bit'] = 6,
            ['name'] = 'CCL: Treble Clef'
        },
        ["1230789"] = {
            ['addr'] = 0x97,
            ['bit'] = 7,
            ['name'] = 'JV: Treble Clef'
        },
    },
    ["STATIONS"] = {
        ["1230790"] = {
            ['addr'] = 0x27,
            ['bit'] = 3,
            ['name'] = "Train Switch GI"
        },
        ["1230791"] = {
            ['addr'] = 0x27,
            ['bit'] = 4,
            ['name'] = "Train Switch TDL"
        },
        ["1230792"] = {
            ['addr'] = 0x35,
            ['bit'] = 0,
            ['name'] = "Train Switch HFP Lava"
        },
        ["1230793"] = {
            ['addr'] = 0x34,
            ['bit'] = 7,
            ['name'] = "Train Switch HFP Ice"
        },
        ["1230794"] = {
            ['addr'] = 0x7B,
            ['bit'] = 3,
            ['name'] = "Train Switch Clifftop"
        },
        ["1230795"] = {
            ['addr'] = 0x0D,
            ['bit'] = 6,
            ['name'] = "Train Switch WW"
        }
    },
    ["CHUFFY"] = {
        ["1230796"] = {
            ['addr'] = 0x0B,
            ['bit'] = 6,
            ['name'] = "King Coal Defeated"
        },
    },
    ["JINJOFAM"] = {
        ["1230676"] = {
            ['addr'] = 0x4F,
            ['bit'] = 0,
            ['name'] = 'JV: White Jinjo Family Jiggy'
        },
        ["1230677"] = {
            ['addr'] = 0x4F,
            ['bit'] = 1,
            ['name'] = 'JV: Orange Jinjo Family Jiggy'
        },
        ["1230678"] = {
            ['addr'] = 0x4F,
            ['bit'] = 2,
            ['name'] = 'JV: Yellow Jinjo Family Jiggy'
        },
        ["1230679"] = {
            ['addr'] = 0x4F,
            ['bit'] = 3,
            ['name'] = 'JV: Brown Jinjo Family Jiggy'
        },
        ["1230680"] = {
            ['addr'] = 0x4F,
            ['bit'] = 4,
            ['name'] = 'JV: Green Jinjo Family Jiggy'
        },
        ["1230681"] = {
            ['addr'] = 0x4F,
            ['bit'] = 5,
            ['name'] = 'JV: Red Jinjo Family Jiggy'
        },
        ["1230682"] = {
            ['addr'] = 0x4F,
            ['bit'] = 6,
            ['name'] = 'JV: Blue Jinjo Family Jiggy'
        },
        ["1230683"] = {
            ['addr'] = 0x4F,
            ['bit'] = 7,
            ['name'] = 'JV: Purple Jinjo Family Jiggy'
        },
        ["1230684"] = {
            ['addr'] = 0x50,
            ['bit'] = 0,
            ['name'] = 'JV: Black Jinjo Family Jiggy'
        },
    },
    ['STOPNSWAP'] = {
        ["1230953"] = {
            ['addr'] = 0x77,
            ['bit'] = 7,
            ['name'] = "Yellow Egg Hatched"
        },
        ["1230954"] = {
            ['addr'] = 0x77,
            ['bit'] = 6,
            ['name'] = "Pink Egg Hatched"
        },
        ["1230955"] = {
            ['addr'] = 0x77,
            ['bit'] = 4,
            ['name'] = "Blue Egg Hatched"
        },
        ["1230956"] = {
            ['addr'] = 0x77,
            ['bit'] = 5,
            ['name'] = "Pink Egg"
        },
        ["1230957"] = {
            ['addr'] = 0x77,
            ['bit'] = 3,
            ['name'] = "Blue Egg"
        },
        ["1230958"] = {
            ['addr'] = 0x77,
            ['bit'] = 2,
            ['name'] = "Ice Key"
        }
    },
    ['ROYSTEN'] = {
        ["1230777"] = {
            ['addr'] = 0x9E,
            ['bit'] = 6,
            ['name'] = "SM: Roysten Reward 1"
        },
        ["1230778"] = {
            ['addr'] = 0x9E,
            ['bit'] = 6,
            ['name'] = "SM: Roysten Reward 2"
        }
    },
    ["CHEATO"] = {
        ["1230992"] = {
            ['addr'] = 0x08,
            ['bit'] = 4,
            ['name'] = "SM: Cheato Reward 1"
        },
        ["1230993"] = {
            ['addr'] = 0x08,
            ['bit'] = 5,
            ['name'] = "SM: Cheato Reward 2"
        },
        ["1230994"] = {
            ['addr'] = 0x08,
            ['bit'] = 6,
            ['name'] = "SM: Cheato Reward 3"
        },
        ["1230995"] = {
            ['addr'] = 0x08,
            ['bit'] = 7,
            ['name'] = "SM: Cheato Reward 4"
        },
        ["1230996"] = {
            ['addr'] = 0x09,
            ['bit'] = 0,
            ['name'] = "SM: Cheato Reward 5"
        },
    },
    ["HONEYB"] = {
        ["1230997"] = {
            ['addr'] = 0x98,
            ['bit'] = 2,
            ['name'] = "IoH: Honey B's Reward 1"
        },
        ["1230998"] = {
            ['addr'] = 0x98,
            ['bit'] = 3,
            ['name'] = "IoH: Honey B's Reward 2"
        },
        ["1230999"] = {
            ['addr'] = 0x98,
            ['name'] = "IoH: Honey B's Reward 3"
        },
        ["1231000"] = {
            ['addr'] = 0x98,
            ['bit'] = 4,
            ['name'] = "IoH: Honey B's Reward 4"
        },
        ["1231001"] = {
            ['addr'] = 0x98,
            ['name'] = "IoH: Honey B's Reward 5"
        },
    },
    ["JCHUNKS"] = {
        ["1231002"] = {
            ['addr'] = 0x7D,
            ['bit'] = 0,
            ['name'] = "GGM: Crushing Shed Jiggy Chunk 1"
        },
        ["1231003"] = {
            ['addr'] = 0x7D,
            ['bit'] = 1,
            ['name'] = "GGM: Crushing Shed Jiggy Chunk 2"
        },
        ["1231004"] = {
            ['addr'] = 0x7D,
            ['bit'] = 2,
            ['name'] = "GGM: Crushing Shed Jiggy Chunk 3"
        }
    },
    --Jinjo Jiggies are part of JINJOFAM
    ["JIGGIES"] = {
        ["1230685"] = {
            ['addr'] = 0x50,
            ['bit'] = 1,
            ['name'] = 'JV: King Jingaling Jiggy'
        },
        ["1230596"] = {
            ['addr'] = 0x45,
            ['bit'] = 0,
            ['name'] = 'MT: Targitzan Jiggy'
        },
        ["1230597"] = {
            ['addr'] = 0x45,
            ['bit'] = 1,
            ['name'] = 'MT: Slightly Sacred Chamber Jiggy'
        },
        ["1230598"] = {
            ['addr'] = 0x45,
            ['bit'] = 2,
            ['name'] = 'MT: Kickball Jiggy'
        },
        ["1230599"] = {
            ['addr'] = 0x45,
            ['bit'] = 3,
            ['name'] = 'MT: Bovina Jiggy'
        },
        ["1230600"] = {
            ['addr'] = 0x45,
            ['bit'] = 4,
            ['name'] = 'MT: Treasure Chamber Jiggy'
        },
        ["1230601"] = {
            ['addr'] = 0x45,
            ['bit'] = 5,
            ['name'] = 'MT: Golden Goliath Jiggy'
        },
        ["1230602"] = {
            ['addr'] = 0x45,
            ['bit'] = 6,
            ['name'] = 'MT: Prison Compound Quicksand Jiggy'
        },
        ["1230603"] = {
            ['addr'] = 0x45,
            ['bit'] = 7,
            ['name'] = 'MT: Pillars Jiggy'
        },
        ["1230604"] = {
            ['addr'] = 0x46,
            ['bit'] = 0,
            ['name'] = 'MT: Top of Temple Jiggy'
        },
        ["1230605"] = {
            ['addr'] = 0x46,
            ['bit'] = 1,
            ['name'] = 'MT: Ssslumber Jiggy'
        },
        ["1230606"] = {
            ['addr'] = 0x46,
            ['bit'] = 2,
            ['name'] = 'GGM: Old King Coal Jiggy'
        },
        ["1230607"] = {
            ['addr'] = 0x46,
            ['bit'] = 3,
            ['name'] = 'GGM: Canary Mary Jiggy'
        },
        ["1230608"] = {
            ['addr'] = 0x46,
            ['bit'] = 4,
            ['name'] = 'GGM: Generator Cavern Jiggy'
        },
        ["1230609"] = {
            ['addr'] = 0x46,
            ['bit'] = 5,
            ['name'] = 'GGM: Waterfall Cavern Jiggy'
        },
        ["1230610"] = {
            ['addr'] = 0x46,
            ['bit'] = 6,
            ['name'] = 'GGM: Ordinance Storage Jiggy'
        },
        ["1230611"] = {
            ['addr'] = 0x46,
            ['bit'] = 7,
            ['name'] = 'GGM: Dilberta Jiggy'
        },
        ["1230612"] = {
            ['addr'] = 0x47,
            ['bit'] = 0,
            ['name'] = 'GGM: Crushing Shed Jiggy'
        },
        ["1230613"] = {
            ['addr'] = 0x47,
            ['bit'] = 1,
            ['name'] = 'GGM: Waterfall Jiggy'
        },
        ["1230614"] = {
            ['addr'] = 0x47,
            ['bit'] = 2,
            ['name'] = 'GGM: Power Hut Basement Jiggy'
        },
        ["1230615"] = {
            ['addr'] = 0x47,
            ['bit'] = 3,
            ['name'] = 'GGM: Flooded Caves Jiggy'
        },
        ["1230616"] = {
            ['addr'] = 0x47,
            ['bit'] = 4,
            ['name'] = 'WW: Hoop Hurry Jiggy'
        },
        ["1230617"] = {
            ['addr'] = 0x47,
            ['bit'] = 5,
            ['name'] = 'WW: Dodgems Jiggy'
        },
        ["1230618"] = {
            ['addr'] = 0x47,
            ['bit'] = 6,
            ['name'] = 'WW: Mr. Patch Jiggy'
        },
        ["1230619"] = {
            ['addr'] = 0x47,
            ['bit'] = 7,
            ['name'] = 'WW: Saucer of Peril Jiggy'
        },
        ["1230620"] = {
            ['addr'] = 0x48,
            ['bit'] = 0,
            ['name'] = 'WW: Balloon Burst Jiggy'
        },
        ["1230621"] = {
            ['addr'] = 0x48,
            ['bit'] = 1,
            ['name'] = 'WW: Dive of Death Jiggy'
        },
        ["1230622"] = {
            ['addr'] = 0x48,
            ['bit'] = 2,
            ['name'] = 'WW: Mrs. Boggy Jiggy'
        },
        ["1230623"] = {
            ['addr'] = 0x48,
            ['bit'] = 3,
            ['name'] = 'WW: Star Spinner Jiggy'
        },
        ["1230624"] = {
            ['addr'] = 0x48,
            ['bit'] = 4,
            ['name'] = 'WW: The Inferno Jiggy'
        },
        ["1230625"] = {
            ['addr'] = 0x48,
            ['bit'] = 5,
            ['name'] = 'WW: Cactus of Strength Jiggy'
        },
        ["1230626"] = {
            ['addr'] = 0x48,
            ['bit'] = 6,
            ['name'] = 'JRL: Mini-Sub Challenge Jiggy'
        },
        ["1230627"] = {
            ['addr'] = 0x48,
            ['bit'] = 7,
            ['name'] = 'JRL: Tiptup Jiggy'
        },
        ["1230628"] = {
            ['addr'] = 0x49,
            ['bit'] = 0,
            ['name'] = 'JRL: Chris P. Bacon Jiggy'
        },
        ["1230629"] = {
            ['addr'] = 0x49,
            ['bit'] = 1,
            ['name'] = 'JRL: Pig Pool Jiggy'
        },
        ["1230630"] = {
            ['addr'] = 0x49,
            ['bit'] = 2,
            ['name'] = "JRL: Smuggler's Cavern Jiggy"
        },
        ["1230631"] = {
            ['addr'] = 0x49,
            ['bit'] = 3,
            ['name'] = 'JRL: Merry Maggie Jiggy'
        },
        ["1230632"] = {
            ['addr'] = 0x49,
            ['bit'] = 4,
            ['name'] = 'JRL: Woo Fak Fak Jiggy'
        },
        ["1230633"] = {
            ['addr'] = 0x49,
            ['bit'] = 5,
            ['name'] = 'JRL: Seemee Jiggy'
        },
        ["1230634"] = {
            ['addr'] = 0x49,
            ['bit'] = 6,
            ['name'] = 'JRL: Pawno Jiggy'
        },
        ["1230635"] = {
            ['addr'] = 0x49,
            ['bit'] = 7,
            ['name'] = 'JRL: UFO Jiggy'
        },
        ["1230636"] = {
            ['addr'] = 0x4A,
            ['bit'] = 0,
            ['name'] = "TDL: Under Terry's Nest Jiggy"
        },
        ["1230637"] = {
            ['addr'] = 0x4A,
            ['bit'] = 1,
            ['name'] = 'TDL: Dippy Jiggy'
        },
        ["1230638"] = {
            ['addr'] = 0x4A,
            ['bit'] = 2,
            ['name'] = 'TDL: Scrotty Jiggy'
        },
        ["1230639"] = {
            ['addr'] = 0x4A,
            ['bit'] = 3,
            ['name'] = 'TDL: Terry Jiggy'
        },
        ["1230640"] = {
            ['addr'] = 0x4A,
            ['bit'] = 4,
            ['name'] = 'TDL: Oogle Boogle Tribe Jiggy'
        },
        ["1230641"] = {
            ['addr'] = 0x4A,
            ['bit'] = 5,
            ['name'] = 'TDL: Chompas Belly Jiggy'
        },
        ["1230642"] = {
            ['addr'] = 0x4A,
            ['bit'] = 6,
            ['name'] = "TDL: Terry's Kids Jiggy"
        },
        ["1230643"] = {
            ['addr'] = 0x4A,
            ['bit'] = 7,
            ['name'] = 'TDL: Stomping Plains Jiggy'
        },
        ["1230644"] = {
            ['addr'] = 0x4B,
            ['bit'] = 0,
            ['name'] = 'TDL: Rocknut Tribe Jiggy'
        },
        ["1230645"] = {
            ['addr'] = 0x4B,
            ['bit'] = 1,
            ['name'] = 'TDL: Code of the Dinosaurs Jiggy'
        },
        ["1230646"] = {
            ['addr'] = 0x4B,
            ['bit'] = 2,
            ['name'] = 'GI: Underwater Waste Disposal Plant Jiggy'
        },
        ["1230647"] = {
            ['addr'] = 0x4B,
            ['bit'] = 3,
            ['name'] = 'GI: Weldar Jiggy'
        },
        ["1230648"] = {
            ['addr'] = 0x4B,
            ['bit'] = 4,
            ['name'] = "GI: Clinker's Cavern Jiggy"
        },
        ["1230649"] = {
            ['addr'] = 0x4B,
            ['bit'] = 5,
            ['name'] = 'GI: Skivvies Jiggy'
        },
        ["1230650"] = {
            ['addr'] = 0x4B,
            ['bit'] = 6,
            ['name'] = 'GI: Floor 5 Jiggy'
        },
        ["1230651"] = {
            ['addr'] = 0x4B,
            ['bit'] = 7,
            ['name'] = 'GI: Quality Control Jiggy'
        },
        ["1230652"] = {
            ['addr'] = 0x4C,
            ['bit'] = 0,
            ['name'] = 'GI: Floor 1 Guarded Jiggy'
        },
        ["1230653"] = {
            ['addr'] = 0x4C,
            ['bit'] = 1,
            ['name'] = 'GI: Trash Compactor Jiggy'
        },
        ["1230654"] = {
            ['addr'] = 0x4C,
            ['bit'] = 2,
            ['name'] = 'GI: Twinkly Packing Jiggy'
        },
        ["1230655"] = {
            ['addr'] = 0x4C,
            ['bit'] = 3,
            ['name'] = 'GI: Waste Disposal Plant Box Jiggy'
        },
        ["1230656"] = {
            ['addr'] = 0x4C,
            ['bit'] = 4,
            ['name'] = 'HFP: Dragon Brothers Jiggy'
        },
        ["1230657"] = {
            ['addr'] = 0x4C,
            ['bit'] = 5,
            ['name'] = 'HFP: Inside the Volcano Jiggy'
        },
        ["1230658"] = {
            ['addr'] = 0x4C,
            ['bit'] = 6,
            ['name'] = 'HFP: Sabreman Jiggy'
        },
        ["1230659"] = {
            ['addr'] = 0x4C,
            ['bit'] = 7,
            ['name'] = 'HFP: Boggy Jiggy'
        },
        ["1230660"] = {
            ['addr'] = 0x4D,
            ['bit'] = 0,
            ['name'] = 'HFP: Icy Side Station Jiggy'
        },
        ["1230661"] = {
            ['addr'] = 0x4D,
            ['bit'] = 1,
            ['name'] = 'HFP: Oil Drill Jiggy'
        },
        ["1230662"] = {
            ['addr'] = 0x4D,
            ['bit'] = 2,
            ['name'] = 'HFP: Stomping Plains Jiggy'
        },
        ["1230663"] = {
            ['addr'] = 0x4D,
            ['bit'] = 3,
            ['name'] = 'HFP: Kickball Jiggy'
        },
        ["1230664"] = {
            ['addr'] = 0x4D,
            ['bit'] = 4,
            ['name'] = 'HFP: Aliens Jiggy'
        },
        ["1230665"] = {
            ['addr'] = 0x4D,
            ['bit'] = 5,
            ['name'] = 'HFP: Lava Waterfall Jiggy'
        },
        ["1230666"] = {
            ['addr'] = 0x4D,
            ['bit'] = 6,
            ['name'] = 'CCL: Mingy Jongo Jiggy'
        },
        ["1230667"] = {
            ['addr'] = 0x4D,
            ['bit'] = 7,
            ['name'] = 'CCL: Mr Fit Jiggy'
        },
        ["1230668"] = {
            ['addr'] = 0x4E,
            ['bit'] = 0,
            ['name'] = "CCL: Pot O' Gold Jiggy"
        },
        ["1230669"] = {
            ['addr'] = 0x4E,
            ['bit'] = 1,
            ['name'] = 'CCL: Canary Mary Jiggy'
        },
        ["1230670"] = {
            ['addr'] = 0x4E,
            ['bit'] = 2,
            ['name'] = 'CCL: Zubbas Jiggy'
        },
        ["1230671"] = {
            ['addr'] = 0x4E,
            ['bit'] = 3,
            ['name'] = 'CCL: Jiggium Plant Jiggy'
        },
        ["1230672"] = {
            ['addr'] = 0x4E,
            ['bit'] = 4,
            ['name'] = 'CCL: Cheese Wedge Jiggy'
        },
        ["1230673"] = {
            ['addr'] = 0x4E,
            ['bit'] = 5,
            ['name'] = 'CCL: Trash Can Jiggy'
        },
        ["1230674"] = {
            ['addr'] = 0x4E,
            ['bit'] = 6,
            ['name'] = 'CCL: Superstash Jiggy'
        },
        ["1230675"] = {
            ['addr'] = 0x4E,
            ['bit'] = 7,
            ['name'] = 'CCL: Jelly Castle Jiggy'
        }
    },
    ['JINJOS'] = {
        ["1230591"] = {
            ['addr'] = 0x3E,
            ['bit'] = 4,
            ['name'] = 'IoH:Wooded Hollow Jinjo'
        },
        ["1230595"] = {
            ['addr'] = 0x3F,
            ['bit'] = 0,
            ['name'] = 'SM: Jinjo'
        },
        ["1230594"] = {
            ['addr'] = 0x3E,
            ['bit'] = 7,
            ['name'] = 'IoH: Plateau Jinjo'
        },
        ["1230551"] = {
            ['addr'] = 0x39,
            ['bit'] = 4,
            ['name'] = 'MT: Jade Snake Grove Jinjo'
        },
        ["1230552"] = {
            ['addr'] = 0x39,
            ['bit'] = 5,
            ['name'] = 'MT: Stadium Jinjo'
        },
        ["1230553"] = {
            ['addr'] = 0x39,
            ['bit'] = 6,
            ['name'] = 'Mayahem Temple: Targitzan Temple Jinjo'
        },
        ["1230554"] = {
            ['addr'] = 0x39,
            ['bit'] = 7,
            ['name'] = 'MT: Water Pool Jinjo'
        },
        ["1230555"] = {
            ['addr'] = 0x3A,
            ['bit'] = 0,
            ['name'] = 'MT: Bridge Jinjo'
        },
        ["1230556"] = {
            ['addr'] = 0x3A,
            ['bit'] = 1,
            ['name'] = 'GGM: Water Storage Jinjo'
        },
        ["1230557"] = {
            ['addr'] = 0x3A,
            ['bit'] = 2,
            ['name'] = 'GGM: Jail Jinjo'
        },
        ["1230558"] = {
            ['addr'] = 0x3A,
            ['bit'] = 3,
            ['name'] = 'GGM: Toxic Gas Cave Jinjo'
        },
        ["1230559"] = {
            ['addr'] = 0x3A,
            ['bit'] = 4,
            ['name'] = 'GGM: Boulder Jinjo'
        },
        ["1230560"] = {
            ['addr'] = 0x3A,
            ['bit'] = 5,
            ['name'] = 'GGM: Mine Tracks Jinjo'
        },
        ["1230561"] = {
            ['addr'] = 0x3A,
            ['bit'] = 6,
            ['name'] = 'WW: Big Top Jinjo'
        },
        ["1230562"] = {
            ['addr'] = 0x3A,
            ['bit'] = 7,
            ['name'] = 'WW: Cave of Horrors Jinjo'
        },
        ["1230563"] = {
            ['addr'] = 0x3B,
            ['bit'] = 0,
            ['name'] = 'WW: Van Door Jinjo'
        },
        ["1230564"] = {
            ['addr'] = 0x3B,
            ['bit'] = 1,
            ['name'] = 'WW: Dodgem Dome Jinjo'
        },
        ["1230565"] = {
            ['addr'] = 0x3B,
            ['bit'] = 2,
            ['name'] = 'WW: Cactus of Strength Jinjo'
        },
        ["1230593"] = {
            ['addr'] = 0x3E,
            ['bit'] = 6,
            ['name'] = 'IoH: Clifftop Jinjo'
        },
        ["1230566"] = {
            ['addr'] = 0x3B,
            ['bit'] = 3,
            ['name'] = 'JRL: Lagoon Alcove Jinjo'
        },
        ["1230567"] = {
            ['addr'] = 0x3B,
            ['bit'] = 4,
            ['name'] = 'JRL: Blubber Jinjo'
        },
        ["1230568"] = {
            ['addr'] = 0x3B,
            ['bit'] = 5,
            ['name'] = 'JRL: Big Fish Jinjo'
        },
        ["1230569"] = {
            ['addr'] = 0x3B,
            ['bit'] = 6,
            ['name'] = 'JRL: Seaweed Sanctum Jinjo'
        },
        ["1230570"] = {
            ['addr'] = 0x3B,
            ['bit'] = 7,
            ['name'] = 'JRL: Sunken Ship Jinjo'
        },
        ["1230592"] = {
            ['addr'] = 0x3E,
            ['bit'] = 5,
            ['name'] = 'IoH: Wasteland Jinjo'
        },
        ["1230571"] = {
            ['addr'] = 0x3C,
            ['bit'] = 0,
            ['name'] = 'TDL: Talon Torp Jinjo'
        },
        ["1230572"] = {
            ['addr'] = 0x3C,
            ['bit'] = 1,
            ['name'] = 'TDL: Cutscene Skip Jinjo'
        },
        ["1230573"] = {
            ['addr'] = 0x3C,
            ['bit'] = 2,
            ['name'] = 'TDL: Beside Rocknut Jinjo'
        },
        ["1230574"] = {
            ['addr'] = 0x3C,
            ['bit'] = 3,
            ['name'] = 'TDL: Big T. Rex Skip Jinjo'
        },
        ["1230575"] = {
            ['addr'] = 0x3C,
            ['bit'] = 4,
            ['name'] = 'TDL: Stomping Plains Jinjo'
        },
        ["1230576"] = {
            ['addr'] = 0x3C,
            ['bit'] = 5,
            ['name'] = 'GI: Floor 5 Jinjo'
        },
        ["1230577"] = {
            ['addr'] = 0x3C,
            ['bit'] = 6,
            ['name'] = 'GI: Leg Spring Jinjo'
        },
        ["1230578"] = {
            ['addr'] = 0x3C,
            ['bit'] = 7,
            ['name'] = 'GI: Waste Disposal Plant Jinjo'
        },
        ["1230579"] = {
            ['addr'] = 0x3D,
            ['bit'] = 0,
            ['name'] = 'GI: Boiler Plant Jinjo'
        },
        ["1230580"] = {
            ['addr'] = 0x3D,
            ['bit'] = 1,
            ['name'] = 'GI: Outside Jinjo'
        },
        ["1230581"] = {
            ['addr'] = 0x3D,
            ['bit'] = 2,
            ['name'] = 'HFP: Lava Waterfall Jinjo'
        },
        ["1230582"] = {
            ['addr'] = 0x3D,
            ['bit'] = 3,
            ['name'] = 'HFP: Boiling Hot Pool Jinjo'
        },
        ["1230583"] = {
            ['addr'] = 0x3D,
            ['bit'] = 4,
            ['name'] = 'HFP: Windy Hole Jinjo'
        },
        ["1230584"] = {
            ['addr'] = 0x3D,
            ['bit'] = 5,
            ['name'] = 'HFP: Icicle Grotto Jinjo'
        },
        ["1230585"] = {
            ['addr'] = 0x3D,
            ['bit'] = 6,
            ['name'] = 'HFP: Mildred Ice Cube Jinjo'
        },
        ["1230586"] = {
            ['addr'] = 0x3D,
            ['bit'] = 7,
            ['name'] = 'CCL: Trash Can Jinjo'
        },
        ["1230587"] = {
            ['addr'] = 0x3E,
            ['bit'] = 0,
            ['name'] = 'CCL: Cheese Wedge Jinjo'
        },
        ["1230588"] = {
            ['addr'] = 0x3E,
            ['bit'] = 1,
            ['name'] = 'CCL: Central Cavern Jinjo'
        },
        ["1230589"] = {
            ['addr'] = 0x3E,
            ['bit'] = 2,
            ['name'] = 'CCL: Fake Mumbo Skull Jinjo'
        },
        ["1230590"] = {
            ['addr'] = 0x3E,
            ['bit'] = 3,
            ['name'] = 'CCL: Wumba Jinjo'
        }
    },
    ['PAGES'] = {
        ["1230752"] = {
            ['addr'] = 0x59,
            ['bit'] = 3,
            ['name'] = 'Spiral Mountain: Cheato Page'
        },
        ["1230728"] = {
            ['addr'] = 0x56,
            ['bit'] = 3,
            ['name'] = 'MT: Snake Head Cheato Page'
        },
        ["1230729"] = {
            ['addr'] = 0x56,
            ['bit'] = 4,
            ['name'] = 'MT: Prison Compound Cheato Page'
        },
        ["1230730"] = {
            ['addr'] = 0x56,
            ['bit'] = 5,
            ['name'] = 'MT: Jade Snake Grove Cheato Page'
        },
        ["1230731"] = {
            ['addr'] = 0x56,
            ['bit'] = 6,
            ['name'] = 'GGM: Canary Mary Cheato Page'
        },
        ["1230732"] = {
            ['addr'] = 0x56,
            ['bit'] = 7,
            ['name'] = 'GGM: Entrance Cheato Page'
        },
        ["1230733"] = {
            ['addr'] = 0x57,
            ['bit'] = 0,
            ['name'] = 'GGM: Water Storage Cheato Page'
        },
        ["1230734"] = {
            ['addr'] = 0x57,
            ['bit'] = 1,
            ['name'] = 'WW: The Haunted Cavern Cheato Page'
        },
        ["1230735"] = {
            ['addr'] = 0x57,
            ['bit'] = 2,
            ['name'] = 'WW: The Inferno Cheato Page'
        },
        ["1230736"] = {
            ['addr'] = 0x57,
            ['bit'] = 3,
            ['name'] = 'WW: Saucer of Peril Cheato Page'
        },
        ["1230737"] = {
            ['addr'] = 0x57,
            ['bit'] = 4,
            ['name'] = "JRL: Pawno's Cheato Page"
        },
        ["1230738"] = {
            ['addr'] = 0x57,
            ['bit'] = 5,
            ['name'] = 'JRL: Seemee Cheato Page'
        },
        ["1230739"] = {
            ['addr'] = 0x57,
            ['bit'] = 6,
            ['name'] = 'JRL: Ancient Baths Cheato Page'
        },
        ["1230740"] = {
            ['addr'] = 0x57,
            ['bit'] = 7,
            ['name'] = "TDL: Dippy's Pool Cheato Page"
        },
        ["1230741"] = {
            ['addr'] = 0x58,
            ['bit'] = 0,
            ['name'] = 'TDL: Inside the Mountain Cheato Page'
        },
        ["1230742"] = {
            ['addr'] = 0x58,
            ['bit'] = 1,
            ['name'] = 'TDL: Boulder Cheato Page'
        },
        ["1230743"] = {
            ['addr'] = 0x58,
            ['bit'] = 2,
            ['name'] = 'GI: Loggo Cheato Page'
        },
        ["1230744"] = {
            ['addr'] = 0x58,
            ['bit'] = 3,
            ['name'] = 'GI: Floor 2 Cheato Page'
        },
        ["1230745"] = {
            ['addr'] = 0x58,
            ['bit'] = 4,
            ['name'] = 'GI: Repair Depot Cheato Page'
        },
        ["1230746"] = {
            ['addr'] = 0x58,
            ['bit'] = 5,
            ['name'] = 'HFP: Lava Side Cheato Page'
        },
        ["1230747"] = {
            ['addr'] = 0x58,
            ['bit'] = 6,
            ['name'] = 'HFP: Icicle Grotto Cheato Page'
        },
        ["1230748"] = {
            ['addr'] = 0x58,
            ['bit'] = 7,
            ['name'] = 'HFP: Icy Side Cheato Page'
        },
        ["1230749"] = {
            ['addr'] = 0x59,
            ['bit'] = 0,
            ['name'] = 'CCL: Canary Mary Cheato Page'
        },
        ["1230750"] = {
            ['addr'] = 0x59,
            ['bit'] = 1,
            ['name'] = "CCL: Pot O' Gold Cheato Page"
        },
        ["1230751"] = {
            ['addr'] = 0x59,
            ['bit'] = 2,
            ['name'] = 'CCL: Zubbas Cheato Page'
        },
    },
    ['HONEYCOMB'] = {
        ["1230727"] = {
            ['addr'] = 0x42,
            ['bit'] = 2,
            ['name'] = 'Plateau: Honeycomb'
        },
        ["1230703"] = {
            ['addr'] = 0x3F,
            ['bit'] = 2,
            ['name'] = 'MT: Entrance Honeycomb'
        },
        ["1230704"] = {
            ['addr'] = 0x3F,
            ['bit'] = 3,
            ['name'] = 'MT: Bovina Honeycomb'
        },
        ["1230705"] = {
            ['addr'] = 0x3F,
            ['bit'] = 4,
            ['name'] = 'MT: Treasure Chamber Honeycomb'
        },
        ["1230706"] = {
            ['addr'] = 0x3F,
            ['bit'] = 5,
            ['name'] = 'GGM: Toxic Gas Cave Honeycomb'
        },
        ["1230707"] = {
            ['addr'] = 0x3F,
            ['bit'] = 6,
            ['name'] = 'GGM: Boulder Honeycomb'
        },
        ["1230708"] = {
            ['addr'] = 0x3F,
            ['bit'] = 7,
            ['name'] = 'GGM: Train Station Honeycomb'
        },
        ["1230709"] = {
            ['addr'] = 0x40,
            ['bit'] = 0,
            ['name'] = 'WW: Space Zone Honeycomb'
        },
        ["1230710"] = {
            ['addr'] = 0x40,
            ['bit'] = 1,
            ['name'] = 'WW: Mumbo Skull Honeycomb'
        },
        ["1230711"] = {
            ['addr'] = 0x40,
            ['bit'] = 2,
            ['name'] = 'WW: Crazy Castle Honeycomb'
        },
        ["1230712"] = {
            ['addr'] = 0x40,
            ['bit'] = 3,
            ['name'] = 'JRL: Seemee Honeycomb'
        },
        ["1230713"] = {
            ['addr'] = 0x40,
            ['bit'] = 4,
            ['name'] = 'JRL: Atlantis Honeycomb'
        },
        ["1230714"] = {
            ['addr'] = 0x40,
            ['bit'] = 5,
            ['name'] = 'JRL: Waste Pipe Honeycomb'
        },
        ["1230715"] = {
            ['addr'] = 0x40,
            ['bit'] = 6,
            ['name'] = 'TDL: Lakeside Honeycomb'
        },
        ["1230716"] = {
            ['addr'] = 0x40,
            ['bit'] = 7,
            ['name'] = 'TDL: Styracosaurus Cave Honeycomb'
        },
        ["1230717"] = {
            ['addr'] = 0x41,
            ['bit'] = 0,
            ['name'] = 'TDL: River Passage Honeycomb'
        },
        ["1230718"] = {
            ['addr'] = 0x41,
            ['bit'] = 1,
            ['name'] = 'GI: Floor 3 Honeycomb'
        },
        ["1230719"] = {
            ['addr'] = 0x41,
            ['bit'] = 2,
            ['name'] = 'GI: Train Station Honeycomb'
        },
        ["1230720"] = {
            ['addr'] = 0x41,
            ['bit'] = 3,
            ['name'] = 'GI: Chimney Honeycomb'
        },
        ["1230721"] = {
            ['addr'] = 0x41,
            ['bit'] = 4,
            ['name'] = 'HFP: Inside the Volcano Honeycomb'
        },
        ["1230722"] = {
            ['addr'] = 0x41,
            ['bit'] = 5,
            ['name'] = 'HFP: Train Station Honeycomb'
        },
        ["1230723"] = {
            ['addr'] = 0x41,
            ['bit'] = 6,
            ['name'] = 'HFP: Lava Side Honeycomb'
        },
        ["1230724"] = {
            ['addr'] = 0x41,
            ['bit'] = 7,
            ['name'] = 'CCL: Dirt Patch Honeycomb'
        },
        ["1230725"] = {
            ['addr'] = 0x42,
            ['bit'] = 0,
            ['name'] = 'CCL: Trash Can Honeycomb'
        },
        ["1230726"] = {
            ['addr'] = 0x42,
            ['bit'] = 1,
            ['name'] = "CCL: Pot O' Gold Honeycomb"
        },
    },
    ['GLOWBO'] = {
        ["1230046"] = {
            ['addr'] = 0x05,
            ['bit'] = 6,
            ['name'] = 'Mega Glowbo'
        },
        ["1230686"] = {
            ['addr'] = 0x42,
            ['bit'] = 7,
            ['name'] = "MT: Mumbo's Glowbo"
        },
        ["1230687"] = {
            ['addr'] = 0x43,
            ['bit'] = 0,
            ['name'] = 'MT: Jade Snake Grove Glowbo'

        },
        ["1230688"] = {
            ['addr'] = 0x43,
            ['bit'] = 1,
            ['name'] = 'GGM: Near Entrance Glowbo'

        },
        ["1230689"] = {
            ['addr'] = 0x43,
            ['bit'] = 2,
            ['name'] = 'GGM: Mine Entrance 2 Glowbo'

        },
        ["1230690"] = {
            ['addr'] = 0x43,
            ['bit'] = 3,
            ['name'] = 'WW: The Inferno Glowbo'

        },
        ["1230691"] = {
            ['addr'] = 0x43,
            ['bit'] = 4,
            ['name'] = "WW: Wumba's Glowbo"

        },
        ["1230702"] = {
            ['addr'] = 0x44,
            ['bit'] = 7,
            ['name'] = 'Cliff Top: Glowbo'

        },
        ["1230692"] = {
            ['addr'] = 0x43,
            ['bit'] = 5,
            ['name'] = "JRL: Pawno's Emporium Glowbo"

        },
        ["1230693"] = {
            ['addr'] = 0x43,
            ['bit'] = 6,
            ['name'] = "JRL: Under Wumba's Wigwam Glowbo"

        },
        ["1230694"] = {
            ['addr'] = 0x43,
            ['bit'] = 7,
            ['name'] = 'TDL: Unga Bunga Cave Entrance Glowbo'

        },
        ["1230695"] = {
            ['addr'] = 0x44,
            ['bit'] = 0,
            ['name'] = "TDL: Behind Mumbo's Skull Glowbo"

        },
        ["1230696"] = {
            ['addr'] = 0x44,
            ['bit'] = 1,
            ['name'] = 'GI: Floor 2 Glowbo'

        },
        ["1230697"] = {
            ['addr'] = 0x44,
            ['bit'] = 2,
            ['name'] = 'GI: Floor 3 Glowbo'

        },
        ["1230698"] = {
            ['addr'] = 0x44,
            ['bit'] = 3,
            ['name'] = 'HFP: Lava Side Glowbo'

        },
        ["1230699"] = {
            ['addr'] = 0x44,
            ['bit'] = 4,
            ['name'] = 'HFP: Icy Side Glowbo'

        },
        ["1230700"] = {
            ['addr'] = 0x44,
            ['bit'] = 5,
            ['name'] = 'CCL: Green Pool Glowbo'

        },
        ["1230701"] = {
            ['addr'] = 0x44,
            ['bit'] = 6,
            ['name'] = 'CCL: Central Cavern Glowbo'

        },
    },
    ['DOUBLOON'] = {
        ["1230521"] = {
            ['addr'] = 0x22,
            ['bit'] = 7,
            ['name'] = 'JRL: Town Center Pole 1 Doubloon'
        },
        ["1230522"] = {
            ['addr'] = 0x23,
            ['bit'] = 0,
            ['name'] = 'JRL: Town Center Pole 2 Doubloon'
        },
        ["1230523"] = {
            ['addr'] = 0x23,
            ['bit'] = 1,
            ['name'] = 'JRL: Town Center Pole 3 Doubloon'
        },
        ["1230524"] = {
            ['addr'] = 0x23,
            ['bit'] = 2,
            ['name'] = 'JRL: Town Center Pole 4 Doubloon'
        },
        ["1230525"] = {
            ['addr'] = 0x23,
            ['bit'] = 3,
            ['name'] = 'JRL: Town Center Pole 5 Doubloon'
        },
        ["1230526"] = {
            ['addr'] = 0x23,
            ['bit'] = 4,
            ['name'] = 'JRL: Town Center Pole 6 Doubloon'
        },
        ["1230527"] = {
            ['addr'] = 0x23,
            ['bit'] = 5,
            ['name'] = 'JRL: Silo 1 Doubloon'
        },
        ["1230528"] = {
            ['addr'] = 0x23,
            ['bit'] = 6,
            ['name'] = 'JRL: Silo 2 Doubloon'
        },
        ["1230529"] = {
            ['addr'] = 0x23,
            ['bit'] = 7,
            ['name'] = 'JRL: Silo 3 Doubloon'
        },
        ["1230530"] = {
            ['addr'] = 0x24,
            ['bit'] = 0,
            ['name'] = 'JRL: Silo 4 Doubloon'
        },
        ["1230531"] = {
            ['addr'] = 0x24,
            ['bit'] = 1,
            ['name'] = 'JRL: Toxic Pool 1 Doubloon'
        },
        ["1230532"] = {
            ['addr'] = 0x24,
            ['bit'] = 2,
            ['name'] = 'JRL: Toxic Pool 2 Doubloon'
        },
        ["1230533"] = {
            ['addr'] = 0x24,
            ['bit'] = 3,
            ['name'] = 'JRL: Toxic Pool 3 Doubloon'
        },
        ["1230534"] = {
            ['addr'] = 0x24,
            ['bit'] = 4,
            ['name'] = 'JRL: Toxic Pool 4 Doubloon'
        },
        ["1230535"] = {
            ['addr'] = 0x24,
            ['bit'] = 5,
            ['name'] = 'JRL: Mumbo Skull 1 Doubloon'
        },
        ["1230536"] = {
            ['addr'] = 0x24,
            ['bit'] = 6,
            ['name'] = 'JRL: Mumbo Skull 2 Doubloon'
        },
        ["1230537"] = {
            ['addr'] = 0x24,
            ['bit'] = 7,
            ['name'] = 'JRL: Mumbo Skull 3 Doubloon'
        },
        ["1230538"] = {
            ['addr'] = 0x25,
            ['bit'] = 0,
            ['name'] = 'JRL: Mumbo Skull 4 Doubloon'
        },
        ["1230539"] = {
            ['addr'] = 0x25,
            ['bit'] = 1,
            ['name'] = 'JRL: Underground 1 Doubloon'
        },
        ["1230540"] = {
            ['addr'] = 0x25,
            ['bit'] = 2,
            ['name'] = 'JRL: Underground 2 Doubloon'
        },
        ["1230541"] = {
            ['addr'] = 0x25,
            ['bit'] = 3,
            ['name'] = 'JRL: Underground 3 Doubloon'
        },
        ["1230542"] = {
            ['addr'] = 0x25,
            ['bit'] = 4,
            ['name'] = 'JRL: Alcove 1 Doubloon'
        },
        ["1230543"] = {
            ['addr'] = 0x25,
            ['bit'] = 5,
            ['name'] = 'JRL: Alcove 2 Doubloon'
        },
        ["1230544"] = {
            ['addr'] = 0x25,
            ['bit'] = 6,
            ['name'] = 'JRL: Alcove 3 Doubloon'
        },
        ["1230545"] = {
            ['addr'] = 0x25,
            ['bit'] = 7,
            ['name'] = 'JRL: Capt Blackeye 1 Doubloon'
        },
        ["1230546"] = {
            ['addr'] = 0x26,
            ['bit'] = 0,
            ['name'] = 'JRL: Capt Blackeye 2 Doubloon'
        },
        ["1230547"] = {
            ['addr'] = 0x26,
            ['bit'] = 1,
            ['name'] = 'JRL: Near Jinjo 1 Doubloon'
        },
        ["1230548"] = {
            ['addr'] = 0x26,
            ['bit'] = 2,
            ['name'] = 'JRL: Near Jinjo 2 Doubloon'
        },
        ["1230549"] = {
            ['addr'] = 0x26,
            ['bit'] = 3,
            ['name'] = 'JRL: Near Jinjo 3 Doubloon'
        },
        ["1230550"] = {
            ['addr'] = 0x26,
            ['bit'] = 4,
            ['name'] = 'JRL: Near Jinjo 4 Doubloon'
        }
    },
    ['NOTES'] = {
        ["1230800"] = {
            ['addr'] = 0x84,
            ['bit'] = 7,
        },
        ["1230801"] = {
            ['addr'] = 0x85,
            ['bit'] = 0,
        },
        ["1230802"] = {
            ['addr'] = 0x85,
            ['bit'] = 1,
        },
        ["1230803"] = {
            ['addr'] = 0x85,
            ['bit'] = 2,
        },
        ["1230804"] = {
            ['addr'] = 0x85,
            ['bit'] = 3,
        },
        ["1230805"] = {
            ['addr'] = 0x85,
            ['bit'] = 4,
        },
        ["1230806"] = {
            ['addr'] = 0x85,
            ['bit'] = 5,
        },
        ["1230807"] = {
            ['addr'] = 0x85,
            ['bit'] = 6,
        },
        ["1230808"] = {
            ['addr'] = 0x85,
            ['bit'] = 7,
        },
        ["1230809"] = {
            ['addr'] = 0x86,
            ['bit'] = 0,
        },
        ["1230810"] = {
            ['addr'] = 0x86,
            ['bit'] = 1,
        },
        ["1230811"] = {
            ['addr'] = 0x86,
            ['bit'] = 2,
        },
        ["1230812"] = {
            ['addr'] = 0x86,
            ['bit'] = 3,
        },
        ["1230813"] = {
            ['addr'] = 0x86,
            ['bit'] = 4,
        },
        ["1230814"] = {
            ['addr'] = 0x86,
            ['bit'] = 5,
        },
        ["1230815"] = {
            ['addr'] = 0x86,
            ['bit'] = 6,
        },
         -- EO Mayahem Temple
         ["1230816"] = {
            ['addr'] = 0x87,
            ['bit'] = 0,
        },
        ["1230817"] = {
            ['addr'] = 0x87,
            ['bit'] = 1,
        },
        ["1230818"] = {
            ['addr'] = 0x87,
            ['bit'] = 2,
        },
        ["1230819"] = {
            ['addr'] = 0x87,
            ['bit'] = 3,
        },
        ["1230820"] = {
            ['addr'] = 0x87,
            ['bit'] = 4,
        },
        ["1230821"] = {
            ['addr'] = 0x87,
            ['bit'] = 5,
        },
        ["1230822"] = {
            ['addr'] = 0x87,
            ['bit'] = 6,
        },
        ["1230823"] = {
            ['addr'] = 0x87,
            ['bit'] = 7,
        },
        ["1230824"] = {
            ['addr'] = 0x88,
            ['bit'] = 0,
        },
        ["1230825"] = {
            ['addr'] = 0x88,
            ['bit'] = 1,
        },
        ["1230826"] = {
            ['addr'] = 0x88,
            ['bit'] = 2,
        },
        ["1230827"] = {
            ['addr'] = 0x88,
            ['bit'] = 3,
        },
        ["1230828"] = {
            ['addr'] = 0x88,
            ['bit'] = 4,
        },
        ["1230829"] = {
            ['addr'] = 0x88,
            ['bit'] = 5,
        },
        ["1230830"] = {
            ['addr'] = 0x88,
            ['bit'] = 6,
        },
        ["1230831"] = {
            ['addr'] = 0x88,
            ['bit'] = 7,
        },
        -- EO GGM
        ["1230832"] = {
            ['addr'] = 0x89,
            ['bit'] = 1,
        },
        ["1230833"] = {
            ['addr'] = 0x89,
            ['bit'] = 2,
        },
        ["1230834"] = {
            ['addr'] = 0x89,
            ['bit'] = 3,
        },
        ["1230835"] = {
            ['addr'] = 0x89,
            ['bit'] = 4,
        },
        ["1230836"] = {
            ['addr'] = 0x89,
            ['bit'] = 5,
        },
        ["1230837"] = {
            ['addr'] = 0x89,
            ['bit'] = 6,
        },
        ["1230838"] = {
            ['addr'] = 0x89,
            ['bit'] = 7,
        },
        ["1230839"] = {
            ['addr'] = 0x8A,
            ['bit'] = 0,
        },
        ["1230840"] = {
            ['addr'] = 0x8A,
            ['bit'] = 1,
        },
        ["1230841"] = {
            ['addr'] = 0x8A,
            ['bit'] = 2,
        },
        ["1230842"] = {
            ['addr'] = 0x8A,
            ['bit'] = 3,
        },
        ["1230843"] = {
            ['addr'] = 0x8A,
            ['bit'] = 4,
        },
        ["1230844"] = {
            ['addr'] = 0x8A,
            ['bit'] = 5,
        },
        ["1230845"] = {
            ['addr'] = 0x8A,
            ['bit'] = 6,
        },
        ["1230846"] = {
            ['addr'] = 0x8A,
            ['bit'] = 7,
        },
        ["1230847"] = {
            ['addr'] = 0x8B,
            ['bit'] = 0,
        },
        --EO WW
        ["1230848"] = {
            ['addr'] = 0x8B,
            ['bit'] = 2,
        },
        ["1230849"] = {
            ['addr'] = 0x8B,
            ['bit'] = 3,
        },
        ["1230850"] = {
            ['addr'] = 0x8B,
            ['bit'] = 4,
        },
        ["1230851"] = {
            ['addr'] = 0x8B,
            ['bit'] = 5,
        },
        ["1230852"] = {
            ['addr'] = 0x8B,
            ['bit'] = 6,
        },
        ["1230853"] = {
            ['addr'] = 0x8B,
            ['bit'] = 7,
        },
        ["1230854"] = {
            ['addr'] = 0x8C,
            ['bit'] = 0,
        },
        ["1230855"] = {
            ['addr'] = 0x8C,
            ['bit'] = 1,
        },
        ["1230856"] = {
            ['addr'] = 0x8C,
            ['bit'] = 2,
        },
        ["1230857"] = {
            ['addr'] = 0x8C,
            ['bit'] = 3,
        },
        ["1230858"] = {
            ['addr'] = 0x8C,
            ['bit'] = 4,
        },
        ["1230859"] = {
            ['addr'] = 0x8C,
            ['bit'] = 5,
        },
        ["1230860"] = {
            ['addr'] = 0x8C,
            ['bit'] = 6,
        },
        ["1230861"] = {
            ['addr'] = 0x8C,
            ['bit'] = 7,
        },
        ["1230862"] = {
            ['addr'] = 0x8D,
            ['bit'] = 0,
        },
        ["1230863"] = {
            ['addr'] = 0x8D,
            ['bit'] = 1,
        },
        -- EO JRL
        ["1230864"] = {
            ['addr'] = 0x8D,
            ['bit'] = 3,
        },
        ["1230865"] = {
            ['addr'] = 0x8D,
            ['bit'] = 4,
        },
        ["1230866"] = {
            ['addr'] = 0x8D,
            ['bit'] = 5,
        },
        ["1230867"] = {
            ['addr'] = 0x8D,
            ['bit'] = 6,
        },
        ["1230868"] = {
            ['addr'] = 0x8D,
            ['bit'] = 7,
        },
        ["1230869"] = {
            ['addr'] = 0x8E,
            ['bit'] = 0,
        },
        ["1230870"] = {
            ['addr'] = 0x8E,
            ['bit'] = 1,
        },
        ["1230871"] = {
            ['addr'] = 0x8E,
            ['bit'] = 2,
        },
        ["1230872"] = {
            ['addr'] = 0x8E,
            ['bit'] = 3,
        },
        ["1230873"] = {
            ['addr'] = 0x8E,
            ['bit'] = 4,
        },
        ["1230874"] = {
            ['addr'] = 0x8E,
            ['bit'] = 5,
        },
        ["1230875"] = {
            ['addr'] = 0x8E,
            ['bit'] = 6,
        },
        ["1230876"] = {
            ['addr'] = 0x8E,
            ['bit'] = 7,
        },
        ["1230877"] = {
            ['addr'] = 0x8F,
            ['bit'] = 0,
        },
        ["1230878"] = {
            ['addr'] = 0x8F,
            ['bit'] = 1,
        },
        ["1230879"] = {
            ['addr'] = 0x8F,
            ['bit'] = 2,
        },
        -- EO TDL
        ["1230880"] = {
            ['addr'] = 0x8F,
            ['bit'] = 4,
        },
        ["1230881"] = {
            ['addr'] = 0x8F,
            ['bit'] = 5,
        },
        ["1230882"] = {
            ['addr'] = 0x8F,
            ['bit'] = 6,
        },
        ["1230883"] = {
            ['addr'] = 0x8F,
            ['bit'] = 7,
        },
        ["1230884"] = {
            ['addr'] = 0x90,
            ['bit'] = 0,
        },
        ["1230885"] = {
            ['addr'] = 0x90,
            ['bit'] = 1,
        },
        ["1230886"] = {
            ['addr'] = 0x90,
            ['bit'] = 2,
        },
        ["1230887"] = {
            ['addr'] = 0x90,
            ['bit'] = 3,
        },
        ["1230888"] = {
            ['addr'] = 0x90,
            ['bit'] = 4,
        },
        ["1230889"] = {
            ['addr'] = 0x90,
            ['bit'] = 5,
        },
        ["1230890"] = {
            ['addr'] = 0x90,
            ['bit'] = 6,
        },
        ["1230891"] = {
            ['addr'] = 0x90,
            ['bit'] = 7,
        },
        ["1230892"] = {
            ['addr'] = 0x91,
            ['bit'] = 0,
        },
        ["1230893"] = {
            ['addr'] = 0x91,
            ['bit'] = 1,
        },
        ["1230894"] = {
            ['addr'] = 0x91,
            ['bit'] = 2,
        },
        ["1230895"] = {
            ['addr'] = 0x91,
            ['bit'] = 3,
        },
        -- EO GI
        ["1230896"] = {
            ['addr'] = 0x91,
            ['bit'] = 5,
        },
        ["1230897"] = {
            ['addr'] = 0x91,
            ['bit'] = 6,
        },
        ["1230898"] = {
            ['addr'] = 0x91,
            ['bit'] = 7,
        },
        ["1230899"] = {
            ['addr'] = 0x92,
            ['bit'] = 0,
        },
        ["1230900"] = {
            ['addr'] = 0x92,
            ['bit'] = 1,
        },
        ["1230901"] = {
            ['addr'] = 0x92,
            ['bit'] = 2,
        },
        ["1230902"] = {
            ['addr'] = 0x92,
            ['bit'] = 3,
        },
        ["1230903"] = {
            ['addr'] = 0x92,
            ['bit'] = 4,
        },
        ["1230904"] = {
            ['addr'] = 0x92,
            ['bit'] = 5,
        },
        ["1230905"] = {
            ['addr'] = 0x92,
            ['bit'] = 6,
        },
        ["1230906"] = {
            ['addr'] = 0x92,
            ['bit'] = 7,
        },
        ["1230907"] = {
            ['addr'] = 0x93,
            ['bit'] = 0,
        },
        ["1230908"] = {
            ['addr'] = 0x93,
            ['bit'] = 1,
        },
        ["1230909"] = {
            ['addr'] = 0x93,
            ['bit'] = 2,
        },
        ["1230910"] = {
            ['addr'] = 0x93,
            ['bit'] = 3,
        },
        ["1230911"] = {
            ['addr'] = 0x93,
            ['bit'] = 4,
        },
        -- EO HFP
        ["1230912"] = {
            ['addr'] = 0x93,
            ['bit'] = 6,
        },
        ["1230913"] = {
            ['addr'] = 0x93,
            ['bit'] = 7,
        },
        ["1230914"] = {
            ['addr'] = 0x94,
            ['bit'] = 0,
        },
        ["1230915"] = {
            ['addr'] = 0x94,
            ['bit'] = 1,
        },
        ["1230916"] = {
            ['addr'] = 0x94,
            ['bit'] = 2,
        },
        ["1230917"] = {
            ['addr'] = 0x94,
            ['bit'] = 3,
        },
        ["1230918"] = {
            ['addr'] = 0x94,
            ['bit'] = 4,
        },
        ["1230919"] = {
            ['addr'] = 0x94,
            ['bit'] = 5,
        },
        ["1230920"] = {
            ['addr'] = 0x94,
            ['bit'] = 6,
        },
        ["1230921"] = {
            ['addr'] = 0x94,
            ['bit'] = 7,
        },
        ["1230922"] = {
            ['addr'] = 0x95,
            ['bit'] = 0,
        },
        ["1230923"] = {
            ['addr'] = 0x95,
            ['bit'] = 1,
        },
        ["1230924"] = {
            ['addr'] = 0x95,
            ['bit'] = 2,
        },
        ["1230925"] = {
            ['addr'] = 0x95,
            ['bit'] = 3,
        },
        ["1230926"] = {
            ['addr'] = 0x95,
            ['bit'] = 4,
        },
        ["1230927"] = {
            ['addr'] = 0x95,
            ['bit'] = 5,
        },
        -- EO CCL
        ["1230928"] = {
            ['addr'] = 0x95,
            ['bit'] = 7,
        },
        ["1230929"] = {
            ['addr'] = 0x96,
            ['bit'] = 0,
        },
        ["1230930"] = {
            ['addr'] = 0x96,
            ['bit'] = 1,
        },
        ["1230931"] = {
            ['addr'] = 0x96,
            ['bit'] = 2,
        },
        ["1230932"] = {
            ['addr'] = 0x96,
            ['bit'] = 3,
        },
        ["1230933"] = {
            ['addr'] = 0x96,
            ['bit'] = 4,
        },
        ["1230934"] = {
            ['addr'] = 0x96,
            ['bit'] = 5,
        },
        ["1230935"] = {
            ['addr'] = 0x96,
            ['bit'] = 6,
        },
        ["1230936"] = {
            ['addr'] = 0x96,
            ['bit'] = 7,
        },
        ["1230937"] = {
            ['addr'] = 0x97,
            ['bit'] = 0,
        },
        ["1230938"] = {
            ['addr'] = 0x97,
            ['bit'] = 1,
        },
        ["1230939"] = {
            ['addr'] = 0x97,
            ['bit'] = 2,
        },
        ["1230940"] = {
            ['addr'] = 0x97,
            ['bit'] = 3,
        },
        ["1230941"] = {
            ['addr'] = 0x97,
            ['bit'] = 4,
        },
        ["1230942"] = {
            ['addr'] = 0x97,
            ['bit'] = 5,
        },
        ["1230943"] = {
            ['addr'] = 0x97,
            ['bit'] = 6,
        }
    },
    ['AMAZE'] = {
        ["1231005"] = {
            ['addr'] = 0x1E,
            ['bit'] = 0,
        }
    },
    ['ROAR'] = {
        ["1231009"] = {
            ['addr'] = 0x1C,
            ['bit'] = 5,
        }
    },
    ['H1'] = {
        ["1230027"] = {
           ['addr'] = 0x03,
           ['bit'] = 3,
           ['name'] = "Hag 1 Defeated"
       },
   },
}

-- Properties of world entrances and associated puzzles
local WORLD_ENTRANCE_MAP = {
    ["WORLD 1"] = {
        ["defaultName"] = "Mayahem Temple",
        ["defaultCost"] = 1,
        ["locationId"] = "0"
    },
    ["WORLD 2"] = {
        ["defaultName"] = "Glitter Gulch Mine",
        ["defaultCost"] = 4,
        ["locationId"] = "0"
    },
    ["WORLD 3"] = {
        ["defaultName"] = "Witchyworld",
        ["defaultCost"] = 8,
        ["locationId"] = "0"
    },
    ["WORLD 4"] = {
        ["defaultName"] = "Jolly Roger's Lagoon",
        ["defaultCost"] = 14,
        ["locationId"] = "0"
    },
    ["WORLD 5"] = {
        ["defaultName"] = "Terrydactyland",
        ["defaultCost"] = 20,
        ["locationId"] = "0"
    },
    ["WORLD 6"] = {
        ["defaultName"] = "Grunty Industries",
        ["defaultCost"] = 28,
        ["locationId"] = "0"
    },
    ["WORLD 7"] = {
        ["defaultName"] = "Hailfire Peaks",
        ["defaultCost"] = 36,
        ["locationId"] = "0"
    },
    ["WORLD 8"] = {
        ["defaultName"] = "Cloud Cuckooland",
        ["defaultCost"] = 45,
        ["locationId"] = "0"
    },
    ["WORLD 9"] = {
        ["defaultName"] = "Cauldron Keep",
        ["defaultCost"] = 55,
        ["locationId"] = "0"
    }
}

-- Used for randomized maps
local MAP_ENTRANCES = {
    [0xB8] = {
        ['name'] = "Mayahem Temple",
        ['entranceId'] = 10,
        ['exitId'] = 2,
        ['exitMap'] = 0x14F
    },
    [0xC7] = {
        ['name'] = "Glitter Gulch Mine",
        ['entranceId'] = 17,
        ['exitId'] = 2,
        ['exitMap'] = 0x152
    },
    [0xD6] = {
        ['name'] = "Witchyworld",
        ['entranceId'] = 18,
        ['exitId'] = 2,
        ['exitMap'] = 0x154
    },
    [0x1A7] = {
        ['name'] = "Jolly Roger's Lagoon - Town Center",
        ['entranceId'] = 3,
        ['exitId'] = 5,
        ['exitMap'] = 0x155
    },
    [0x112] = {
        ['name'] = "Terrydactyland",
        ['entranceId'] = 23,
        ['exitId'] = 2,
        ['exitMap'] = 0x15A
    },
    [0x100] = {
        ['name'] = "Outside Grunty Industries",
        ['entranceId'] = 9,
        ['exitId'] = 2,
        ['exitMap'] = 0x15C
    },
    [0x127] = {
        ['name'] = "Hailfire Peaks",
        ['entranceId'] = 21,
        ['exitId'] = 6,
        ['exitMap'] = 0x155
    },
    [0x136] = {
        ['name'] = "Cloud Cuckooland",
        ['entranceId'] = 20,
        ['exitId'] = 5,
        ['exitMap'] = 0x15A
    },
    [0x15D] = {
        ['name'] = "Cauldron Keep",
        ['entranceId'] = 1,
        ['exitId'] = 3,
        ['exitMap'] = 0x15C
    }
}



---------------------------------- JIGGIES ---------------------------------

function obtain_AP_JIGGY()
    if DEBUG_JIGGY == true
    then
        print("Jiggy Obtained")
    end
    TOTAL_JIGGY = TOTAL_JIGGY + 1
    BTH:setItem(ITEM_TABLE["AP_ITEM_JIGGY"], TOTAL_JIGGY)
    check_open_level()
end

function jiggy_check()
    local checks = {}
        if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
        then
            if ASSET_MAP_CHECK[CURRENT_MAP]["JIGGIES"] ~= nil
            then
                for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["JIGGIES"])
                do
                    checks[locationId] = BTH:checkRealFlag(ADDRESS_MAP["JIGGIES"][locationId]['addr'], ADDRESS_MAP["JIGGIES"][locationId]['bit'])
                    if DEBUG_JIGGY == true
                    then
                        print(ADDRESS_MAP["JIGGIES"][locationId]['name']..":"..tostring(checks[locationId]))
                    end
                end
            end
        end
        for _,locationId in pairs(ASSET_MAP_CHECK["ALL"]["JIGGIES"])
        do
            checks[locationId] = BTH:checkRealFlag(ADDRESS_MAP["JIGGIES"][locationId]['addr'], ADDRESS_MAP["JIGGIES"][locationId]['bit'])
        end
    return checks
end

---------------------------------- TREBLE ---------------------------------

function obtain_AP_TREBLE()
    if DEBUG_TREBLE == true
    then
        print("Treble Obtained")
    end
    TOTAL_TREBLE = TOTAL_TREBLE + 1
    BTH:setItem(ITEM_TABLE["AP_ITEM_TREBLE"], TOTAL_TREBLE)
end

function treble_check()
    local checks = {}
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["TREBLE"] ~= nil
        then
            for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["TREBLE"])
            do
                checks[locationId] = BTH:checkRealFlag(ADDRESS_MAP["TREBLE"][locationId]['addr'], ADDRESS_MAP["TREBLE"][locationId]['bit'])
                if DEBUG_TREBLE == true
                then
                    print(ADDRESS_MAP["TREBLE"][locationId]['name'] .. ":" .. tostring(checks[locationId]))
                end
            end
        end
    end
    return checks
end

--------------------------------- Roysten --------------------------------

function roysten_check()
    local checks = {}
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["ROYSTEN"] ~= nil
        then
            for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["ROYSTEN"])
            do
                checks[locationId] = BTH:checkRealFlag(ADDRESS_MAP["ROYSTEN"][locationId]['addr'], ADDRESS_MAP["ROYSTEN"][locationId]['bit'])
                if DEBUG_ROYSTEN == true
                then
                    print(ADDRESS_MAP["ROYSTEN"][locationId]['name'] .. ":" .. tostring(checks[locationId]))
                end
            end
        end
    end
    return checks
end

function obtain_roysten_moves(itemId)
    if itemId == 1230831
    then
        if BTH:getItem(ITEM_TABLE["AP_ITEM_DIVE"]) == 0
        then
            BTH:setItem(ITEM_TABLE["AP_ITEM_DIVE"], 1)
        elseif BTH:getItem(ITEM_TABLE["AP_ITEM_DAIR"]) == 0
        then
            BTH:setItem(ITEM_TABLE["AP_ITEM_DAIR"], 1)
        elseif BTH:getItem(ITEM_TABLE["AP_ITEM_FSWIM"]) == 0
        then
            BTH:setItem(ITEM_TABLE["AP_ITEM_FSWIM"], 1)
        end
    elseif itemId == 1230777
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_FSWIM"], 1)
    elseif itemId == 1230778
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_DAIR"], 1)
    end
end

--------------------------------- AMAZE-O-GAZE ------------------------------------

function amaze_check() -- returns true or false
    local check = false
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["AMAZE"] ~= nil
        then
            for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["AMAZE"])
            do
                check = BTH:checkFakeFlag(ADDRESS_MAP["AMAZE"][locationId]['addr'], ADDRESS_MAP["AMAZE"][locationId]['bit'])
                if DEBUG_AMAZE == true
                then
                    print(ADDRESS_MAP["AMAZE"][locationId]['name'] .. ":" .. tostring(check))
                end
            end
        end
    end
    return check
end

function obtain_amaze_o_gaze()
    BTH:setItem(ITEM_TABLE["AP_ITEM_AMAZEOGAZE"], 1)
end

---------------------------------- ROAR --------------------------------------------

function roar_check() -- returns true or false
    local check = false
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["ROAR"] ~= nil
        then
            for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["ROAR"])
            do
                check = BTH:checkFakeFlag(ADDRESS_MAP["ROAR"][locationId]['addr'], ADDRESS_MAP["ROAR"][locationId]['bit'])
                if DEBUG_AMAZE == true
                then
                    print(ADDRESS_MAP["ROAR"][locationId]['name'] .. ":" .. tostring(check))
                end
            end
        end
    end
    return check
end

function obtain_roar()
    BTH:setItem(ITEM_TABLE["AP_ITEM_ROAR"], 1)
end

---------------------------------- PAGES ---------------------------------

function pages_check()
    local checks = {}
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["PAGES"] ~= nil
        then
            for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["PAGES"])
            do
                checks[locationId] = BTH:checkRealFlag(ADDRESS_MAP["PAGES"][locationId]['addr'], ADDRESS_MAP["PAGES"][locationId]['bit'])
                if DEBUG_PAGES == true
                then
                    print(ADDRESS_MAP["PAGES"][locationId]['name']..":"..tostring(checks[locationId]))
                end
            end
        end
    end
    return checks
end

function obtain_AP_PAGES()
    if DEBUG_PAGES == true
    then
        print("Cheato Page Obtained")
    end
    TOTAL_PAGES = TOTAL_PAGES + 1
    BTH:setItem(ITEM_TABLE["AP_ITEM_PAGES"], TOTAL_PAGES)
end

--------------------------------- CHEATO REWARDS ----------------------------------

function cheato_rewards_check()
    local checks = {}
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["CHEATOR"] ~= nil
        then
            for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["CHEATOR"])
            do
                checks[locationId] = BTH:checkRealFlag(ADDRESS_MAP["CHEATO"][locationId]['addr'], ADDRESS_MAP["CHEATO"][locationId]['bit'])
                if DEBUG_CHEATO == true
                then
                    print(ADDRESS_MAP["CHEATO"][locationId]['name']..":"..tostring(checks[locationId]))
                end
            end
        end
    end
    return checks
end

---------------------------------- HONEYCOMBS ---------------------------------

function honeycomb_check()
    local checks = {}
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["HONEYCOMB"] ~= nil
        then
            for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["HONEYCOMB"])
            do
                checks[locationId] = BTH:checkRealFlag(ADDRESS_MAP["HONEYCOMB"][locationId]['addr'], ADDRESS_MAP["HONEYCOMB"][locationId]['bit'])
                if DEBUG_HONEY == true
                then
                    print(ADDRESS_MAP["HONEYCOMB"][locationId]['name']..":"..tostring(checks[locationId]))
                end
            end
        end
    end
    return checks
end

function obtained_AP_HONEYCOMB()
    if DEBUG_HONEYCOMB == true
    then
        print("Obtain HC")
    end
    TOTAL_HONEYCOMBS = TOTAL_HONEYCOMBS + 1
    BTH:setItem(ITEM_TABLE["AP_ITEM_HONEY"], TOTAL_HONEYCOMBS)
end

--------------------------------- HONEY B REWARDS -----------------------------------

function honey_b_check()
    local checks = {}
    local bit1 = 0
    local bit2 = 0
    local bit3 = 0
    local base_location_id = 1230996
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["HONEYCOMB"] ~= nil
        then
            local result_bit1 = BTH:checkRealFlag(0x98, 2)
            local result_bit2 = BTH:checkRealFlag(0x98, 3)
            local result_bit3 = BTH:checkRealFlag(0x98, 4)
            if result_bit1 == true
            then
                bit1 = 1
            end
            if result_bit2 == true
            then
                bit2 = 2
            end
            if result_bit3 == true
            then
                bit3 = 4
            end
            local final_res = bit1 + bit2 + bit3
            for i = 1230997, final_res + base_location_id, 1 do
                checks[tostring(i)] = true
            end
        end
    end
    return checks
end

---------------------------------- GLOWBO AND MAGIC ---------------------------------

function glowbo_check()
    local checks = {}
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["GLOWBO"] ~= nil
        then
            for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["GLOWBO"])
            do
                checks[locationId] = BTH:checkRealFlag(ADDRESS_MAP["GLOWBO"][locationId]['addr'], ADDRESS_MAP["GLOWBO"][locationId]['bit'])
                if DEBUG_GLOWBO == true
                then
                    print(ADDRESS_MAP["GLOWBO"][locationId]['name']..":"..tostring(checks[locationId]))
                end
            end
        end
    end
    return checks
end

function obtain_AP_MAGIC(itemId)
    if itemId == 1230855
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_MUMBOMT"], 1)
    elseif itemId == 1230856
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_MUMBOGM"], 1)
    elseif itemId == 1230857
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_MUMBOWW"], 1)
    elseif itemId == 1230858
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_MUMBOJR"], 1)
    elseif itemId == 1230859
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_MUMBOTD"], 1)
    elseif itemId == 1230860
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_MUMBOGI"], 1)
    elseif itemId == 1230861
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_MUMBOHP"], 1)
    elseif itemId == 1230862
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_MUMBOCC"], 1)
    elseif itemId == 1230863
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_MUMBOIH"], 1)

    elseif itemId == 1230174
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_HUMBAMT"], 1)
    elseif itemId == 1230175
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_HUMBAGM"], 1)
    elseif itemId == 1230176
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_HUMBAWW"], 1)
    elseif itemId == 1230177
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_HUMBAJR"], 1)
    elseif itemId == 1230178
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_HUMBATD"], 1)
    elseif itemId == 1230179
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_HUMBAGI"], 1)
    elseif itemId == 1230180
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_HUMBAHP"], 1)
    elseif itemId == 1230181
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_HUMBACC"], 1)
    elseif itemId == 1230182
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_HUMBAIH"], 1)
    end
end

--------------------------------- DOUBLOONS -------------------------------------

function doubloon_check()
    local checks = {}
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["DOUBLOON"] ~= nil
        then
            for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["DOUBLOON"])
            do
                checks[locationId] = BTH:checkRealFlag(ADDRESS_MAP["DOUBLOON"][locationId]['addr'], ADDRESS_MAP["DOUBLOON"][locationId]['bit'])
                if DEBUG_DOUBLOON == true
                then
                    print(ADDRESS_MAP["DOUBLOON"][locationId]['name']..":"..tostring(checks[locationId]))
                end
            end
        end
    end
    return checks
end

function obtained_AP_DOUBLOON()
    if DEBUG_DOUBLOON == true
    then
        print("Doubloon Obtained")
    end
    TOTAL_DOUBLOONS = TOTAL_DOUBLOONS + 1
    BTH:setItem(ITEM_TABLE["AP_ITEM_DOUBLOON"], TOTAL_DOUBLOONS)
end

---------------------------------- NOTES ---------------------------------

function notes_check()
    local checks = {}
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["NOTES"] ~= nil
        then
            for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["NOTES"])
            do
                checks[locationId] = BTH:checkRealFlag(ADDRESS_MAP["NOTES"][locationId]['addr'], ADDRESS_MAP["NOTES"][locationId]['bit'])
                if DEBUG_NOTES == true
                then
                    print(locationId .. ":" .. tostring(checks[locationId]))
                end
            end
        end
    end
    return checks
end

function obtain_AP_NOTES()
    if DEBUG_NOTES == true
    then
        print("Note Obtained")
    end
    TOTAL_NOTES = TOTAL_NOTES + 1
    BTH:setItem(ITEM_TABLE["AP_ITEM_NOTE"], TOTAL_NOTES)
end

--------------------------------- JIGGY CHUNKS ----------------------------------

function jiggy_chunks_check()
    local checks = {}
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["JCHUNKS"] ~= nil
        then
            for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["JCHUNKS"])
            do
                checks[locationId] = BTH:checkRealFlag(ADDRESS_MAP["JCHUNKS"][locationId]['addr'], ADDRESS_MAP["JCHUNKS"][locationId]['bit'])
            end
        end
    end
    return checks
end

--------------------------------- Dino Kids -------------------------------------------

function dino_kids_check()
    local checks = {
        ["1231006"] = false,
        ["1231007"] = false,
        ["1231008"] = false,
    }
    if checks["1231006"] == false
    then
        local scrut = BTH:checkRealFlag(0x0C, 2)
        if scrut == true
        then
            checks["1231006"] = true
        end
    end

    if checks["1231007"] == false
    then
        local scrat_healed = BTH:checkRealFlag(0x26, 6)
        local scrat_train = BTH:checkRealFlag(0x2C, 1)
        if scrat_healed == true and scrat_train == false
        then
            checks["1231007"] = true
        end
    end

    if checks["1231008"] == false
    then
        local scrit_grow = BTH:checkRealFlag(0x26, 7)
        if scrit_grow == true
        then
            checks["1231008"] = true
        end
    end
    return checks
end

--------------------------------- BK MOVES ----------------------------------------------
function obtain_bkmove(itemId)
    if itemId == 1230810 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_DIVE"], 1)
    elseif itemId == 1230811 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_FPAD"], 1)
    elseif itemId == 1230812 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_FFLIP"], 1)
    elseif itemId == 1230813 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_EGGSHOOT"], 1)
    elseif itemId == 1230814 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_ROLL"], 1)
    elseif itemId == 1230815 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_TTROT"], 1)
    elseif itemId == 1230816 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_TJUMP"], 1)
    elseif itemId == 1230817 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_CLIMB"], 1)
    elseif itemId == 1230818 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_FLUTTER"], 1)
    elseif itemId == 1230819 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_WWING"], 1)
    elseif itemId == 1230820 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_BBUST"], 1)
    elseif itemId == 1230821 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_TTRAIN"], 1)
    elseif itemId == 1230822 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_ARAT"], 1)
    elseif itemId == 1230823 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_BEGGS"], 1)
    elseif itemId == 1230824 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_GRAT"], 1)
    elseif itemId == 1230825 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_BBARGE"], 1)
    elseif itemId == 1230826 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_SSTRIDE"], 1)
    elseif itemId == 1230827 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_BBOMB"], 1)
    end
end

--------------------------------- PROGRSSIVE ITEMS ---------------------------------------

function obtain_progressive_moves(itemId)
    if itemId == 1230828 -- Progressive Beak Buster
    then
        if BTH:getItem(ITEM_TABLE["AP_ITEM_BBUST"]) == 0
        then
            obtain_bkmove(1230820);
        else
            BTH:setItem(ITEM_TABLE["AP_ITEM_BBUST"], 1)
        end
    elseif(itemId == 1230829) -- Progressive Eggs
    then
        if BTH:getItem(ITEM_TABLE["AP_ITEM_FEGGS"]) == 0
        then
            BTH:setItem(ITEM_TABLE["AP_ITEM_FEGGS"], 1)
        elseif BTH:getItem(ITEM_TABLE["AP_ITEM_GEGGS"]) == 0
        then
            BTH:setItem(ITEM_TABLE["AP_ITEM_GEGGS"], 1)
        elseif BTH:getItem(ITEM_TABLE["AP_ITEM_IEGGS"]) == 0
        then
            BTH:setItem(ITEM_TABLE["AP_ITEM_IEGGS"], 1)
        elseif BTH:getItem(ITEM_TABLE["AP_ITEM_CEGGS"]) == 0
        then
            BTH:setItem(ITEM_TABLE["AP_ITEM_CEGGS"], 1)
        end
    elseif(itemId == 1230830) -- Progressive Shoes
    then
        if BTH:getItem(ITEM_TABLE["AP_ITEM_SSTRIDE"]) == 0
        then
            obtain_bkmove(1230826);
        elseif BTH:getItem(ITEM_TABLE["AP_ITEM_TTRAIN"]) == 0
        then
            obtain_bkmove(1230821);
        elseif BTH:getItem(ITEM_TABLE["AP_ITEM_SPRINGB"]) == 0
        then
            BTH:setItem(ITEM_TABLE["AP_ITEM_SPRINGB"], 1)
        elseif BTH:getItem(ITEM_TABLE["AP_ITEM_CLAWBTS"]) == 0
        then
            BTH:setItem(ITEM_TABLE["AP_ITEM_CLAWBTS"], 1)
        end  
    elseif(itemId == 1230831)
    then
        obtain_roysten_moves(itemId);
    elseif(itemId == 1230832)
    then
        BTH:getItem(ITEM_TABLE["AP_ITEM_BBASH"])
        if BTH:getItem(ITEM_TABLE["AP_ITEM_GRAT"]) == 0
        then
            obtain_bkmove(1230824);
        elseif BTH:getItem(ITEM_TABLE["AP_ITEM_BBASH"]) == 0
        then
            BTH:setItem(ITEM_TABLE["AP_ITEM_BBASH"], 1)
        end
    end
end

--------------------------------- Stop N Swap --------------------------------

function mystery_check()
    local checks = {}
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["STOPNSWAP"] ~= nil
        then
            for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["STOPNSWAP"])
            do
                if locationId == "1230953" or locationId == "1230954" or locationId == "1230955"
                then
                    checks[locationId] = BTH:checkRealFlag(ADDRESS_MAP["STOPNSWAP"][locationId]['addr'], ADDRESS_MAP["STOPNSWAP"][locationId]['bit'])
                else
                    checks[locationId] = BTH:checkFakeFlag(ADDRESS_MAP["STOPNSWAP"][locationId]['addr'], ADDRESS_MAP["STOPNSWAP"][locationId]['bit'])
                end
                if DEBUG_STOPNSWAP == true
                then
                    print(locationId .. ":" .. tostring(checks[locationId]))
                end
            end
        end
    end
    return checks
end

function obtain_mystery_item(itemId)
    if itemId == 1230799
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_IKEY"], 1)
    elseif itemId == 1230800
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_BBASH"], 1)
    elseif itemId == 1230801
    then
        -- Jinjo Multiplayer
        return
    elseif itemId == 1230802
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_HOMINGEGGS"], 1)
    elseif itemId == 1230803
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_BMEGG"], 1)
    elseif itemId == 1230804
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_PMEGG"], 1)
    end
end

---------------------------------- Station ---------------------------------

function init_STATIONS(type, getReceiveMap) -- Initialize BMK
    for locationId,v in pairs(ADDRESS_MAP['STATIONS'])
    do
        if type == "BMM"
        then
            BMM_STATIONS[locationId] = BTRAMOBJ:checkFlag(v['addr'], v['bit'])
        elseif type == "AGI"
        then
            AGI_STATIONS[locationId] = false
        end
    end
    if type == "AGI" and getReceiveMap == true
    then
        for _, itemId in pairs(receive_map)
        do
            if itemId == "1230790" or itemId == "1230791" or itemId == "1230792"
                or itemId == "1230793" or itemId == "1230794" or itemId == "1230795"
            then
                obtained_AP_STATIONS(itemId)
            end
        end
    end
end

function set_checked_STATIONS() --Only run transitioning maps
    if ASSET_MAP_CHECK[NEXT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[NEXT_MAP]["STATIONBTN"] ~= nil and mainmemory.readbyte(0x11B065) ~= 4
        then
            local stationId = ASSET_MAP_CHECK[NEXT_MAP]["STATIONBTN"];
            local get_addr = ADDRESS_MAP['STATIONS'][stationId];
            if BMM_STATIONS[stationId] == true
            then
                BTRAMOBJ:setFlag(get_addr['addr'], get_addr['bit']);
            else
                BTRAMOBJ:clearFlag(get_addr['addr'], get_addr['bit']);
            end
            if DEBUG_STATION == true
            then
                print("Clearing of Stations")
                print(BMM_STATIONS[stationId])
            end
        else
            if CURRENT_MAP == 0x155 or CURRENT_MAP == 0xD7 or CURRENT_MAP == 0x12A or CURRENT_MAP == 0xEC or CURRENT_MAP == 0x102
            or CURRENT_MAP == 0x129 or CURRENT_MAP == 0xD0 or CURRENT_MAP == 0x127 or CURRENT_MAP == 0x128 or CURRENT_MAP == 0x100
            or NEXT_MAP == 0x155 or NEXT_MAP == 0xD7 or NEXT_MAP == 0x12A or NEXT_MAP == 0xEC or NEXT_MAP == 0x102 or NEXT_MAP == 0x129 or NEXT_MAP == 0xD0
            or NEXT_MAP == 0x100 or NEXT_MAP == 0x112
            then           
                for locationId, get_addr in pairs(ADDRESS_MAP['STATIONS'])
                do
                        BTRAMOBJ:clearFlag(get_addr['addr'], get_addr['bit']);
                end
                if DEBUG_STATION == true
                then
                    print("Clearing ALL Stations")
                end
            else
                if DEBUG_STATION == true
                then
                    print("Canceling Clearing of Stations")
                end
            end
        end
    end
end

function set_AP_STATIONS() -- Only run after Transition
    if mainmemory.readbyte(0x11B065) ~= 4
    then
        for stationId, value in pairs(AGI_STATIONS)
        do
            local get_addr = ADDRESS_MAP['STATIONS'][stationId]
            if value == true
            then
                BTRAMOBJ:setFlag(get_addr['addr'], get_addr['bit']);
            else
                BTRAMOBJ:clearFlag(get_addr['addr'], get_addr['bit']);
            end
        end
        if DEBUG_STATION == true
        then
            print("Setting AGI Stations")
        end
    end
end

function obtained_AP_STATIONS(itemId)
    AGI_STATIONS[tostring(itemId)] = true
    local get_addr = ADDRESS_MAP['STATIONS'][tostring(itemId)]
    BTRAMOBJ:setFlag(get_addr['addr'], get_addr['bit']);
end

function check_STATION_BUTTONS()
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if CURRENT_MAP == 0x155 or CURRENT_MAP == 0xD7 or CURRENT_MAP == 0x12A or CURRENT_MAP == 0xEC
            or CURRENT_MAP == 0x114 or CURRENT_MAP == 0x102 or CURRENT_MAP == 0x129 or CURRENT_MAP == 0x127
            or CURRENT_MAP == 0x128 or CURRENT_MAP == 0x100 or CURRENT_MAP == 0x112
            or NEXT_MAP == 0x155 or NEXT_MAP == 0xD7 or NEXT_MAP == 0x12A or NEXT_MAP == 0xEC
            or NEXT_MAP == 0x114 or NEXT_MAP == 0x102 or NEXT_MAP == 0x129 or NEXT_MAP == 0x127
            or NEXT_MAP == 0x128 or NEXT_MAP == 0x100 or NEXT_MAP == 0x112
        then
            STATION_BTN_TIMER = STATION_BTN_TIMER + 1
            -- if STATION_BTN_TIMER == 25
            -- then
            --     set_AP_STATIONS()
            -- end
        else
            set_AP_STATIONS()
            STATION_BTN_TIMER = 25
        end
    else
        set_AP_STATIONS()
        STATION_BTN_TIMER = 25
    end
end

function watchBtnAnimation()
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["STATIONBTN"] ~= nil
        then
            BTMODELOBJ:changeName("Station Switch", false);
            local POS = BTMODELOBJ:getSingleModelCoords();
            local currentAnimation = BTMODELOBJ:getObjectAnimation();
            if currentAnimation ~= 0x81 -- not yet pressed
            then
                if DEBUG_STATION == true
                then
                    mapaddr = BTRAMOBJ:getMap(false)
                    tmapaddr = BTRAMOBJ:getMap(true)
                    print("Station Button not pressed")
                    print("current map: " ..tostring(mapaddr) .. " nextmap:" .. tostring(tmapaddr))
                end
            else
                if DEBUG_STATION == true
                then
                    mapaddr = BTRAMOBJ:getMap(false)
                    tmapaddr = BTRAMOBJ:getMap(true)
                    print("Detected Station Button got pressed")
                    print("current map: " ..tostring(mapaddr) .. " nextmap:" .. tostring(tmapaddr))
                end
                BMM_STATIONS[ASSET_MAP_CHECK[CURRENT_MAP]["STATIONBTN"]] = true;
            end
        end
    end
end


function nearChuffySign()
    if mainmemory.readbyte(0x11B065) ~= 4
    then
        banjo = BTRAM:getBanjoMovementState()
        if banjo ~= 0x33 and banjo ~= 0x01 and banjo ~= 0x15 and banjo ~= 0x45 and banjo ~= 0x48
        and banjo ~= 0x5E and banjo ~= 0x5F and banjo ~= 0x6E and banjo ~= 0x7E and banjo ~= 0x74
        and banjo ~= 0x75 and banjo ~= 0x76 and banjo ~= 0x79 and banjo ~= 0x80 and banjo ~= 0x8F
        and banjo ~= 0x92 and banjo ~= 0x93 and banjo ~= 0x94 and banjo ~= 0x98 and banjo ~= 0x9A
        and banjo ~= 0xBB and banjo ~= 0xE5 and banjo ~= 0xF2 and banjo ~= 0xF5 and banjo ~= 0xF6
        and banjo ~= 0x73 and banjo ~= 0x00
        then
            BTMODELOBJ:changeName("Chuffy Sign", false);
            local playerDist = BTMODELOBJ:getClosestModelDistance()
            if playerDist == false
            then
                return;
            end
            if playerDist <= 700
            then
                if DEBUG_STATION == true
                then
                    print("Near Chuffy Sign");
                    print(banjo)
                end
                set_AP_STATIONS()
                if CURRENT_MAP == 0x155 -- IoH
                then
                    -- unset WW due to switch may be pressed
                    BTRAMOBJ:clearFlag(ADDRESS_MAP["STATIONS"]["1230795"]['addr'], ADDRESS_MAP["STATIONS"]["1230795"]['bit'], "button")
                elseif CURRENT_MAP == 0xEC -- WW
                then
                    -- unset IoH due to switch may be pressed
                    BTRAMOBJ:clearFlag(ADDRESS_MAP["STATIONS"]["1230794"]['addr'], ADDRESS_MAP["STATIONS"]["1230794"]['bit'], "button")
                end
            end
        end
    else
        set_checked_STATIONS()
    end
end

---------------------------------- Chuffy ------------------------------------

function init_CHUFFY(type, getReceiveMap) -- Initialize Chuffy
    for locationId,v in pairs(ADDRESS_MAP['CHUFFY'])
    do
        if type == "BMM"
        then
            BMM_CHUFFY[locationId] = BTRAMOBJ:checkFlag(v['addr'], v['bit'])
            if DEBUG_CHUFFY == true
            then
                print("Chuffy BMM Initialized")
            end
        elseif type == "AGI"
        then
            AGI_CHUFFY[locationId] = false
            if DEBUG_CHUFFY == true
            then
                print("Chuffy AGI Initialized")
            end
        end
    end
    if type == "AGI" and getReceiveMap == true
    then
        for _, locationId in pairs(receive_map)
        do
            if locationId == "1230796"
            then
                obtained_AP_CHUFFY()
            end
        end
    end
end

function set_checked_CHUFFY() --Only when Inside Chuffy
    local get_addr = ADDRESS_MAP['CHUFFY']["1230796"];
    if BMM_CHUFFY["1230796"] == false and BMM_JIGGIES["1230606"] == false
    then
        BTRAMOBJ:clearFlag(get_addr['addr'], get_addr['bit']);
        if DEBUG_CHUFFY == true
        then
            print("Chuffy Unset")
        end
    else
        BTRAMOBJ:setFlag(get_addr['addr'], get_addr['bit']);
        if DEBUG_CHUFFY == true
        then
            print("Chuffy Set")
        end
    end
end

function watchChuffyFlag()
    if CURRENT_MAP == 0xD1 and BMM_CHUFFY["1230796"] == false
    then
        BTMODELOBJ:changeName("Jiggy", false)
        killedKing = BTMODELOBJ:checkModel()
        if killedKing == true
        then  -- Sanity check incase Pointer is moving
            BMM_CHUFFY["1230796"] = true
        end
        if DEBUG_CHUFFY == true
        then
            print("Chuffy Jiggywatch")
        end
    end
end

function set_AP_CHUFFY() -- Only run after Transistion
    local get_addr = ADDRESS_MAP['CHUFFY']["1230796"];
    if AGI_CHUFFY["1230796"] == true
    then
        BTRAMOBJ:setFlag(get_addr['addr'], get_addr['bit']);
        BTRAMOBJ:setFlag(0x0D, 5) -- Levitate
        if DEBUG_CHUFFY == true
        then
            print("Chuffy is open")
        end
        return true
    else
        BTRAMOBJ:clearFlag(get_addr['addr'], get_addr['bit']);
        if DEBUG_CHUFFY == true
        then
            print("Chuffy not yet open")
        end
        return false
    end
end

function obtained_AP_CHUFFY()
    AGI_CHUFFY["1230796"] = true
    BTRAMOBJ:setFlag(0x0D, 5) -- Levitate
    local get_addr = ADDRESS_MAP['CHUFFY']["1230796"]
    if CURRENT_MAP == 0xD0 or CURRENT_MAP == 0xD1
    then
        return
    end
    BTRAMOBJ:setFlag(get_addr['addr'], get_addr['bit']);
    if DEBUG_CHUFFY == true
    then
        print("Chuffy Obtained")
    end
end

function getChuffyMaps()
    if CURRENT_MAP == 0xD0 or CURRENT_MAP == 0xD1
    then
        set_checked_CHUFFY()
    else
        set_AP_CHUFFY()
    end
end

function ChuffyTDLFix()
    if (NEXT_MAP == 0x114 or CURRENT_MAP == 0x114) and AGI_STATIONS["1230791"] == true
    then
        BTRAMOBJ:setFlag(ADDRESS_MAP['STATIONS']["1230791"]['addr'], ADDRESS_MAP['STATIONS']["1230791"]['bit'])
        if DEBUG_STATION == true
        then
            print("TDL Station Set")
        end
    end
end


---------------------------------- JamJars MOVES -----------------------------------

function init_BMK(type) -- Initialize BMK
    local checks = {}
    for k,v in pairs(ADDRESS_MAP['MOVES'])
    do
        if type == "BKM"
        then
            BKM[k] = BTRAMOBJ:checkFlag(v['addr'], v['bit'])
        elseif type == "AGI"
        then
            checks[k] = BTRAMOBJ:checkFlag(v['addr'], v['bit'])
        end
    end
    return checks
end

function update_BMK_MOVES_checks() --Only run when close to Silos
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["SILO"] ~= nil
        then
            for keys, locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["SILO"])
            do
                if keys ~= "Exceptions"
                then
                    local get_addr = ADDRESS_MAP['MOVES'][locationId]
                    if BKM[locationId] == false
                    then
                        local res = BTRAMOBJ:checkFlag(get_addr['addr'], get_addr['bit'])
                        if res == true
                        then
                            if DEBUG_SILO == true
                            then
                                print("Already learnt this Silo. finished")
                            end
                            BKM[locationId] = res
                            SILOS_LOADED = true
                        end
                    end
                end
            end
        end
    end
end

function clear_AMM_MOVES_checks(mapaddr) --Only run when transitioning Maps AND Close to Silo.
    --Only clear the moves that we need to clear
    if ASSET_MAP_CHECK[mapaddr] == nil or ASSET_MAP_CHECK[mapaddr]["SILO"] == nil
    then
        if DEBUG_SILO == true
        then
            print("Canceling Clearing of AMM Moves")
        end
        return false
    end
    for keys, locationId in pairs(ASSET_MAP_CHECK[mapaddr]["SILO"])
    do
        if keys ~= "Exceptions"
        then
            local addr_info = ADDRESS_MAP["MOVES"][locationId]
            if BKM[locationId] == true
            then
                BTRAMOBJ:setFlag(addr_info['addr'], addr_info['bit'])
                if DEBUG_SILO == true
                then
                    print(addr_info['name'] .. " IS SET")
                end
            else
                BTRAMOBJ:clearFlag(addr_info['addr'], addr_info['bit']);
                if DEBUG_SILO == true
                then
                    print(addr_info['name'] .. " IS CLEARED")
                end
            end
        else
            for _, disable_move in pairs(ASSET_MAP_CHECK[mapaddr]["SILO"][keys]) --Exception list, always disable
            do
                local addr_info = ADDRESS_MAP["MOVES"][disable_move]
                BTRAMOBJ:clearFlag(addr_info['addr'], addr_info['bit'], "CLEAR_AMM_MOVES_EXCEPTION");
            end
        end
    end
    if mapaddr == 0x152 or mapaddr == 0x155 or mapaddr == 0x15B or mapaddr == 0x15A
    then
        if ENABLE_AP_BK_MOVES ~= 0
        then
            local egg_found = false
            for apid, itemId in pairs(receive_map)
            do
                if itemId == "1230823"
                then
                    egg_found = true
                    break
                end
            end
            if egg_found == false
            then
                BTRAMOBJ:setFlag(0x1E, 6, "Blue Eggs")
                TEMP_EGGS = true
            end
        end
    end
    return true
end

function transform_logic_flags() -- Checks receive map for items need to calculate transformation logic
    for apid, itemId in pairs(receive_map)
    do
        if ENABLE_AP_BK_MOVES ~= 2
        then
            TALONTROT = true
            TALLJUMP = true
        end
        if ENABLE_AP_BK_MOVES == 0
        then
            AIRRATATATRAP = true
            FLAPFLIP = true
            CLIMB = true
            FLUTTER = true
            TURBOTRAINERS = true
        end
        if itemId == "1230855"
        then
            GOLIATH = true
        elseif itemId == "1230176"
        then
            VAN = true
        elseif itemId == "1230761"
        then
            SPLITUP = true
        elseif itemId == "1230815"
        then
            TALONTROT = true
        elseif itemId == "1230816"
        then
            TALLJUMP = true
        elseif itemId == "1230821"
        then
            TURBOTRAINERS = true
        elseif itemId == "1230768"
        then
            SPRINGYSTEPSHOES = true
        elseif itemId == "1230812"
        then
            FLAPFLIP = true
        elseif itemId == "1230772"
        then
            LEGSPRING = true
        elseif itemId == "1230753"
        then
            GRIPGRAB = true
        elseif itemId == "1230817"
        then
            CLIMB = true
        elseif itemId == "1230822"
        then
            AIRRATATATRAP = true
        elseif itemId == "1230818"
        then
            FLUTTER = true
        end
    end
end

-- function updateMagic()
--     for apid, itemId in pairs(receive_map)
--     do
--         if itemId == MAGIC_MAP
--         then
--             MAGIC_MAP[itemId] = true
--         end
--     end
-- end



function transform_swap(mapaddr, currentState) --Only run when transitioning Maps
    local check_controls = joypad.get()
    local death_flg = mainmemory.read_u8(0x1354F9)
    BTMODELOBJ:changeName("Player", false)
    local check = BTMODELOBJ:checkModel();

    if mapaddr == 0x142
    then
        REVERTING_MUMBO = true
        return
    end
    
    if death_flg  == 1 and (currentState == 8 or currentState == 15 or currentState == 16 or 
    currentState == 12 or currentState == 18 or currentState == 7 or currentState == 2 or currentState == 6
    or currentState == 13) --mumbo or any transformation except big t-rex, respawns in JV if transformation not done properly
    then
        setCurrentHealth(10) -- sets transformation health to max plus 1 so when banjo returns to that form he wont be on 0 health
        REVERTING_MUMBO = true
        return BTRAM:setTransformation(1) -- Banjo
    end
    if TRANSFORM_SWAP_MAP[mapaddr] == nil or BTRAMOBJ == nil
    then
        return false
    end
    if TRANSFORM_SWAP_MAP[mapaddr]["skull"] ~= nil and currentState == 13 and FAKE_MUMBO == true -- panic detransform mumbo going into mumbos hut
    then
        REVERTING_MUMBO = true
        return BTRAM:setTransformation(1) -- Banjo
    end
    if TRANSFORM_SWAP_MAP[mapaddr]["skull"] ~= nil and currentState == 13 and FAKE_MUMBO == false -- panic detransform mumbo going into mumbos hut
    then
        return -- panic option wont allow any action if true mumbo returns home
    end
    if check_controls ~= nil and check_controls['P1 L'] == true and check_controls['P1 R'] == false
    then
        if currentState == 1 or currentState == 8 or currentState == 15 or currentState == 16 or 
        currentState == 12 or currentState == 18 or currentState == 7 or currentState == 2 or currentState == 6 -- banjo or non-mumbo transforms
        then
            for apid, itemId in pairs(receive_map)
            do
                if itemId == TRANSFORM_SWAP_MAP[mapaddr]["mumbo"]
                then
                    if itemId == "1230855"  -- MT Mumbo Item
                    then
                        FAKE_MUMBO = true
                        return BTRAM:setTransformation(13) -- Mumbo
                    elseif itemId == "1230856" and (TURBOTRAINERS == true or SPRINGYSTEPSHOES == true or TALONTROT == true)-- GGM Humba Item
                    then
                        FAKE_MUMBO = true
                        return BTRAM:setTransformation(13) -- Mumbo
                    elseif itemId == "1230857" and VAN == true and ((FLAPFLIP == true and GRIPGRAB == true) or
                    (CLIMB == true and FLAPFLIP == true and TALONTROT == true and (FLUTTER == true or AIRRATATATRAP ==true)) or 
                    (SPLITUP == true and LEGSPRING == true))-- WW Mumbo Item
                    then
                        FAKE_MUMBO = true
                        return BTRAM:setTransformation(13) -- Mumbo
                    elseif itemId == "1230858" -- JRL Mumbo Item
                    then
                        FAKE_MUMBO = true
                        return BTRAM:setTransformation(13)-- Mumbo
                    elseif itemId == "1230859" -- TDL Mumbo Item
                    then
                        FAKE_MUMBO = true
                        return BTRAM:setTransformation(13) -- Mumbo
                    elseif itemId == "1230860" -- GI Mumbo Item
                    then
                        FAKE_MUMBO = true
                        return BTRAM:setTransformation(13) -- Mumbo
                    elseif itemId == "1230861" -- HFP Mumbo Item
                    then
                        FAKE_MUMBO = true
                        return BTRAM:setTransformation(13) -- Mumbo
                    elseif itemId == "1230862" -- CCL Mumbo Item
                    then
                        FAKE_MUMBO = true
                        return BTRAM:setTransformation(13) -- Mumbo
                    elseif itemId == "1230863" -- IOH Mumbo Item
                    then
                        FAKE_MUMBO = true
                        return BTRAM:setTransformation(13) -- Mumbo
                    end
                else
                    BTRAM:setTransformation(1) -- Banjo
                end
            end
        elseif currentState == 13 and FAKE_MUMBO == true
        then
            REVERTING_MUMBO = true
            BTRAM:setTransformation(1) -- Banjo
        end
    elseif check_controls ~= nil and check_controls['P1 R'] == true and check_controls['P1 L'] == false
    then
        if currentState == 1 or (currentState == 13 and FAKE_MUMBO == true) -- Banjo or Mumbo
        then
            for apid, itemId in pairs(receive_map)
            do
                if itemId == TRANSFORM_SWAP_MAP[mapaddr]["humba"]
                then
                    if itemId == "1230174" and GOLIATH == true -- MT Humba Item
                    then
                        return BTRAM:setTransformation(8) --Stony
                    elseif itemId == "1230175" and (TURBOTRAINERS == true or SPRINGYSTEPSHOES == true or TALONTROT == true)-- GGM Humba Item
                    then
                        return BTRAM:setTransformation(15) -- Detonator
                    elseif itemId == "1230176" and ((FLAPFLIP == true and GRIPGRAB == true) or
                    (CLIMB == true and FLAPFLIP == true and TALONTROT == true and (FLUTTER == true or AIRRATATATRAP ==true)) or 
                    (SPLITUP == true and LEGSPRING == true))-- WW Humba Item
                    then
                        return BTRAM:setTransformation(16) -- Van
                    elseif itemId == "1230177" -- JRL Humba Item
                    then
                        return BTRAM:setTransformation(12) -- Submarine
                    elseif itemId == "1230178" -- TDL Humba Item
                    then
                        return BTRAM:setTransformation(18) -- Small T-rex
                    elseif itemId == "1230179" -- GI Humba Item
                    then
                        return BTRAM:setTransformation(7) -- Washing Machine
                    elseif itemId == "1230180" -- HFP Humba Item
                    then
                        return BTRAM:setTransformation(2) -- Snowball
                    elseif itemId == "1230181" -- CCL Humba Item
                    then
                        return BTRAM:setTransformation(6) -- Bee
                    end
                else
                    BTRAM:setTransformation(1) -- Banjo
                end
            end
        elseif currentState == 8 or currentState == 15 or currentState == 16 or currentState == 12 or 
        currentState == 18 or currentState == 7 or currentState == 2 or currentState == 6 or 
        (currentState == 13 and FAKE_MUMBO == true)
        then
            REVERTING_MUMBO = true
            BTRAM:setTransformation(1) -- Banjo
        end
    end
end



function check_jamjar_silo()
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["SILO"] ~= nil
        then
            SILO_TIMER = SILO_TIMER + 1
            if SILO_TIMER >= 25
            then
                SILO_TIMER = 25
                BTMODELOBJ:changeName("Silo", false);
                local modelPOS = BTMODELOBJ:getMultipleModelCoords()
                if modelPOS == false
                then
                    set_AGI_MOVES_checks()
                    return
                end
                local siloPOS = { ["Distance"] = 9999};
                for modelObjPtr, POS in pairs(modelPOS) do
                    if POS ~= false
                    then
                        siloPOS = POS
                    end
                end
                if siloPOS["Distance"] >= 650
                then
                    set_AGI_MOVES_checks()
                end
            end
        else
            set_AGI_MOVES_checks()
            SILO_TIMER = 25
        end
    else
        set_AGI_MOVES_checks()
        SILO_TIMER = 25
    end
end

function set_AGI_MOVES_checks() -- SET AGI Moves into RAM AFTER BT/Silo Model is loaded
    for moveId, table in pairs(ADDRESS_MAP['MOVES'])
    do
        if AGI_MOVES[moveId] == true
        then
            BTRAMOBJ:setFlag(table['addr'], table['bit']);
        else
            BTRAMOBJ:clearFlag(table['addr'], table['bit'], "CLEAR_AGI_MOVES");
        end
    end
    if TEMP_EGGS == true
    then
        BTRAMOBJ:clearFlag(0x1E, 6)
        TEMP_EGGS = false
    end
    if DEBUG_SILO == true
    then
        print("AGI MOVES IS SET")
    end
end

function nearSilo()
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["SILO"] ~= nil
        then
            BTMODELOBJ:changeName("Silo", false);
            local modelPOS = BTMODELOBJ:getMultipleModelCoords()
            if modelPOS == false
            then
                return
            end
            local siloPOS = { ["Distance"] = 9999};
            for modelObjPtr, POS in pairs(modelPOS) do
                if POS ~= false
                then
                    siloPOS = POS
                    --Move the Silo in Witchyworld.
                    if POS["Xpos"] == 0 and POS["Ypos"] == -163 and POS["Zpos"] == -1257
                        and CURRENT_MAP == 0xD6
                    then
                        mainmemory.writefloat(modelObjPtr + 0x0C, POS["Zpos"] + 120, true);
                        MoveWitchyPads();
                    end

                    if POS["Distance"] <= 650 and CURRENT_MAP ~= 0x1A7 -- Not CC
                    then
                        if DEBUG_SILO == true and LOAD_BMK_MOVES == false
                        then
                            print("Near Silo");
                        end
                        break;
                    elseif POS["Distance"] <= 300 and CURRENT_MAP == 0x1A7 -- CC
                    then
                        if DEBUG_SILO == true and LOAD_BMK_MOVES == false
                        then
                            print("Near Silo");
                        end
                        break;
                    end
                end
            end
        
            if siloPOS["Distance"] <= 650 -- and CURRENT_MAP ~= 0x1A7
            then
               
                if LOAD_BMK_MOVES == false
                then
                    clear_AMM_MOVES_checks(CURRENT_MAP);
                    update_BMK_MOVES_checks();
                    LOAD_BMK_MOVES = true
                elseif SILOS_LOADED == false
                then
                    if DEBUG_SILO == true
                    then
                        print("Watching BKM Moves");
                    end
                    update_BMK_MOVES_checks();
                end
            else
                if LOAD_BMK_MOVES == true
                then
                    if DEBUG_SILO == true
                    then
                        print("Reseting Movelist");
                    end
                    set_AGI_MOVES_checks();
                    LOAD_BMK_MOVES = false;
                    SILOS_LOADED = false;
                end
            end

            if siloPOS["Distance"] <= 800 and CURRENT_MAP == 0x152
            then
                    BTRAMOBJ:setBanjoSelectedEgg(0)
            end

            if siloPOS["Distance"] <= 410 and CURRENT_MAP ~= 0x13A -- Notes and not CCL
            then
                if LOAD_SILO_NOTES == false
                then
                    LOAD_SILO_NOTES = true
                end
            elseif siloPOS["Distance"] > 410 and CURRENT_MAP ~= 0x13A
            then
                if LOAD_SILO_NOTES == true
                then
                    if DEBUG_SILO == true
                    then
                        print("Reseting Note Count");
                    end
                    LOAD_SILO_NOTES = false;
                end
            end

            if siloPOS["Distance"] <= 260 and CURRENT_MAP == 0x13A -- Notes and CCL
            then
                if LOAD_SILO_NOTES == false
                then
                    LOAD_SILO_NOTES = true
                end
            elseif siloPOS["Distance"] > 260 and CURRENT_MAP == 0x13A -- Notes and CCL
            then
                if LOAD_SILO_NOTES == true
                then
                    if DEBUG_SILO == true
                    then
                        print("Reseting Note Count");
                    end
                    LOAD_SILO_NOTES = false;
                end
            end
        end
    end
end

------------------ Jinjos -------------------

function init_JINJOS(type) -- Initialize JINJOS
    for locationId,v in pairs(ADDRESS_MAP["JINJOS"])
    do
        if type == "BMM"
        then
            BMM_JINJOS[locationId] = BTRAMOBJ:checkFlag(v['addr'], v['bit'])
        elseif type == "AGI"
        then
            AGI_JINJOS = {
                ["1230501"] = 0, -- white
                ["1230502"] = 0, -- orange
                ["1230503"] = 0, -- yellow
                ["1230504"] = 0, -- brown
                ["1230505"] = 0, -- green
                ["1230506"] = 0, -- red
                ["1230507"] = 0, -- blue
                ["1230508"] = 0, -- purple
                ["1230509"] = 0, -- black
            };
        end
    end
end

function restore_BMM_JINJOS() -- Not sure if we need this...
    if BMM_BACKUP_JINJO == true
    then
        for locationId,v in pairs(ADDRESS_MAP["JINJOS"]) do
            if BMM_JINJOS[locationId] == true
            then
                BTRAMOBJ:setFlag(v['addr'], v['bit']);
            else
                BTRAMOBJ:clearFlag(v['addr'], v['bit']);
            end
        end
        BMM_BACKUP_JINJO = false
    end
end

function jinjo_ui_update()
    mainmemory.write_u16_be(0x11B140, AGI_JINJOS["1230501"]) -- WHITE
    mainmemory.write_u16_be(0x11B14C, AGI_JINJOS["1230502"]) -- ORANGE
    mainmemory.write_u16_be(0x11B158, AGI_JINJOS["1230503"]) -- YELLOW
    mainmemory.write_u16_be(0x11B164, AGI_JINJOS["1230504"]) -- BROWN
    mainmemory.write_u16_be(0x11B170, AGI_JINJOS["1230505"]) -- GREEN
    mainmemory.write_u16_be(0x11B17C, AGI_JINJOS["1230506"]) -- RED
    mainmemory.write_u16_be(0x11B188, AGI_JINJOS["1230507"]) -- BLUE
    mainmemory.write_u16_be(0x11B194, AGI_JINJOS["1230508"]) -- PURPLE
    mainmemory.write_u16_be(0x11B1A0, AGI_JINJOS["1230509"]) -- BLACK
end

function jinjo_check()
    local checks = {}
    if BMM_BACKUP_JINJO == true
    then
        jinjo_ui_update()
        if DEBUG == true
        then
            print("Setting BMM Jinjos")
        end
        return BMM_JINJOS
    end
    if ASSET_MAP_CHECK[CURRENT_MAP] ~= nil
    then
        if ASSET_MAP_CHECK[CURRENT_MAP]["JINJOS"] ~= nil
        then
            for _,locationId in pairs(ASSET_MAP_CHECK[CURRENT_MAP]["JINJOS"])
            do
                checks[locationId] = BTRAMOBJ:checkFlag(ADDRESS_MAP["JINJOS"][locationId]['addr'], ADDRESS_MAP["JINJOS"][locationId]['bit'])
                if DEBUG == true
                then
                    print(ADDRESS_MAP["JINJOS"][locationId]['name']..":"..tostring(checks[locationId]))
                end
            end
        end
    end
    return checks
end

function backup_BMM_JINJOS()
    if BMM_BACKUP_JINJO == false
    then
        for locationId,v in pairs(ADDRESS_MAP["JINJOS"]) do
            if BTRAMOBJ:checkFlag(v['addr'], v['bit']) == true
            then
                BMM_JINJOS[locationId] = true
            else
                BMM_JINJOS[locationId] = false
            end
        end
        BMM_BACKUP_JINJO = true
        JinjoPause()
    end
end

-- Family complete checks are stored in BKJINJOFAM
function init_JinjoFam()
    for locId, _ in pairs(ADDRESS_MAP["JINJOFAM"])
    do
        BKJINJOFAM[locId] = false
    end
end

function JinjoCounter() -- counts AP jinjos and Marks as Completed if true
    init_JINJOS("AGI")
    for _, locationId in pairs(receive_map) do
        if locationId == "1230501" or locationId == "1230502" or locationId == "1230503" or locationId == "1230504"
            or locationId == "1230505" or locationId == "1230506" or locationId == "1230507" or locationId == "1230508"
            or locationId == "1230509"
        then
            AGI_JINJOS[locationId] = AGI_JINJOS[locationId] + 1
        end
    end
    -- for locId, value in pairs(AGI_JINJOS)
    -- do
    --     print(locId ..": " .. tostring(value))
    -- end
    for locId, value in pairs(BKJINJOFAM) do
        if value == false
        then
            if locId == "1230676"
            then
                if AGI_JINJOS["1230501"] >= 1 then
                    BKJINJOFAM[locId] = true
                end
            end
            if locId == "1230677"
            then
                if AGI_JINJOS["1230502"] >= 2 then
                    BKJINJOFAM[locId] = true
                end
            end
            if locId == "1230678"
            then
                if AGI_JINJOS["1230503"] >= 3 then
                    BKJINJOFAM[locId] = true
                end
            end
            if locId == "1230679"
            then
                if AGI_JINJOS["1230504"] >= 4 then
                    BKJINJOFAM[locId] = true
                end
            end
            if locId == "1230680"
            then
                if AGI_JINJOS["1230505"] >= 5 then
                    BKJINJOFAM[locId] = true
                end
            end
            if locId == "1230681"
            then
                if AGI_JINJOS["1230506"] >= 6 then
                    BKJINJOFAM[locId] = true
                end
            end
            if locId == "1230682"
            then
                if AGI_JINJOS["1230507"] >= 7 then
                    BKJINJOFAM[locId] = true
                end
            end
            if locId == "1230683"
            then
                if AGI_JINJOS["1230508"] >= 8 then
                    BKJINJOFAM[locId] = true
                end
            end
            if locId == "1230684"
            then
                if AGI_JINJOS["1230509"] >= 9 then
                    BKJINJOFAM[locId] = true
                end
            end
        end
    end
end

function JinjoPause()
    -- Clear all Jinjo AMM Flags first, then Set. after
    -- -- 15 =  0000 1111
    -- -- 254 = 1111 1110
    BTRAMOBJ:setMultipleFlags(0x39, 15, 0)
    BTRAMOBJ:setMultipleFlags(0x3A, 0, 0)
    BTRAMOBJ:setMultipleFlags(0x3B, 0, 0)
    BTRAMOBJ:setMultipleFlags(0x3C, 0, 0)
    BTRAMOBJ:setMultipleFlags(0x3D, 0, 0)
    BTRAMOBJ:setMultipleFlags(0x3E, 0, 0)
    BTRAMOBJ:setMultipleFlags(0x3F, 254, 0)
    for itemId, value in pairs(AGI_JINJOS)
    do
        if value > 0
        then
            for i = 0, value - 1,1
            do
                if JINJO_PATTER_MAP[itemId][tostring(i)] == nil
                then
                    if DEBUG == true
                    then
                        print("Jinjo Overflow. Stopping Loop but everything is OK.")
                    end
                    break;
                end
                if DEBUG == true
                then
                    print("Setting Jinjo ID: " .. itemId .. " # " .. tostring(i))
                end
                BTRAMOBJ:setFlag(ADDRESS_MAP["JINJOS"][JINJO_PATTER_MAP[itemId][tostring(i)]]['addr'],
                ADDRESS_MAP["JINJOS"][JINJO_PATTER_MAP[itemId][tostring(i)]]['bit'])
            end
        end
    end
end

------------------ DEATH LINK ---------------

function minigameMaps()
    if CURRENT_MAP == 0xC6 or CURRENT_MAP == 0xC8 or CURRENT_MAP == 0xC9  -- MT Kickballs
    then
        return true
    elseif CURRENT_MAP == 0x16F or CURRENT_MAP == 0x170 --Canary GGM Race
    then
        return true
    -- elseif CURRENT_MAP == 0xE4 or CURRENT_MAP == 0xE5 --Crazy Castle Minigames
    -- then
    --     return true
    elseif CURRENT_MAP == 0xDE or CURRENT_MAP == 0xDF or CURRENT_MAP == 0xE0 -- Dodgems
    then
        return true
    elseif CURRENT_MAP == 0x124 or CURRENT_MAP == 0x141 or CURRENT_MAP == 0x13C -- Saucer of Peril
    then
        return true
    -- elseif CURRENT_MAP == 0x17D -- GI Packing Game
    -- then
    --     return true
    elseif CURRENT_MAP == 0x12E or CURRENT_MAP == 0x12F or CURRENT_MAP == 0x130  -- HFP Kickballs
    then
        return true
    elseif CURRENT_MAP == 0x161 -- Canary CC Race
    then
        return true
    elseif CURRENT_MAP == 0x15F -- ToT
    then
        return true
    end
    return false
end

function cutsceneMaps()
    if CURRENT_MAP == 0x197 or CURRENT_MAP == 0x199 or CURRENT_MAP == 0xA3 or CURRENT_MAP == 0x18F 
    or CURRENT_MAP == 0x195 or CURRENT_MAP == 0x195 or CURRENT_MAP == 0xAC or CURRENT_MAP == 0x192
    or CURRENT_MAP == 0x193 or CURRENT_MAP == 0x19D or CURRENT_MAP == 0xA9 or CURRENT_MAP == 0xA5
    or CURRENT_MAP == 0xA2 or CURRENT_MAP == 0xA6 or CURRENT_MAP == 0x18C or CURRENT_MAP == 0x190
    or CURRENT_MAP == 0x198 or CURRENT_MAP == 0x18D or CURRENT_MAP == 0x196 or CURRENT_MAP == 0x18E
    or CURRENT_MAP == 0xAA or CURRENT_MAP == 0xAB or CURRENT_MAP == 0x159 or CURRENT_MAP == 0xA8
    or CURRENT_MAP == 0xA4 or CURRENT_MAP == 0x19C or CURRENT_MAP == 0x191 or CURRENT_MAP == 0xA1
    or CURRENT_MAP == 0x17E or CURRENT_MAP == 0x158
    then
        return true
    end
    return false
end

function setCurrentHealth(value)
	local currentTransformation = mainmemory.readbyte(0x11B065);
    local health_table = {
        [0x01] = 0x11B644, -- Main
        [0x10] = 0x11B65F, -- Banjo (Solo)
        [0x11] = 0x11B668, -- Mumbo
        [0x2E] = 0x11B66E, -- Detonator
        [0x2F] = 0x11B665, -- Submarine
        [0x30] = 0x11B677, -- T. Rex
        [0x31] = 0x11B653, -- Bee
        [0x32] = 0x11B647, -- Snowball
        [0x36] = 0x11B656, -- Washing Machine
        [0x5F] = 0x11B662, -- Kazooie (Solo)
    }
	if type(health_table[currentTransformation]) == 'number' then
		value = value or 0;
		value = math.max(0x00, value);
		value = math.min(0xFF, value);
		mainmemory.write_u8(health_table[currentTransformation], value);
        return currentTransformation
	end
    return false
end

function killBT()
    if KILL_BANJO == true then
        CHECK_DEATH = true -- Avoid Death loops
        BTMODELOBJ:changeName("Player", false)
        local player = BTMODELOBJ:checkModel();
        if player == false
        then
            return
        end
        if minigameMaps() == false and cutsceneMaps() == false and GAME_LOADED == true
        then 
            tranformation = setCurrentHealth(0)
            if type(tranformation) == 'number' then
                mainmemory.write_u16_be(0x12b062, 0x0100)--max air and suffocation flag?
                mainmemory.write_u16_be(0x12b068, 0x800C)--max air and suffocation flag?
                mainmemory.write_u16_be(0x12b06A, 0xF734)--max air and suffocation flag?

                mainmemory.write_u32_be(0x12b050, 0x00)-- kill in water
                mainmemory.write_u32_be(0x12b054, 0x00)-- kill in water
                local kill_animation = 0x01 -- funny drowning death
                if tranformation ~= 0x01
                then
                    kill_animation = 0x02 -- Explode 
                end 
                mainmemory.write_u8(0x12b161, kill_animation)--max air and suffocation flag?
                local death_flg = mainmemory.read_u8(0x1354F9)
                if death_flg == 1
                then
                    KILL_BANJO = false
                end
            end
        end
    end
end

function getBanjoDeath()
    if DEATH_LINK == true and KILL_BANJO == false
    then
        local death_flg = mainmemory.read_u8(0x1354F9)
        BTMODELOBJ:changeName("Player", false)
        local check = BTMODELOBJ:checkModel();
        if death_flg  == 0 and CHECK_DEATH == true
        then
            CHECK_DEATH = false
            return
        end
        if CHECK_DEATH == false and death_flg == 1
        then
            DETECT_DEATH = true
        end
    end
end

---------------------- MOVED ASSETS -------------------

function MoveWitchyPads() -- Called from nearSilo Function
    BTMODELOBJ:changeName("Kazooie Split Pad", false)
    local modelPOS = BTMODELOBJ:getMultipleModelCoords()
    if modelPOS == false
    then
        return;
    end
    for modelObjPtr, POS in pairs(modelPOS) do

        if (POS["Xpos"] == -125 and POS["Ypos"] == -163 and POS["Zpos"] == -1580)
            and CURRENT_MAP == 0xD6
        then
            BTMODELOBJ:moveModelObject(modelObjPtr, -300, -163, -1855)
            break
        end
    end
    BTMODELOBJ:changeName("Banjo Split Pad", false)
    local modelPOS = BTMODELOBJ:getMultipleModelCoords()
    if modelPOS == false
    then
        return;
    end
    for modelObjPtr, POS in pairs(modelPOS) do
        if (POS["Xpos"] == 125 and POS["Zpos"] == -1580)
            and CURRENT_MAP == 0xD6
        then
            BTMODELOBJ:moveModelObject(modelObjPtr, 304, -163, -1855)
            break
        end
    end
end

function MoveBathPads()
    if CURRENT_MAP == 0xF4 and BATH_PADS_QOL == false
    then
        BTMODELOBJ:changeName("Kazooie Split Pad", false)
        POS = BTMODELOBJ:getSingleModelCoords(nil)
        if POS == false
        then
            return
        end

        BTMODELOBJ:moveModelObject(nil, nil, POS["Ypos"] - 75, POS["Zpos"] + 450 );
        BTMODELOBJ:changeRotation(nil, nil, 0);

        BTMODELOBJ:changeName("Banjo Split Pad", false)
        POS = BTMODELOBJ:getSingleModelCoords(nil)
        if POS == false
        then
            return
        end
        BTMODELOBJ:moveModelObject(nil, nil, POS["Ypos"] - 75, POS["Zpos"] + 450);
        BTMODELOBJ:changeRotation(nil, nil, 0)
        BATH_PADS_QOL = true
    elseif  CURRENT_MAP ~= 0xF4 and BATH_PADS_QOL == true
    then
        BATH_PADS_QOL = false
    end
end

function moveLevitatePad()
    if ENABLE_AP_CHUFFY == true
    then
        if AGI_CHUFFY["1230796"] == false and CURRENT_MAP == 0xD7 and LEVI_PAD_MOVED == false
        then
            BTMODELOBJ:changeName("Levitate Pad", false)
            local model = BTMODELOBJ:checkModel();
            if model == false
            then
                return false
            end
            BTMODELOBJ:moveModelObject(nil, nil, -100, nil)
            LEVI_PAD_MOVED = true;
            if DEBUG_CHUFFY == true
            then
                print("Lebitate Pads Moved")
            end
            return true
        elseif AGI_CHUFFY["1230796"] == false and CURRENT_MAP ~= 0xD7 and LEVI_PAD_MOVED == true
        then
            LEVI_PAD_MOVED = false
        end
    end
end

---------------------- GAME FUNCTIONS -------------------

function zoneWarp(zone_table)
    -- from name -> to name
    print(zone_table)
    for orig_world, new_world in pairs(zone_table)
    do
        local success = false
        local orig_table = {}
        local orig_map = 0x0
        local new_table = {}
        local new_map = 0x0;
       for world_id, world_table in pairs(MAP_ENTRANCES)
       do
            if world_table["name"] == orig_world
            then
                orig_table = world_table
                orig_map = world_id
            end
            if world_table["name"] == new_world
            then
                new_table = world_table
                new_map = world_id
            end
       end
       while success == false do
            BTH:setWorldEntrance(orig_map, new_map, orig_table['entranceId'], orig_table['exitMap'], new_table['entranceId'])
            success = BTH:setWorldEntrance(new_table['exitMap'], orig_table['exitMap'], new_table['exitId'], new_map, orig_table['exitId'])
            if orig_map == 0xC7 -- Glitter Gulch Mine 
            then
                BTH:setWorldEntrance(orig_map, new_map, 16, orig_table['exitMap'], new_table['entranceId'])
            end
            emu.frameadvance()
       end
    end
end

function hag1_open()
    if GOAL_TYPE == 0 and OPEN_HAG1 == false and TOTAL_JIGGY >= 70
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_H1A"], 1)
    elseif GOAL_TYPE == 4 and TOTAL_MUMBO_TOKENS >= 32
    then
        BTH:setItem(ITEM_TABLE["AP_ITEM_H1A"], 1)
    end
end

function check_open_level(show_message)  -- See if entrance conditions for a level have been met    
    if DEBUG == true then
        print(TOTAL_JIGGY)
    end
    for _, values in pairs(WORLD_ENTRANCE_MAP)
    do
        if TOTAL_JIGGY >= values["defaultCost"]
        then
            UNLOCKED_WORLDS[values["locationId"]] = true
        end
    end
    hag1_open()
end

function unlock_worlds(itemId)
    if itemId == 1230944 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_MTA"], 1)
    end
    if itemId == 1230945 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_GGA"], 1)
    end
    if itemId == 1230946 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_WWA"], 1)
    end
    if itemId == 1230947 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_JRA"], 1)
    end
    if itemId == 1230948 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_TDA"], 1)
    end
    if itemId == 1230949 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_GIA"], 1)
    end
    if itemId == 1230950 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_HFA"], 1)
    end
    if itemId == 1230951 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_CCA"], 1)
    end
    if itemId == 1230952 then
        BTH:setItem(ITEM_TABLE["AP_ITEM_CKA"], 1)
    end
end

function DPadStats()
    if GAME_LOADED == true
    then
        local check_controls = joypad.get()
        
        -- SNEAK
        if check_controls ~= nil and check_controls['P1 DPad U'] == true and SNEAK == false and check_controls['P1 L'] == false
        then
            joypad.setanalog({['P1 Y Axis'] = 18 })
            SNEAK = true
        elseif check_controls ~= nil and check_controls['P1 DPad U'] == false and SNEAK == true and check_controls['P1 L'] == false
        then
            joypad.setanalog({['P1 Y Axis'] = '' })
            SNEAK = false
        end
		
        -- Check Obtained Moves and Worlds
		if check_controls ~= nil and check_controls['P1 DPad R'] == true and check_controls['P1 L'] == false and CHECK_MOVES_R == false
        then
            print(" ")
            print(" ")
            print("Unlocked Moves:")
            if ENABLE_AP_BK_MOVES ~= 0
            then
                for locationId, table in pairs(ADDRESS_MAP["BKMOVES"])
                do
                    if BTRAMOBJ:checkFlag(table['addr'], table['bit']) == true
                    then
                        print(table['name'])
                    end
                end
            end
            for locationId, values in pairs(ADDRESS_MAP["MOVES"])
            do             
                if AGI_MOVES[locationId] == true
                then
                    print(values['name'])
                end
            end
            if AGI_MYSTERY["1230800"] == true
            then
                print("Breegull Bash");
            end
            if FAST_SWIM == true
            then
                print("Fast Swimming")
            end
            if DOUBLE_AIR == true
            then
                print("Double Air")
            end
            print(" ")
            print(" ")
            print("Unlocked Worlds")
            for world, table in pairs(WORLD_ENTRANCE_MAP)
            do
                if table["opened"] == true
                then
                    print(table["defaultName"])
                end
            end
            CHECK_MOVES_R = true
        elseif check_controls ~= nil and check_controls['P1 DPad R'] == false and check_controls['P1 L'] == false and CHECK_MOVES_R == true
        then
            CHECK_MOVES_R = false
		end
		-- Check Magic
		if check_controls ~= nil and check_controls['P1 DPad L'] == true and check_controls['P1 L'] == false and CHECK_MOVES_L == false
        then
            print(" ")
            print(" ")
            print("Unlocked Magic:")
            CHECK_MOVES_L = true
        elseif check_controls ~= nil and check_controls['P1 DPad L'] == false and check_controls['P1 L'] == false and CHECK_MOVES_L == true
        then
            CHECK_MOVES_L = false
        end
		-- Check Collected Treble, Stations and Victory Condition
		if check_controls ~= nil and check_controls['P1 DPad D'] == true and check_controls['P1 L'] == false and CHECK_MOVES_D == false
        then
            print(" ")
            print(" ")
            print("Collected Treble Clefs:")
            for locationId, values in pairs(ADDRESS_MAP["TREBLE"])
            do        
                local results = BTRAMOBJ:checkFlag(values['addr'], values['bit'])
                if results == true then
                    print(values['name'])
                end
            end
			print(" ")
            if DEBUG_STATION == true
            then
                print("DEBUGGING Opened Train Stations:")
                for locationId, values in pairs(ADDRESS_MAP["STATIONS"])
                do        
                    local results = BTRAMOBJ:checkFlag(values['addr'], values['bit'])
                    if results == true then
                        print(values['name'])
                    end
                end
            end
            print("Open Train Stations:")
            local TRAIN_TBL = {}
            for apId, itemId in pairs(receive_map)
            do
                if ADDRESS_MAP["STATIONS"][itemId] ~= nil
                then
                    if TRAIN_TBL[itemId] == nil
                    then
                        print(ADDRESS_MAP["STATIONS"][itemId]['name'])
                        TRAIN_TBL[itemId] = "Y"
                    end
                end
            end
            if GOAL_TYPE ~= 0
            then
                local token_count = 0;
                for id, itemId in pairs(receive_map)
                do
                    if itemId == "1230798"
                    then
                        token_count = token_count + 1
                    end
                end
                print(" ")
			    print("Collected Mumbo Tokens: "..token_count)
            end
            CHECK_MOVES_D = true
        elseif check_controls ~= nil and check_controls['P1 DPad D'] == false and check_controls['P1 L'] == false and CHECK_MOVES_D == true
        then
            CHECK_MOVES_D = false
        end
		
        -- CHEAT: Refill & Double
        if check_controls ~= nil and check_controls['P1 DPad U'] == true and check_controls['P1 L'] == true and REFILL_HOLD == false
        then
            BTRAMOBJ:setFlag(0xA1, 4, "Double Feathers") -- Double Feathers
            BTRAMOBJ:setFlag(0xA1, 5, "Double Eggs") -- Double Eggs
			BTCONSUMEOBJ:changeConsumable("Red Feathers")
			BTCONSUMEOBJ:setConsumable(200)
			BTCONSUMEOBJ:changeConsumable("Gold Feathers")
			BTCONSUMEOBJ:setConsumable(20)
			BTCONSUMEOBJ:changeConsumable("BLUE EGGS")
			BTCONSUMEOBJ:setConsumable(200)
			BTCONSUMEOBJ:changeConsumable("FIRE EGGS")
			BTCONSUMEOBJ:setConsumable(100)
            BTCONSUMEOBJ:changeConsumable("GRENADE EGGS")
            BTCONSUMEOBJ:setConsumable(50)
            BTCONSUMEOBJ:changeConsumable("ICE EGGS")
            BTCONSUMEOBJ:setConsumable(100)
            BTCONSUMEOBJ:changeConsumable("CWK EGGS")
            BTCONSUMEOBJ:setConsumable(20)
			print(" ")
            print("Eggs and Feathers Doubled")
			print("Eggs and Feathers Refilled")
            REFILL_HOLD = true
        elseif check_controls ~= nil and (check_controls['P1 DPad U'] == false or check_controls['P1 L'] == false) and REFILL_HOLD == true
        then
            REFILL_HOLD = false
        end

        -- CHEAT: Super Banjo
        if check_controls ~= nil and check_controls['P1 DPad R'] == true and check_controls['P1 L'] == true and SUPERBANJO == false and SUPERBANJO_HOLD == false
        then
           BTRAMOBJ:setFlag(0xA2, 2, "Super Banjo")
           SUPERBANJO = true
           print(" ")
           print("Super Banjo Enabled")
           SUPERBANJO_HOLD = true
        elseif check_controls ~= nil and check_controls['P1 DPad R'] == true and check_controls['P1 L'] == true and SUPERBANJO == true and SUPERBANJO_HOLD == false
        then
            BTRAMOBJ:clearFlag(0xA2, 2)
            SUPERBANJO = false
            print(" ")
            print("Super Banjo Disabled")
            SUPERBANJO_HOLD = true
        elseif check_controls ~= nil and (check_controls['P1 DPad R'] == false or check_controls['P1 L'] == false)  and SUPERBANJO_HOLD == true
        then
            SUPERBANJO_HOLD = false
        end

        -- CHEAT / APFeature: Aim Assist
        if check_controls ~= nil and check_controls['P1 DPad L'] == true and check_controls['P1 L'] == true and AIMASSIST == false and AIMASSIST_HOLD == false
        then
            if ENABLE_AP_MYSTERY == true
            then
                if AGI_MYSTERY["1230802"] == true
                then
                    BTRAMOBJ:setFlag(0xAF, 3, "Aim Assist")
                    AIMASSIST = true
                    print(" ")
                    print("Aim Assist Enabled")
                else
                    print("Homing Eggs not found")
                end
            else
                BTRAMOBJ:setFlag(0xAF, 3, "Aim Assist")
                AIMASSIST = true
                print(" ")
                print("Aim Assist Enabled")
            end
            AIMASSIST_HOLD = true
        elseif check_controls ~= nil and check_controls['P1 DPad L'] == true and check_controls['P1 L'] == true and AIMASSIST == true and AIMASSIST_HOLD == false
        then
            BTRAMOBJ:clearFlag(0xAF, 3)
            AIMASSIST = false
            print(" ")
            print("Aim Assist Disabled")
            AIMASSIST_HOLD = true
        elseif check_controls ~= nil and (check_controls['P1 DPad L'] == false or check_controls['P1 L'] == false) and AIMASSIST_HOLD == true
        then
            AIMASSIST_HOLD = false
        end
		
        -- CHEAT: Health Regen
		if check_controls ~= nil and check_controls['P1 DPad D'] == true and check_controls['P1 L'] == true and REGEN == false and REGEN_HOLD == false
        then
            if DEATH_LINK == true
            then
                print(" ")
                print("Regen can't be enable with Deathlink.")
                REGEN_HOLD = true
            else
                BTRAMOBJ:setFlag(0xA1, 7, "Automatic Energy Regain")
                REGEN = true
                print(" ")
                print("Energy Regen Enabled")
                REGEN_HOLD = true
            end
        elseif check_controls ~= nil and check_controls['P1 DPad D'] == true and check_controls['P1 L'] == true and REGEN == true and REGEN_HOLD == false
        and DEATH_LINK == false
        then
            BTRAMOBJ:clearFlag(0xA1, 7)
            REGEN = false
            print(" ")
            print("Energy Regen Disabled")
            REGEN_HOLD = true
        elseif check_controls ~= nil and (check_controls['P1 DPad D'] == false or check_controls['P1 L'] == false) and REGEN_HOLD == true
        then 
            REGEN_HOLD = false
        end

        -- APFeature 60 FPS
        if check_controls ~= nil and check_controls['P1 L'] == true and check_controls['P1 Start'] == true and FPS == false and FPS_HOLD == false
        then
            mainmemory.write_u8(0x07913F, 1)
            print("Smooth Banjo Enabled")
            FPS = true
            FPS_HOLD = true
        elseif check_controls ~= nil and check_controls['P1 L'] == true and check_controls['P1 Start'] == true and FPS == true and FPS_HOLD == false
        then
            mainmemory.write_u8(0x07913F, 2)
            print("Smooth Banjo Disabled")
            FPS = false
            FPS_HOLD = true
        elseif check_controls ~= nil and (check_controls['P1 L'] == false or check_controls['P1 Start'] == false) and FPS_HOLD == true
        then
            FPS_HOLD = false
        end
    end
end


function setToTComplete()
	-- this fixes a bug that messes up game progression
	if BTRAMOBJ:checkFlag(0x83, 1) == false and TOT_SET_COMPLETE == false then -- CK Klungo Boss Room
		BTRAMOBJ:setFlag(0x83, 1);
        TOT_SET_COMPLETE = true;
	end
end

function gameSaving()
    if PAUSED ~= true
    then
        return
    else
        local save_game = mainmemory.read_u8(0x044A81);
        if save_game == 1
        then
            SAVE_GAME = true
            if DEBUG == true
            then
                print("Game Entering Save State")
            end
        end
    end
end

function saveGame()
    GAME_LOADED = false;
    SAVE_GAME = false;
end

function hag1_phase_skips()
    local tmp_flg_pointer = 0x12C774
    local beginning_phase_offset = 0x09
    local ending_phase_offset = 0x0A

    local pointer_addr = BTRAMOBJ:dereferencePointer(tmp_flg_pointer)
    mainmemory.writebyte(pointer_addr + beginning_phase_offset, 255); -- Skips part 1
    mainmemory.writebyte(pointer_addr + ending_phase_offset, 31); -- Skips Part 2
end

function ccl_cutscene_skip()
    local tmp_flg_pointer = 0x12C774
    local pointer_addr = BTRAMOBJ:dereferencePointer(tmp_flg_pointer)
    play_cutscene = mainmemory.read_u8(pointer_addr + 0x11)
    if play_cutscene == 0x04
    then
        mainmemory.write_u8(pointer_addr + 0x11, 0)
    end
end 

---------------------- ARCHIPELAGO FUNCTIONS -------------

function mumbo_announce()
    if GOAL_TYPE == 5 and TOKEN_ANNOUNCE == false
    then
        local token_count = 0;
        for id, itemId in pairs(receive_map)
        do
            if itemId == "1230798"
            then
                token_count = token_count + 1
            end
        end
        if token_count >= TH_LENGTH
        then
            message = "You have found enough Mumbo Tokens! Time to head home!"
            print(" ")
            print(message)
            table.insert(AP_MESSAGES, message);
            TOKEN_ANNOUNCE = true
        end
    end
end


function processMessages()
    if next(AP_MESSAGES) ~= nil
    then
        if TEXT_START == false
        then
            message = table.remove(AP_MESSAGES)
            archipelago_msg_box(message)
        end
    end
end

function archipelago_msg_box(msg)
    gui.use_surface("client")
    local bgcolor = "#590000"
    local fgcolor = "#ca0000"
    if TEXT_COLOUR == 0
    then
        bgcolor = "#590000"
        fgcolor = "#ca0000"
    elseif TEXT_COLOUR == 1
    then
        bgcolor = "#0000ff"
        fgcolor = "#ffffff"
    end

    local ratio = client.screenwidth() / client.screenheight()
    if ratio > 1.35
    then
        textXpos = math.floor(client.screenwidth()*.41)
        textYpos = math.floor(client.screenheight()*.70)
        textSize = math.floor((client.screenheight()*.03)+.5)
    else
        textXpos = math.floor(client.screenwidth()*.41)
        textYpos = math.floor(client.screenheight()*.65)
        textSize = math.floor((client.screenheight()*.03)+.5)
    end

    if TEXT_START == false
    then
        if ACTIVATE_TEXT_OVERLAY == true then
            gui.drawText(textXpos, textYpos, msg, fgcolor, bgcolor, textSize, nil, nil, "center")
        end
        TEXT_START = true
    end
end

function clearText()
    if TEXT_TIMER > 0
    then
        TEXT_TIMER = TEXT_TIMER - 1
    else
        gui.clearGraphics()
        TEXT_TIMER = 3
        TEXT_START = false
    end
end

function processAGIItem(item_list)
    for ap_id, memlocation in pairs(item_list) -- Items unrelated to AGI_MAP like Consumables
    do
        if receive_map[tostring(ap_id)] == nil
        then
            if( 1230944 <= memlocation and memlocation <= 1230952) -- Worlds
            then
                unlock_worlds(memlocation)
            elseif( 1230810 <= memlocation and memlocation <= 1230827) -- BK Moves
            then
                obtain_bkmove(memlocation)

            elseif((1230855 <= memlocation and memlocation <= 1230863) or (1230174 <= memlocation and memlocation <= 1230182))
            then
                obtain_AP_MAGIC(memlocation)
            elseif(1230753 <= memlocation and memlocation <= 1230776)
            then
                if DEBUG_SILO == true
                then
                    print("Move Obtained")
                end
                for location, values in pairs(ADDRESS_MAP["MOVES"])
                do
                    if AGI_MOVES[location] == false and location == tostring(memlocation)
                    then
                        AGI_MOVES[location] = true
                        if ADDRESS_MAP["MOVES"][location]['name'] == ('Fire Eggs')
                        then
                            BTCONSUMEOBJ:changeConsumable("FIRE EGGS")
                            BTCONSUMEOBJ:setConsumable(100)
                        elseif ADDRESS_MAP["MOVES"][location]['name'] == ('Grenade Eggs')
                        then
                            BTCONSUMEOBJ:changeConsumable("GRENADE EGGS")
                            BTCONSUMEOBJ:setConsumable(50)
                        elseif ADDRESS_MAP["MOVES"][location]['name'] == ('Ice Eggs')
                        then
                            BTCONSUMEOBJ:changeConsumable("ICE EGGS")
                            BTCONSUMEOBJ:setConsumable(100)
                        elseif ADDRESS_MAP["MOVES"][location]['name'] == ('Clockwork Kazooie Eggs')
                        then
                            BTCONSUMEOBJ:changeConsumable("CWK EGGS")
                            BTCONSUMEOBJ:setConsumable(20)
                        end
                    end
                end
                check_jamjar_silo()
            elseif(1230790 <= memlocation and memlocation <= 1230795) -- Station Btns
            then
                obtained_AP_STATIONS(memlocation);
            elseif memlocation == 1230796 and ENABLE_AP_CHUFFY == true
            then
                obtained_AP_CHUFFY()
            elseif( 1230501 <= memlocation and memlocation <= 1230509) -- Jinjos
            then
                AGI_JINJOS[tostring(memlocation)] = AGI_JINJOS[tostring(memlocation)] + 1
            elseif( 1230777 <= memlocation and memlocation <= 12307778) -- Roysten Moves
            then
                obtain_roysten_moves(memlocation)
            elseif( 1230828 <= memlocation and memlocation <= 1230832) -- Progressive Moves
            then
                obtain_progressive_moves(memlocation)
            elseif( 1230799 <= memlocation and memlocation <= 1230804) -- StopNSwap
            then
                obtain_mystery_item(memlocation)
            elseif(memlocation == 1230514) -- Doubloon Item
            then
                obtained_AP_DOUBLOON()
            elseif(memlocation == 1230515) -- Jiggy
            then
                obtain_AP_JIGGY()
                check_open_level(true) -- check if the current jiggy count opens a new level
            elseif memlocation == 1230516 -- Treble Clef
            then
                obtain_AP_TREBLE()
            elseif(memlocation == 1230831) -- Progressive Water Training
            then
                obtain_roysten_moves(memlocation)
            elseif(memlocation == 1230513) -- Cheato Item
            then
                obtain_AP_PAGES()
            elseif(memlocation == 1230512)  -- Honeycomb Item
            then
                obtained_AP_HONEYCOMB()
            elseif(memlocation == 1230797) -- Notes
            then
                obtain_AP_NOTES()

            elseif(memlocation == 1230823)
            then
                BTRAMOBJ:setFlag(0x1E, 6, "Blue Eggs")
                BTCONSUMEOBJ:changeConsumable("BLUE EGGS")
                BTCONSUMEOBJ:setConsumable(100)
                TEMP_EGGS = false
            elseif(memlocation == 1230779) --amaze-o-gaze
            then
               obtain_amaze_o_gaze()
            elseif(memlocation == 1230780) --Roar
            then
                obtain_roar()
            end
            receive_map[tostring(ap_id)] = tostring(memlocation)
        end
    end
end

function process_block(block)
    -- Sometimes the block is nothing, if this is the case then quietly stop processing
    if block == nil then
        return
    end
    if block['slot_player'] ~= nil
    then
        return
    end
    if next(block['items']) ~= nil
    then
        processAGIItem(block['items'])
    end
    if next(block['messages']) ~= nil
    then
        for k, message in pairs(block['messages'])
        do
            if not string.find(message, "%(found%)")
            then
                table.insert(AP_MESSAGES, message)
            end
        end
    end
    if block['triggerDeath'] == true
    then
        KILL_BANJO = true;
    end

    if DEBUGLVL3 == true then
        print(block)
    end
end

function SendToBTClient()
    local retTable = {}
    retTable["scriptVersion"] = SCRIPT_VERSION;
    retTable["playerName"] = PLAYER;
    retTable["deathlinkActive"] = DEATH_LINK;
    retTable["jiggies"] = jiggy_check()
    retTable["jinjos"] = jinjo_check()
    retTable["pages"] = pages_check()
    retTable["honeycomb"] = honeycomb_check()
    retTable["glowbo"] = glowbo_check()
    retTable["doubloon"] = doubloon_check()
    retTable["notes"] = notes_check()
    retTable["hag"] = BTH:checkRealFlag(ADDRESS_MAP["H1"]["1230027"]['addr'], ADDRESS_MAP["H1"]["1230027"]['bit'])
    retTable['unlocked_moves'] = BKM;
    retTable['treble'] = treble_check();
    retTable['stations'] = BMM_STATIONS;
    retTable['chuffy'] = BMM_CHUFFY;
    retTable["isDead"] = DETECT_DEATH;
    retTable["jinjofam"] = BKJINJOFAM;
    retTable["worlds"] = UNLOCKED_WORLDS;
    retTable["mystery"] = mystery_check();
    retTable["roysten"] = roysten_check();
    retTable["cheato_rewards"] = cheato_rewards_check();
    retTable["honeyb_rewards"] = honey_b_check();
    retTable["jiggy_chunks"] = jiggy_chunks_check();
    retTable["goggles"] = amaze_check();
    retTable["roar"] = roar_check();
    retTable["dino_kids"] = dino_kids_check();
    retTable["DEMO"] = false;
    retTable["sync_ready"] = "true"

    if CURRENT_MAP == nil
    then
        retTable["banjo_map"] = 0x0;
    else
        retTable["banjo_map"] = CURRENT_MAP;
    end 
    if DEBUGLVL3 == true
    then
        print("Send Data")
    end

    local msg = json.encode(retTable).."\n"
    local ret, error = BT_SOCK:send(msg)
    if ret == nil then
        print(error)
    elseif CUR_STATE == STATE_INITIAL_CONNECTION_MADE then
        CUR_STATE = STATE_TENTATIVELY_CONNECTED
    elseif CUR_STATE == STATE_TENTATIVELY_CONNECTED then
        archipelago_msg_box("Connected to the Banjo Tooie Client!");
        print("Connected!")
        PRINT_GOAL = true;
        CUR_STATE = STATE_OK
    end
    if DETECT_DEATH == true
    then
        DETECT_DEATH = false
    end
end

function receive()
    if PLAYER == "" and SEED == 0
    then
        getSlotData()
    else
        -- Send the message
        SendToBTClient()

        l, e = BT_SOCK:receive()
        -- Handle incoming message
        if e == 'closed' then
            if CUR_STATE == STATE_OK then
                archipelago_msg_box("Connection closed")
                print("Connection closed")
            end
            CUR_STATE = STATE_UNINITIALIZED
            return
        elseif e == 'timeout' then
            archipelago_msg_box("timeout")
            print("timeout")
            return
        elseif e ~= nil then
            print(e)
            CUR_STATE = STATE_UNINITIALIZED
            return
        end
        if DEBUGLVL3 == true
        then
            print("Processing Block");
        end
        process_block(json.decode(l))
        if DEBUGLVL3 == true
        then
            print("Finish");
        end
    end
end

function savingAGI()
    local f = io.open("BT" .. PLAYER .. "_" .. SEED .. ".AGI", "w") --generate #BTplayer_seed.AGI
    if DEBUGLVL2 == true
    then
        print("Writing AGI File from Saving");
        print(receive_map)
    end
    f:write(json.encode(AGI_MOVES) .. "\n");
    if DEBUGLVL2 == true
    then
        print("Writing MYSTERY");
    end
    f:write(json.encode(AGI_MYSTERY) .. "\n");
    if DEBUGLVL2 == true
    then
        print("Writing Received_Map");
    end
    f:write(json.encode(receive_map))
    f:close()
    if DEBUG == true
    then
        print("AGI Table Saved");
    end
end

function loadAGI()
    local f = io.open("BT" .. PLAYER .. "_" .. SEED .. ".AGI", "r") --generate #BTplayer_seed.AGI
    if f==nil then
        if next(AGI_MOVES) == nil then
            AGI_MOVES = init_BMK("AGI");
        end
        if next(AGI_STATIONS) == nil then
            init_STATIONS("AGI", false);
        end
        if next(AGI_CHUFFY) == nil then
            init_CHUFFY("AGI", false);
        end

        f = io.open("BT" .. PLAYER .. "_" .. SEED .. ".AGI", "w");
        if DEBUGLVL2 == true
        then
            print("Writing AGI File from LoadAGI");
        end
        f:write(json.encode(AGI_MOVES).."\n");
        f:write(json.encode(receive_map));
        f:close();
    else
        if DEBUGLVL2 == true
        then
            print("Loading AGI File");
        end
        AGI_MOVES = json.decode(f:read("l"));
        AGI_MYSTERY = json.decode(f:read("l"));
        receive_map = json.decode(f:read("l"));
        f:close();
    end
end

function getSlotData()
    local retTable = {}
    retTable["getSlot"] = true;
    if DEBUGLVL2 == true
    then
        print("Encoding getSlot");
    end
    local msg = json.encode(retTable).."\n"
    local ret, error = BT_SOCK:send(msg)
    l, e = BT_SOCK:receive()
    -- Handle incoming message
    if e == 'closed' then
        if CUR_STATE == STATE_OK then
            archipelago_msg_box("Connection closed")
            print("Connection closed")
        end
        CUR_STATE = STATE_UNINITIALIZED
        return
    elseif e == 'timeout' then
        archipelago_msg_box("timeout")
        print("timeout")
        return
    elseif e ~= nil then
        print(e)
        CUR_STATE = STATE_UNINITIALIZED
        return
    end
    if DEBUGLVL2 == true
    then
        print("Processing Slot Data");
    end
    process_slot(json.decode(l))
end

function process_slot(block)
    if DEBUGLVL3 == true then
        print("slot_data")
        print(block)
        print("EO_slot_data")
    end

    for index, item in pairs(ROM_ITEM_TABLE)
    do
        ITEM_TABLE[item] = index - 1
    end
    if block['slot_player'] ~= nil and block['slot_player'] ~= ""
    then
        PLAYER = block['slot_player']
    end
    if block['slot_seed'] ~= nil and block['slot_seed'] ~= ""
    then
        SEED = block['slot_seed']
        BTH:setSettingSeed(SEED)
    end
    if block['slot_deathlink'] ~= nil and block['slot_deathlink'] ~= "false"
    then
        DEATH_LINK = true
    end
    if block['slot_logic_type'] ~= nil and block['slot_logic_type'] ~= "false"
    then
        LOGIC = block['slot_logic_type']
    end
    if block['slot_activate_text'] ~= nil and block['slot_activate_text'] ~= "false"
    then
        ACTIVATE_TEXT_OVERLAY = true
    end
    if block['slot_skip_tot'] ~= nil and block['slot_skip_tot'] ~= ""
    then
        SKIP_TOT = block['slot_skip_tot']
        if block['slot_skip_tot'] == "false"
        then
            BTH:setSettingToT(0)
        elseif block['slot_skip_tot'] == "false"  then
            BTH:setSettingToT(1)
        else
            BTH:setSettingToT(2)
        end
    end
    if block['slot_honeycomb'] ~= nil and block['slot_honeycomb'] ~= "false"
    then
        ENABLE_AP_HONEYCOMB = true
    end
	if block['slot_pages'] ~= nil and block['slot_pages'] ~= "false"
    then
        ENABLE_AP_PAGES = true
    end
    if block['slot_moves'] ~= nil and block['slot_moves'] ~= "false"
    then
        ENABLE_AP_MOVES = true
    end
    if block['slot_bkmoves'] ~= nil and block['slot_bkmoves'] ~= "false"
    then
        ENABLE_AP_BK_MOVES = block['slot_bkmoves']
    end
    if block['slot_cheatorewards'] ~= nil and block['slot_cheatorewards'] ~= "false"
    then
        ENABLE_AP_CHEATO_REWARDS = true
    end
    if block['slot_honeybrewards'] ~= nil and block['slot_honeybrewards'] ~= "false"
    then
        ENABLE_AP_HONEYB_REWARDS = true
    end

    if block['slot_minigames'] ~= nil and block['slot_minigames'] ~= ""
    then
        MINIGAMES = block['slot_minigames']
        if MINIGAMES == "skip"
        then
            BTH:setSettingMinigames(1)
        end
    end
    if block['slot_skip_puzzles'] ~= nil and block['slot_skip_puzzles'] ~= "false"
    then
        SKIP_PUZZLES = true
        BTH:setSettingPuzzle(1)
    end
    if block['slot_skip_klungo'] ~= nil and block['slot_skip_klungo'] ~= "false"
    then
        SKIP_KLUNGO = true
        BTH:setSettingKlungo(1)
    end
    if block['slot_open_hag1'] ~= nil and block['slot_open_hag1'] ~= "false"
    then
        OPEN_HAG1 = true
        if block['slot_goal_type'] == 0
        then
            BTH:setItem(ITEM_TABLE["AP_ITEM_H1A"], 1)
        end
    end
    if block['slot_chuffy'] ~= nil and block['slot_chuffy'] ~= "false"
    then
        ENABLE_AP_CHUFFY = true
        BTH:setSettingChuffy(1)
    end
    if block['slot_worlds'] ~= nil and block['slot_worlds'] ~= "false"
    then
        ENABLE_AP_WORLDS = true
    end

    -- if block['slot_mystery'] ~= nil
    -- then
    --     if ENABLE_AP_MYSTERY == false
    --     then
            
    --     end
    -- end
    if block['slot_goal_type'] ~= nil and block['slot_goal_type'] ~= ""
    then
        GOAL_TYPE = block['slot_goal_type']
    end
    if block['slot_minigame_hunt_length'] ~= nil and block['slot_minigame_hunt_length'] ~= ""
    then
        MGH_LENGTH = block['slot_minigame_hunt_length']
    end
    if block['slot_boss_hunt_length'] ~= nil and block['slot_boss_hunt_length'] ~= ""
    then
        BH_LENGTH = block['slot_boss_hunt_length']
    end
    if block['slot_jinjo_family_rescue_length'] ~= nil and block['slot_jinjo_family_rescue_length'] ~= ""
    then
        JFR_LENGTH = block['slot_jinjo_family_rescue_length']
    end
    if block['slot_token_hunt_length'] ~= nil and block['slot_token_hunt_length'] ~= ""
    then
        TH_LENGTH = block['slot_token_hunt_length']
    end
    if block['slot_world_order'] ~= nil
    then
        for level, jiggy_amt in pairs(block['slot_world_order'])
        do
            local locationId = block['slot_keys'][level]
            if(level == "Mayahem Temple")
            then
                BTH:setSettingJiggyRequirements(0, jiggy_amt)
            elseif(level == "Glitter Gulch Mine")
            then
                BTH:setSettingJiggyRequirements(1, jiggy_amt)
            
            elseif(level == "Witchyworld")
            then
                BTH:setSettingJiggyRequirements(2, jiggy_amt)
            
            elseif(level == "Jolly Roger's Lagoon - Town Center")
            then
                level = "Jolly Roger's Lagoon"
                BTH:setSettingJiggyRequirements(3, jiggy_amt)
            
            elseif(level == "Terrydactyland")
            then
                BTH:setSettingJiggyRequirements(4, jiggy_amt)
            
            elseif(level == "Outside Grunty Industries")
            then
                level = "Grunty Industries"
                BTH:setSettingJiggyRequirements(5, jiggy_amt)
            
            elseif(level == "Hailfire Peaks")
            then
                BTH:setSettingJiggyRequirements(6, jiggy_amt)
            
            elseif(level == "Cloud Cuckooland")
            then
                BTH:setSettingJiggyRequirements(7, jiggy_amt)
            
            elseif(level == "Cauldron Keep")
            then
                BTH:setSettingJiggyRequirements(8, jiggy_amt)
            end
            for worlds, t in pairs(WORLD_ENTRANCE_MAP)
            do
                if t['defaultName'] == level
                then
                    WORLD_ENTRANCE_MAP[worlds]["defaultCost"] = jiggy_amt
                    WORLD_ENTRANCE_MAP[worlds]["locationId"] = tostring(locationId)
                end
            end
        end
    end
    if block['slot_open_silo'] ~= nil
    then
        OPEN_SILO = block['slot_open_silo']
        print(OPEN_SILO)
        if OPEN_SILO == "ALL"
        then
            BTH:setSettingOpenSilos(0, 1) -- JV
            BTH:setSettingOpenSilos(1, 1) -- WH
            BTH:setSettingOpenSilos(2, 1) -- PL
            BTH:setSettingOpenSilos(3, 1) -- PG
            BTH:setSettingOpenSilos(4, 1) -- CT
            BTH:setSettingOpenSilos(5, 1) -- WL
            BTH:setSettingOpenSilos(6, 1) -- QM
        elseif string.find(OPEN_SILO, "Wasteland") ~= nil then
            BTH:setSettingOpenSilos(0, 1)
            BTH:setSettingOpenSilos(5, 1) -- WL
        elseif string.find(OPEN_SILO, "Quagmire") ~= nil then
            BTH:setSettingOpenSilos(0, 1)
            BTH:setSettingOpenSilos(6, 1) -- QM
        elseif string.find(OPEN_SILO, "Plateau") ~= nil then
            BTH:setSettingOpenSilos(0, 1)
            BTH:setSettingOpenSilos(2, 1) -- PL
        elseif string.find(OPEN_SILO, "Pine Grove") ~= nil then
            BTH:setSettingOpenSilos(0, 1)
            BTH:setSettingOpenSilos(3, 1) -- PG
        elseif string.find(OPEN_SILO, "Cliff Top") ~= nil then
            BTH:setSettingOpenSilos(0, 1)
            BTH:setSettingOpenSilos(4, 1) -- CT
        end
    end
    if block['slot_version'] ~= nil and block['slot_version'] ~= ""
    then
        CLIENT_VERSION = block['slot_version']
        if CLIENT_VERSION ~= BT_VERSION
        then
            VERROR = true
            return false
        end
    end

    if block['slot_zones'] ~= nil
    then
        zoneWarp(block['slot_zones'])
    end
    printGoalInfo();
    return true
end

function printGoalInfo()
    local randomEncouragment = ENCOURAGEMENT[math.random(1, #ENCOURAGEMENT)]["message"]
    if GOAL_TYPE ~= nil and MGH_LENGTH ~= nil and BH_LENGTH ~= nil and 
    JFR_LENGTH ~= nil and TH_LENGTH ~= nil then
        local message = ""
        if GOAL_TYPE == 0 then
            message = "You need to hunt down Grunty in her HAG1 \nand put her back in the ground!"..randomEncouragment;
        elseif GOAL_TYPE == 1 and MGH_LENGTH == 15 then
            message = "You are hunting down all 15 of the Mumbo Tokens \nfound in Grunty's dastardly minigames! Good luck and"..randomEncouragment;
        elseif GOAL_TYPE == 1 and MGH_LENGTH < 15 then
            message = "You are hunting for "..MGH_LENGTH.." Mumbo Tokens from \nGrunty's dastardly minigames! Good Luck and"..randomEncouragment;
        elseif GOAL_TYPE == 2 and BH_LENGTH == 8 then
            message = "You are hunting down all 8 Mumbo Tokens from \neach world boss! Good Luck and"..randomEncouragment;
        elseif GOAL_TYPE == 2 and BH_LENGTH < 8 then
            message = "You are hunting for "..BH_LENGTH.." Mumbo Tokens from \nthe 8 world bosses! Good Luck and"..randomEncouragment;
        elseif GOAL_TYPE == 3 and JFR_LENGTH == 9 then
            message ="You are trying to rescue all 9 Jinjo families and \nretrieve their Mumbo Tokens! Good Luck and"..randomEncouragment;
        elseif GOAL_TYPE == 3 and JFR_LENGTH < 9 then
            message = "You are trying to rescue "..JFR_LENGTH.." of the 9 Jinjo families \nand retrieve their Mumbo Tokens! Good Luck and"..randomEncouragment;
        elseif GOAL_TYPE == 4 then
            message ="You absolute mad lad! You're doing the Wonder Wing Challenge! Good Luck and"..randomEncouragment;
        elseif GOAL_TYPE == 5 and TH_LENGTH == 15 then
            message ="You are trying to find all 15 of Mumbo's Tokens scattered \nthroughout the Isle of Hags! Good Luck and"..randomEncouragment;
        elseif GOAL_TYPE == 5 and TH_LENGTH < 15 then
            message = "You are trying to find "..TH_LENGTH.." of the 15 of Mumbo Tokens \nscattered throughout the Isle of Hags! Good Luck and"..randomEncouragment;
        end
        print(message)
        table.insert(AP_MESSAGES, message);
    end
end

---------------------- MAIN LUA LOOP -------------------------

function main()
    if not checkBizHawkVersion() then
        return
    end
    mainmemory.writebyte(0x12C78D, 64); -- Skips Intro waiting
    print("Banjo-Tooie Archipelago Version " .. BT_VERSION)
    server, error = socket.bind('localhost', 21221)
    BTRAMOBJ = BTRAM:new(nil);
    BTH = BTHACK:new(nil) 
    while true do
        FRAME = FRAME + 1
        if not (CUR_STATE == PREV_STATE) then
            PREV_STATE = CUR_STATE
        end
        if (CUR_STATE == STATE_OK) or (CUR_STATE == STATE_INITIAL_CONNECTION_MADE) or (CUR_STATE == STATE_TENTATIVELY_CONNECTED) then
            if (FRAME % 30 == 1) then
                CURRENT_MAP = BTH:getMap()
                receive();
                if VERROR == true
                then
                    print("ERROR: Banjo_Tooie_connector Mismatch. Please obtain the correct version")
                    print("Connector Version: " .. BT_VERSION)
                    print("Client Version: " .. CLIENT_VERSION)
                    return
                end
            end

        elseif (CUR_STATE == STATE_UNINITIALIZED) then
            if  (FRAME % 60 == 1) then
                server:settimeout(2)
                local client, timeout = server:accept()
                if timeout == nil then
                    print('Initial Connection Made')
                    CUR_STATE = STATE_INITIAL_CONNECTION_MADE
                    BT_SOCK = client
                    BT_SOCK:settimeout(0)
                else
                    print('Connection failed, ensure Banjo Tooie Client is running, connected and rerun banjotooie_connector.lua')
                    return
                end
            end
        end
        emu.frameadvance()
    end
end

main()
