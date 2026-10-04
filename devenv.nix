{
  pkgs,
  lib,
  config,
  inputs,
  bikeshed,
  ...
}@args:
let
  lib' = bikeshed.lib;
in
{
  imports = [
    bikeshed.devenvModules.recommended
  ];

  packages = with pkgs; [
    act
    actionlint
    gh
    shellcheck
    yamlfmt
  ];

  git-hooks.hooks = {
    actionlint = {
      enable = true;
      name = "actionlint";
      entry = "${pkgs.actionlint}/bin/actionlint";
      files = "^\\.github/workflows/.*\\.ya?ml$";
    };
  };

  # Declare the resource-isolated "agents" profile
  profiles.agents.module = {
    imports = [
      inputs.bikeshed.devenvModules.agents
    ];

    agents = {
      claude.enable = true;
      gemini.enable = true;
    };
  };
}
