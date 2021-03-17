state("Dolphin") {}

startup {
  settings.Add("settings", true, "Settings");
  settings.Add("o_startonselect", true, "Start as soon as Game Start is selected", "settings");
  settings.SetToolTip("o_startonselect", "Experimental, for Real Time timing purposes. If you have problems with this, disable it.");
  
  settings.Add("splits", true, "Major Splits");
  settings.Add("p38", true, "Guard Encounter", "splits");
  settings.Add("p48", true, "Revolver Ocelot", "splits");
  settings.Add("p77", true, "M1 Tank", "splits");
  settings.Add("p91", true, "Ninja", "splits");
  settings.Add("p146", true, "Psycho Mantis", "splits");
  settings.Add("p165", true, "Sniper Wolf 1", "splits");
  settings.Add("p230", true, "Hind D", "splits");
  settings.Add("p243", true, "Sniper Wolf 2", "splits");
  settings.Add("p261", true, "Vulcan Raven", "splits");
  settings.Add("p311", true, "Metal Gear REX", "splits");
  settings.Add("p335", true, "Liquid Snake", "splits");
  settings.Add("p347", true, "Escape", "splits");
  settings.Add("c_score", true, "Final Time", "splits");
  settings.SetToolTip("c_score", "This split occurs shortly after the final pre-credits cutscene");
  
  settings.Add("minor", true, "Minor Splits");
  settings.Add("p7", false, "[Dock] Reached the elevator", "minor");
  settings.Add("p28", false, "[Holding Cell] Reached Darpa Chief", "minor");
  settings.Add("p36", false, "[Holding Cell] Reached Guard Encounter", "minor");
  settings.Add("p46", false, "[Armory South] Reached Revolver Ocelot", "minor");
  settings.Add("p74", false, "[Canyon] Reached M1 Tank", "minor");
  settings.Add("p89", false, "[Nuke Building B2] Reached Ninja", "minor");
  settings.Add("p125", false, "[Nuke Building B1] Cornered Meryl", "minor");
  settings.Add("p139", false, "[Commander's Room] Reached Psycho Mantis", "minor");
  settings.Add("p159", false, "[Underground Passage] Reached Sniper Wolf ambush", "minor");
  settings.Add("c_reachwolf1", false, "[Underground Passage] Reached Sniper Wolf 1", "minor");
  settings.Add("p166", false, "[Underground Passage] Got caught", "minor");
  settings.Add("p199", false, "[Medi Room] Defeated Johnny", "minor");
  settings.Add("p210", false, "[Comms Tower A] Reached stairs chase", "minor");
  settings.Add("p212", false, "[Comms Tower A] Completed stairs chase", "minor");
  settings.Add("p219", false, "[Comms Tower A] Completed rappel", "minor");
  settings.Add("p228", false, "[Comms Tower B] Reached Hind D", "minor");
  settings.Add("p237", false, "[Comms Tower B] Reached elevator ambush", "minor");
  settings.Add("p238", false, "[Comms Tower B] Defeated elevator ambush", "minor");
  settings.Add("p241", false, "[Snowfield] Reached Sniper Wolf 2", "minor");
  settings.Add("p251", false, "[Cargo Elevator] Reached elevator ambush", "minor");
  settings.Add("p254", false, "[Cargo Elevator] Defeated elevator ambush", "minor");
  settings.Add("p257", false, "[Warehouse] Reached Vulcan Raven", "minor");
  settings.Add("p279", false, "[Underground Base] Reached the control room", "minor");
  settings.Add("p289", false, "[Underground Base] Picked up the PAL Key", "minor");
  settings.SetToolTip("p289", "Split occurs the moment you pick up the PAL Key");
  settings.Add("p290", false, "[Control Room] Reached the Normal PAL Key computer", "minor");
  settings.Add("p292", false, "[Control Room] Reached the Cold PAL Key computer", "minor");
  settings.Add("p298", false, "[Control Room] Reached the Hot PAL Key computer", "minor");
  settings.Add("p303", false, "[Supply Route] Reached Metal Gear REX", "minor");
  settings.Add("p307", false, "[Supply Route] Defeated Metal Gear REX (Phase 1)", "minor");
  settings.Add("p344", false, "[Escape Route] Reached Liquid chase", "minor");
  
  vars.D = new ExpandoObject();
  var D = vars.D;
  
  D.BaseAddr = IntPtr.Zero;
  D.GameActive = false;
  D.FinalTimeIter = 0;
  D.i = 0;
  
  D.GameIds = new Dictionary<string, bool>() {
    { "GGSPA4", true }, // Europe
    { "GGSJA4", true }, // Japan
    { "GGSEA4", true }  // USA
  };
  
  D.Endian = new ExpandoObject();
  D.Endian.Uint = (Func<uint, uint>)((val) => {
    return (val & 0x000000FF) << 24 |
            (val & 0x0000FF00) << 8 |
            (val & 0x00FF0000) >> 8 |
            ((uint)(val & 0xFF000000)) >> 24;
  });
  D.Endian.Short = (Func<ushort, short>)((val) => {
    return (short)((val & 0x00FF) << 8 |
            ((ushort)(val & 0xFF00)) >> 8);
  });
  
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
      print("Found MGS Twin Snakes memory at " + D.BaseAddr + " (dec)");
      return true;
    }
    
    D.GameActive = false;
    return false;
  });
  
  D.AddrFor = (Func<int, IntPtr>)((val) => (IntPtr)((long)D.BaseAddr + val));
  
  D.ResetVars = (Func<bool>)(() => {
    D.FinalTimeIter = 0;
    return true;
  });
  
}

update {
  var D = vars.D;
  D.current = current;
  D.old = old; 
  D.i++;
  
  current.Progress = 0;
  current.GameTime = 0;
  
  if ((D.i % 60) == 0) {
    if (!D.LookForGameMemory(game, memory)) return false;
  }
  else if (!D.GameActive) return false;
  
  ushort progress = memory.ReadValue<ushort>((IntPtr)D.AddrFor(0x5a2ed2));
  current.Progress = D.Endian.Short(progress);
  
  uint gameTime = memory.ReadValue<uint>((IntPtr)D.AddrFor(0x5a1a58));
  current.GameTime = D.Endian.Uint(gameTime);
  
  current.Location = memory.ReadString((IntPtr)D.AddrFor(0x5a348c), 10);
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
  
  if ((settings["c_reachwolf1"]) && (current.Progress == 164) && (old.Location == "area14a") && (current.Location == "area15a"))
    return true;
  
  if ((settings["c_score"]) && (current.Progress == 359) && (current.Location == "ending")) {
    if (current.GameTime == old.GameTime) {
      if (D.FinalTimeIter++ == 6) return true;
    }
    else D.FinalTimeIter = 0;
  }
  
  if (current.Progress == old.Progress) return false;
  
  string ProgressCode = "p" + current.Progress;
  if (settings.ContainsKey(ProgressCode) && (settings[ProgressCode])) return true;
  
  return false; 
}

start {
  var D = vars.D;
  if (!D.GameActive) return false;
  
  if ( (settings["o_startonselect"]) && (current.Progress == -1) && (current.Location == "n_title") ) {
    var ptr = memory.ReadValue<uint>((IntPtr)D.AddrFor(0x11b1334));
    if (ptr != 0) {
      ptr = D.Endian.Uint(ptr) & 0x0fffffff;
      if (memory.ReadValue<byte>((IntPtr)D.AddrFor((int)ptr + 0x4f)) == 7)
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