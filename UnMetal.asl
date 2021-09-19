/*********************************************************/
/* UnMetal (PC) Autosplitter dev                         */
/*                                                       */
/* Created by bmn for Metal Gear Solid Speedrunners      */
/*                                                       */
/* Thanks to unepic_fran, Jacklifear, SRGTSilent         */
/* for their help and input                              */
/*********************************************************/


state("UnMetal_Demo") {
  
}


startup {
  
  dynamic D = new ExpandoObject();
  dynamic F = new ExpandoObject();
  dynamic New = new ExpandoObject();
  D.F = F;
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
  
  

  F.NewEvent = (Func<uint, uint, string, bool, string, dynamic>)(
    (offset, stage, description, defaultEnabled, toolTip) => {
    dynamic o = new ExpandoObject();
    o.Offset = offset;
    o.OffsetHex = offset.ToString("X2");
    o.Stage = stage;
    o.Description = description;
    o.DefaultEnabled = defaultEnabled;
    o.ToolTip = toolTip;
    o.Enabled = (Func<bool>)(() => F.EventEnabled(offset));
    return o;
  });


  var Events = new List<dynamic>() {
    F.NewEvent(0x00, 1, "Escaped the cell", true, null),
    F.NewEvent(0x08, 1, "Talked to Col. Harris", false, null),
  };

  settings.Add("Opt.Debug", true, "Debug Logging");
  settings.Add("Opt.Debug.File", true, "Save debug information to LiveSplit directory", "Opt.Debug");
  settings.SetToolTip("Opt.Debug.File", "Log location: " + D.DebugLogPath);
  settings.Add("Opt.Debug.StdOut", true, "Log debug information to Windows debug log", "Opt.Debug");
  settings.SetToolTip("Opt.Debug.StdOut", "This can be viewed in a tool such as DebugView.");

  settings.Add("Split", true, "Split on...");
  settings.Add("Split.Stage", true, "Stage Complete", "Split");
  settings.SetToolTip("Split.Stage", "Split on Stage Complete");
  settings.Add("Split.Event", true, "Stage Events", "Split");
  settings.SetToolTip("Split.Event", "Split when an event occurs during a stage");
  
  for (int i = 1; i <= 3; i++) {
    string name = "Stage " + i;
    settings.Add("Split.Stage." + i, true, name, "Split.Stage");
    settings.Add("Split.Event.Stage" + i, true, name, "Split.Event");
  }

  D.Events = new Dictionary<uint, dynamic>();
  foreach (var evt in Events) {
    string key = "Split.Event." + evt.OffsetHex;
    settings.Add(key, evt.DefaultEnabled, evt.Description, "Split.Event.Stage" + evt.Stage);
    if (evt.ToolTip != null) {
      settings.SetToolTip(key, evt.ToolTip);
    }
    D.Events.Add(evt.Offset, evt);
  }

}


init {
  var D = vars.D; var F = D.F;

  if (!D.Initialised) {
    D.Initialised = true;

    F.Debug = (Action<string>)((message) => {
      if (settings["Opt.Debug.File"]) D.DebugLogBuffer.Add(
        string.Format("[{0}] {1}", DateTime.Now.ToString("T"), message));
      if (settings["Opt.Debug.StdOut"]) print("[UnMetal] " + message);
    });

    F.EventLogWritten = new EntryWrittenEventHandler((Action<object, EntryWrittenEventArgs>)((sender, e) => {
      var entry = e.Entry;
      print("1");
      print(settings["Opt.Debug.File"].ToString());
      print(entry.Source);
      print (entry.EntryType.ToString());
      if ( (settings["Opt.Debug.File"]) && (entry.Source.Equals("LiveSplit"))
        && (entry.EntryType.ToString().Equals("Error")) ) {
        if ( (entry.TimeGenerated - D.LastErrorTime).Seconds > 4 ) {
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


    F.NewCompletedEvents = (Func<List<dynamic>>)(() => {
      var o = new List<dynamic>();
      for (int i = 0; i < current.EventsArray.Length; i += 4) {
        if ( (current.EventsArray[i] == 1) && (old.EventsArray[i] == 0)
          && (D.Events.ContainsKey(i)) ) {
          o.Add(D.Events[i]);
        }
      }
      return o;
    });

    F.EventEnabled = (Func<uint, bool>)((offset) => { // use event object instead?
      string key = "Split.Event." + offset.ToString("X2");
      return (settings.ContainsKey(key) && (settings[key]));
    });
  }
  
  F.Debug( string.Format("Attached to UnMetal process ({0} bytes)",
    modules.First().ModuleMemorySize) );
}


start {
  if (vars.D.StartInstantly) {
    vars.D.StartInstantly = false;
    return true;
  }
  if (current.TotalAttempts > old.TotalAttempts) {
    D.Debug("START for new attempt");
    return true;
  }
  return false;
}


reset {
  if (current.TotalAttempts > old.TotalAttempts) {
    vars.D.StartInstantly = true;
    F.Debug("RESET + START for new attempt")
  }
  return false;
}


gameTime {
  return TimeSpan.FromSeconds(current.GameTime);
}


isLoading {
  return true;
}

shutdown {
  vars.D.EventLog.EntryWritten -= vars.D.F.EventLogWritten;
  vars.D.F.FlushDebugBuffer();
}



split {
  var D = vars.D; var F = D.F;

  foreach (var evt in F.NewCompletedEvents()) {
    if (evt.Enabled()) {
      F.Debug( string.Format("SPLIT for new Stage {0} event \"{1}\"",
        evt.Stage, evt.Description) );
      return true;
    }
    else F.Debug( string.Format("New Stage {0} event \"{1}\" (split disabled)",
      evt.stage, evt.Description) );
  }

  return false;

}