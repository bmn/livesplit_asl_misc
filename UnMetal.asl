/*********************************************************/
/* UnMetal (PC) Autosplitter dev                         */
/*                                                       */
/* Created by bmn for Metal Gear Solid Speedrunners      */
/*                                                       */
/* Thanks to unepic_fran, Jacklifear, SRGTSilent         */
/* for their help and input                              */
/*********************************************************/


state("unmetal") {}


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
  D.Initialised = false;

  // Game runs at around 35fps, lowering refreshRate can improve performance & smoothness
  refreshRate = 40;


  F.Debug = (Action<string>)((message) =>
    print("[UnMetal] " + message) );


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
  
  
  F.NewObject = (Func<int, string, bool, dynamic>)(
    (stage, description, defaultEnabled) => {
    dynamic o = new ExpandoObject();
    o.Stage = stage;
    o.Description = description;
    o.DefaultEnabled = defaultEnabled;
    o.ToolTip = null;
    return o;
  });

  F.NewEvent = (Func<int, int, string, bool, dynamic>)(
    (offset, stage, description, defaultEnabled) => {
    dynamic o = F.NewObject(stage, description, defaultEnabled);
    o.Offset = offset;
    o.OffsetHex = offset.ToString("X2");
    o.Class = "Event";
    o.SettingsKey = "Split.Event." + o.OffsetHex;
    return o;
  });

  F.NewMission = (Func<int, int, string, bool, dynamic>)(
    (offset, stage, description, defaultEnabled) => {
    dynamic o = F.NewEvent(offset, stage, description, defaultEnabled);
    o.Class = "Mission";
    o.SettingsKey = "Split.Mission." + o.OffsetHex;
    return o;
  });

  F.NewBoss = (Func<int, int, int, string, bool, dynamic>)(
    (offset, target, stage, description, defaultEnabled) => {
    dynamic o = F.NewObject(stage, description, defaultEnabled);
    o.Target = target;
    o.Offset = offset;
    o.OffsetHex = offset.ToString("X2");
    o.Class = "Boss";
    o.SettingsKey = string.Format("Split.Boss.{0}.{1}", o.OffsetHex, o.Target);
    return o;
  });

  F.NewCoordinate = (Func<int, int, int, string, bool, Func<bool>, dynamic>)(
    (coordX, coordY, stage, description, defaultEnabled, callback) => {
    dynamic o = F.NewObject(stage, description, defaultEnabled);
    o.CoordX = coordX;
    o.CoordY = coordY;
    o.Callback = callback;
    o.Class = "Coordinate";
    o.SettingsKey = "Split.Coordinate." + F.CoordinateKey(stage, coordX, coordY);
    return o;
  });

  F.NewArray = (Func<IntPtr, int, int, dynamic>)((addr, len, bytes) => {
    //len *= bytes;
    dynamic ba = new ExpandoObject();
    ba.Address = addr;
    ba.Length = len;
    ba.Bytes = bytes;
    ba.Current = null;
    ba.Old = null;
    ba.CurrentRaw = null;
    ba.OldRaw = null;
    ba.Changed = false;
    ba.Update = F.UpdateArray;
    return ba;
  });

  F.NewDeadTime = (Func<string, dynamic>)((name) => {
    dynamic o = new ExpandoObject();
    o.Name = name;
    o.OldActive = false;
    o.Active = false;
    o.ShowLapTime = false;
    o.StartTime = TimeSpan.FromSeconds(0);
    o.RunningTotal = TimeSpan.FromSeconds(0);
    return o;
  });

  F.CoordinateKey = (Func<int, int, int, string>)((stage, coordX, coordY) =>
    string.Format("{0}.{1}.{2}", stage, coordX, coordY) );

  F.BossKey = (Func<int, int, string>)((offset, target) =>
    string.Format("{0}.{1}", offset, target) );

  F.InitVariables = (Action)(() => {
    D.StartInstantly = false;
    D.LastErrorTime = DateTime.Now;
    D.LastErrorCount = 0;
    F.EventLogWritten = null;
    D.TotalDeadTime = TimeSpan.FromSeconds(0);
    D.DeadTime = new Dictionary<int, dynamic>() {
      { 1, F.NewDeadTime("Menu") },
      { 2, F.NewDeadTime("Inventory") },
      { 3, F.NewDeadTime("Ingame") },
    };
  });
  F.InitVariables();


  var Events = new List<dynamic>() {
    F.NewEvent(0, 1, "Escaped the cell", true),
    F.NewMission(0, 1, "Found the sewer", true),
    F.NewMission(1, 1, "Talked to Col. Harris", false),
    F.NewMission(2, 1, "Picked up Harris' radio", false),
    F.NewMission(3, 1, "Encrypted Harris' radio", false),
    F.NewMission(4, 1, "Gave Harris the radio", true),
    F.NewMission(17, 1, "Encrypted Jesse's radio", false),
    F.NewBoss(0, 1, 1, "Reached Grenade Guy", true),
    F.NewBoss(0, 2, 1, "Grenade Guy", true),
    F.NewMission(5, 1, "Entered the sewer", false),

    F.NewMission(9, 2, "Tested the waters", false),
    F.NewBoss(1, 1, 2, "Reached Sgt. Rosco", true),
    F.NewBoss(1, 2, 2, "Sgt. Rosco", true),
    F.NewEvent(1, 2, "Found the first intel file", true),
    F.NewEvent(2, 2, "Examined the truck's engine", true),
    F.NewMission(7, 2, "Gave Robert the radio", true),
    F.NewMission(6, 2, "Built the floating platform", false),
    F.NewEvent(3, 2, "Used the floating platform for the first time", true),
    F.NewEvent(4, 2, "Ambushed by rodents!", true),
    F.NewEvent(5, 2, "Found the broken flamethrower", true),
    F.NewBoss(2, 1, 2, "Reached Sewerjunk", true),
    F.NewBoss(2, 2, 2, "Sewerjunk", true),
    F.NewMission(8, 2, "Escape from the sewer", false),

    F.NewEvent(6, 3, "Met Doctor Hoffman", true),
    F.NewEvent(7, 3, "Found the pistol", false),
    F.NewEvent(8, 3, "Found the second intel file", true),
    F.NewMission(10, 3, "Reached the elevator on F1", false),
    F.NewBoss(3, 1, 3, "Reached Megadron", true),
    F.NewBoss(3, 2, 3, "Megadron", true),
    F.NewMission(16, 3, "Create the chloroform", true),
    F.NewEvent(9, 3, "Found the third intel file", true),
    F.NewMission(19, 3, "Give Mike the batteries", false),
    F.NewMission(12, 3, "Reach Lt. Markuson's office", true),
    F.NewMission(22, 3, "Use the chloroform", false),
    F.NewMission(13, 3, "Reach the sickbay", true),
    F.NewMission(23, 3, "Hide from Lt. Markuson", false),
    F.NewMission(24, 3, "Reenter the sickbay", false),
    F.NewBoss(4, 1, 3, "Reached Lt. Markuson", true),
    F.NewBoss(4, 2, 3, "Lt. Markuson", true),
    F.NewMission(18, 3, "Overcome the biometric scanner", false),
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

  settings.Add("ASL", true, "ASL Var Viewer Support");
  settings.SetToolTip("ASL", "For use with hawkerm's ASL Var Viewer component for LiveSplit.\nhttps://github.com/hawkerm/LiveSplit.ASLVarViewer\n\nIf you don't use ASLVV, disabling these settings may slightly improve performance.");
  settings.Add("ASL.DeadTime", true, "Dead Time", "ASL");
  settings.SetToolTip("ASL.DeadTime", "Tracks the amount of dead time spent in menus, skipping cutscenes, etc.\n\nProvided variables:\n * vars.DeadTime (total from all sources)\n * vars.DeadTimeIngame (decision-making, going through doors, etc.)\n * vars.DeadTimeInventory (inventory, missions)\n * vars.DeadTimeMenu (pause menu)");
  settings.Add("ASL.DeadTime.StageReset", true, "Reset counters at the start of a new Stage", "ASL.DeadTime");
  settings.Add("ASL.DeadTime.2DP", false, "Extra timer precision (to 2 decimal places)", "ASL.DeadTime");

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
  D.Missions = new Dictionary<int, dynamic>();
  D.Bosses = new Dictionary<string, dynamic>();
  D.Coordinates = new Dictionary<string, List<dynamic>>();
  foreach (var evt in Events) {
    settings.Add(evt.SettingsKey, evt.DefaultEnabled, evt.Description, "Split.Event.Stage" + evt.Stage);
    if (evt.ToolTip != null)
      settings.SetToolTip(evt.SettingsKey, evt.ToolTip);
    if (evt.Class == "Event")
      D.Events.Add(evt.Offset, evt);
    if (evt.Class == "Mission")
      D.Missions.Add(evt.Offset, evt);
    else if (evt.Class == "Boss")
      D.Bosses.Add( F.BossKey(evt.Offset, evt.Target), evt );
    else if (evt.Class == "Coordinate") {
      string key = F.CoordinateKey(evt.Stage, evt.CoordX, evt.CoordY);
      if (!D.Coordinates.ContainsKey(key))
        D.Coordinates.Add(key, new List<dynamic>());
      D.Coordinates[key].Add(evt);
    }
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
      m.OldRaw = m.CurrentRaw;
      m.Old = m.Current;
      m.CurrentRaw = g.ReadBytes((IntPtr)m.Address, (int)(m.Length * m.Bytes));

      if (m.OldRaw == null)
        m.Changed = true;
      else
        m.Changed = (!Enumerable.SequenceEqual((byte[])m.CurrentRaw, (byte[])m.OldRaw));

      if (m.Changed) {
        if (m.Bytes == 1) {
          m.Current = m.CurrentRaw;
        }
        else {
          m.Current = new int[m.Length];
          Buffer.BlockCopy(m.CurrentRaw, 0, m.Current, 0, m.CurrentRaw.Length);
        }
        if (m.OldRaw == null) {
          m.OldRaw = m.CurrentRaw;
          m.Old = m.Current;
          m.Changed = false;
        }
      }
    });

    F.NewCompletedEvents = (Func<string, List<dynamic>>)((type) => {
      var o = new List<dynamic>();
      var m = A[type];
      for (int i = 0; i < m.Length; i ++) {

        if (type == "Events") { 
          if ( (m.Current[i] == 1) && (m.Old[i] == 0) ) {
            if (D.Events.ContainsKey(i))
              o.Add(D.Events[i]);
            else F.Debug("New quest event at offset " + i + " (undefined)");
          }
        }

        else if (type == "Missions") { 
          if ( (m.Current[i] == 1) && (m.Old[i] == 0) ) {
            if (D.Missions.ContainsKey(i))
              o.Add(D.Missions[i]);
            else F.Debug("New mission event at offset " + i + " (undefined)");
          }
        }

        else if (type == "Bosses") {
          var cur = m.Current[i];
          var ol = m.Old[i];
          if (cur != ol) {
            string key = F.BossKey(i, cur);
            if (D.Bosses.ContainsKey(key))
              o.Add(D.Bosses[key]);
            else F.Debug( string.Format("New boss event at offset {0}, value {1} (undefined)",
              i, cur) );
          }
        }

      }

      return o;
    });

    F.NewCompletedBosses = (Func<List<dynamic>>)(() => {
      var o = new List<dynamic>();
      var b = A["Bosses"];
      for (int i = 0; i < b.Length; i++) {
        var cur = b.Current[i];
        var ol = b.Old[i];
        if (cur != ol) {
          string key = F.BossKey(i, cur);
          if (D.Bosses.ContainsKey(key))
            o.Add(D.Bosses[key]);
          else F.Debug( string.Format("New boss event at offset {0}, value {1} (undefined)",
            i, cur) );
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
        for (int i = 0; i < w.Value.Length; i++) {
          content += (w.Value.Current[i] == 0) ? "x" : (j % 10).ToString();
          j++;
        }
        cur[w.Key] = content;
      }
    });

    F.StartedNewAttempt = (Func<bool>)(() =>
      //( (M["GameState"].Old == 0) && (M["GameState"].Current == 3) ) );
      (M["Attempts"].Changed) );


    F.UpdateASL = (Action)(() => {
      if (settings["ASL.DeadTime"])
        F.UpdateASLDeadTime();
    });

    F.UpdateASLDeadTime = (Action)(() => {
      var state = M["GameState"];
      var cutscene = M["InCutscene"];
      var stage = Math.Min(M["Stage"].Current - 1, 0);

      if ( (state.Current != 0) && (A["StageTimes"].Current[stage] == 0)
        && ((state.Current != 3) || (cutscene.Current)) ) {
        D.DeadTime[state.Current].Active = true;
      }
      
      var v = vars as IDictionary<string, object>;

      string formatSecs = "s\\.f";
      string formatMins = "m\\:ss\\.f";
      if (settings["ASL.DeadTime.2DP"]) {
        formatSecs += "f";
        formatMins += "f";
      }

      var totalLoss = TimeSpan.FromSeconds(0);
      bool reset = false;
      bool totalLapTime = false;

      foreach (var t in D.DeadTime) {
        var tl = t.Value;

        if (M["Stage"].Changed || M["Attempts"].Changed) {
          tl.RunningTotal = TimeSpan.FromSeconds(0);
          v["DeadTime" + tl.Name] = "0:00";
          if (!reset) {
            D.TotalDeadTime = TimeSpan.FromSeconds(0);
            vars.DeadTime = "0:00";
          }
          reset = true;
        }

        TimeSpan now = TimeSpan.FromMilliseconds(M["GameTime"].Current);
        TimeSpan then = TimeSpan.FromMilliseconds(M["GameTime"].Old);

        if ( (tl.Active) || (tl.OldActive) ) {

          tl.ShowLapTime = true;
          totalLapTime = true;

          TimeSpan newLoss = TimeSpan.FromSeconds(0);
          if (tl.OldActive) {
            newLoss = ((TimeSpan)now - (TimeSpan)tl.StartTime);
            var delta = ((TimeSpan)now - (TimeSpan)then);
            tl.RunningTotal += delta;
            D.TotalDeadTime += delta;
          }

          if (tl.OldActive != tl.Active) {
            tl.StartTime = now;
          }

          v["DeadTime" + tl.Name] = string.Format("[+{0}] {1}",
            newLoss.ToString( (newLoss.Minutes > 0) ? formatMins : formatSecs ),
            tl.RunningTotal.ToString( (tl.RunningTotal.Minutes > 0) ? formatMins : formatSecs )
          );

          vars.DeadTime = string.Format("[+{0}] {1}",
            newLoss.ToString( (newLoss.Minutes > 0) ? formatMins : formatSecs ),
            D.TotalDeadTime.ToString( (D.TotalDeadTime.Minutes > 0) ? formatMins : formatSecs )
          );
        }
        else if (tl.ShowLapTime) {

          if ( (now - TimeSpan.FromSeconds(3)) > tl.StartTime ) {
            tl.ShowLapTime = false;

            v["DeadTime" + tl.Name] = tl.RunningTotal.ToString(
              (tl.RunningTotal.Minutes > 0) ? formatMins : formatSecs );
          }
          else totalLapTime = true;

        }

        totalLoss += tl.RunningTotal;
        tl.OldActive = tl.Active;
        tl.Active = false;
      }

      if (!totalLapTime)
        vars.DeadTime = D.TotalDeadTime.ToString(
          (D.TotalDeadTime.Minutes > 0) ? formatMins : formatSecs );
    });

  }
  

  var mainModule = modules.First();

  F.Debug( string.Format("Attached to UnMetal process ({0} bytes)",
    mainModule.ModuleMemorySize) );

  string signature = "53 50 45 45 44 52 55 4E ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 42 4F 53 53 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 51 55 53 54 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 45 56 4E 54 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 45 4E 44 2E";
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
    new MemoryWatcher<int>(offset + 0x1C)  { Name = "Stage" },

    new MemoryWatcher<int>(offset + 0x48)  { Name = "GameTime" },
    new MemoryWatcher<int>(offset + 0x4C)  { Name = "CurrentStageTime"},
    // 0 = main menu, 1 = menu pause/menu death, 2 = inventory/missions, 3 = ingame
    new MemoryWatcher<int>(offset + 0x50)  { Name = "GameState" },
    new MemoryWatcher<bool>(offset + 0x54)  { Name = "InCutscene" },
  });

  A.Clear();
  A.Add("StageTimes", F.NewArray(offset + 0x20, 10, 4));
  A.Add("Bosses", F.NewArray(offset + 0x5C, 14, 4));
  A.Add("Missions", F.NewArray(offset + 0x98, 54, 1));
  A.Add("Events", F.NewArray(offset + 0xD2, 64, 1));

  D.M.UpdateAll(game);
  D.F.UpdateAllArrays(game);
  D.F.UpdateCurrent();

}

