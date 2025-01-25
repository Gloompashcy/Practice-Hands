--- MOD_NAME: Practice Hands
--- MOD_ID: PracticeHandsMod
--- MOD_AUTHOR: [Gloompashcy]
--- MOD_DESCRIPTION: Adds Various different types of new poker hands in order to practice coding them
--- BADGE_COLOUR: A67C00
--- PREFIX: PracHands
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]

----------------------------------------------
------------MOD CODE -------------------------

--First Set

--Changes to base game items and text
SMODS.Joker:take_ownership('j_four_fingers', { loc_txt = {
	name = "Four Fingers",
	text = {
		"All {C:attention}Flushes{},",
		"{C:attention}Straights{} and {C:attention}Mingles{}",
		"can be made with {C:attention}4{} cards",
	},
}}, true)

--Atlases for Example cards
SMODS.Atlas{ key = 'IMGExCardshc', path = 'ExampleCards_hc.png', px = 71, py = 95 }
SMODS.Atlas{ key = 'IMGExCardslc', path = 'ExampleCards_lc.png', px = 71, py = 95 }
SMODS.Atlas{ key = 'IMGExCardsUI', path = 'ExampleCards_lc.png', px = 1, py = 1 }

-- Cards for hand examples

SMODS.Suit {
	key = 'Example',
	card_key = 'EX',
	hidden = true,

	hc_atlas = 'IMGExCardshc',
	lc_atlas = 'IMGExCardslc',

	hc_ui_atlas = 'IMGExCardsUI',
	lc_ui_atlas = 'IMGExCardsUI',

	pos = { y = 0 },
	ui_pos = { x = 0, y = 0 },

	hc_colour = HEX('000000'),
	lc_colour = HEX('000000'),

	in_pool = function(self, args)
        return false end
}

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
		local FlSuits = {}
		FlSuits['Spades'] = 0
		FlSuits['Hearts'] = 0
		FlSuits['Clubs'] = 0
		FlSuits['Diamonds'] = 0
		for i = 1, #hand do
			if hand[i].ability.name ~= 'Wild Card' then
				for k, v in pairs(FlSuits) do
					if hand[i]:is_suit(k, nil, true) then
						FlSuits[k] = v + 1
					end
				end
			end
		end
		for k, v in pairs(FlSuits) do
			if v >= 2 then return {} end
		end
		local wilds = 0
		for i = 1, #hand do
			if hand[i].ability.name == 'Wild Card' then
				wilds = wilds + 1
			end
		end
		if wilds >= #hand - 1 or wilds == 0 then
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

--Jackpot Hand Part
SMODS.PokerHandPart{
	key = 'PRTJackpot',
	func = function(hand)
		local sevcheck = 0
		local luckcheck = 0
		for i = 1, #hand do
			local sevrank = SMODS.Ranks[hand[i].base.value]
			if sevrank.key == '7' then
				sevcheck = sevcheck + 1
			end
			if hand[i].ability.name == 'Lucky Card' then
				luckcheck = luckcheck + 1
			end
		end
		if sevcheck >= 5 and luckcheck >= 5 then
			return { SMODS.merge_lists( hand ) }
		end
	end
}

