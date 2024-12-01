from dataclasses import dataclass
from Options import Toggle, DeathLink, PerGameCommonOptions, Choice, DefaultOnToggle, Range, StartInventoryPool, FreeText

class EnableMultiWorldMoveList(DefaultOnToggle):
    """Jamjars & Roysten Movelist are locked between the MultiWorld. Other players need to unlock Banjo's Moves."""
    display_name = "Jamjars' Movelist"

class JamjarsSiloCosts(Choice):
    """Change how many notes it takes to use Jamjars' move silos. Requires Jamjars' movelist to be changed."""
    display_name = "Jamjars' Silo Costs"
    option_vanilla = 0
    option_randomize = 1
    option_progressive = 2
    default = 0

class EnableMultiWorldBKMoveList(Choice):
    """Banjo-Kazooie's Movelist is locked between the MultiWorld. Other players need to unlock Banjo's Moves.
    Mcjiggy Special - No Talon Trot and Tall Jump in the Pool """
    display_name = "BK Original Movelist"
    option_none = 0
    option_mcjiggy_special = 1
    option_all = 2
    default = 0

class ProgressiveBeakBuster(Toggle):
    """Beak Buster to Bill Drill. Randomize Moves and Randomize BK Moves are required."""
    display_name = "Progressive Beak Buster"

class EggsBehaviour(Choice):
    """Change the way Eggs work in Banjo-Tooie. Randomize Moves and Randomize BK Moves are required."""
    display_name = "Banjo-Tooie Eggs"
    option_start_with_blue_eggs = 0
    option_random_starting_egg = 1
    option_progressive_eggs = 2
    default = 0

class ProgressiveShoes(Toggle):
    """Stilt Stride to Turbo Trainers to Spring Boots to Claw Climber Boots. Randomize Moves and Randomize BK Moves are required."""
    display_name = "Progressive Kazooie Shoes"

class ProgressiveSwimming(Toggle):
    """Dive to Double Air to Faster Swimming. Randomize Moves and Randomize BK Moves are required."""
    display_name = "Progressive Water Training"

class ProgressiveBashAttack(Toggle):
    """Ground Rat-a-tat Rap to Breegull Bash. Randomize Stop N Swap and Randomize BK Moves are required"""
    display_name = "Progressive Bash Attack"

class EnableCheatoRewards(DefaultOnToggle):
    """Cheato rewards you with a cheat and an additional randomized reward. Use Cheato Pages as Filler cannot be set if this is enabled."""
    display_name = "Cheato Rewards"

class ActivateOverlayText(DefaultOnToggle):
    """Activates the overlay text on screen. Useful if you are not streaming/viewing the BT_Client."""
    display_name = "Activate Overlay Text"

class OverlayTextColour(Choice):
    """Choose which colour the overlay text should display."""
    display_name = "Text Overlay Colour"
    option_chilli_billi = 0
    option_chilly_willy = 1
    default = 0

class EnableMultiWorldJinjos(DefaultOnToggle):
    """Jinjos have fled to other worlds. Other players need to return them home."""
    display_name = "Randomize Jinjos"

class EnableMultiWorldDoubloons(Toggle):
    """Jolly Roger's Doubloons are scattered across the MultiWorld."""
    display_name = "Randomize Doubloons"

class EnableMultiWorldCheatoPages(DefaultOnToggle):
    """Cheato pages are scattered across the MultiWorld."""
    display_name = "Randomize Cheato Pages"

class SetMultiWorldCheatoPagesFiller(Toggle):
    """If Cheato pages are scattered, sets Cheato Items as filler."""
    display_name = "Use Cheato Pages as Filler"

class EnableMultiWorldHoneycombs(DefaultOnToggle):
    """Honeycombs are scattered across the MultiWorld."""
    display_name = "Randomize Honeycombs"

class EnableHoneyBRewards(DefaultOnToggle):
    """Honey B gives you health and an additional randomized reward."""
    display_name = "Honey B Rewards"

class EnableMultiWorldGlowbos(DefaultOnToggle):
    """Glowbos are scattered across the MultiWorld."""
    display_name = "Randomize Glowbos"

class EnableMultiWorldTrebleClefs(DefaultOnToggle):
    """Treble Clefs are scattered across the MultiWorld."""
    display_name = "Randomize Treble Clefs"

class EnableMultiWorldTrainStationSwitches(Toggle):
    """Train Stations are scattered across the MultiWorld."""
    display_name = "Randomize Train Station Switches"

class EnableMultiWorldChuffyTrain(Toggle):
    """Chuffy is lost somewhere in the MultiWorld."""
    display_name = "Chuffy as a randomized AP Item"

