state("Dolphin") {}

startup {
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
  settings.Add("score", true, "Score (not done yet)", "splits");
  
  settings.Add("minor", true, "Minor Splits");
  settings.Add("p7", false, "[Dock] Reached the elevator", "minor");
  settings.Add("p28", false, "[Holding Cell] Reached Darpa Chief", "minor");
  settings.Add("p36", false, "[Holding Cell] Reached Guard Encounter", "minor");
  settings.Add("p46", false, "[Armory South] Reached Revolver Ocelot", "minor");
  settings.Add("p74", false, "[Canyon] Reached M1 Tank", "minor");
  settings.Add("p89", false, "[Nuke Building B2] Reached Ninja", "minor");
  settings.Add("p125", false, "[Nuke Building B1] Cornered Meryl", "minor");
  settings.Add("p139", false, "[Commander's Room] Reached Mantis", "minor");
  settings.Add("p159", false, "[Underground Passage] Reached Sniper Wolf ambush", "minor");
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
  
	D.Watchers = new MemoryWatcherList();
  
  D.BaseAddr = IntPtr.Zero;
  D.GameActive = false;
  D.i = 0;
  
  D.Endian = new ExpandoObject();
  D.Endian.uint = (Func<uint, uint>)((val) => {
    return (val & 0x000000FF) << 24 |
            (val & 0x0000FF00) << 8 |
            (val & 0x00FF0000) >> 8 |
            ((uint)(val & 0xFF000000)) >> 24;
  });
  D.Endian.short = (Func<ushort, short>)((val) => {
    return (short)((val & 0x00FF) << 8 |
            ((ushort)(val & 0xFF00)) >> 8);
  });
  
  D.LookForGameMemory = (Func<Process, Process, bool>)((g, m) => {
    string gameCode = "GGSEA4";
    
    if ( (D.BaseAddr != IntPtr.Zero) && (m.ReadString((IntPtr)D.BaseAddr, 6) == gameCode) ) return true;
    
    foreach (var page in g.MemoryPages(true))
    {
      if ((page.RegionSize != (UIntPtr)0x2000000) || (page.Type != MemPageType.MEM_MAPPED)) continue;
      
      if (m.ReadString(page.BaseAddress, 6) != gameCode) continue;
      
      D.BaseAddr = page.BaseAddress;
      D.GameActive = true;
      print("Found MGS Twin Snakes memory at " + D.BaseAddr + " (dec)");
      return true;
    }
    return false;
  });
  
  D.AddrFor = (Func<int, IntPtr>)((val) => (IntPtr)((long)D.BaseAddr + val));
  
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
  current.Progress = D.Endian.short(progress);
  uint gameTime = memory.ReadValue<uint>((IntPtr)D.AddrFor(0x5a1a58));
  current.GameTime = D.Endian.uint(gameTime);
}

gameTime {
  return TimeSpan.FromMilliseconds((float)current.GameTime / 60 * 1000);
}

isLoading {
  return true;
}

split {
  var D = vars.D;
  if (!D.GameActive) return false;
  if (current.Progress == old.Progress) return false;
  
  string ProgressCode = "p" + current.Progress;
  if (settings.ContainsKey(ProgressCode) && (settings[ProgressCode])) return true;
  
  return false; 
}

start {
  return ( (current.Progress == 3) && (old.Progress == -1) );
}

reset {
  return ( (current.Progress == -1) && (old.Progress != -1) );
}