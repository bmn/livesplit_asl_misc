state("Dolphin") {}

startup {
  settings.Add("behaviour", true, " Autosplitter Behaviour");
    settings.Add("o_startonselect", true, " Start as soon as Game Start is selected", "behaviour");
    settings.SetToolTip("o_startonselect", "Experimental, for Real Time timing purposes. If you have problems with this, disable it.");
    settings.Add("o_norepeat", true, " Suppress repeats of the same split", "behaviour");
  
  settings.Add("features", true, " Other Features");
    settings.Add("debug_file", true, " Save debug information to LiveSplit program directory", "features");
    settings.SetToolTip("debug_file", "The log will be saved at mgstts.log.");
    settings.Add("debug_stdout", true, " Log debug information to Windows debug log", "features");
    settings.SetToolTip("debug_stdout", "This can be viewed in a tool such as DebugView.");
  
  settings.Add("splits", true, " Split Points");
  
  settings.Add("major", true, " Major Splits", "splits");
    settings.Add("p38", true, " Guard Encounter", "major");
    settings.Add("p48", true, " Revolver Ocelot", "major");
    settings.Add("p77", true, " M1 Tank", "major");
    settings.Add("p91", true, " Ninja", "major");
    settings.Add("p146", true, " Psycho Mantis", "major");
    settings.Add("p165", true, " Sniper Wolf 1", "major");
    settings.Add("p230", true, " Hind D", "major");
    settings.Add("p243", true, " Sniper Wolf 2", "major");
    settings.Add("p261", true, " Vulcan Raven", "major");
    settings.Add("p311", true, " Metal Gear REX", "major");
    settings.Add("p335", true, " Liquid Snake", "major");
    settings.Add("p347", true, " Escape", "major");
    settings.Add("c_score", true, " Final Time", "major");
    settings.SetToolTip("c_score", "This split occurs shortly after the final pre-credits cutscene.");
  
  settings.Add("route", true, " Full Route", "splits");
    settings.Add("p7", true, " Dock ⮞ Heliport", "route");
    settings.Add("area02a_area04a_heliport", true, " Heliport ⮞ Tank Hangar", "route");
    settings.Add("tankhangar_area05a_heliport", true, " Tank Hangar ⮞ Holding Cells", "route");
    settings.Add("p28", true, " Reached DARPA Chief in Holding Cells", "route");
    settings.Add("p36", true, " Reached Guard Encounter", "route");
    settings.Add("tankhangar_area06a_p45", true, " Holding Cells ⮞ Armory", "route");
    settings.Add("area06a_area06b_p45", true, " Armory ⮞ Armory South", "route");
    settings.Add("p46", true, " Reached Revolver Ocelot", "route");
    settings.Add("area06c_area06a_ocelot", true, " Armory South ⮞ Armory", "route");
    settings.Add("tankhangar_area07a_ocelot", true, " Armory ⮞ Tank Hangar", "route");
    settings.Add("area07a_area08a_p73", true, " Tank Hangar ⮞ Canyon", "route");
    settings.Add("p74", true, " Reached M1 Tank", "route");
    settings.Add("nukebuilding_area10a_p78", true, " Nuke Building 1F ⮞ Nuke Building B1", "route");
    settings.Add("nukebuilding_area11a_p78", true, " Nuke Building B1 ⮞ Nuke Building B2", "route");
    settings.Add("area11a_area12a_p82", true, " Nuke Building B2 ⮞ Lab Hallway", "route");
    settings.Add("p89", true, " Reached Ninja", "route");
    settings.Add("area12b_area12a_p124", true, " Lab ⮞ Lab Hallway", "route");
    settings.Add("area12a_area11a_p124", true, " Lab Hallway ⮞ Nuke Building B2", "route");
    settings.Add("nukebuilding_area10a_p124", true, " Nuke Building B2 ⮞ Nuke Building B1", "route");
    settings.Add("p125", true, " Cornered Meryl in Nuke Building B1", "route");
    settings.Add("p133", true, " Nuke Building B1 ⮞ Commander's Room", "route");
    settings.Add("p139", true, " Reached Psycho Mantis", "route");
    settings.Add("p151", true, " Commander's Room ⮞ Caves", "route");
    settings.Add("p155", true, " Caves ⮞ Underground Passage", "route");
    settings.Add("p159", true, " Ambushed by Sniper Wolf in Underground Passage", "route");
    settings.Add("area15a_area14a_p163", true, " Underground Passage ⮞ Caves", "route");
    settings.Add("area14a_area13a_p163", true, " Caves ⮞ Commander's Room", "route");
    settings.Add("area13a_area10a_p164", true, " Commander's Room ⮞ Nuke Building B1", "route");
    settings.Add("area10a_area13a_p164", true, " Nuke Building B1 ⮞ Commander's Room", "route");
    settings.Add("area13a_area14a_p164", true, " Commander's Room ⮞ Caves", "route");
    settings.Add("area14a_area15a_p164", true, " Caves ⮞ Sniper Wolf 1", "route");
    settings.Add("p166", true, " Captured by Sniper Wolf in Underground Passage", "route");
    settings.Add("p199", true, " Defeated Johnny while escaping the Medi Room", "route");
    settings.Add("area16a_area05a_capture", true, " Medi Room ⮞ Holding Cells", "route");
    settings.Add("tankhangar_area07a_capture", true, " Holding Cells ⮞ Tank Hangar", "route");
    settings.Add("area07a_area08b_capture", true, " Tank Hangar ⮞ Canyon", "route");
    settings.Add("area08b_area09a_capture", true, " Canyon ⮞ Nuke Building 1F", "route");
    settings.Add("nukebuilding_area10a_capture", true, " Nuke Building 1F ⮞ Nuke Building B1", "route");
    settings.Add("area10a_area13a_capture", true, " Nuke Building B1 ⮞ Commander's Room", "route");
    settings.Add("area13a_area14a_capture", true, " Commander's Room ⮞ Cave", "route");
    settings.Add("area14a_area15a_capture", true, " Cave ⮞ Underground Passage", "route");
    settings.Add("area15a_area17a_capture", true, " Underground Passage ⮞ Comm Tower A", "route");
    settings.Add("p210", true, " Reached Comm Tower A chase", "route");
    settings.Add("area17a_area17b_p210", true, " Comm Tower A ⮞ Comm Tower A Roof", "route");
    settings.Add("p216", true, " Comm Tower A Roof ⮞ Comm Tower A Wall", "route");
    settings.Add("p219", true, " Comm Tower A Wall ⮞ Comm Tower Corridor", "route");
    settings.Add("area17e_area18a_p222", true, " Comm Tower Corridor ⮞ Comm Tower B", "route");
    settings.Add("p225", true, " Reached Otacon in Comm Tower B", "route");
    settings.Add("area18a_area19a_p226", true, " Comm Tower B ⮞ Comm Tower B Roof", "route");
    settings.Add("p228", true, " Reached Hind D", "route");
    settings.Add("area19a_area18a_p233", true, " Comm Tower B Roof ⮞ Comm Tower B", "route");
    settings.Add("p237", true, " Reached elevator ambush in Comm Tower B", "route");
    settings.Add("p238", true, " Defeated elevator ambush in Comm Tower B", "route");
    settings.Add("p241", true, " Comm Tower B ⮞ Snowfield", "route");
    settings.Add("area20a_area21a_p245", true, " Snowfield ⮞ Blast Furnace", "route");
    settings.Add("area21a_area22a_p245", true, " Blast Furnace ⮞ Cargo Elevator Top", "route");
    settings.Add("p251", true, " Reached elevator ambush in Cargo Elevator", "route");
    settings.Add("p254", true, " Defeated elevator ambush in Cargo Elevator", "route");
    settings.Add("area22c_area22b_p254", true, " Cargo Elevator Mid ⮞ Cargo Elevator Lower", "route");
    settings.Add("p257", true, " Reached Vulcan Raven", "route");
    settings.Add("area23a_area23b_p268", true, " Warehouse ⮞ Warehouse North", "route");
    settings.Add("area23b_area24a_p268", true, " Warehouse North ⮞ Underground Base", "route");
    settings.Add("area24a_area24b_p276", true, " Underground Base ⮞ Command Room", "route");
    settings.Add("p289", true, " Picked up the PAL Key", "route");
    settings.SetToolTip("p289", "Split occurs the moment you pick up the PAL Key.");
    settings.Add("area24a_area24b_p289", true, " Underground Base ⮞ Command Room", "route");
    settings.Add("p290", true, " Entered the Normal PAL Key", "route");
    settings.Add("area24b_area24a_p291", true, " Command Room ⮞ Underground Base", "route");
    settings.Add("area24a_area24b_p291", true, " Underground Base ⮞ Command Room", "route");
    settings.Add("p292", true, " Entered the Cold PAL Key", "route");
    settings.Add("area24b_area24a_p293", true, " Command Room ⮞ Underground Base", "route");
    settings.Add("area24a_area24b_p297", true, " Underground Base ⮞ Command Room", "route");
    settings.Add("p298", true, " Entered the Hot PAL Key", "route");
    settings.Add("p303", true, " Reached Metal Gear REX", "route");
    settings.Add("p307", true, " Defeated Metal Gear REX (Phase 1)", "route");
    settings.Add("p344", true, " Reached Liquid during Escape", "route");
 
  
  vars.D = new ExpandoObject();
  var D = vars.D;
  
  D.BaseAddr = IntPtr.Zero;
  D.CompletedSplits = new Dictionary<string, bool>();
  D.DebugFileList = new List<string>();
  D.FinalTimeIter = 0;
  D.GameActive = false;
  D.GameId = null;
  D.SplitCheck = new Dictionary<string, Func<bool>>();
  D.i = 0;
  
  D.GameIds = new Dictionary<string, string>() {
    { "GGSPA4", "Europe" }, // Europe
    { "GGSJA4", "Japan" }, // Japan
    { "GGSEA4", "America" }  // USA
  };
  
  D.Addr = new Dictionary<string, Dictionary<string, int>>() {
    { "GGSPA4", new Dictionary<string, int>() { // Europe
      { "GameTime", 0x5666f4 },
      { "Location", 0x568128 },
      { "Progress", 0x567b6e },
      { "Alerts", 0x5666fe },
      { "Continues", 0x5666ec },
      { "Kills", 0x566700 },
      { "Rations", 0x567b4c },
      { "Saves", 0x5666f2 },
      { "ShotsFired", 0x5666fc },
      { "NikitaAmmo", 0x566874 },
      { "PSG1Ammo", 0x566870 },
      { "PSG1TAmmo", 0x56688e },
      { "GameStartPtr", 0x11b1454 }
    } },
    { "GGSJA4", new Dictionary<string, int>() { // Japan
      { "GameTime", 0x5a1a5c },
      { "Location", 0x5a3490 },
      { "Progress", 0x5a2ed6 },
      { "Alerts", 0x5a1a66 },
      { "Continues", 0x5a1a54 },
      { "Kills", 0x5a1a68 },
      { "Rations", 0x5a2eb4 },
      { "Saves", 0x5a1a5a },
      { "ShotsFired", 0x5a1a64 },
      { "NikitaAmmo", 0x5a1bdc },
      { "PSG1Ammo", 0x5a1bd8 },
      { "PSG1TAmmo", 0x5a1bf6 },
      { "GameStartPtr", 0x11b1454 }
    } },
    { "GGSEA4", new Dictionary<string, int>() { // USA
      { "GameTime", 0x5a1a58 },
      { "Location", 0x5a348c },
      { "Progress", 0x5a2ed2 },
      { "Alerts", 0x5a1a62 },
      { "Continues", 0x5a1a50 },
      { "Kills", 0x5a1a64 },
      { "Rations", 0x5a2eb0 },
      { "Saves", 0x5a1a56 },
      { "ShotsFired", 0x5a1a60 },
      { "NikitaAmmo", 0x5a1bd8 },
      { "PSG1Ammo", 0x5a1bd4 },
      { "PSG1TAmmo", 0x5a1bf2 },
      { "GameStartPtr", 0x11b1334 }
    } }
  };
  
  var progressSets = new Dictionary<string, short[]>() {
    { "heliport", new short[] { 18, 34 } },
    { "ocelot",   new short[] { 61, 67 } },
    { "capture",  new short[] { 188, 209 } }
  };
  D.ProgressSets = new Dictionary<short, string>();
  foreach (var p in progressSets) {
    for (short i = p.Value[0]; i <= p.Value[1]; i++) D.ProgressSets.Add(i, p.Key);
  }
  
  var locationSets = new Dictionary<string, string[]>() {
    { "tankhangar",   new string[] { "area04a", "area05a", "area06a" } },
    { "nukebuilding", new string[] { "area09a", "area10a", "area11a" } }
  };
  D.LocationSets = new Dictionary<string, string>();
  foreach (var l in locationSets) {
    foreach (var m in l.Value) D.LocationSets.Add(m, l.Key);
  }
  
  D.LookForGameMemory = (Func<Process, Process, bool>)((g, m) => {
    string gameId = null;
    
    if (D.BaseAddr != IntPtr.Zero) {
      gameId = m.ReadString((IntPtr)D.BaseAddr, 6);
      if ( (gameId != null) && (D.GameIds.ContainsKey(gameId)) ) return true;
    }
    
    foreach (var page in g.MemoryPages(true))
    {
      if ((page.RegionSize != (UIntPtr)0x2000000) || (page.Type != MemPageType.MEM_MAPPED)) continue;
      
      gameId = m.ReadString((IntPtr)page.BaseAddress, 6);
      if ( (gameId == null) || (!D.GameIds.ContainsKey(gameId)) ) continue;
      
      D.BaseAddr = page.BaseAddress;
      D.GameActive = true;
      D.GameId = gameId;
      D.Debug("Found MGS Twin Snakes (" + D.GameIds[gameId] + ") memory at " + D.BaseAddr.ToString("X"));
      return true;
    }
    
    D.GameActive = false;
    D.GameId = null;
    return false;
  });
  
  D.AddrFor = (Func<int, IntPtr>)((val) => (IntPtr)((long)D.BaseAddr + val));
  
  D.VarAddr = (Func<string, int>)((key) => D.Addr[D.GameId][key]);
  
  D.ResetVars = (Func<bool>)(() => {
    D.CompletedSplits.Clear();
    D.FinalTimeIter = 0;
    return true;
  });
}

