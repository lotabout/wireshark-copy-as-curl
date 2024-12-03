-- Wireshark Lua Plugin: Copy as cURL
-- Adds a "Copy as cURL" option to the HTTP protocol's context menu


-- How to setup
-- On Mac: put the script in ~/.config/wireshark/plugins

-- Function to extract HTTP fields and generate cURL command
local function generate_curl_command(...)
    local fields = {...};

    local headers = {};

    for i, field in ipairs( fields ) do
        if field.name == 'http.request.line' and field.value then
            if field.value:find('^Host:') == nil and
                field.value:find('^Content-Length:') == nil then
                table.insert(headers, field.value)
            end
        end
    end

    local field_map = {};
    for i, field in ipairs( fields ) do
        -- keep the first value (e.g. json.object might be overwritten by nested)
        if not field_map[field.name] then
            field_map[field.name] = field.value;
        end
    end

    local cmd_builder = {};
    table.insert(cmd_builder, 'curl -X ' .. field_map['http.request.method'] .. ' \'' .. field_map['http.host'] .. field_map['http.request.uri'] .. '\'');
    for i, header in ipairs( headers ) do
        table.insert(cmd_builder, '-H \'' .. string.gsub(header, '%s+$', '') .. '\'');
    end

    if field_map['json.object'] then
        table.insert(cmd_builder, '-d \'' .. field_map['json.object'] .. '\'');
    end

    copy_to_clipboard(table.concat(cmd_builder, ' \\\n'));
end

-- Register the menu item under HTTP protocol
register_packet_menu("Copy as cURL", generate_curl_command, 'http.request')
