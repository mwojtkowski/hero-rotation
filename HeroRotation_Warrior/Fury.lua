--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL         = HeroLib
local Cache      = HeroCache
local Unit       = HL.Unit
local Player     = Unit.Player
local Target     = Unit.Target
local Pet        = Unit.Pet
local Spell      = HL.Spell
local MultiSpell = HL.MultiSpell
local Item       = HL.Item
-- HeroRotation
local HR         = HeroRotation

-- Azerite Essence Setup
local AE         = HL.Enum.AzeriteEssences
local AESpellIDs = HL.Enum.AzeriteEssenceSpellIDs

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Warrior then Spell.Warrior = {} end
Spell.Warrior.Fury = {
  RecklessnessBuff                      = Spell(1719),
  Recklessness                          = Spell(1719),
  FuriousSlashBuff                      = Spell(202539),
  FuriousSlash                          = Spell(100130),
  RecklessAbandon                       = Spell(202751),
  HeroicLeap                            = Spell(6544),
  Siegebreaker                          = Spell(280772),
  Rampage                               = Spell(184367),
  FrothingBerserker                     = Spell(215571),
  Carnage                               = Spell(202922),
  EnrageBuff                            = Spell(184362),
  Massacre                              = Spell(206315),
  Execute                               = MultiSpell(5308, 280735),
  Bloodthirst                           = Spell(23881),
  RagingBlow                            = Spell(85288),
  Bladestorm                            = Spell(46924),
  SiegebreakerDebuff                    = Spell(280773),
  DragonRoar                            = Spell(118000),
  Whirlwind                             = Spell(190411),
  Charge                                = Spell(100),
  FujiedasFuryBuff                      = Spell(207775),
  MeatCleaverBuff                       = Spell(85739),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  BagofTricks                           = Spell(312411),
  Pummel                                = Spell(6552),
  IntimidatingShout                     = Spell(5246),
  ColdSteelHotBlood                     = Spell(288080),
  BloodoftheEnemy                       = Spell(297108),
  MemoryofLucidDreams                   = Spell(298357),
  PurifyingBlast                        = Spell(295337),
  RippleInSpace                         = Spell(302731),
  ConcentratedFlame                     = Spell(295373),
  TheUnboundForce                       = Spell(298452),
  WorldveinResonance                    = Spell(295186),
  FocusedAzeriteBeam                    = Spell(295258),
  GuardianofAzeroth                     = Spell(295840),
  GuardianofAzerothBuff                 = Spell(295855),
  ReapingFlames                         = Spell(310690),
  ConcentratedFlameBurn                 = Spell(295368),
  RecklessForceBuff                     = Spell(302932),
  RazorCoralDebuff                      = Spell(303568),
  ConductiveInkDebuff                   = Spell(302565)
};
local S = Spell.Warrior.Fury;

-- Items
if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Fury = {
  PotionofUnbridledFury            = Item(169299),
  AshvanesRazorCoral               = Item(169311, {13, 14}),
  AzsharasFontofPower              = Item(169314, {13, 14})
};
local I = Item.Warrior.Fury;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Warrior.Commons,
  Fury = HR.GUISettings.APL.Warrior.Fury
};

-- Stuns
local StunInterrupts = {
  {S.IntimidatingShout, "Cast Intimidating Shout (Interrupt)", function () return true; end},
};

local EnemyRanges = {8}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--S.ExecuteDefault    = Spell(5308)
--S.ExecuteMassacre   = Spell(280735)

--local function UpdateExecuteID()
  --S.Execute = S.Massacre:IsAvailable() and S.ExecuteMassacre or S.ExecuteDefault