init {
  var D = vars.D;
  D.SplitCheck.Clear();
  
  D.Debug = (Action<string>)((message) => {
    message = "[" + D.current.GameTime + "] " + message;
    if (settings["debug_file"]) D.DebugFileList.Add(message);
    if (settings["debug_stdout"]) print("[TTS-AS] " + message);
  });
  
  D.Split = (Func<string, bool>)((code) => {
    if ((settings["o_norepeat"]) && (D.CompletedSplits.ContainsKey(code))) {
      D.Debug("Repeat split for " + code + ", not splitting");
      return false;
    }
    else {
      D.Debug("Splitting for " + code);
      D.CompletedSplits.Add(code, true);
      return true;
    }
  });
  
  D.ManualSplit = (Action)(() => {
    var timerModel = new TimerModel { CurrentState = timer };
    timerModel.Split();
  });
  
  D.Read = new ExpandoObject();
  D.Read.Uint = (Func<int, uint>)((addr) => {
    uint val = memory.ReadValue<uint>((IntPtr)D.AddrFor(addr));
    return (val & 0x000000FF) << 24 |
            (val & 0x0000FF00) << 8 |
            (val & 0x00FF0000) >> 8 |
            ((uint)(val & 0xFF000000)) >> 24;
  });
  D.Read.Short = (Func<int, short>)((addr) => {
    ushort val = memory.ReadValue<ushort>((IntPtr)D.AddrFor(addr));
    return (short)((val & 0x00FF) << 8 |
            ((ushort)(val & 0xFF00)) >> 8);
  });
  D.Read.String = (Func<int, int, string>)((addr, len) => memory.ReadString((IntPtr)D.AddrFor(addr), len));
  
  var HasNikita = (Func<bool>)(() => {
    short nikita = D.Read.Short( D.VarAddr("NikitaAmmo") );
    D.Debug("Nikita ammo count: " + nikita);
    return (nikita != -1);
  });
  D.SplitCheck.Add("nukebuilding_area11a_p78", HasNikita);
  
  D.SplitCheck.Add("area16a_area05a_capture", (Func<bool>)(() => {
    if ( (settings["p199"]) && (current.Progress < 199) ) {
      if (D.Split("p199")) {
        D.ManualSplit();
        return false;
      }
    }
    return (HasNikita());
  }) );
  
  var HasPSG1 = (Func<bool>)(() => {
    short psg1 = D.Read.Short( D.VarAddr("PSG1Ammo") );
    short psg1t = D.Read.Short( D.VarAddr("PSG1TAmmo") );
    D.Debug("PSG1 ammo count: " + psg1 + " & T: " + psg1t);
    return ( (psg1 != -1) || (psg1t != -1) );
  });
  D.SplitCheck.Add("area10a_area13a_p164", HasPSG1);
  D.SplitCheck.Add("area13a_area14a_p164", HasPSG1);
  D.SplitCheck.Add("area14a_area15a_p164", HasPSG1);
}

