{ pkgs, inputs }:
inputs.wrappers.wrapperModules.fuzzel.apply {
  inherit pkgs;
  settings = {
    main = {
      anchor = "top";
      layer = "overlay";
    };
    colors = {
      #apparently fuzzel wants an alpha channel too?
      background = "1a1b26ff";
      text = "a9b1d6ff";
    };
  };
}
