local conf = require("anki_configuration")

local BlockquoteContext = {
    description = "Wraps the sentence context in a <blockquote> element before the note is sent to Anki.",
    -- HTML the context is wrapped in; %s is replaced with the extracted context
    template = "<blockquote>\n  %s\n</blockquote>",
}

function BlockquoteContext:run(note)
    local context_field = conf.context_field:get_value()
    if not context_field then
        return note -- no context field configured, nothing to do
    end
    local context = note.fields[context_field]
    if context and #context > 0 then
        note.fields[context_field] = self.template:format(context)
    end
    return note
end

return BlockquoteContext
