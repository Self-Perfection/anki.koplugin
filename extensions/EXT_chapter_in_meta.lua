local conf = require("anki_configuration")

-- Rebuilds the metadata field so it holds the full document hierarchy,
-- ordered from broadest to most specific:
--   Author - Title - <ToC level 1> - ... - <ToC level N> (page/total)
-- All nested table-of-contents levels for the current page are included,
-- not just the deepest one.
local ChapterInMeta = {
    description = "Stores the full chapter hierarchy (every table-of-contents level for the current page) in the metadata field, ordered from book down to the current section.",
    -- separator placed between the hierarchy parts
    separator = " - ",
}

function ChapterInMeta:run(note)
    local meta_field = conf.meta_field:get_value()
    if not meta_field then
        return note -- no metadata field configured, nothing to write
    end
    -- ui/toc/document/view are only present when reading a document
    if not (self.ui and self.ui.toc and self.ui.view and self.ui.document) then
        return note
    end
    local meta = self.ui.document._anki_metadata
    if not meta then
        return note
    end

    local parts = { meta.author, meta.title }
    local pageno = self.ui.view.state.page or self.ui:getCurrentPage()
    if pageno then
        -- getFullTocTitleByPage returns all nested levels for the page, ordered
        -- from the outermost (e.g. part) to the innermost (e.g. section)
        for _, level in ipairs(self.ui.toc:getFullTocTitleByPage(pageno)) do
            table.insert(parts, level)
        end
    end

    note.fields[meta_field] = string.format("%s (%d/%d)", table.concat(parts, self.separator), meta:current_page(), meta.pages())
    return note
end

return ChapterInMeta