update {
  var D = vars.D;
  D.current = current;
  D.old = old; 
  D.i++;
  
  if ((D.i % 64) == 0) {
    if ( (settings["debug_file"]) && (D.DebugFileList.Count > 0) ) {
      string DebugPath = System.IO.Path.GetDirectoryName(Application.ExecutablePath) + "\\mgstts.log";
      using(System.IO.StreamWriter stream = new System.IO.StreamWriter(DebugPath, true)) {
        stream.WriteLine(string.Join("\n", vars.D.DebugFileList));
        stream.Close();
        vars.D.DebugFileList.Clear();
      }
    }
    D.LookForGameMemory(game, memory);
  }
  
  if (!D.GameActive) {
    current.GameTime = 0;
    current.Location = "";
    current.Progress = 0;
    
    current.Alerts = 0;
    current.Continues = 0;
    current.Kills = 0;
    current.Rations = 0;
    current.Saves = 0;
    current.ShotsFired = 0;
    
    return false;
  }
  
  current.GameTime = D.Read.Uint( D.VarAddr("GameTime") );
  current.Location = D.Read.String( D.VarAddr("Location"), 7 );
  current.Progress = D.Read.Short( D.VarAddr("Progress") );

  current.Alerts = D.Read.Short( D.VarAddr("Alerts") );
  current.Continues = D.Read.Short( D.VarAddr("Continues") );
  current.Kills = D.Read.Short( D.VarAddr("Kills") );
  current.Rations = D.Read.Short( D.VarAddr("Rations") );
  current.Saves = D.Read.Short( D.VarAddr("Saves") );
  current.ShotsFired = D.Read.Short( D.VarAddr("ShotsFired") );
  
  return true;
}

