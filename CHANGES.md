# BambuStudio / slynn1324 fork

There are just a few features from BambuStudio that I'm currently missing for it to be the ideal multi-purpose slicer for my use cases.  This fork adds those features, attempting to diverge from upstream as little as possible.  Hopefully, these features will someday be absorbed or otherwise made unnecessary and I'll close down this fork. 


# Changes from the original BambuStudio 

## Add Moonraker compatible metadata to bottom of GCode export for non-Bambu Printers

1) Uncomment and conditionalize exsiting lines of code that generate the embedded base64 thumbnail in generated GCode - condiitonal for non-Bambu printers.
2) Change the size of the Thumbnail from 50x50 to 300x300.  This is currently not configurable.  A code search appears this only affects the embedded thumbnail for non-Bambu printers but I'm not 100% positive.  I have not noticed any other side effects of this change.
3) Add more print metadata (e.g., temparatures, filament settings) in PrusaSlicer/OrcaSlicer format to the end of the GCode output file for non-Bambu printers, so that the metadata populated by Moonraker for Mainsail is complete. 

Files
```
src/libslic3r/GCode.cpp
src/libslic3r/GCode/GCodeProcessor.cpp
src/libslic3r/GCode/GCodeProcessor.hpp
src/libslic3r/GCode/ThumbnailData.hpp
```

As of 8/22/23 - under PR -- https://github.com/bambulab/BambuStudio/pull/2333



## bambu_status_webhook_url

Optionally publishes the status reports received over a LAN connection from a Bambu Printer to a configured webhook url.

The latest P1 firmware appears to have restricted the use of MQTT to a single receiver at a time -- only one instance of BambuStudio or a 3rd party MQTT client can connect simultaneously, breaking 3rd party monitoring.  This requires a slicer instances to remain open on a PC for monitoring, but makes integration possible without adding load to the printer.

To configure, add the following to BambuStudio.conf (~/Library/Application Support/BambuStudio/BambuStudio.conf), configuring the host and port:
```
{
    "app": {
        ...
        "bambu_status_webhook_url": "http://localhost:3000",
        ...
    }
}
```

Files
```
src/slic3r/GUI/GUI_App.cpp
```

When configured, BambuStudio will attempt to send via HTTP POST the raw JSON message that was received over the Printer interface connection.  These are in the same format as the device/{sn}/report MQTT messages.  The device id in use for the UI is provided as the "dev_id" header on the HTTP POST request. 

The ultimate goal is to enable reliable HomeAssistant integration for remote monitoring and alerts, without remaining in LAN only operation.  

A simple sample implementation of a webhook receiver that bridges to a MQTT broker is available at https://www.github.com/slynn1324/bambu-bridge.  