--Express Straight Part
SMODS.PokerHandPart {
	key = 'PRTExpress',
	func = function(hand)
		local usedranks = {}
		for i = 1, 13 do
			usedranks[i] = 0 end
		local confirmedranks = 0
		local COMPrank = nil
		local STRrank = nil
		for i = 1, #hand do
			STRrank = SMODS.Ranks[hand[i].base.value]
			if STRrank.key == '2' then
				for j = 1, #hand do
					COMPrank = SMODS.Ranks[hand[j].base.value]
					if COMPrank.key == '3' or COMPrank.key == 'Ace' then
						return {}
					elseif COMPrank.key == '4' or COMPrank.key == 'King' then
						if usedranks[2] <= 0 then
							confirmedranks = confirmedranks + 1
							usedranks[2] = 1 end
					end
				end
			elseif STRrank.key == '3' then
				for j = 1, #hand do
					COMPrank = SMODS.Ranks[hand[j].base.value]
					if COMPrank.key == '4' or COMPrank.key == '2' then
						return {}
					elseif COMPrank.key == '5' or COMPrank.key == 'Ace' then
						if usedranks[3] <= 0 then
							confirmedranks = confirmedranks + 1
							usedranks[3] = 1 end
					end
				end
			elseif STRrank.key == '4' then
				for j = 1, #hand do
					COMPrank = SMODS.Ranks[hand[j].base.value]
					if COMPrank.key == '5' or COMPrank.key == '3' then
						return {}
					elseif COMPrank.key == '6' or COMPrank.key == '2' then
						if usedranks[4] <= 0 then
							confirmedranks = confirmedranks + 1 
							usedranks[4] = 1 end
					end
				end
			elseif STRrank.key == '5' then
				for j = 1, #hand do
					COMPrank = SMODS.Ranks[hand[j].base.value]
					if COMPrank.key == '6' or COMPrank.key == '4' then
						return {}
					elseif COMPrank.key == '7' or COMPrank.key == '3' then
						if usedranks[5] <= 0 then
							confirmedranks = confirmedranks + 1 
							usedranks[5] = 1 end
					end
				end
			elseif STRrank.key == '6' then
				for j = 1, #hand do
					COMPrank = SMODS.Ranks[hand[j].base.value]
					if COMPrank.key == '7' or COMPrank.key == '5' then
						return {}
					elseif COMPrank.key == '8' or COMPrank.key == '4' then
						if usedranks[6] <= 0 then
							confirmedranks = confirmedranks + 1
							usedranks[6] = 1 end
					end
				end
			elseif STRrank.key == '7' then
				for j = 1, #hand do
					COMPrank = SMODS.Ranks[hand[j].base.value]
					if COMPrank.key == '8' or COMPrank.key == '6' then
						return {}
					elseif COMPrank.key == '9' or COMPrank.key == '5' then
						if usedranks[7] <= 0 then
							confirmedranks = confirmedranks + 1
							usedranks[7] = 1 end
					end
				end
			elseif STRrank.key == '8' then
				for j = 1, #hand do
					COMPrank = SMODS.Ranks[hand[j].base.value]
					if COMPrank.key == '9' or COMPrank.key == '7' then
						return {}
					elseif COMPrank.key == '10' or COMPrank.key == '6' then
						if usedranks[8] <= 0 then
							confirmedranks = confirmedranks + 1
							usedranks[8] = 1 end
					end
				end
			elseif STRrank.key == '9' then
				for j = 1, #hand do
					COMPrank = SMODS.Ranks[hand[j].base.value]
					if COMPrank.key == '10' or COMPrank.key == '8' then
						return {}
					elseif COMPrank.key == 'Jack' or COMPrank.key == '7' then
						if usedranks[9] <= 0 then
							confirmedranks = confirmedranks + 1
							usedranks[9] = 1 end
					end
				end
			elseif STRrank.key == '10' then
				for j = 1, #hand do
					COMPrank = SMODS.Ranks[hand[j].base.value]
					if COMPrank.key == 'Jack' or COMPrank.key == '9' then
						return {}
					elseif COMPrank.key == 'Queen' or COMPrank.key == '8' then
						if usedranks[10] <= 0 then
							confirmedranks = confirmedranks + 1
							usedranks[10] = 1 end
					end
				end
			elseif STRrank.key == 'Jack' then
				for j = 1, #hand do
					COMPrank = SMODS.Ranks[hand[j].base.value]
					if COMPrank.key == 'Queen' or COMPrank.key == '10' then
						return {}
					elseif COMPrank.key == 'King' or COMPrank.key == '9' then
						if usedranks[11] <= 0 then
							confirmedranks = confirmedranks + 1
							usedranks[11] = 1 end
					end
				end
			elseif STRrank.key == 'Queen' then
				for j = 1, #hand do
					COMPrank = SMODS.Ranks[hand[j].base.value]
					if COMPrank.key == 'King' or COMPrank.key == 'Jack' then
						return {}
					elseif COMPrank.key == 'Ace' or COMPrank.key == '10' then
						if usedranks[12] <= 0 then
							confirmedranks = confirmedranks + 1
							usedranks[12] = 1 end
					end
				end
			elseif STRrank.key == 'King' then
				for j = 1, #hand do
					COMPrank = SMODS.Ranks[hand[j].base.value]
					if COMPrank.key == 'Ace' or COMPrank.key == 'Queen' then
						return {}
					elseif COMPrank.key == '2' or COMPrank.key == 'Jack' then
						if usedranks[13] <= 0 then
							confirmedranks = confirmedranks + 1
							usedranks[13] = 1 end
					end
				end
			elseif STRrank.key == 'Ace' then
				for j = 1, #hand do
					COMPrank = SMODS.Ranks[hand[j].base.value]
					if COMPrank.key == '2' or COMPrank.key == 'King' then
						return {}
					elseif COMPrank.key == '3' or COMPrank.key == 'Queen' then
						if usedranks[1] <= 0 then
							confirmedranks = confirmedranks + 1
							usedranks[1] = 1 end
					end
				end
			end
		end
		if confirmedranks >= 5 or (next(find_joker('Four Fingers')) and confirmedranks >= 4) then
			return { hand }
		else return {} end
	end
}