class EnableMultiWorldNotes(Toggle):
    """Note Nests are scattered across the MultiWorld."""
    display_name = "Randomize Note Nests"

class BassclefNotes(Range):
    """Convert some 5 notes into Bassclefs (10 notes). How many notes do you want converted?
       Be aware that 1 bassclef removes two 5 notes and adds an additional Big-O-Pants."""
    display_name = "Bassclefs (10 notes) Amount"
    range_start = 0
    range_end = 30
    default = 0

class TrebleclefNotes(Range):
    """Convert some 5 notes into Trebleclefs (20 notes). How many notes do you want converted?
       Be aware that 1 Trebleclef removes four 5 notes and adds three additional Big-O-Pants."""
    display_name = "Add additional Trebleclefs (20 notes) Amount"
    range_start = 0
    range_end = 21
    default = 0

class EnableMultiWorldDinoRoar(Toggle):
    """Baby T-Rex Roar is lost across the MultiWorld. Other players need to help him learn to ROAR!"""
    display_name = "Baby T-Rex Roar"

class KingJingalingHasJiggy(DefaultOnToggle):
    """King Jingaling will always have a Jiggy for you."""
    display_name = "King Jingaling Jiggy"

class SkipPuzzles(DefaultOnToggle):
    """Open world entrances without having to go to Jiggywiggy."""
    display_name = "Skip Puzzles"

class Backdoors(Toggle):
    """Opens many one way switches on game start, allowing for more backdoor access to levels.
    The following gates are preopened: MT>TDL, MT>HFP, GGM>WW, WW>TDL
    For MT>TDL only the gate accessed from TDL's side is opened and for GGM>WW the boulders are still unexploded
    The bridge from HFPs entrance is pre-moved to allow secondary access to clifftop
    George is also pre-dropped to make HFP>JRL more accessible"""
    display_name = "Open Backdoors"

class OpenHag1(DefaultOnToggle):
    """HAG 1 boss fight is opened when Cauldron Keep is opened. Only 55 jiggies are needed to win."""
    display_name = "HAG 1 Open"

class RandomizeWorlds(Toggle):
    """Worlds will open in a randomized order. Randomized Moves and Puzzle Skip Required."""
    display_name = "Randomize Worlds"

class RandomizeWorldZones(Toggle):
    """World Entrances will warp you to a different world. This does not affect Chuffy."""
    display_name = "Randomize World Entrances"

class RandomizeStopnSwap(Toggle):
    """Mystery Eggs, their rewards, and the Ice Key are scattered across the MultiWorld."""
    display_name = "Randomize Stop n Swap"

class SkipToT(Choice):
    """Choose whether to play the full quiz, start at round 3, or skip it."""
    display_name = "Tower of Tragedy Quiz"
    option_full = 0
    option_skip = 1
    option_round_3 = 2
    default = 1

class LogicType(Choice):
    """Choose your logic difficulty and difficulty of tricks you are expected to perform to reach certain areas."""
    display_name = "Logic Type"
    option_intended = 0
    option_easy_tricks = 1
    option_hard_tricks = 2
    option_glitches = 3
    default = 0

class Silos(Choice):
    """Choose if you want IoH Silos to be closed, randomly open 1 or enable all. If you enabled Randomized Worlds with BK Moves randomized and
       silos set to none, it will be enforced to one."""
    display_name = "Open Silos"
    option_none = 0
    option_one = 1
    option_all = 2
    default = 0

class SpeedUpMinigames(DefaultOnToggle):
    """Start 3-round minigames at Round 3."""
    display_name = "Speed Up Minigames"

class VictoryCondition(Choice):
    """Choose which victory condition you want
    HAG1: Unlock the HAG1 fight and defeat Gruntilda
    Minigame Hunt: Clear the 14 minigames and the final Canary Mary race in Cloud Cuckcoo Land to collect Mumbo Tokens
    Boss Hunt: Kill the 8 world bosses and collect their Mumbo Tokens
    Jinjo Family Rescue: Rescue Jinjo Families to collect their prized Mumbo Tokens
    Wonderwing Challenge: Collect all 32 Mumbo Tokens across all boss fights, mini games and every Jinjo family
        to gain access to HAG1 and Defeat Grunty. The Ultimate Banjo Tooie experience!!
    Token Hunt: Mumbo's Tokens are scattered around the world. Help him find them"""
    display_name = "Victory Condition"
    option_hag1 = 0
    option_minigame_hunt = 1
    option_boss_hunt = 2
    option_jinjo_family_rescue = 3
    option_wonder_wing_challenge = 4
    option_token_hunt = 5
    default = 0

