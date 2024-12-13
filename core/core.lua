--------------------------------------------------
--------- Incredible mod configuration -----------
--------------------------------------------------

local copy_when_highlighted
-- Blueprint will stop copying texture when highlighted (by clicking on it)
-- Remove -- in front of next line to disable this behaviour
-- copy_when_highlighted = true

local inverted_colors = false
-- Blueprint shader normally inverts sprite colors
-- Remove -- in front of next line to disable this behaviour
-- inverted_colors = false

local use_debuff_logic = true
-- Dont change sprite for debuffed jokers

local use_brainstorm_logic = true
-- Normally blueprint copying brainstorm will show sprite of joker copied by brainstorm
-- Remove -- in front of next line to disable this behaviour
-- use_brainstorm_logic = false

-- Decreasing this value makes blueprinted sprites darker, going above 0.28 is not recommended.
local lightness_offset = 0.131

-- Change coloring mode
-- 1 = linear (1 or less)
-- 2 = exponent
-- 3 = parabola
-- 4 = sin
local coloring_mode = 1

-- Change pow for exponent and parabola modes
local power = 1



--------------------------------------------------

-- Avg blueprint color
local canvas_background_color = {
    (62 + 198) / 255 / 2,
    (96 + 210) / 255 / 2,
    (212 + 252) / 255 / 2,
    0
}

-- Blueprinted border color
canvas_background_color = {
    76 / 255,
    108 / 255,
    216 / 255,
    0
}

local function process_texture_blueprint(image)
    local h, w = image:getDimensions()
    local canvas = love.graphics.newCanvas(h, w, {type = '2d', readable = true})

    love.graphics.push()
    
    
    
    local oldCanvas = love.graphics.getCanvas()
    --local old_filter1, old_filter2 = image:getFilter()
    --local old_filter11, old_filter22 = love.graphics.getDefaultFilter()
    
    -- I dont think changing filter does anything.. the image still looks blurry
    --image:setFilter("nearest", "nearest")
    --canvas:setFilter("nearest", "nearest")
    --love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setCanvas( canvas )
    love.graphics.clear(canvas_background_color)
    
    love.graphics.setColor(1, 1, 1, 1)

    G.SHADERS['blueprint_shader']:send('inverted', inverted_colors)
    G.SHADERS['blueprint_shader']:send('lightness_offset', lightness_offset)
    G.SHADERS['blueprint_shader']:send('mode', coloring_mode)
    G.SHADERS['blueprint_shader']:send('expo', power)
    love.graphics.setShader( G.SHADERS['blueprint_shader'] )
    
    -- Draw image with blueprint shader on new canvas
    love.graphics.draw( image )


    love.graphics.setShader()
    love.graphics.setCanvas(oldCanvas)
    --image:setFilter(old_filter1, old_filter2)
    --canvas:setFilter(image:getFilter())
    --love.graphics.setDefaultFilter(old_filter11, old_filter22)

    love.graphics.pop()

    --local fileData = canvas:newImageData():encode('png', 'imblueeeeeedabudeedabudai.png')

    if true then
        return love.graphics.newImage(canvas:newImageData()) --, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling}
    end

    return canvas
end

local function process_texture_brainstorm(image)
    local h, w = image:getDimensions()
    local canvas = love.graphics.newCanvas(h, w, {type = '2d', readable = true})

    love.graphics.push()
    
    
    
    local oldCanvas = love.graphics.getCanvas()
    --local old_filter1, old_filter2 = image:getFilter()
    --local old_filter11, old_filter22 = love.graphics.getDefaultFilter()
    
    -- I dont think changing filter does anything.. the image still looks blurry
    --image:setFilter("nearest", "nearest")
    --canvas:setFilter("nearest", "nearest")
    --love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setCanvas( canvas )
    love.graphics.clear(canvas_background_color)
    
    love.graphics.setColor(1, 1, 1, 1)

    G.SHADERS['brainstorm_shader']:send('inverted', inverted_colors)
    G.SHADERS['brainstorm_shader']:send('lightness_offset', lightness_offset)
    G.SHADERS['brainstorm_shader']:send('mode', coloring_mode)
    G.SHADERS['brainstorm_shader']:send('expo', power)
    love.graphics.setShader( G.SHADERS['brainstorm_shader'] )
    
    -- Draw image with brainstorm shader on new canvas
    love.graphics.draw( image )


    love.graphics.setShader()
    love.graphics.setCanvas(oldCanvas)
    --image:setFilter(old_filter1, old_filter2)
    --canvas:setFilter(image:getFilter())
    --love.graphics.setDefaultFilter(old_filter11, old_filter22)

    love.graphics.pop()

    --local fileData = canvas:newImageData():encode('png', 'imblueeeeeedabudeedabudai.png')

    if true then
        return love.graphics.newImage(canvas:newImageData()) --, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling}
    end

    return canvas
