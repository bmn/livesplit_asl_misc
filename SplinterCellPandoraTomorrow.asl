state("SplinterCell2") {
  string20 Map:       "SNDDSound3DDLL.dll", 0x62DCC;
  int      LevelTime: "Core.dll",           0xB8F30;
  bool     Movie1:    "Core.dll",           0xBBBA8;
  bool     Movie2:    "Engine.dll",         0x2E8F68;
}

isLoading {
  return ( (current.LevelTime <= old.LevelTime) || (current.LevelTime < 3) );
}

start {
  return ( (current.Map != old.Map) && (old.Map == vars.D.Menu) && !(vars.D.EndSplit = false) );
}

reset {
  return ( (current.Map != old.Map) && (current.Map == vars.D.Menu) && !(vars.D.EndSplit = false) );
}

startup {
  vars.CurrentLevel = "";
  vars.D = new ExpandoObject();
  vars.D.EndSplit = false;
  vars.D.Menu = "0_0_0_Menu";
  vars.D.Maps = new Dictionary<string, string> {
    { "1_1_2_EMBASSY", "Dili, Timor (2)" },
    { "2_1_1_LAB", "Paris, France (1)" },
    { "2_1_2_LAB", "Paris, France (2)" },
    { "2_2_1_Train", "Paris-Nice, France" },
    { "3_1_1_MARKET", "Jerusalem, Israel (1)" },
    { "3_1_2_MARKET", "Jerusalem, Israel (2)" },
    { "3_1_3_MARKET", "Jerusalem, Israel (3)" },
    { "4_1_1_village", "Kundang Camp, Indonesia (1)" },
    { "4_1_2_village", "Kundang Camp, Indonesia (2)" },
    { "4_1_3_village", "Kundang Camp, Indonesia (3)" },
    { "4_2_1_Dock", "Komodo, Indonesia (1)" },
    { "4_2_2_Dock", "Komodo, Indonesia (2)" },
    { "4_3_1_TV", "Jakarta, Indonesia (1)" },
    { "4_3_2_TV", "Jakarta, Indonesia (2)" },
    { "5_1_1_LAX", "Los Angeles, USA (1)" },
    { "5_1_2_LAX", "Los Angeles, USA (2)" }
  };
  settings.Add("splits", true, "Split upon reaching...");
  foreach (KeyValuePair<string, string> Map in vars.D.Maps) {
    settings.Add(Map.Key, true, Map.Value, "splits");
  }
  settings.Add("split_end", true, "End of game", "splits");
}

split {
  if ( (settings["split_end"]) && (current.Map == "5_1_2_LAX") &&
    (current.Movie1) && (current.Movie2) && (!vars.D.EndSplit) ) {
    vars.D.Endsplit = true;
    return true;
  }
  if (current.Map == old.Map) return false;
  string Map = "";
  vars.D.Maps.TryGetValue(current.Map, out Map);
  vars.CurrentLevel = Map;
  if (old.Map == vars.D.Menu) return false;
  if (current.Map == vars.D.Menu) return false;
  if (!settings.ContainsKey(current.Map)) return false;
  if (!settings[current.Map]) return false;
  return true;
}