start {
  var D = vars.D; var F = D.F;

  bool start = false;
  if (D.StartInstantly) {
    D.StartInstantly = false;
    start = true;
  }
  if (F.StartedNewAttempt()) {
    F.Debug("START for new attempt");
    start = true;
  }

  if (start)
    F.InitVariables();
  return start;
}


reset {
  var D = vars.D; var M = D.M; var F = D.F;

  bool reset = false;
  if (settings["Behaviour.ResetMainMenu"]) {
    if ( (M["GameState"].Changed) && (M["GameState"].Current == 0) ) {
      F.Debug("RESET for main menu");
      reset = true;
    }
  }
  else if (F.StartedNewAttempt()) {
    D.StartInstantly = true;
    F.Debug("RESET + START for new attempt");
    reset = true;
  }

  if (reset)
    F.InitVariables();
  return reset;
}


gameTime {
  return TimeSpan.FromMilliseconds(vars.D.M["GameTime"].Current);
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
  var D = vars.D; var F = D.F;
  D.M.UpdateAll(game);
  F.UpdateAllArrays(game);
  F.UpdateCurrent();
}



split {
  var D = vars.D; var F = D.F; var M = D.M; var A = D.A;

  if (settings["ASL"])
    F.UpdateASL();

  if (A["StageTimes"].Changed) {
    int stage = M["Stage"].Current;
    if (F.SettingEnabled("Split.Stage." + stage)) {
      F.Debug( string.Format("SPLIT for completed Stage {0}", stage) );
      return true;
    }
    else F.Debug( string.Format("Completed Stage {0} (split disabled)", stage) );
  }

  foreach (string type in new string[] { "Missions", "Events", "Bosses" }) {
    if (A[type].Changed) {
      foreach (var evt in F.NewCompletedEvents(type)) {
        if (F.SettingEnabled(evt.SettingsKey)) {
          F.Debug( string.Format("SPLIT for new Stage {0} {1} event \"{2}\"",
            evt.Stage, type, evt.Description) );
          return true;
        }
        else F.Debug( string.Format("New Stage {0} {1} event \"{2}\" (split disabled)",
          evt.Stage, type, evt.Description) );
      }
    }  
  }

  if ( (M["RoomX"].Changed) || (M["RoomY"].Changed) || (M["Stage"].Changed) ) {
    int stage = M["Stage"].Current;
    int coordX =  M["RoomX"].Current;
    int coordY = M["RoomY"].Current;
    string key = F.CoordinateKey(stage, coordX, coordY);
    if (D.Coordinates.ContainsKey(key)) {
      foreach (var coord in D.Coordinates[key]) {
        if ( (coord.Callback == null) || (coord.Callback()) ) {
          if (F.SettingEnabled(coord.SettingsKey)) {
            F.Debug( string.Format("SPLIT for coordinate \"{0}\" at Stage {1} ({2},{3})",
              coord.Description, stage, coordX, coordY) );
            return true;
          }
          else F.Debug( string.Format("Coordinate \"{0}\" at Stage {1} ({2},{3}) (split disabled)",
              coord.Description, stage, coordX, coordY) );
        }
      }
    }
  }

  return false;

}