--Flush Four hand
SMODS.PokerHand {
	key = 'FlushFour',
	chips = 100,
	mult = 10,
	l_chips = 10,
	l_mult = 5,
	above_hand = 'Four of a Kind',
	visible = false,
	example = {
		{ 'S_J', true },
		{ 'S_J', true },
		{ 'S_J', true },
		{ 'S_J', true },
		{ 'S_3', false },
	},
	evaluate = function(parts, hand)
		if next(find_joker('Four Fingers')) and next(parts._4) and next(parts._flush) then
			local _FLfour = {}
			local _four = SMODS.merge_lists(parts._4)
			local _Flush = SMODS.merge_lists(parts._flush)
			for i = 1, #_four do
				for j = 1, #_Flush do
					if _Flush[j] == _four[i] then
						table.insert(_FLfour, _Flush[j])
						break
					end
				end
			end
			if #_FLfour >= 4 then
				return { _FLfour }
			else return {} end
		else return {} end
	end
}

--Mingle hands

SMODS.PokerHand {
	key = 'Mingle',
	chips = 50,
	mult = 5,
	l_chips = 25,
	l_mult = 4,
	visible = true,
	example = {
		{ 'S_5', true },
		{ 'C_Q', true },
		{ 'H_3', true },
		{ 'D_9', true },
		{ 'PracHands_EX_5', true },
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
		{ 'PracHands_EX_T', true },
		{ 'H_9', true },
		{ 'D_8', true },
		{ 'S_7', true },
		{ 'C_6', true },
	},
	evaluate = function(parts, hand)
		if next(parts.PracHands_PRTMingle) and next(parts._straight) then
			return { SMODS.merge_lists(parts.PracHands_PRTMingle, parts._straight) }
		end
	end,
	modify_display_text = function(self, scoring_hand)
		local royal = true
		for j = 1, #scoring_hand do
			local rank = SMODS.Ranks[scoring_hand[j].base.value]
			royal = royal and (rank.key == 'Ace' or rank.key == '10' or rank.face)
		end
		if royal then return self.key..'_Royal' end
	end
}

SMODS.PokerHand {
	key = 'HouseMingle',
	chips = 150,
	mult = 15,
	l_chips = 40,
	l_mult = 4,
	visible = false,
	example = {
		{ 'S_J', true },
		{ 'C_J', true },
		{ 'H_5', true },
		{ 'D_5', true },
		{ 'PracHands_EX_5', true },
	},
	evaluate = function(parts, hand)
		if next(parts._3) and #parts._2 >= 2 and next(parts.PracHands_PRTMingle) then
			return { hand }
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
		{ 'S_A', true },
		{ 'D_A', true },
		{ 'PracHands_EX_A', true },
		{ 'C_A', true },
		{ 'H_A', true },
	},
	evaluate = function(parts, hand)
		if next(parts.PracHands_PRTMingle) and next(parts._5) then
			return { hand }
		end
	end
}

--Jackpot Hand
SMODS.PokerHand {
	key = 'Jackpot',
	chips = 777,
	mult = 77,
	l_chips = 0,
	l_mult = 0,
	visible = false,
	example = {
		{ 'PracHands_EX_7', true },
		{ 'PracHands_EX_7', true },
		{ 'PracHands_EX_7', true },
		{ 'PracHands_EX_7', true },
		{ 'PracHands_EX_7', true },
	},
	evaluate = function(parts, hand)
		if next(parts.PracHands_PRTJackpot) and next(parts._5) and next(parts._flush) then
			return { SMODS.merge_lists(parts._5, parts._flush) }
		end
	end
}