end

local function blueprint_atlas(atlas)
    local blueprinted = atlas.."_blueprinted"

    if not G.ASSET_ATLAS[blueprinted] then
        G.ASSET_ATLAS[blueprinted] = {}
        G.ASSET_ATLAS[blueprinted].blueprint = true
        G.ASSET_ATLAS[blueprinted].name = G.ASSET_ATLAS[atlas].name
        G.ASSET_ATLAS[blueprinted].type = G.ASSET_ATLAS[atlas].type
        G.ASSET_ATLAS[blueprinted].px = G.ASSET_ATLAS[atlas].px
        G.ASSET_ATLAS[blueprinted].py = G.ASSET_ATLAS[atlas].py
        G.ASSET_ATLAS[blueprinted].image = process_texture_blueprint(G.ASSET_ATLAS[atlas].image)
    end

    return G.ASSET_ATLAS[blueprinted]
end

local function brainstorm_atlas(atlas)
    local brainstormed = atlas.."_brainstormed"

    if not G.ASSET_ATLAS[brainstormed] then
        G.ASSET_ATLAS[brainstormed] = {}
        G.ASSET_ATLAS[brainstormed].brainstorm = true
        G.ASSET_ATLAS[brainstormed].name = G.ASSET_ATLAS[atlas].name
        G.ASSET_ATLAS[brainstormed].type = G.ASSET_ATLAS[atlas].type
        G.ASSET_ATLAS[brainstormed].px = G.ASSET_ATLAS[atlas].px
        G.ASSET_ATLAS[brainstormed].py = G.ASSET_ATLAS[atlas].py
        G.ASSET_ATLAS[brainstormed].image = process_texture_brainstorm(G.ASSET_ATLAS[atlas].image)
    end

    return G.ASSET_ATLAS[brainstormed]
end

local function equal_sprites(first, second)
    -- Dynamically update sprite for animated jokers & multiple blueprint copies
    return first.atlas.name == second.atlas.name and first.sprite_pos.x == second.sprite_pos.x and first.sprite_pos.y == second.sprite_pos.y
end


local function align_sprite(self, card, restore)
    if restore then
        if self.blueprint_T then
            self.T.h = self.blueprint_T.h
            self.T.w = self.blueprint_T.w
--        else
--            self.T.h = G.CARD_H
--            self.T.w = G.CARD_W
        end
        return
    end

    if not self.blueprint_T then
        self.blueprint_T = {h = self.T.h, w = self.T.w}
    end

    self.T.h = card.T.h
    self.T.w = card.T.w
    self.children.center.scale.y = card.children.center.scale.y
end

