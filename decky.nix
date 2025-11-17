{ config, pkgs, ... }:

# Setup the service and start decky after using the installer from online  
let
  plugin_loader = pkgs.buildFHSUserEnv {
    name = "PluginLoader";
    targetPkgs = p: with p; [
      zlib
      coreutils
      /* needed for css loader */
      curl
      unzip
      /* needed for volume mixer */
      pulseaudio
    ];
    runScript = "/home/chris/homebrew/services/PluginLoader";
  };
in 
{
  systemd.services.plugin_loader = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment = {
      PLUGIN_PATH = "/home/chris/homebrew/plugins";
      LOG_LEVEL = "INFO";
    };
    serviceConfig = {
      Type = "simple";
      User = "root";
      Restart = "always";
      ExecStart = "${plugin_loader}/bin/PluginLoader";
      WorkingDirectory = "/home/chris/homebrew/services";
      KillSignal = "SIGKILL";
    };
  };
}
