{ lib, ... }:
with lib;
let
  discover = directory:
    let
      entries = builtins.readDir directory;
    in
    concatMap (name:
      let
        path = directory + "/${name}";
        type = entries.${name};
      in
      if type == "directory" then
        discover path
      else if type == "regular" && hasSuffix ".nix" name then
        [ path ]
      else
        [ ]
    ) (builtins.attrNames entries);
in
{
  imports = discover ../modules;
}
