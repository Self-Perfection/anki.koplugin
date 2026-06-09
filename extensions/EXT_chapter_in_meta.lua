local conf = require("anki_configuration")

local ChapterInMeta = {
    description = "Appends the current chapter title (from the table of contents) to the metadata field.",
    -- how the chapter is appended to the existing metadata; %s is replaced with the chapter title
    template = " - %s",
}

function ChapterInMeta:run(note)
    local meta_field = conf.meta_field:get_value()
    if not meta_field then
        return note -- no metadata field configured, nothing to append to
    end
    -- ui/toc are only present when reading a document
    if not (self.ui and self.ui.toc and self.ui.view) then
        return note
    end
    local pageno = self.ui.view.state.page or self.ui:getCurrentPage()
    local chapter = pageno and self.ui.toc:getTocTitleByPage(pageno) or ""
    if chapter and #chapter > 0 then
        local current = note.fields[meta_field] or ""
        note.fields[meta_field] = current .. self.template:format(chapter)
    end
    return note
end

return ChapterInMeta
