from BaseClasses import Item
import typing
from .Names import itemName
from .Names import locationName


class BanjoTooieItem(Item):
    game: str = "Banjo-Tooie"
class ItemData(typing.NamedTuple):
    btid: int = 0
    qty: int = 0
    type: str = ""
    defualt_location: None | str = "" 



jinjo_table = {
    itemName.WJINJO:        ItemData(1230501, 1, "progress", None),
    itemName.OJINJO:        ItemData(1230502, 2, "progress", None),
    itemName.YJINJO:        ItemData(1230503, 3, "progress", None),
    itemName.BRJINJO:       ItemData(1230504, 4, "progress", None),
    itemName.GJINJO:        ItemData(1230505, 5, "progress", None),
    itemName.RJINJO:        ItemData(1230506, 6, "progress", None),
    itemName.BLJINJO:       ItemData(1230507, 7, "progress", None),
    itemName.PJINJO:        ItemData(1230508, 8, "progress", None),
    itemName.BKJINJO:       ItemData(1230509, 9, "progress", None)
}

jiggy_table = {
    itemName.JIGGY:         ItemData(1230515, 81, "progress", None),
}

moves_table = {
    itemName.GGRAB:         ItemData(1230753, 1, "progress", locationName.GGRAB),
    itemName.BBLASTER:      ItemData(1230754, 1, "progress", locationName.BBLASTER),
    itemName.EGGAIM:        ItemData(1230755, 1, "progress", locationName.EGGAIM),

    itemName.FEGGS:         ItemData(1230756, 1, "progress", locationName.FEGGS),

    itemName.BDRILL:        ItemData(1230757, 1, "progress", locationName.BDRILL),
    itemName.BBAYONET:      ItemData(1230758, 1, "progress", locationName.BBAYONET),

    itemName.GEGGS:         ItemData(1230759, 1, "progress", locationName.GEGGS),

    itemName.AIREAIM:       ItemData(1230760, 1, "progress", locationName.AIREAIM),
    itemName.SPLITUP:       ItemData(1230761, 1, "progress", locationName.SPLITUP),
    itemName.PACKWH:        ItemData(1230762, 1, "progress", locationName.PACKWH),
    
    itemName.IEGGS:         ItemData(1230763, 1, "progress", locationName.IEGGS),

    itemName.WWHACK:        ItemData(1230764, 1, "progress", locationName.WWHACK),
    itemName.TTORP:         ItemData(1230765, 1, "progress", locationName.TTORP),
    itemName.AUQAIM:        ItemData(1230766, 1, "progress", locationName.AUQAIM),

    itemName.CEGGS:         ItemData(1230767, 1, "progress", locationName.CEGGS),

    itemName.SPRINGB:       ItemData(1230768, 1, "progress", locationName.SPRINGB),
    itemName.TAXPACK:       ItemData(1230769, 1, "progress", locationName.TAXPACK),
    itemName.HATCH:         ItemData(1230770, 1, "progress", locationName.HATCH),

    itemName.SNPACK:        ItemData(1230771, 1, "progress", locationName.SNPACK),
    itemName.LSPRING:       ItemData(1230772, 1, "progress", locationName.LSPRING),
    itemName.CLAWBTS:       ItemData(1230773, 1, "progress", locationName.CLAWBTS),

    itemName.SHPACK:        ItemData(1230774, 1, "progress", locationName.SHPACK),
    itemName.GLIDE:         ItemData(1230775, 1, "progress", locationName.GLIDE),

    itemName.SAPACK:        ItemData(1230776, 1, "progress", locationName.SAPACK),

 #   itemName.FSWIM:         ItemData(1230777, 1, "progress", locationName.FSWIM:),
}

level_progress_table = {
    itemName.MUMBOMT:        ItemData(1230855, 1, "progress", locationName.GLOWBOMT1),
    itemName.MUMBOGM:        ItemData(1230856, 1, "progress", locationName.GLOWBOGM1),
    itemName.MUMBOWW:        ItemData(1230857, 1, "progress", locationName.GLOWBOWW1),
    itemName.MUMBOJR:        ItemData(1230858, 1, "progress", locationName.GLOWBOJR1),
    itemName.MUMBOTD:        ItemData(1230859, 1, "progress", locationName.GLOWBOTL1),
    itemName.MUMBOGI:        ItemData(1230860, 1, "progress", locationName.GLOWBOGI1),
    itemName.MUMBOHP:        ItemData(1230861, 1, "progress", locationName.GLOWBOHP1),
    itemName.MUMBOCC:        ItemData(1230862, 1, "progress", locationName.GLOWBOCC1),
    itemName.MUMBOIH:        ItemData(1230863, 1, "progress", locationName.GLOWBOIH1),

    itemName.HUMBAMT:        ItemData(1230174, 1, "progress", locationName.GLOWBOMT2),
    itemName.HUMBAGM:        ItemData(1230175, 1, "progress", locationName.GLOWBOGM2),
    itemName.HUMBAWW:        ItemData(1230176, 1, "progress", locationName.GLOWBOWW2),
    itemName.HUMBAJR:        ItemData(1230177, 1, "progress", locationName.GLOWBOJR2),
    itemName.HUMBATD:        ItemData(1230178, 1, "progress", locationName.GLOWBOTL2),
    itemName.HUMBAGI:        ItemData(1230179, 1, "progress", locationName.GLOWBOGI2),
    itemName.HUMBAHP:        ItemData(1230180, 1, "progress", locationName.GLOWBOHP2),
    itemName.HUMBACC:        ItemData(1230181, 1, "progress", locationName.GLOWBOCC2),
    itemName.HUMBAIH:        ItemData(1230182, 1, "progress", locationName.GLOWBOMEG),
}

misc_collectable_table = {
    itemName.HONEY:         ItemData(1230512, 25, "useful", None),
    itemName.PAGES:         ItemData(1230513, 25, "useful", None),
    itemName.DOUBLOON:      ItemData(1230514, 30, "progress", None),
    itemName.TREBLE:        ItemData(1230778,  9, "progress", None)
}



all_item_table = {
    **moves_table,
    **jinjo_table,
    **level_progress_table,
    **misc_collectable_table,
    **jiggy_table,

}

all_group_table = {
    'jiggy' : jiggy_table,
    'jinjo' : jinjo_table,
    'misc' : misc_collectable_table,
    'moves': moves_table,
    "magic": level_progress_table
}