local function blueprint_sprite(blueprint, card)
    if equal_sprites(blueprint.children.center, card.children.center) then
        if card.children.floating_sprite and not equal_sprites(blueprint.children.floating_sprite, card.children.floating_sprite) then
            -- blueprinted card has floating sprite, and floating sprites aren't equal
            -- need to update!
        else
            return
        end
    end

    -- Not copying any other joker's sprite at the moment. Cache current sprite before updating
    if not blueprint.blueprint_sprite_copy then
        blueprint.blueprint_sprite_copy = blueprint.children.center
    end
    blueprint.blueprint_copy_key = card.config.center.key

    -- Make sure to remove floating sprite before applying new one
    if blueprint.children.floating_sprite then
        blueprint.children.floating_sprite:remove()
        blueprint.children.floating_sprite = nil
    end

    align_sprite(blueprint, nil, true)

    blueprint.children.center = Sprite(blueprint.T.x, blueprint.T.y, blueprint.T.w, blueprint.T.h, blueprint_atlas(card.children.center.atlas.name), card.children.center.sprite_pos)
    blueprint.children.center.states.hover = blueprint.states.hover
    blueprint.children.center.states.click = blueprint.states.click
    blueprint.children.center.states.drag = blueprint.states.drag
    blueprint.children.center.states.collide.can = false
    blueprint.children.center:set_role({major = blueprint, role_type = 'Glued', draw_major = blueprint})

    if card.children.floating_sprite then
        blueprint.children.floating_sprite = Sprite(blueprint.T.x, blueprint.T.y, blueprint.T.w, blueprint.T.h, blueprint_atlas(card.children.floating_sprite.atlas.name), card.children.floating_sprite.sprite_pos)
        blueprint.children.floating_sprite.role.draw_major = blueprint
        blueprint.children.floating_sprite.states.hover.can = false
        blueprint.children.floating_sprite.states.click.can = false
    end

    --if card.children.floating_sprite2 then
    --    blueprint.children.floating_sprite2 = Sprite(blueprint.T.x, blueprint.T.y, blueprint.T.w, blueprint.T.h, G.ASSET_ATLAS[card.children.floating_sprite2.atlas.name], card.children.floating_sprite2.sprite_pos)
    --    blueprint.children.floating_sprite2.role.draw_major = blueprint
    --    blueprint.children.floating_sprite2.states.hover.can = false
    --    blueprint.children.floating_sprite2.states.click.can = false
    --end
    align_sprite(blueprint, card)
end

local function brainstorm_sprite(brainstorm, card)
    if equal_sprites(brainstorm.children.center, card.children.center) then
        if card.children.floating_sprite and not equal_sprites(brainstorm.children.floating_sprite, card.children.floating_sprite) then
            -- blueprinted card has floating sprite, and floating sprites aren't equal
            -- need to update!
        else
            return
        end
    end

    -- Not copying any other joker's sprite at the moment. Cache current sprite before updating
    if not brainstorm.blueprint_sprite_copy then
        brainstorm.blueprint_sprite_copy = brainstorm.children.center
    end
    brainstorm.blueprint_copy_key = card.config.center.key

    -- Make sure to remove floating sprite before applying new one
    if brainstorm.children.floating_sprite then
        brainstorm.children.floating_sprite:remove()
        brainstorm.children.floating_sprite = nil
    end

    align_sprite(brainstorm, nil, true)

    brainstorm.children.center = Sprite(brainstorm.T.x, brainstorm.T.y, brainstorm.T.w, brainstorm.T.h, brainstorm_atlas(card.children.center.atlas.name), card.children.center.sprite_pos)
    brainstorm.children.center.states.hover = brainstorm.states.hover
    brainstorm.children.center.states.click = brainstorm.states.click
    brainstorm.children.center.states.drag = brainstorm.states.drag
    brainstorm.children.center.states.collide.can = false
    brainstorm.children.center:set_role({major = brainstorm, role_type = 'Glued', draw_major = brainstorm})

    if card.children.floating_sprite then
        brainstorm.children.floating_sprite = Sprite(brainstorm.T.x, brainstorm.T.y, brainstorm.T.w, brainstorm.T.h, brainstorm_atlas(card.children.floating_sprite.atlas.name), card.children.floating_sprite.sprite_pos)
        brainstorm.children.floating_sprite.role.draw_major = brainstorm
        brainstorm.children.floating_sprite.states.hover.can = false
        brainstorm.children.floating_sprite.states.click.can = false
    end

    --if card.children.floating_sprite2 then
    --    blueprint.children.floating_sprite2 = Sprite(blueprint.T.x, blueprint.T.y, blueprint.T.w, blueprint.T.h, G.ASSET_ATLAS[card.children.floating_sprite2.atlas.name], card.children.floating_sprite2.sprite_pos)
    --    blueprint.children.floating_sprite2.role.draw_major = blueprint
    --    blueprint.children.floating_sprite2.states.hover.can = false
    --    blueprint.children.floating_sprite2.states.click.can = false
    --end
    align_sprite(brainstorm, card)
