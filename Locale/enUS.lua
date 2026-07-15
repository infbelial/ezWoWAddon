-- Kinda backwards but ruRU is the default loclae, because it's the only supported locale
if GetLocale() == "ruRU" then
    return
end

EZTEXT_DUNGEON_FINDER   = "Dungeon finder"
EZTEXT_RAID_FINDER      = "Raid finder"

ezWoWText = ezWoWText or {}

local T = ezWoWText

T.MENU_BUTTON_ACCOUNT               = "Account"
T.ACCOUNT_SETTINGS_HEADER           = "Account settings"
T.CONFIRM_RESET_ACCOUNT_SETTINGS    = "Do you want to reset all settings, or only the settings for this category?"

-- Information panel
T.MENU_INFO_TITLE                   = "Information"
T.MENU_INFO_SUB_TEXT                = ""
T.INFO_ACCOUNT                      = "Account: %s"
T.INFO_MUTE                         = "Chat restricitons"
T.INFO_NO_MUTE                      = "|cFF00FF00No|r"
T.INFO_SUBSCRIPTIONS                = "Subscriptions"
T.INFO_PREMIUM                      = "Premium"
T.INFO_EZPLUS                       = "EzPlus+"
T.INFO_SUB_PETS_MOUNTS_TOYS         = "Mounts, pets and toys collection"
T.INFO_SUB_TRANSMOG                 = "Transmogrification collection"
T.INFO_SUB_SKINS                    = "Skin collection"
T.INFO_SUB_ACTIVE                   = "Ends %s (%s)"
T.INFO_SUB_NOT_ACTIVE               = "|cFF808080Not active|r"
T.INFO_SUB_STATUS_DAYS              = "|cFF00FF00%u |4day:days;|r"
T.INFO_SUB_STATUS_HOURS_MINUTES     = "|cFF00FF00%u |4hour:hours; %u |4minute:minutes;|r"
T.INFO_SUB_STATUS_MINUTES_SECONDS   = "|cFF00FF00%u |4minute:minutes; %u |4second:seconds;|r"
T.INFO_SUB_STATUS_SECONDS           = "|cFF00FF00%u |4second:seconds;|r"

-- Loot options panel
T.MENU_LOOT_TITLE                   = "Loot"
T.MENU_LOOT_SUB_TEXT                = "Customize you looting experience"
T.OPT_LOOT_PARTIAL                  = "Partial Looting"
T.OPT_LOOT_PARTIAL_TOOLTIP          = "Partially loot item stacks if they don't fit into your inventory"
T.OPT_LOOT_AOE                      = "AoE Looting"
T.OPT_LOOT_AOE_TOOLTIP              = "Show loot from all nearby corpses at once"
T.OPT_LOOT_AOE_RADIUS               = "Максимальный радиус добычи с области"
T.OPT_LOOT_AOE_RADIUS_TOOLTIP       = "Increases the range of AoE looting to visibility distance"
T.OPT_LOOT_AOE_VISUAL               = "AoE Looting Visual Effect"
T.OPT_LOOT_AOE_VISUAL_TOOLTIP       = "Show an effect on all corpses that were AoE looted (visible only to you)"

-- Display options panel 
T.MENU_DISPLAY_TITLE                = "Display"
T.MENU_DISPLAY_SUB_TEXT             = "Options for displaying various nuances of the gameplay that can create viual discomfort"
T.OPT_BG_RACE_MODE                  = "Players' race on a cross-faction battleground"
T.OPT_SHOW_SHOP_SKINS               = "Show shop skins"
T.OPT_SHOW_SPECIAL_SHAPESHIFT       = "Show special druid shapeshifts"
T.OPT_SHOW_TRANSMOG                 = "Show transmogrification on other players"
T.OPT_SHOW_TRANSMOG_MIXED           = "Show transmogrification of incompatible armor types"
T.OPT_SHOW_SHECIAL_MOUNTS           = "Show expensive mounts on other players"
T.OPT_SHOW_SCALE                    = "Show modified scale on other players"
T.OPT_SHOW_NORMAL_SKINS             = "Show regular transformations on other players"
T.OPT_SHOW_GUILD_ITEM               = "Show loot items in guild"
T.OPT_SHOW_GUILD_BOSS               = "Show completed bosses in guild"
T.OPT_SHOW_AUTO_QUESTS              = "Show when an automatic quest is taken or completed"
T.BG_RACE_DONT_CHANGE               = "Do not change"
T.BG_RACE_RELATIVE_TO_ME            = "My team as my faction, enemies as opposite"
T.BG_RACE_RELATIVE_TO_BG_TEAM_EXCLUDING_ME = "Same faction as a BG team, excluding me"
T.BG_RACE_RELATIVE_TO_BG_TEAM_INCLUDING_ME = "Same faction as a BG team, including me"

