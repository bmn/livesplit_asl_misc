/*********************************************************/
/* UnMetal (PC) Autosplitter dev                         */
/*                                                       */
/* Created by bmn for Metal Gear Solid Speedrunners      */
/*                                                       */
/* Thanks to unepic_fran, Jacklifear, SRGTSilent         */
/* for their help and input                              */
/*********************************************************/


state("UnMetal") {}


startup {
  
  dynamic D = new ExpandoObject();
  dynamic F = new ExpandoObject();
  dynamic M = new MemoryWatcherList();
  dynamic A = new Dictionary<string, dynamic>();
  dynamic New = new ExpandoObject();
  D.F = F;
  D.M = M;
  D.A = A;
  vars.D = D;

  D.DebugLogBuffer = new List<string>();
  D.EventLog = new EventLog("Application") {
    EnableRaisingEvents = true,
  };

  D.LiveSplitPath = System.IO.Path.GetDirectoryName(Application.ExecutablePath);
  D.DebugLogPath = Path.Combine(D.LiveSplitPath, "UnMetal.Autosplitter.log");
  D.StartInstantly = false;
  D.LastErrorTime = DateTime.Now;
  D.LastErrorCount = 0;
  D.Initialised = false;
  F.EventLogWritten = null;
  


  F.Debug = (Action<string>)((message) => {
    print("[UnMetal] " + message);
  });


  F.WriteFile = (Action<string, string, bool>)((file, content, append) => {
    string dir = Path.GetDirectoryName(file);
    if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
    using( System.IO.StreamWriter stream = 
      new System.IO.StreamWriter(file, append) ) {
      stream.WriteLine(content);
      stream.Close();
    }
  });

  F.FlushDebugBuffer = (Action)(() => {
    if (D.DebugLogBuffer.Count > 0) {
      F.WriteFile(D.DebugLogPath, string.Join("\n", D.DebugLogBuffer), true);
      D.DebugLogBuffer.Clear();
    }
  });
  var flushDebugBufferTimer = new System.Timers.Timer(10000) {
    Interval = 1000,
    Enabled = true,
  };
  flushDebugBufferTimer.Elapsed += new System.Timers.ElapsedEventHandler(
    (Action<object, System.Timers.ElapsedEventArgs>)((sender, e) => F.FlushDebugBuffer()));
  
  
  F.NewObject = (Func<int, int, string, bool, dynamic>)(
    (offset, stage, description, defaultEnabled) => {
    dynamic o = new ExpandoObject();
    o.Offset = offset;
    o.OffsetHex = offset.ToString("X2");
    o.Stage = stage;
    o.Description = description;
    o.DefaultEnabled = defaultEnabled;
    o.ToolTip = null;
    return o;
  });

  F.NewEvent = (Func<int, int, string, bool, dynamic>)(
    (offset, stage, description, defaultEnabled) => {
    dynamic o = F.NewObject(offset, stage, description, defaultEnabled);
    o.Class = "Event";
    o.SettingsKey = "Split.Event." + o.OffsetHex;
    return o;
  });

  F.NewBoss = (Func<int, int, string, bool, dynamic>)(
    (offset, stage, description, defaultEnabled) => {
    dynamic o = F.NewObject(offset, stage, description, defaultEnabled);
    o.Class = "Boss";
    o.SettingsKey = "Split.Boss." + o.OffsetHex;
    return o;
  });

  F.NewArray = (Func<IntPtr, int, int, dynamic>)((addr, len, bytes) => {
    len *= bytes;
    dynamic ba = new ExpandoObject();
    ba.Address = addr;
    ba.Length = len;
    ba.Bytes = bytes;
    ba.Current = null;
    ba.Old = null;
    ba.Changed = false;
    ba.Update = F.UpdateArray;
    return ba;
  });


  var Events = new List<dynamic>() {
    //F.NewCustom(1, "Escaped the cell", true),
    F.NewEvent(0, 1, "Found the sewer", true),
    F.NewEvent(1, 1, "Talked to Col. Harris", false),
    F.NewEvent(2, 1, "Picked up Harris' radio", false),
    F.NewEvent(3, 1, "Encrypted Harris' radio", false),
    F.NewEvent(4, 1, "Gave Harris the radio", true),
    F.NewEvent(17, 1, "Encrypted Jesse's radio", false),
    F.NewBoss(0, 1, "Grenade Guy", true),
    F.NewEvent(5, 1, "Entered the sewer", true),

    F.NewEvent(9, 2, "Tested the waters", false),
    F.NewBoss(1, 2, "Sgt. Rosco", true),
    F.NewEvent(7, 2, "Gave Robert the radio", true),
    F.NewEvent(6, 2, "Built the floating bridge", false),
    F.NewBoss(2, 2, "Sewerjunk", true),
    F.NewEvent(8, 2, "Escape from the sewer", true),

    F.NewEvent(10, 3, "Reach the F1 elevator? (1)", true),
    F.NewEvent(11, 3, "Reach the F1 elevator? (2)", true),
    F.NewBoss(3, 3, "Megadron", true),
    F.NewEvent(16, 3, "Create the chloroform", true),
    F.NewEvent(19, 3, "Give Mike the batteries", true),
    F.NewEvent(12, 3, "Reach Lt. Markuson's office", true),
    F.NewEvent(22, 3, "Use the chloroform", false),
    F.NewEvent(13, 3, "Reach the sickbay", true),
    F.NewEvent(23, 3, "Hide from Lt. Markuson", true),
    F.NewEvent(24, 3, "Reenter the sickbay", true),
    F.NewBoss(4, 3, "Lt. Markuson", true),
    F.NewEvent(14, 3, "??? Immediately after beating Markuson", true),
    F.NewEvent(15, 3, "??? Doesn't happen consistently?", true),
    F.NewEvent(18, 3, "Overcome the biometric scanner", true),
  };

  var StageNames = new List<string>() {
    "The Great Escape",
    "Something Stinks Really Bad",
    "In The Lion's Den",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
  };

  settings.Add("Debug", true, "Debug Logging");
  settings.Add("Debug.File", true, "Save debug information to LiveSplit directory", "Debug");
  settings.SetToolTip("Debug.File", "Log location: " + D.DebugLogPath);
  settings.Add("Debug.StdOut", true, "Log debug information to Windows debug log", "Debug");
  settings.SetToolTip("Debug.StdOut", "This can be viewed in a tool such as DebugView.");

  settings.Add("Behaviour", true, "Behaviour");
  settings.Add("Behaviour.ResetMainMenu", true, "Reset when returning to Main Menu", "Behaviour");
  settings.SetToolTip("Behaviour.ResetMainMenu",
    "If ENABLED: will reset at the main menu\nIf DISABLED: will reset and restart timer on a new attempt");

  settings.Add("Split", true, "Split on...");
  settings.Add("Split.Stage", true, "Stage Complete", "Split");
  settings.SetToolTip("Split.Stage", "Split on Stage Complete");
  settings.Add("Split.Event", true, "Stage Events", "Split");
  settings.SetToolTip("Split.Event", "Split when an event occurs during a stage");
  
  
  for (int i = 1; i <= 3; i++) {
    string name = string.Format("Stage {0}: {1}", i, StageNames[i - 1]);
    settings.Add("Split.Stage." + i, true, name, "Split.Stage");
    settings.Add("Split.Event.Stage" + i, true, name, "Split.Event");
  }

  D.Events = new Dictionary<int, dynamic>();
  D.Bosses = new Dictionary<int, dynamic>();
  foreach (var evt in Events) {
    settings.Add(evt.SettingsKey, evt.DefaultEnabled, evt.Description, "Split.Event.Stage" + evt.Stage);
    if (evt.ToolTip != null)
      settings.SetToolTip(evt.SettingsKey, evt.ToolTip);
    if (evt.Class == "Event")
      D.Events.Add(evt.Offset, evt);
    else if (evt.Class == "Boss")
      D.Bosses.Add(evt.Offset, evt);
  }

}