end

local function restore_sprite(blueprint)
    if not blueprint.blueprint_sprite_copy then
        return
    end

    blueprint.children.center:remove()
    blueprint.children.center = blueprint.blueprint_sprite_copy
    blueprint.blueprint_sprite_copy = nil
    blueprint.blueprint_copy_key = nil

    if blueprint.children.floating_sprite then
        blueprint.children.floating_sprite:remove()
        blueprint.children.floating_sprite = nil
    end

    --if blueprint.children.floating_sprite2 then
    --    blueprint.children.floating_sprite2:remove()
    --    blueprint.children.floating_sprite2 = nil
    --end

    align_sprite(blueprint, nil, true)
end

local function is_blueprint(card)
    return card and card.config and card.config.center and card.config.center.key == 'j_blueprint'
end

local function is_brainstorm(card)
    return card and card.config and card.config.center and card.config.center.key == 'j_brainstorm'
end

-- mapping from index in G.jokers.cards to the index in G.jokers.cards to display
-- an example with blueprint at index 2 would be [1, 3, 3, 4, 5]
-- an example with a blueprint and brainstorm at indices 3 and 4 would be [1, 2, 1, 4, 5] if use_brainstorm_logic is true
-- use_brainstorm_logic determines whether or not brainstorms are followed
local function create_joker_mapping(joker_cards)
    local mapping = {}
    for i = 1, #joker_cards do
        local j = i
        -- step through blueprints until the end of the jokers, a debuffed joker, or a non-blueprint is met
        while true do
            if j > #joker_cards or joker_cards[j].debuff or not joker_cards[j].config.center.blueprint_compat then
                j = i
                break
            end
            if not is_blueprint(joker_cards[j]) then
                break
            end
            j = j + 1
        end
        -- brainstorm step
        if is_brainstorm(joker_cards[j]) then
            j = 1
        end
        -- step through blueprints again in the same way
        while true do
            if j > #joker_cards or joker_cards[j].debuff or not joker_cards[j].config.center.blueprint_compat then
                j = i
                break
            end
            if not is_blueprint(joker_cards[j]) then
                break
            end
            j = j + 1
        end
        -- if a brainstorm has been reached here, we're in an infinite loop of blueprints and brainstorms
        if is_brainstorm(joker_cards[j]) then
            j = i
        end
        table.insert(mapping, j)
    end
    return mapping
end

return function ()


local sprite_reset = Sprite.reset
function Sprite:reset()
    if self.atlas.blueprint then
        if type(self.atlas.release) == "function" then
            self.atlas:release()
        end
        self.atlas = blueprint_atlas(self.atlas.name)
        self:set_sprite_pos(self.sprite_pos)
        return
    end
    
    return sprite_reset(self)
end


local cardarea_align_cards = CardArea.align_cards
function CardArea:align_cards()
    local ret = cardarea_align_cards(self)

    if self ~= G.jokers then return ret end

    local joker_mapping = create_joker_mapping(G.jokers.cards)
    
    for original_index, mapped_to_index in pairs(joker_mapping) do
        if original_index ~= mapped_to_index then
            if is_blueprint(G.jokers.cards[original_index]) then
                blueprint_sprite(G.jokers.cards[original_index], G.jokers.cards[mapped_to_index])
            end
            if is_brainstorm(G.jokers.cards[original_index]) then
                brainstorm_sprite(G.jokers.cards[original_index], G.jokers.cards[mapped_to_index])
            end
        else
            restore_sprite(G.jokers.cards[original_index])
        end
    end


    return ret
end





end