-- Privacy options panel
T.MENU_PRIVACY_TITLE                = "Privacy"
T.MENU_PRIVACY_SUB_TEXT             = "Privacy settings"
T.OPT_SHOW_IN_GUILD                 = "Show in guild roster"
T.OPT_SHOW_IN_WHO                   = "Show in /who list"
T.OPT_SHOW_IN_FRIENDS               = "Show in friend lists"
T.OPT_SHOW_PRIVATE_MESSAGES         = "Show private messages (premium only):"
T.OPT_SHOW_PARTY_INVITES            = "Show invitations to group (premium only):"
T.PRIVACY_ALL                       = "From all"
T.PRIVACY_FRIENDS                   = "From firends"
T.PRIVACY_NOBODY                    = "From nobody"

-- Rate options panel
T.MENU_RATES_TITLE          = "Rates"
T.MENU_RATES_SUB_TEXT       = "By default rates are set to the maximum available value.\nIf you set a custom value it will be used even if the server rates are boosted (i.e. on weekends or you've activated premium subscrition)"
T.MENU_RATES_MAXIMUM        = "Maximum"
T.MENU_RATES_FIXED          = "Custom"
T.OPT_RATE_XP_KILL          = "XP from kills"
T.OPT_RATE_XP_QUEST         = "XP from quests"
T.OPT_RATE_REPUTATION       = "Reputation"
T.OPT_RATE_HONOR            = "Honor"


-- Collection options panel
T.MENU_COLLECTIONS_TITLE            = "Collections"
T.MENU_COLLECTIONS_SUB_TEXT         = "Options for your account collections and subscriptions"
T.OPT_SUB_MOUNTS                    = "Use mounts collections"
T.OPT_SUB_MOUNTS_TOOLTIP            = "This otion works only with the ezPlus+ subscripton or the standalone subscription (mounts)"
T.OPT_SUB_PETS                      = "Use pets collections"
T.OPT_SUB_PETS_TOOLTIP              = "This otion works only with the ezPlus+ subscripton or the standalone subscription (pets)"
T.OPT_SUB_TRANSMOG                  = "Use transmogrification collections"
T.OPT_SUB_TRANSMOG_TOOLTIP          = "This otion works only with the ezPlus+ subscripton or the standalone subscription (transmogrification)"
T.OPT_SUB_SKINS                     = "Use skins collections"
T.OPT_SUB_SKINS_TOOLTIP             = "This otion works only with the ezPlus+ subscripton or the standalone subscription (skins)"
T.OPT_SUB_TOYS                      = "Use toys collections"
T.OPT_SUB_TOYS_TOOLTIP              = "This otion works only with the ezPlus+ subscripton or the standalone subscription (toys)"
T.OPT_ACCOUNTWIDE_MOUNTS            = "Use account wide mounts"
T.OPT_ACCOUNTWIDE_MOUNTS_TOOLTIP    = "If enabled your character will have access to all available mounts from this account.\nIf disabled - only to mounts learned on this character"
T.OPT_ACCOUNTWIDE_PETS              = "Use account wide pets"
T.OPT_ACCOUNTWIDE_PETS_TOOLTIP      = "If enabled your character will have access to all available pets from this account.\nIf disabled - only to pets learned on this character"

-- Arena options panel
T.MENU_ARENA_TITLE                  = "Arena"
T.MENU_ARENA_SUB_TEXT               = "Settings for the mixed arena queue"
T.OPT_ARENA_BRACKETS                = "Participate in game modes"
T.OPT_ARENA_AGAINST_GROUPS          = "Play against groups while solo"
T.OPT_ARENA_ANNOUNCMENTS            = "Show arena queue updates"
T.BRACKETS_ALL                      = "All"
T.BRACKETS_3_2                      = "3x3, 2x2"
T.BRACKETS_3_1                      = "3x3, 1x1"
T.BRACKETS_3                        = "3x3"
T.GROUPS_ALWAYS                     = "Always"
T.GROUPS_2                          = "Only 2x2"
T.GROUPS_3                          = "Only 3x3"
T.ANNOUNCE_WHEN_IN_QUEUE            = "While in queue"
T.ANNOUNCE_ALWAYS                   = "Always"
T.ANNOUNCE_NEVER                    = "Never"

-- System messages option panel
T.MENU_SYS_MESSAGES_TITLE           = "System messages"
T.MENU_SYS_MESSAGES_SUB_TEXT        = "Do you want to display this messages in a chat window"
T.OPT_SHOW_CHAT_WARNINGS            = "Warnings recieved by other players"
T.OPT_SHOW_CHAT_MUTES               = "Mutes received by other players"
T.OPT_SHOW_BANS                     = "Bans received by other players"