class MinigameHuntLength(Range):
    """How many Mumbo Tokens are needed to clear the Minigame Hunt.
    Choose a value between 1 and 15"""
    display_name = "Minigame Hunt Length"
    range_start = 1
    range_end = 15
    default = 14

class BossHuntLength(Range):
    """How many Mumbo Tokens are needed to clear the Boss Hunt.
    Choose a value between 1 and 8"""
    display_name = "Boss Hunt Length"
    range_start = 1
    range_end = 8
    default = 8

class JinjoFamilyRescueLength(Range):
    """How many Jinjo families' Mumbo Tokens are needed to clear the Jinjo family rescue.
    Choose a value between 1 and 9."""
    display_name = "Jinjo Family Rescue Length"
    range_start = 1
    range_end = 9
    default = 9

class TokenHuntLength(Range):
    """How many Mumbo Tokens of the 15 hidden throughout the world do you need to find.
    Choose a value between 1 and 15."""
    display_name = "Token Hunt Length"
    range_start = 1
    range_end = 15
    default = 5

class GameLength(Choice):
    """Choose how quickly the worlds open between each over.
    quick: Worlds opens at 1, 3, 6, 10, 15, 21, 28, 36, and 44 Jiggys
    normal: Worlds opens at 1, 4, 8, 14, 20, 28, 36, 45, and 55 Jiggys
    long: Worlds opens at 1, 8, 16, 25, 34, 43, 52, 61, and 70 Jiggys
    custom: You pick when they open
    """
    display_name = "World Requirements"
    option_quick = 0 
    option_normal = 1
    option_long = 2
    option_custom = 3
    option_randomize = 4
    default = 1

class CustomWorlds(FreeText):
    """Enter a list of jiggy requirements you want for each world unlock. Max values of each world are: 1,20,30,40,50,60,70,80,90"""
    display_name = "Enter your custom world jiggy requirement list"
    default = "1,4,8,14,20,28,36,45,55"


class SkipKlungo(Toggle):
    """Make it so you can skip Klungo 1 and 2."""
    display_name = "Skip Klungo"

@dataclass
class BanjoTooieOptions(PerGameCommonOptions):
    start_inventory_from_pool: StartInventoryPool
    death_link: DeathLink
    activate_overlay_text:ActivateOverlayText
    overlay_text_colour:OverlayTextColour
    randomize_moves: EnableMultiWorldMoveList
    jamjars_silo_costs: JamjarsSiloCosts
    randomize_bk_moves: EnableMultiWorldBKMoveList
    progressive_beak_buster: ProgressiveBeakBuster
    egg_behaviour:EggsBehaviour
    progressive_shoes: ProgressiveShoes
    progressive_water_training: ProgressiveSwimming
    progressive_bash_attack: ProgressiveBashAttack
    randomize_jinjos: EnableMultiWorldJinjos
    randomize_doubloons: EnableMultiWorldDoubloons
    randomize_cheato: EnableMultiWorldCheatoPages
    cheato_rewards: EnableCheatoRewards
    cheato_as_filler: SetMultiWorldCheatoPagesFiller
    randomize_honeycombs: EnableMultiWorldHoneycombs
    honeyb_rewards: EnableHoneyBRewards
    randomize_glowbos: EnableMultiWorldGlowbos
    randomize_treble: EnableMultiWorldTrebleClefs
    randomize_stations: EnableMultiWorldTrainStationSwitches
    randomize_chuffy: EnableMultiWorldChuffyTrain
    randomize_notes: EnableMultiWorldNotes
    bassclef_amount: BassclefNotes
    extra_trebleclefs_count: TrebleclefNotes
    randomize_stop_n_swap: RandomizeStopnSwap
    randomize_dino_roar: EnableMultiWorldDinoRoar
    jingaling_jiggy: KingJingalingHasJiggy
    skip_puzzles: SkipPuzzles
    backdoors:Backdoors
    skip_klungo: SkipKlungo
    skip_tower_of_tragedy: SkipToT
    speed_up_minigames: SpeedUpMinigames
    logic_type: LogicType
    victory_condition: VictoryCondition
    minigame_hunt_length: MinigameHuntLength
    boss_hunt_length: BossHuntLength
    jinjo_family_rescue_length: JinjoFamilyRescueLength
    token_hunt_length: TokenHuntLength
    randomize_worlds: RandomizeWorlds
    randomize_world_loading_zone: RandomizeWorldZones
    open_silos: Silos
    game_length: GameLength
    open_hag1: OpenHag1
    custom_worlds:CustomWorlds