init {
  var D = vars.D; var F = D.F; var M = D.M; var A = D.A;

  if (!D.Initialised) {
    D.Initialised = true;

    F.Debug = (Action<string>)((message) => {
      if (settings["Debug.File"]) D.DebugLogBuffer.Add(
        string.Format("[{0}] {1}", DateTime.Now.ToString("T"), message));
      if (settings["Debug.StdOut"]) print("[UnMetal] " + message);
    });

    F.EventLogWritten = new EntryWrittenEventHandler((Action<object, EntryWrittenEventArgs>)((sender, e) => {
      var entry = e.Entry;
      if ( (settings["Debug.File"]) && (entry.Source.Equals("LiveSplit"))
        && (entry.EntryType.ToString().Equals("Error")) ) {
        if ( (entry.TimeGenerated - D.LastErrorTime).Seconds > 9 ) {
          D.LastErrorTime = DateTime.Now;
          string message = string.Format("[Error at {0}] {1}",
            D.LastErrorTime.ToString("T"), entry.Message);
          if (D.LastErrorCount != 0)
            message = "[" + D.LastErrorCount + " suppressed] " + message;
          
          D.DebugLogBuffer.Add(message);
          D.LastErrorCount = 0;
        }
        else D.LastErrorCount++;
      }
    }));
    D.EventLog.EntryWritten += F.EventLogWritten;

    F.UpdateAllArrays = (Action<Process>)((g) => {
      foreach (var m in A)
        m.Value.Update(m.Value, g);
    });

    F.UpdateArray = (Action<dynamic, Process>)((m, g) => {
      m.Old = m.Current;
      m.Current = g.ReadBytes((IntPtr)m.Address, (int)m.Length);
      if (m.Old == null) {
        m.Old = m.Current;
        m.Changed = false;
      }
      else m.Changed = (!Enumerable.SequenceEqual((byte[])m.Current, (byte[])m.Old));
    });

    F.NewCompletedEvents = (Func<List<dynamic>>)(() => {
      var o = new List<dynamic>();
      var m = A["Missions"];
      for (int i = 0, j = 0; i < m.Current.Length; i += m.Bytes, j++) {
        if ( (m.Current[i] == 1) && (m.Old[i] == 0) ) {
          if (D.Events.ContainsKey(j))
            o.Add(D.Events[j]);
          else F.Debug("New event at offset " + j + " (undefined)");
        }
      }
      return o;
    });

    F.NewCompletedBosses = (Func<List<dynamic>>)(() => {
      var o = new List<dynamic>();
      var b = A["Bosses"];
      for (int i = 0, j = 0; i < b.Current.Length; i += b.Bytes, j++) {
        if ( (b.Current[i] == 1) && (b.Old[i] == 0) ) {
          if (D.Bosses.ContainsKey(j))
            o.Add(D.Bosses[j]);
          else F.Debug("New boss defeat at offset " + j + " (undefined)");
        }
      }
      return o;
    });

    F.NewKeyItems = (Func<List<dynamic>>)(() => {
      var o = new List<dynamic>();
      for (int i = 0; i < current.ItemsArray.Length; i += 4) {
        if ( (current.ItemsArray[i] == 1) && (old.ItemsArray[i] == 0)
          && (D.KeyItems.ContainsKey(i)) ) {
          o.Add(D.KeyItems[i]);
        }
      }
      return o;
    });

    F.EventEnabled = (Func<dynamic, bool>)((evt) => {
      string key = "Split.Event." + evt.OffsetHex;
      return (settings.ContainsKey(key) && (settings[key]));
    });

    F.KeyItemEnabled = (Func<dynamic, bool>)((item) => {
      string key = "Split.KeyItem." + item.OffsetHex;
      return (settings.ContainsKey(key) && (settings[key]));
    });

    F.SettingEnabled = (Func<string, bool>)((key) => 
      (settings.ContainsKey(key) && (settings[key])) );

    F.UpdateCurrent = (Action)(() => {
      var cur = current as IDictionary<string, object>;
      foreach (var w in vars.D.M)
        cur[w.Name] = w.Current;

      foreach (var w in vars.D.A) {
        string content = "";
        int j = 0;
        for (int i = 0; i < w.Value.Length; i += w.Value.Bytes) {
          content += (w.Value.Current[i] == 1) ? (j % 10).ToString() : "x";
          j++;
        }
        cur[w.Key] = content;
      }
    });
  }
  

  var mainModule = modules.First();

  F.Debug( string.Format("Attached to UnMetal process ({0} bytes)",
    mainModule.ModuleMemorySize) );

  string signature = "53 50 45 45 44 52 55 4E ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 42 4F 53 53 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 51 55 53 54 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 45 4E 44 2E";
  var sigTarget = new SigScanTarget(0, signature);
  var sigScanner = new SignatureScanner(game, mainModule.BaseAddress,
    (int)mainModule.ModuleMemorySize);
  IntPtr offset = sigScanner.Scan(sigTarget);

  if (offset == IntPtr.Zero) {
    Thread.Sleep(3000);
    throw new NullReferenceException("Couldn't find the SPEEDRUN struct, aborting");
  }

  F.Debug("Found SPEEDRUN struct at " + offset.ToString("X2"));
  D.DataOffset = offset;

  M.Clear();
  M.AddRange(new MemoryWatcherList(){
    new MemoryWatcher<int>(offset + 0x8)   { Name = "PlayerLevel" },
    new MemoryWatcher<int>(offset + 0xC)   { Name = "RoomX" },
    new MemoryWatcher<int>(offset + 0x10)  { Name = "RoomY" },
    new MemoryWatcher<bool>(offset + 0x14) { Name = "TimerActive" },
    new MemoryWatcher<int>(offset + 0x18)  { Name = "Attempts" },
  });

  A.Clear();
  A.Add("Bosses", F.NewArray(offset + 0x20, 14, 1));
  A.Add("Missions", F.NewArray(offset + 0x34, 54, 4));

  D.M.UpdateAll(game);
  D.F.UpdateAllArrays(game);
  D.F.UpdateCurrent();

}

