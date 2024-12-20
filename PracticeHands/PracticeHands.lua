--- MOD_NAME: Practice Hands
--- MOD_ID: PracticeHandsMod
--- MOD_AUTHOR: [Gloompashcy]
--- MOD_DESCRIPTION: Adds Various different types of new poker hands in order to practice coding them
--- BADGE_COLOUR: A67C00
--- PREFIX: PracHands
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]

----------------------------------------------
------------MOD CODE -------------------------

--Changes to base game items and text
SMODS.Joker:take_ownership('j_four_fingers', {
		loc_txt = {
			name = "Four Fingers",
			text = {
				"All {C:attention}Flushes{}, {C:attention}Straights{}",
				"and {C:attention}Mingles{} can",
				"be made with {C:attention}4{} cards,",
				"also allows {C:attention}new hand types{}",
				"to be played",
			},
		},
}, true)

--New hand part for mingle
SMODS.PokerHandPart {
	key = 'PRTMingle',
	func = function(hand)
		local FourFing = false
		local Scards = {}
		local used_wilds = {}
		local USuits = {}
		USuits['Spades'] = 0
		USuits['Hearts'] = 0
		USuits['Clubs'] = 0
		USuits['Diamonds'] = 0
		if next(find_joker('Four Fingers')) then
			FourFing = true
			if #hand < 4 then return {} end
		elseif #hand < 5 then return {} end
		local wilds = 0
		for i = 1, #hand do
			if hand[i].ability.name == 'Wild Card' then
				wilds = wilds + 1
			end
		end
		if wilds >= #hand - 1 then
			return {} end
		for i = 1, #hand do
			if hand[i].ability.name ~= 'Wild Card' then
				for k, v in pairs(USuits) do
					if hand[i]:is_suit(k, nil, true) and v == 0 then
						table.insert(Scards, hand[i])
						USuits[k] = v + 1
						break
					end
				end
			end
		end
		for i = 1, #hand do
			if hand[i].ability.name == 'Wild Card' then
				for k, v in pairs(USuits) do
					if hand[i]:is_suit(k, nil, true) and v == 0 then
						table.insert(Scards, hand[i])
						used_wilds[#used_wilds + 1] = hand[i]
						USuits[k] = v + 1
						break
					end
				end
			end
		end
		local addwild = true
		for i = #hand, 1, -1 do
			if hand[i].ability.name == 'Wild Card' then
				if (used_wilds[1] or used_wilds[2]) == hand[i] then
					addwild = false
					break
				else
					table.insert(Scards, hand[i])
					break
				end
			end
			if hand[i].ability.name == 'Wild Card' then break end
		end
		local Nsuit = 0
		for _, v in pairs(USuits) do
			if v >= 1 then
				Nsuit = Nsuit + 1
			end
		end
		if (Nsuit >= 4) and (addwild or FourFing) then
			return { Scards }
		else return {} end
	end
}

--Flush Four hand
SMODS.PokerHand {
	key = 'Flush Four',
	chips = 100,
	mult = 10,
	l_chips = 10,
	l_mult = 5,
	above_hand = 'Four of a Kind',
	visible = false,
	example = {
		{ 'S_J',    true },
		{ 'S_J',    true },
		{ 'S_J',    true },
		{ 'S_J',    true },
		{ 'S_3',    false },
	},
	loc_txt = {
		name = "Flush Four",
		description = {
			"4 cards with the same rank and suit",
			'(Requires the "Four Fingers" joker)'
		}
	},
	evaluate = function(parts, hand)
		if next(find_joker('Four Fingers')) and next(parts._4) and next(parts._flush) then
			local _four = SMODS.merge_lists(parts._4)
			local _Flush = SMODS.merge_lists(parts._flush)
			for j = 1, #_Flush do
				if _Flush[j].ability.name ~= 'Wild Card' then
					local R_suit = SMODS.Suits[_Flush[j].base.suit]
					local SuitK = R_suit.key
					break
				end
			end
			local FlushFour = true
			for i = 1, #_four do
				FlushFour = FlushFour and (_four[i]:is_suit(SuitK, nil, true))
			end
			if FlushFour then 
				return { _Four }
			else return {} end
		end
	end,
}

--Mingle hands

SMODS.PokerHand {
	key = 'Mingle',
	chips = 50,
	mult = 5,
	l_chips = 25,
	l_mult = 4,
	visible = false,
	example = {
		{ 'S_5', true },
		{ 'C_Q', true },
		{ 'H_3', true },
		{ 'D_9', true },
		{ 'D_5', true },
	},
	loc_txt = {
		name = "Mingle",
		description = {
			"5 cards with 1 from each suit",
			"and 1 wild card"
		}
	},
	evaluate = function(parts, hand)
		if next(parts.PracHands_PRTMingle) then
			return { SMODS.merge_lists(parts.PracHands_PRTMingle) }
		end
	end
}

SMODS.PokerHand {
	key = 'STRMingle',
	chips = 110,
	mult = 9,
	l_chips = 40,
	l_mult = 4,
	visible = false,
	example = {
		{ 'S_6', true },
		{ 'C_7', true },
		{ 'H_8', true },
		{ 'D_9', true },
		{ 'D_T', true },
	},
	loc_txt = {
		name = "Straight Mingle",
		description = {
			"5 cards in a row (consecutive ranks) with",
			"1 from each suit and 1 wild card"
		}
	},
	evaluate = function(parts, hand)
		if next(parts.PracHands_PRTMingle) and next(parts._straight) then
			return { SMODS.merge_lists(parts.PracHands_PRTMingle, parts._straight) }
		end
	end
}

SMODS.PokerHand {
	key = 'VMingle',
	chips = 180,
	mult = 18,
	l_chips = 70,
	l_mult = 5,
	visible = false,
	example = {
		{ 'S_5', true },
		{ 'C_5', true },
		{ 'H_5', true },
		{ 'D_5', true },
		{ 'D_5', true },
	},
	loc_txt = {
		name = "Mingle Five",
		description = {
			"5 cards of the same rank with",
			"1 from each suit and 1 wild card"
		}
	},
	evaluate = function(parts, hand)
		if next(parts.PracHands_PRTMingle) and next(parts._5) then
			return { hand }
		end
	end
}

--Stone/Enhanced Hands (Planned)


--Consumable atlases
SMODS.Atlas { key = 'IMGPhobos', path = 'phobos.png', px = 71, py = 95 }
SMODS.Atlas { key = 'IMGOrcus', path = 'orcus.png', px = 71, py = 95 }
SMODS.Atlas { key = 'IMGHaumea', path = 'haumea.png', px = 71, py = 95 }
SMODS.Atlas { key = 'IMGMakemake', path = 'makemake.png', px = 71, py = 95 }

--New planet cards
SMODS.Consumable {
    set = 'Planet',
    key = 'P_phobos',
    config = { hand_type = 'PracHands_Flush Four', softlock = true },
    pos = {x = 0, y = 0 },
    atlas = 'IMGPhobos',
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge("Moon", get_type_colour(self or card.config, card), nil, 1.2)
    end,
    process_loc_text = function(self)
        local target_text = G.localization.descriptions[self.set]['c_mars'].text
        SMODS.Consumable.process_loc_text(self)
        G.localization.descriptions[self.set][self.key].text = target_text
    end,
    generate_ui = 0,
    loc_txt = {
            name = "Phobos"
    }
}


SMODS.Consumable {
    set = 'Planet',
    key = 'P_orcus',
    config = { hand_type = 'PracHands_Mingle', softlock = true },
    pos = {x = 0, y = 0 },
    atlas = 'IMGOrcus',
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge("Dwarf Planet?", get_type_colour(self or card.config, card), nil, 1.2)
    end,
    process_loc_text = function(self)
        local target_text = G.localization.descriptions[self.set]['c_jupiter'].text
        SMODS.Consumable.process_loc_text(self)
        G.localization.descriptions[self.set][self.key].text = target_text
    end,
    generate_ui = 0,
    loc_txt = {
            name = "Orcus"
    }
}

SMODS.Consumable {
    set = 'Planet',
    key = 'P_haumea',
    config = { hand_type = 'PracHands_STRMingle', softlock = true },
    pos = {x = 0, y = 0 },
    atlas = 'IMGHaumea',
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge("Dwarf Planet", get_type_colour(self or card.config, card), nil, 1.2)
    end,
    process_loc_text = function(self)
        local target_text = G.localization.descriptions[self.set]['c_neptune'].text
        SMODS.Consumable.process_loc_text(self)
        G.localization.descriptions[self.set][self.key].text = target_text
    end,
    generate_ui = 0,
    loc_txt = {
            name = "Haumea"
    }
}

SMODS.Consumable {
    set = 'Planet',
    key = 'P_makemake',
    config = { hand_type = 'PracHands_VMingle', softlock = true },
    pos = {x = 0, y = 0 },
    atlas = 'IMGMakemake',
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge("Dwarf Planet", get_type_colour(self or card.config, card), nil, 1.2)
    end,
    process_loc_text = function(self)
        local target_text = G.localization.descriptions[self.set]['c_eris'].text
        SMODS.Consumable.process_loc_text(self)
        G.localization.descriptions[self.set][self.key].text = target_text
    end,
    generate_ui = 0,
    loc_txt = {
            name = "Makemake"
    }
}