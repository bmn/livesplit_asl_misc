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
  D.Debug = false;


  F.Debug = (Action<string>)((message) =>
    print("[UnMetal] " + message) );

  F.RoutePathFull = (Func<string, string>)((type) => {
    string ext = (type == null) ? "" : "." + type;
    return Path.Combine(D.LiveSplitPath, "UnMetal.Route" + ext + ".txt");
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
  
  
  F.NewObject = (Func<int, string, bool, bool, dynamic>)(
    (stage, description, skippable, defaultEnabled) => {
    dynamic o = new ExpandoObject();
    o.Stage = stage;
    o.Description = description;
    o.DefaultEnabled = defaultEnabled;
    o.Skippable = skippable;
    o.ToolTip = null;
    return o;
  });

  F.NewEvent = (Func<int, int, string, bool, bool, dynamic>)(
    (offset, stage, description, skippable, defaultEnabled) => {
    dynamic o = F.NewObject(stage, description, skippable, defaultEnabled);
    o.Offset = offset;
    o.OffsetHex = offset.ToString("X2");
    o.Class = "Event";
    o.SettingsKey = "Split.Event." + o.OffsetHex;
    return o;
  });

  F.NewMission = (Func<int, int, string, bool, bool, dynamic>)(
    (offset, stage, description, skippable, defaultEnabled) => {
    dynamic o = F.NewEvent(offset, stage, description, skippable, defaultEnabled);
    o.Class = "Mission";
    o.SettingsKey = "Split.Mission." + o.OffsetHex;
    return o;
  });

  F.NewBoss = (Func<int, int, int, string, bool, bool, dynamic>)(
    (offset, target, stage, description, skippable, defaultEnabled) => {
    dynamic o = F.NewObject(stage, description, skippable, defaultEnabled);
    o.Target = target;
    o.Offset = offset;
    o.OffsetHex = offset.ToString("X2");
    o.Class = "Boss";
    o.SettingsKey = string.Format("Split.Boss.{0}.{1}", o.OffsetHex, o.Target);
    return o;
  });

  F.NewCoordinate = (Func<int, int, int, string, bool, bool, Func<bool>, dynamic>)(
    (coordX, coordY, stage, description, skippable, defaultEnabled, callback) => {
    dynamic o = F.NewObject(stage, description, skippable, defaultEnabled);
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
    D.RouteIndex = 0;
    D.Route = new List<int[]>();
    vars.DeadTime = "0:00";
    vars.DeadTimeIngame = "0:00";
    vars.DeadTimeInventory = "0:00";
    vars.DeadTimeMenu = "0:00";
  });
  F.InitVariables();


  var Events = new List<dynamic>() {
    F.NewEvent(0, 1, "Escape the cell", false, true),
    F.NewMission(0, 1, "Discover the sewer", false, true),
    F.NewMission(1, 1, "Talk to Col. Harris", false, false),
    F.NewMission(2, 1, "Pick up Harris' radio", false, false),
    F.NewMission(3, 1, "Encrypt Harris' radio", false, false),
    F.NewMission(4, 1, "Give Harris the radio", false, true),
    F.NewMission(17, 1, "Encrypt Jesse's radio", false, false),
    F.NewBoss(0, 1, 1, "Reach Grenade Guy", false, true),
    F.NewBoss(0, 2, 1, "Defeat Grenade Guy", false, true),
    F.NewMission(5, 1, "Enter the sewer", false, false),

    F.NewMission(9, 2, "Test the waters", false, false),
    F.NewBoss(1, 1, 2, "Reach Sg. Rosco", false, true),
    F.NewBoss(1, 2, 2, "Sg. Rosco", false, true),
    F.NewEvent(1, 2, "Find intel file 1", false, true),
    F.NewEvent(2, 2, "Examine the truck's engine", true, false),
    F.NewMission(7, 2, "Give Robert the radio", false, true),
    F.NewMission(6, 2, "Build the floating platform", false, false),
    F.NewEvent(3, 2, "Get past the sewer channel", false, true),
    F.NewEvent(4, 2, "Ambushed by rodents", false, true),
    F.NewEvent(5, 2, "Find the broken flamethrower", false, true),
    F.NewBoss(2, 1, 2, "Reach Sewerjunk", false, true),
    F.NewBoss(2, 2, 2, "Defeat Sewerjunk", false, true),
    F.NewMission(8, 2, "Escape the sewer", false, false),

    F.NewEvent(6, 3, "Meet Doctor Hoffman", false, true),
    F.NewEvent(7, 3, "Find the pistol", false, false),
    F.NewEvent(8, 3, "Found intel file 2", false, true),
    F.NewMission(10, 3, "Reach the F1 elevator", false, false),
    F.NewBoss(3, 1, 3, "Reach Megadron", false, true),
    F.NewBoss(3, 2, 3, "Defeat Megadron", false, true),
    F.NewMission(16, 3, "Mix the chloroform", false, true),
    F.NewEvent(9, 3, "Find intel file 3", false, true),
    F.NewMission(19, 3, "Disable the door lasers", false, false),
    F.NewMission(12, 3, "Reach Markuson's office", false, true),
    F.NewMission(22, 3, "Use the chloroform", true, false),
    F.NewMission(13, 3, "Reach the sickbay in time", false, true),
    F.NewMission(23, 3, "Hide from Markuson", false, false),
    F.NewMission(24, 3, "Reenter the sickbay", false, false),
    F.NewBoss(4, 1, 3, "Reach Lt. Markuson", false, true),
    F.NewBoss(4, 2, 3, "Defeat Lt. Markuson", false, true),
    F.NewMission(18, 3, "Overcome the biometric scanner", false, false),

    F.NewEvent(10, 4, "Get past the hounds", false, true),
    F.NewBoss(5, 1, 4, "Reach Turret Storm", true, true),
    F.NewBoss(5, 2, 4, "Defeat Turret Storm", true, true),
    F.NewEvent(11, 4, "Find the metal detector", true, true),
    F.NewEvent(12, 4, "Get through minefield 1", true, true),
    F.NewEvent(13, 4, "Get through minefield 2", false, true),
    F.NewEvent(14, 4, "Get through minefield 3", true, true),
    F.NewEvent(15, 4, "Find Henry's corpse", false, true),
    F.NewEvent(16, 4, "Find a third unidentified(?) corpse", false, true),
    F.NewEvent(17, 4, "Fix the compass", true, false),
    F.NewMission(25, 4, "Sneak into the truck", false, false), // and 27?

    F.NewEvent(18, 5, "Meet Drunken Mike", true, false),
    F.NewBoss(6, 1, 5, "Reach Drill Instructor", true, false),
    F.NewBoss(6, 2, 5, "Defeat Drill Instructor", true, false),
    F.NewEvent(19, 5, "Stamp the permission slip", true, false),
    F.NewMission(28, 5, "Return the permission slip", true, false), // also Event 19
    F.NewBoss(7, 1, 5, "Reach Machine-Gun Mike", false, true),
    F.NewBoss(7, 2, 5, "Defeat Machine-Gun Mike", true, false),
    F.NewBoss(8, 1, 5, "Reach Splash Mike", false, true),
    F.NewBoss(8, 2, 5, "Defeat Splash Mike", false, false),

    F.NewEvent(21, 6, "Reach the engineers", false, true),
    F.NewEvent(23, 6, "Find the logbook", false, true),
    F.NewEvent(22, 6, "Recycle your useless junk", false, true),
    F.NewEvent(24, 6, "Commandeer the submarine", false, true),
    F.NewBoss(9, 1, 6, "Reach Hugeel", false, true),
    F.NewBoss(9, 2, 6, "Defeat Hugeel", false, true),

    F.NewMission(39, 7, "Buy the SS Velles", false, true),
    F.NewBoss(10, 1, 7, "Reach Nuclear Sub", false, true),
    F.NewBoss(10, 2, 7, "Defeat Nuclear Sub", false, true),
    F.NewMission(35, 7, "Repair one of the boats", false, false),
    F.NewBoss(11, 1, 7, "Reach Black Thunder", false, true),
    F.NewBoss(11, 2, 7, "Defeat Black Thunder", false, false),

    F.NewMission(44, 8, "Approach the compound", false, false),
    F.NewMission(32, 8, "Collect the bolt cutters", false, true),
    F.NewEvent(28, 8, "Find the uniforms", false, true),
    F.NewEvent(29, 8, "Find the EM grenades", false, true),
    F.NewMission(40, 8, "Create a clone of Mike", false, false),
    F.NewMission(31, 8, "Approach the Omega building", false, true),

    F.NewMission(53, 9, "Disable the F1 alarm system", true, false),
    F.NewEvent(32, 9, "Meet Doctor Hoffman", false, true),
    F.NewEvent(33, 9, "Find the anti-rad suit", true, false),
    F.NewEvent(34, 9, "Meet Doctor Hoffman again", true, true),
    F.NewMission(49, 9, "Find access card 4", false, true),
    F.NewEvent(37, 9, "Enter the rooftop", false, true),
    F.NewMission(51, 9, "Disable the communications tower", false, true), // and 52
    F.NewMission(41, 9, "Check the helicopter", false, true),
    F.NewEvent(40, 9, "Enter the 3rd floor", false, false),
    F.NewBoss(12, 1, 9, "Reach Takuma Takagashi", false, true),
    F.NewBoss(12, 2, 9, "Defeat Takuma Takagashi", false, true),
    F.NewEvent(41, 9, "Get the maze directions from Mike", false, true),
    F.NewEvent(42, 9, "Find the night goggles", false, true),
    F.NewEvent(43, 9, "Reach the first maze intersection", false, true),

    F.NewEvent(44, 10, "Set the C4 on the gas tank", false, true),
    F.NewMission(20, 10, "Rescue Harris and Doctor", false, false),
    F.NewMission(46, 10, "Leave the X room with Harris", false, true),
    F.NewBoss(13, 1, 10, "Reach General X", false, true),
    F.NewEvent(47, 10, "Defeat the drones", false, false),
    F.NewEvent(48, 10, "Defeat the tank", false, false),
    F.NewBoss(13, 2, 10, "Defeat General X", false, true),
    F.NewMission(45, 10, "\"Convince\" Harris", false, false),
  };

  var StageNames = new List<string>() {
    "The Great Escape",
    "Something Stinks Really Bad",
    "In The Lion's Den",
    "Welcome To The Jungle",
    "The Barracks",
    "Engineering Problems",
    "Boom Docks",
    "A Thousand Eyes Are Watching You",
    "Jerico's Heart",
    "Escape Complete!",
  };

  string pre = " ";
  settings.Add("Debug", true, pre+"Debug Logging");
  settings.Add("Debug.File", true, pre+"Save debug information to LiveSplit directory", "Debug");
  settings.SetToolTip("Debug.File", "Log location: " + D.DebugLogPath);
  settings.Add("Debug.StdOut", true, pre+"Log debug information to Windows debug log", "Debug");
  settings.SetToolTip("Debug.StdOut", "This can be viewed in a tool such as DebugView.");

  settings.Add("Behaviour", true, pre+"Behaviour");
  settings.Add("Behaviour.ResetMainMenu", true, pre+"Reset when returning to Main Menu", "Behaviour");
  settings.SetToolTip("Behaviour.ResetMainMenu",
    "If ENABLED: will reset at the main menu\nIf DISABLED: will reset and restart timer on a new attempt");

  settings.Add("ASL", true, pre+"ASL Var Viewer Support");
  settings.SetToolTip("ASL", "For use with hawkerm's ASL Var Viewer component for LiveSplit.\nhttps://github.com/hawkerm/LiveSplit.ASLVarViewer\n\nIf you don't use ASLVV, disabling these settings may slightly improve performance.");
  settings.Add("ASL.DeadTime", true, pre+"Dead Time", "ASL");
  settings.SetToolTip("ASL.DeadTime", "Tracks the amount of dead time spent in menus, skipping cutscenes, etc.\n\nProvided variables:\n * vars.DeadTime (total from all sources)\n * vars.DeadTimeIngame (decision-making, going through doors, etc.)\n * vars.DeadTimeInventory (inventory, missions)\n * vars.DeadTimeMenu (pause menu)");
  settings.Add("ASL.DeadTime.StageReset", true, pre+"Reset counters at the start of a new Stage", "ASL.DeadTime");
  settings.Add("ASL.DeadTime.2DP", false, pre+"Extra timer precision (to 2 decimal places)", "ASL.DeadTime");

  settings.Add("Split", true, pre+"Split on...");
  settings.Add("Split.Stage", true, pre+"Stage Complete", "Split");
  settings.SetToolTip("Split.Stage", "Split on Stage Complete");
  settings.Add("Split.Event", true, pre+"Stage Events", "Split");
  settings.SetToolTip("Split.Event", "Split when an event occurs during a stage");
  settings.Add("Split.Route", false, pre+"Custom Splits", "Split");
  settings.SetToolTip("Split.Route", "Split when you reach certain areas.\n\nBy default this uses the route file:\n" + F.RoutePathFull(null) + "\n\nSelect one of ALPHA/BRAVO/CHARLIE below to use a different route file instead.\n\nSee the README for more information on custom splits.");
  settings.Add("Split.Route.A", false, pre+"Use route ALPHA", "Split.Route");
  settings.SetToolTip("Split.Route.A", "Route file:\n" + F.RoutePathFull("A"));
  settings.Add("Split.Route.B", false, pre+"Use route BRAVO", "Split.Route");
  settings.SetToolTip("Split.Route.B", "Route file:\n" + F.RoutePathFull("B"));
  settings.Add("Split.Route.C", false, pre+"Use route CHARLIE", "Split.Route");
  settings.SetToolTip("Split.Route.C", "Route file:\n" + F.RoutePathFull("C"));
  
  
  for (int i = 1; i <= 10; i++) {
    string name = string.Format("Stage {0}: {1}", i, StageNames[i - 1]);
    settings.Add("Split.Stage." + i, true, pre+name, "Split.Stage");
    settings.Add("Split.Event.Stage" + i, true, pre+name, "Split.Event");
  }

  D.Events = new Dictionary<int, dynamic>();
  D.Missions = new Dictionary<int, dynamic>();
  D.Bosses = new Dictionary<string, dynamic>();
  D.Coordinates = new Dictionary<string, List<dynamic>>();
  foreach (var evt in Events) {
    string skip = evt.Skippable ? "[S] " : "";
    settings.Add(evt.SettingsKey, evt.DefaultEnabled, pre+skip+evt.Description, "Split.Event.Stage" + evt.Stage);
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

    F.RoutePath = (Func<string>)(() => {
      string ext = String.Empty;
      foreach (var l in new char[] { 'A', 'B', 'C' }) {
        if (settings["Split.Route." + l])
          ext = "." + l;
      }
      return Path.Combine(D.LiveSplitPath, "UnMetal.Route" + ext + ".txt");
    });

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

    F.SettingEnabled = (Func<string, bool>)((key) => 
      (settings.ContainsKey(key) && (settings[key])) );

    F.UpdateCurrent = (Action)(() => {
      var cur = current as IDictionary<string, object>;
      foreach (var w in vars.D.M)
        cur[w.Name] = w.Current;

      if (D.Debug) {
        foreach (var w in vars.D.A) {
          string content = "";
          int j = 0;
          for (int i = 0; i < w.Value.Length; i++) {
            content += (w.Value.Current[i] == 0) ? "x" : (j % 10).ToString();
            j++;
          }
          cur[w.Key] = content;
        }
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
      var stage = Math.Max(M["Stage"].Current - 1, 0);

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

    F.LoadRouteFromFile = (Action)(() => {
      var route = new List<int[]>();
      int stage = 0;
      var coordSplit = new char[] { ',', '?', '!' };
      var commentSplit = new string[] { "//" };

      string path = F.RoutePath();
      if (File.Exists(path)) {
        string[] lines = File.ReadAllLines(path);
        foreach (string l in lines) {
          string line = l.Trim().ToLower();

          if (line.StartsWith("stage")) {
            if (int.TryParse(line.Substring(6), out stage)) {
              //F.Debug("found stage " + stage);
              if ( (stage < 1) || (stage > 10) )
                stage = 0;
            }
          }
          else if (stage == M["Stage"].Current) {
            if (line.Contains(",")) {
              var bits = line.Split(coordSplit, StringSplitOptions.RemoveEmptyEntries);
              int x; int y;
              if ( (int.TryParse(bits[0], out x)) && (int.TryParse(bits[1], out y)) ) {
                int optional = line.Contains("?") ? 1 : 0;
                int enabled = line.Contains("!") ? 1 : 0;
                int en;
                if ( (enabled == 1) && (bits.Length > 2) && (int.TryParse(bits[2], out en)) )
                  enabled = en;
                //F.Debug("new coord " + x.ToString() + "," + y.ToString());
                route.Add( new int[] { x, y, enabled, optional } );
              }
            }
          }
        }
        D.Route = route;
      }
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
    new MemoryWatcher<bool>(offset + 0x54) { Name = "InCutscene" },
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

    if (settings["Split.Route"]) {
      if (M["Stage"].Changed)
        F.LoadRouteFromFile();

      if (D.RouteIndex < D.Route.Count) {
        int roomsAhead = 0;
        int optionalGroup = 0;
        int[] coord;
        do {
          coord = D.Route[D.RouteIndex + roomsAhead];
          if ( (roomsAhead != 0) && (coord[3] == optionalGroup) ) {}
          else if ( (coordX == coord[0]) && (coordY == coord[1]) ) {
            D.RouteIndex += roomsAhead;
            if (coord[2] == 1) {
              F.Debug( string.Format("SPLIT for next room ({0},{1}) in Stage {2} route",
                coordX, coordY, stage ) );
              return true;
            }
          }
          optionalGroup = coord[3];
          roomsAhead++;
        } while ( (coord[3] != 0) && ((D.RouteIndex + roomsAhead) < D.Route.Count) );
      }
    }

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