--end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Movement, SingleTarget
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  --UpdateExecuteID()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    if Everyone.TargetIsValid() then
      -- use_item,name=azsharas_font_of_power
      if I.AzsharasFontofPower:IsEquipReady() and Settings.Commons.UseTrinkets then
        if HR.Cast(I.AzsharasFontofPower, nil, Settings.Commons.TrinketDisplayStyle) then return "azsharas_font_of_power precombat"; end
      end
      -- worldvein_resonance
      if S.WorldveinResonance:IsCastableP() then
        if HR.Cast(S.WorldveinResonance, nil, Settings.Commons.EssenceDisplayStyle) then return "worldvein_resonance precombat"; end
      end
      -- memory_of_lucid_dreams
      if S.MemoryofLucidDreams:IsCastableP() then
        if HR.Cast(S.MemoryofLucidDreams, nil, Settings.Commons.EssenceDisplayStyle) then return "memory_of_lucid_dreams precombat"; end
      end
      -- guardian_of_azeroth
      if S.GuardianofAzeroth:IsCastableP() then
        if HR.Cast(S.GuardianofAzeroth, nil, Settings.Commons.EssenceDisplayStyle) then return "guardian_of_azeroth precombat"; end
      end
      -- recklessness
      if S.Recklessness:IsCastableP() then
        if HR.Cast(S.Recklessness, Settings.Fury.GCDasOffGCD.Recklessness) then return "recklessness precombat"; end
      end
      -- potion
      if I.PotionofUnbridledFury:IsReady() and Settings.Commons.UsePotions then
        if HR.CastSuggested(I.PotionofUnbridledFury) then return "potion precombat"; end
      end
    end
  end
  Movement = function()
    -- heroic_leap
    if S.HeroicLeap:IsCastableP() then
      if HR.Cast(S.HeroicLeap, Settings.Fury.GCDasOffGCD.HeroicLeap) then return "heroic_leap 16"; end
    end
  end
  SingleTarget = function()
    -- siegebreaker
    if S.Siegebreaker:IsCastableP("Melee") and HR.CDsON() then
      if HR.Cast(S.Siegebreaker, Settings.Fury.GCDasOffGCD.Siegebreaker) then return "siegebreaker 18"; end
    end
    -- rampage,if=(buff.recklessness.up|buff.memory_of_lucid_dreams.up)|(talent.frothing_berserker.enabled|talent.carnage.enabled&(buff.enrage.remains<gcd|rage>90)|talent.massacre.enabled&(buff.enrage.remains<gcd|rage>90))
    if S.Rampage:IsReadyP("Melee") and ((Player:BuffP(S.RecklessnessBuff) or Player:BuffP(S.MemoryofLucidDreams)) or (S.FrothingBerserker:IsAvailable() or S.Carnage:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90) or S.Massacre:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90))) then
      if HR.Cast(S.Rampage) then return "rampage 20"; end
    end
    -- execute
    if S.Execute:IsReady("Melee") then
      if HR.Cast(S.Execute) then return "execute 34"; end
    end
    -- furious_slash,if=!buff.bloodlust.up&buff.furious_slash.remains<3
    if S.FuriousSlash:IsCastableP() and (not Player:HasHeroism() and Player:BuffRemainsP(S.FuriousSlashBuff) < 3) then
      if HR.Cast(S.FuriousSlash) then return "furious_slash 36"; end
    end
    -- bladestorm,if=prev_gcd.1.rampage
    if S.Bladestorm:IsCastableP("Melee") and HR.CDsON() and (Player:PrevGCDP(1, S.Rampage)) then
      if HR.Cast(S.Bladestorm, Settings.Fury.GCDasOffGCD.Bladestorm) then return "bladestorm 37"; end
    end
    -- bloodthirst,if=buff.enrage.down|azerite.cold_steel_hot_blood.rank>1
    if S.Bloodthirst:IsCastableP("Melee") and (Player:BuffDownP(S.EnrageBuff) or S.ColdSteelHotBlood:AzeriteRank() > 1) then
      if HR.Cast(S.Bloodthirst) then return "bloodthirst 38"; end
    end
    -- dragon_roar,if=buff.enrage.up
    if S.DragonRoar:IsCastableP(12) and HR.CDsON() and (Player:BuffP(S.EnrageBuff)) then
      if HR.Cast(S.DragonRoar, Settings.Fury.GCDasOffGCD.DragonRoar) then return "dragon_roar 39"; end
    end
    -- raging_blow,if=charges=2
    if S.RagingBlow:IsCastableP("Melee") and (S.RagingBlow:ChargesP() == 2) then
      if HR.Cast(S.RagingBlow) then return "raging_blow 42"; end
    end
    -- bloodthirst
    if S.Bloodthirst:IsCastableP("Melee") then
      if HR.Cast(S.Bloodthirst) then return "bloodthirst 48"; end
    end
    -- raging_blow,if=talent.carnage.enabled|(talent.massacre.enabled&rage<80)|(talent.frothing_berserker.enabled&rage<90)
    if S.RagingBlow:IsCastableP("Melee") and (S.Carnage:IsAvailable() or (S.Massacre:IsAvailable() and Player:Rage() < 80) or (S.FrothingBerserker:IsAvailable() and Player:Rage() < 90)) then
      if HR.Cast(S.RagingBlow) then return "raging_blow 62"; end
    end
    -- furious_slash,if=talent.furious_slash.enabled
    if S.FuriousSlash:IsCastableP("Melee") and (S.FuriousSlash:IsAvailable()) then
      if HR.Cast(S.FuriousSlash) then return "furious_slash 70"; end
    end
    -- whirlwind
    if S.Whirlwind:IsCastableP("Melee") then
      if HR.Cast(S.Whirlwind) then return "whirlwind 74"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- charge
    if S.Charge:IsReadyP() and S.Charge:ChargesP() >= 1 then
      if HR.Cast(S.Charge, Settings.Fury.GCDasOffGCD.Charge) then return "charge 78"; end
    end
    -- Interrupts
    Everyone.Interrupt(5, S.Pummel, Settings.Commons.OffGCDasOffGCD.Pummel, StunInterrupts);
    -- run_action_list,name=movement,if=movement.distance>5
    -- heroic_leap,if=(raid_event.movement.distance>25&raid_event.movement.in>45)
    if ((not Target:IsInRange("Melee")) and Target:IsInRange(40)) then
      return Movement();
    end
    -- potion,if=buff.guardian_of_azeroth.up|(!essence.condensed_lifeforce.major&target.time_to_die=60)
    if I.PotionofUnbridledFury:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.GuardianofAzerothBuff) or (not Spell:MajorEssenceEnabled(AE.CondensedLifeForce) and Target:TimeToDie() == 60)) then
      if HR.CastSuggested(I.PotionofUnbridledFury) then return "battle_potion_of_strength 84"; end
    end
    -- rampage,if=cooldown.recklessness.remains<3
    if S.Rampage:IsReadyP("Melee") and (S.Recklessness:CooldownRemainsP() < 3) then
      if HR.Cast(S.Rampage) then return "rampage 108"; end
    end
    -- blood_of_the_enemy,if=buff.recklessness.up
    if S.BloodoftheEnemy:IsCastableP() and (Player:BuffP(S.RecklessnessBuff)) then
      if HR.Cast(S.BloodoftheEnemy, nil, Settings.Commons.EssenceDisplayStyle) then return "blood_of_the_enemy"; end
    end
    -- purifying_blast,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.PurifyingBlast:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      if HR.Cast(S.PurifyingBlast, nil, Settings.Commons.EssenceDisplayStyle) then return "purifying_blast"; end
    end
    -- ripple_in_space,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.RippleInSpace:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      if HR.Cast(S.RippleInSpace, nil, Settings.Commons.EssenceDisplayStyle) then return "ripple_in_space"; end
    end
    -- worldvein_resonance,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.WorldveinResonance:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      if HR.Cast(S.WorldveinResonance, nil, Settings.Commons.EssenceDisplayStyle) then return "worldvein_resonance"; end
    end
    -- focused_azerite_beam,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.FocusedAzeriteBeam:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      if HR.Cast(S.FocusedAzeriteBeam, nil, Settings.Commons.EssenceDisplayStyle) then return "focused_azerite_beam"; end
    end
    -- reaping_flames,if=!buff.recklessness.up&!buff.siegebreaker.up
    if S.ReapingFlames:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff)) then
      if HR.Cast(S.ReapingFlames, nil, Settings.Commons.EssenceDisplayStyle) then return "reaping_flames"; end
    end
    -- concentrated_flame,if=!buff.recklessness.up&!buff.siegebreaker.up&dot.concentrated_flame_burn.remains=0
    if S.ConcentratedFlame:IsCastableP() and (Player:BuffDownP(S.Recklessness) and Target:DebuffDownP(S.SiegebreakerDebuff) and Target:DebuffDownP(S.ConcentratedFlameBurn)) then
      if HR.Cast(S.ConcentratedFlame, nil, Settings.Commons.EssenceDisplayStyle) then return "concentrated_flame"; end
    end
    -- the_unbound_force,if=buff.reckless_force.up
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff)) then
      if HR.Cast(S.TheUnboundForce, nil, Settings.Commons.EssenceDisplayStyle) then return "the_unbound_force"; end
    end
    -- guardian_of_azeroth,if=!buff.recklessness.up&(target.time_to_die>195|target.health.pct<20)
    if S.GuardianofAzeroth:IsCastableP() and (Player:BuffDownP(S.RecklessnessBuff) and (Target:TimeToDie() > 195 or Target:HealthPercentage() < 20)) then
      if HR.Cast(S.GuardianofAzeroth, nil, Settings.Commons.EssenceDisplayStyle) then return "guardian_of_azeroth"; end
    end
    -- memory_of_lucid_dreams,if=!buff.recklessness.up
    if S.MemoryofLucidDreams:IsCastableP() and (Player:BuffDownP(S.RecklessnessBuff)) then
      if HR.Cast(S.MemoryofLucidDreams, nil, Settings.Commons.EssenceDisplayStyle) then return "memory_of_lucid_dreams"; end
    end
    -- recklessness,if=!essence.condensed_lifeforce.major&!essence.blood_of_the_enemy.major|cooldown.guardian_of_azeroth.remains>1|buff.guardian_of_azeroth.up|cooldown.blood_of_the_enemy.remains<gcd
    if S.Recklessness:IsCastableP() and HR.CDsON() and (not Spell:MajorEssenceEnabled(AE.CondensedLifeForce) and not Spell:MajorEssenceEnabled(AE.BloodoftheEnemy) or S.GuardianofAzeroth:CooldownRemainsP() > 1 or Player:BuffP(S.GuardianofAzerothBuff) or S.BloodoftheEnemy:CooldownRemainsP() < Player:GCD()) then
      if HR.Cast(S.Recklessness, Settings.Fury.GCDasOffGCD.Recklessness) then return "recklessness 112"; end
    end
    -- whirlwind,if=spell_targets.whirlwind>1&!buff.meat_cleaver.up
    if S.Whirlwind:IsCastableP("Melee") and (Cache.EnemiesCount[8] > 1 and Player:BuffDownP(S.MeatCleaverBuff)) then
      if HR.Cast(S.Whirlwind) then return "whirlwind 114"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=target.time_to_die<20|!debuff.razor_coral_debuff.up|(target.health.pct<30.1&debuff.conductive_ink_debuff.up)|(!debuff.conductive_ink_debuff.up&buff.memory_of_lucid_dreams.up|prev_gcd.2.guardian_of_azeroth|prev_gcd.2.recklessness&(buff.guardian_of_azeroth.up|!essence.memory_of_lucid_dreams.major&!essence.condensed_lifeforce.major))
    if I.AshvanesRazorCoral:IsEquipReady() and Settings.Commons.UseTrinkets and (Target:TimeToDie() < 20 or Target:DebuffDownP(S.RazorCoralDebuff) or (Target:HealthPercentage() < 30 and Target:DebuffP(S.ConductiveInkDebuff)) or (Target:DebuffDownP(S.ConductiveInkDebuff) and Player:BuffP(S.MemoryofLucidDreams) or Player:PrevGCDP(2, S.GuardianofAzeroth) or Player:PrevGCDP(2, S.Recklessness) and (Player:BuffP(S.GuardianofAzerothBuff) or not Spell:MajorEssenceEnabled(AE.MemoryofLucidDreams) and not Spell:MajorEssenceEnabled(AE.CondensedLifeForce)))) then
      if HR.Cast(I.AshvanesRazorCoral, nil, Settings.Commons.TrinketDisplayStyle) then return "ashvanes_razor_coral 115"; end
    end
    if (HR.CDsON()) then
      -- blood_fury,if=buff.recklessness.up
      if S.BloodFury:IsCastableP() and (Player:BuffP(S.RecklessnessBuff)) then
        if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 118"; end
      end
      -- berserking,if=buff.recklessness.up
      if S.Berserking:IsCastableP() and (Player:BuffP(S.RecklessnessBuff)) then
        if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 122"; end
      end
      -- lights_judgment,if=buff.recklessness.down
      if S.LightsJudgment:IsCastableP() and (Player:BuffDownP(S.RecklessnessBuff)) then
        if HR.Cast(S.LightsJudgment, Settings.Commons.OffGCDasOffGCD.Racials) then return "lights_judgment 126"; end
      end
      -- fireblood,if=buff.recklessness.up
      if S.Fireblood:IsCastableP() and (Player:BuffP(S.RecklessnessBuff)) then
        if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 130"; end
      end
      -- ancestral_call,if=buff.recklessness.up
      if S.AncestralCall:IsCastableP() and (Player:BuffP(S.RecklessnessBuff)) then
        if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 134"; end
      end
      -- bag_of_tricks,if=buff.recklessness.up
      if S.BagofTricks:IsCastableP() and (Player:BuffP(S.RecklessnessBuff)) then
        if HR.Cast(S.BagofTricks, Settings.Commons.OffGCDasOffGCD.Racials) then return "bag_of_tricks 136"; end
      end
    end
    -- run_action_list,name=single_target
    if (true) then
      return SingleTarget();
    end
  end
end

local function Init ()
  HL.RegisterNucleusAbility(46924, 8, 6)               -- Bladestorm
  HL.RegisterNucleusAbility(118000, 12, 6)             -- Dragon Roar
  HL.RegisterNucleusAbility(190411, 8, 6)              -- Whirlwind
end

HR.SetAPL(72, APL, Init)
