
-- Return path to .ogg file or empty string.
local function dataPathSound(lang, basename)
    local soundFile = "sound/"..codename.."/"..lang.."/"..basename..".ogg"
    if not file_exists(soundFile) then
        soundFile = ""
    end
    return soundFile
end

local DialogState = {
    DEFAULT_LANG = "",
    lang = "",
    name = "",
    font = "",
    dialogs = {},
}

-- Loads localized dialogs from prefix.."dialogs_*.lua"
function dialogLoad(prefix)
    -- NOTE: uses select_lang.lua to determine avaiable languages
    local langs = {}
    local oldfunc = select_addFlag
    function select_addFlag(lang, flag)
        table.insert(langs, lang)
    end
    file_include("script/select_lang.lua")
    select_addFlag = oldfunc

    for key, lang in pairs(langs) do
        local dialogFile = prefix.."dialogs_"..lang..".lua"
        if file_exists(dialogFile) then
            if "" == DialogState.DEFAULT_LANG then
                DialogState.DEFAULT_LANG = lang
            end
            DialogState.lang = lang
            file_include(dialogFile)
        else
            if string.len(lang) <= 2 then
                print(string.format("DEBUG: missing translation"..
                    "; lang=%q; file=%q", lang, dialogFile))
            end
        end
    end
end

--- Prepares localized dialog and checks for consistency.
-- @param dialogName dialog codename
-- @param fontName font codename (e.g. font_elk, font_parrot, ...)
-- @param defaultSubtitle prime subtitle to translate
function dialogId(dialogName, fontName, defaultSubtitle)
    DialogState.name = dialogName
    DialogState.font = fontName
    local primeDialog = DialogState.dialogs[dialogName]
    if not primeDialog then
        if DialogState.lang == DialogState.DEFAULT_LANG then
            dialogStr(defaultSubtitle)
            DialogState.dialogs[dialogName] = {
                font = fontName,
                subtitle = defaultSubtitle,
            }
        else
            print(string.format("WARNING: extra foreign dialog"..
                "; lang=%q; name=%q; subtitle=%q",
                DialogState.lang, dialogName, defaultSubtitle or ""))
        end
    else
        if primeDialog.font ~= fontName then
            print(string.format("WARNING: bad font for foreign dialog"..
                "; lang=%q; name=%q; primeFont=%q; font=%q",
                DialogState.lang, dialogName,
                primeDialog.font or "", fontName or ""))
        end
        if primeDialog.subtitle ~= defaultSubtitle then
            print(string.format(
                "WARNING: bad defaultSubtitle for foreign dialog"..
                "; lang=%q; name=%q; primeSubtitle=%q; defaultSubtitle=%q",
                DialogState.lang, dialogName,
                primeDialog.subtitle or "", defaultSubtitle or ""))
        end
    end
end

--- Defines text for localizated dialog
-- @param subtitle localized text
function dialogStr(subtitle)
    dialog_addDialog(DialogState.name, DialogState.lang,
        dataPathSound(DialogState.lang, DialogState.name),
        DialogState.font, subtitle)
end