--Express Straight Hands
SMODS.PokerHand {
	key = 'Express',
	chips = 45,
	mult = 6,
	l_chips = 35,
	l_mult = 3,
	visible = false,
	example = {
		{ 'C_A', true },
		{ 'S_Q', true },
		{ 'C_T', true },
		{ 'H_8', true },
		{ 'C_6', true },
	},
	evaluate = function(parts, hand)
		if next(parts._straight) and next(parts.PracHands_PRTExpress) and next(find_joker('Shortcut')) then
			return { SMODS.merge_lists(parts._straight) }
		end
	end
}

SMODS.PokerHand {
	key = 'FLExpress',
	chips = 120,
	mult = 10,
	l_chips = 55,
	l_mult = 6,
	visible = false,
	example = {
		{ 'S_J', true },
		{ 'S_9', true },
		{ 'S_7', true },
		{ 'S_5', true },
		{ 'S_3', true },
	},
	evaluate = function(parts, hand)
		if next(parts._straight) and next(parts._flush) and next(parts.PracHands_PRTExpress) and next(find_joker('Shortcut')) then
			return { SMODS.merge_lists(parts._straight, parts._flush) }
		end
	end
}

--Consumable atlases (merge into one when first hand batch completed)
SMODS.Atlas { key = 'IMGPlanets1', path = 'planetsset1.png', px = 65, py = 95 }

--New planet cards
SMODS.Consumable {
    set = 'Planet',
    key = 'P_phobos',
    config = { hand_type = 'PracHands_FlushFour', softlock = true },
    pos = {x = 0, y = 0 },
    atlas = 'IMGPlanets1',
	unlocked = true,
	discovered = false,
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge("Moon", get_type_colour(self or card.config, card), nil, 1.2)
    end,
    generate_ui = 0,
}


SMODS.Consumable {
    set = 'Planet',
    key = 'P_orcus',
    config = { hand_type = 'PracHands_Mingle', softlock = true },
    pos = {x = 1, y = 0 },
    atlas = 'IMGPlanets1',
	unlocked = true,
	discovered = false,
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge("Dwarf Planet?", get_type_colour(self or card.config, card), nil, 1.2)
    end,
    generate_ui = 0,
}

SMODS.Consumable {
    set = 'Planet',
    key = 'P_haumea',
    config = { hand_type = 'PracHands_STRMingle', softlock = true },
    pos = {x = 2, y = 0 },
    atlas = 'IMGPlanets1',
	unlocked = true,
	discovered = false,
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge("Dwarf Planet", get_type_colour(self or card.config, card), nil, 1.2)
    end,
    generate_ui = 0,
}

SMODS.Consumable {
    set = 'Planet',
    key = 'P_makemake',
    config = { hand_type = 'PracHands_VMingle', softlock = true },
    pos = {x = 3, y = 0 },
    atlas = 'IMGPlanets1',
	unlocked = true,
	discovered = false,
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge("Dwarf Planet", get_type_colour(self or card.config, card), nil, 1.2)
    end,
    generate_ui = 0,
}

SMODS.Consumable {
    set = 'Planet',
    key = 'P_pallas',
    config = { hand_type = 'PracHands_HouseMingle', softlock = true },
    pos = {x = 0, y = 1 },
    atlas = 'IMGPlanets1',
	unlocked = true,
	discovered = false,
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge("Asteriod", get_type_colour(self or card.config, card), nil, 1.2)
    end,
    generate_ui = 0,
}

SMODS.Consumable {
    set = 'Planet',
    key = 'P_titan',
    config = { hand_type = 'PracHands_Express', softlock = true },
    pos = {x = 1, y = 1 },
    atlas = 'IMGPlanets1',
	unlocked = true,
	discovered = false,
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge("Moon", get_type_colour(self or card.config, card), nil, 1.2)
    end,
    generate_ui = 0,
}
SMODS.Consumable {
    set = 'Planet',
    key = 'P_rhea',
    config = { hand_type = 'PracHands_FLExpress', softlock = true },
    pos = {x = 2, y = 1 },
    atlas = 'IMGPlanets1',
	unlocked = true,
	discovered = false,
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge("Moon", get_type_colour(self or card.config, card), nil, 1.2)
    end,
    generate_ui = 0,
}
SMODS.Consumable {
    set = 'Planet',
    key = 'P_slotmachine',
    config = { hand_type = 'PracHands_Jackpot', softlock = true },
    pos = {x = 3, y = 1 },
    atlas = 'IMGPlanets1',
	unlocked = true,
	discovered = false,
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge("Your World", get_type_colour(self or card.config, card), nil, 1.2)
    end,
    generate_ui = 0,
}





--Second Set