gameTime {
  float msecs = ( (vars.D.GameActive) && (current.Progress >= 3) ) ?
    ((float)current.GameTime / 60 * 1000) : 0;
  return TimeSpan.FromMilliseconds(msecs);
}

isLoading {
  return true;
}

split {
  var D = vars.D;
  if (!D.GameActive) return false;
  
  if ((settings["c_score"]) && (current.Progress == 359) && (current.Location == "ending")) {
    if (current.GameTime == old.GameTime) {
      if (D.FinalTimeIter++ == 6) return true;
    }
    else D.FinalTimeIter = 0;
  }
  
  if (current.Progress != old.Progress) {
    
    string progressCode = "p" + current.Progress;
    char setting = !settings.ContainsKey(progressCode) ? '?' : (settings[progressCode] ? 'T' : 'F');
    D.Debug("Progress " + progressCode + " [" + setting + "]");
    if (settings.ContainsKey(progressCode) && (settings[progressCode]))
      return D.Split(progressCode);
    
  }
  
  if (current.Location != old.Location) {
    
    var departureAreas = new List<string>() { old.Location };
    if (D.LocationSets.ContainsKey(old.Location)) departureAreas.Add( D.LocationSets[old.Location] );
    
    var destinationAreas = new List<string>() { current.Location };
    if (D.LocationSets.ContainsKey(current.Location)) destinationAreas.Add( D.LocationSets[current.Location] );
    
    var progressCodes = new List<string>() { "p" + current.Progress };
    if (D.ProgressSets.ContainsKey(current.Progress)) progressCodes.Add( D.ProgressSets[current.Progress] );
    
    var validCodes = new List<string>();
    foreach (var dep in departureAreas) {
      foreach (var dest in destinationAreas) {
        string movement = dep + "_" + dest;
        validCodes.Add(movement);
        foreach (var prog in progressCodes)
          validCodes.Add(movement + "_" + prog);
      }
    }
    D.Debug("Location (" + string.Join(" ", validCodes) + ")");
    
    foreach (var code in validCodes) {
      if (settings.ContainsKey(code) && (settings[code])) {
        if ( (!D.SplitCheck.ContainsKey(code)) || (D.SplitCheck[code]()) ) {
          if (D.Split(code)) return true;
        }
      }
    }
    D.Debug("No match, not splitting");
    
  }
  
  return false; 
}

start {
  var D = vars.D;
  if (!D.GameActive) return false;
  
  if ( (settings["o_startonselect"]) && (current.Progress == -1) && (current.Location == "n_title") ) {
    var ptr = D.Read.Uint( D.VarAddr("GameStartPtr") );
    if (ptr != 0) {
      ptr &= 0x0fffffff;
      if ( (memory.ReadValue<byte>((IntPtr)D.AddrFor((int)ptr + 0xe3)) == 1)
        && (memory.ReadValue<byte>((IntPtr)D.AddrFor((int)ptr + 0x4f)) == 7) )
        return D.ResetVars();
    }
  }
  
  if ( (current.Progress == 3) && (old.Progress == -1) )
    return D.ResetVars();
    
  return false;
}

reset {
  var D = vars.D;
  if (!D.GameActive) return false;
  if ( ((current.Progress == -1) || (current.Progress == 0)) && (old.Progress != -1) )
    return D.ResetVars();
  return false;
}