start {
  var D = vars.D;
  if (D.StartInstantly) {
    D.StartInstantly = false;
    return true;
  }
  if (D.M["Attempts"].Changed) {
    D.F.Debug("START for new attempt");
    return true;
  }
  return false;
}


reset {
  var D = vars.D; var M = D.M; var F = D.F;

  if (settings["Behaviour.ResetMainMenu"]) {
    if ( (M["MainMenu"].Changed) && (M["MainMenu"].Current) ) {
      F.Debug("RESET for main menu");
      return true;
    }
  }
  else if (M["Attempts"].Changed) {
    D.StartInstantly = true;
    F.Debug("RESET + START for new attempt");
    //return true;
  }
  return false;
}


gameTime {
  return null; // TimeSpan.FromSeconds(vars.D.M["GameTime"].Current);
}


isLoading {
  return true;
}

shutdown {
  var D = vars.D; var F = D.F;
  
  if (F.EventLogWritten != null)
    D.EventLog.EntryWritten -= F.EventLogWritten;

  F.FlushDebugBuffer();
}

update {
  var D = vars.D;
  D.M.UpdateAll(game);
  D.F.UpdateAllArrays(game);
  D.F.UpdateCurrent();
}



split {
  var D = vars.D; var F = D.F;

  if (D.A["Missions"].Changed) {
    foreach (var evt in F.NewCompletedEvents()) {
      if (F.SettingEnabled(evt.SettingsKey)) {
        F.Debug( string.Format("SPLIT for new Stage {0} event \"{1}\"",
          evt.Stage, evt.Description) );
        return true;
      }
      else F.Debug( string.Format("New Stage {0} event \"{1}\" (split disabled)",
        evt.Stage, evt.Description) );
    }
  }

  if (D.A["Bosses"].Changed) {
    foreach (var boss in F.NewCompletedBosses()) {
      if (F.SettingEnabled(boss.SettingsKey)) {
        F.Debug( string.Format("SPLIT for new Stage {0} boss \"{1}\"",
          boss.Stage, boss.Description) );
        return true;
      }
      else F.Debug( string.Format("New Stage {0} boss \"{1}\" (split disabled)",
        boss.Stage, boss.Description) );
    }
  }

  return false;

}