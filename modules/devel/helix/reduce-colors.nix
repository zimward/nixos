# literals and comments get colour; keywords, operators, punctuation and
# variables stay in the plain foreground colour.
let
  plain = {
    fg = "fg";
  };
  dim = {
    fg = "fg-dark";
  };
in
{
  # keep coloured: names of functions and types
  function = {
    fg = "blue";
  };
  "function.builtin" = {
    fg = "blue";
  };
  "function.macro" = {
    fg = "cyan";
  };
  "function.special" = {
    fg = "cyan";
  };
  type = {
    fg = "aqua";
  };
  "type.builtin" = {
    fg = "aqua";
  };
  "type.enum.variant" = {
    fg = "aqua";
  };
  constructor = {
    fg = "aqua";
  };

  # keep coloured: literals
  string = {
    fg = "light-green";
  };
  "string.regexp" = {
    fg = "light-green";
  };
  "string.special" = {
    fg = "light-green";
  };
  constant = {
    fg = "orange";
  };
  "constant.builtin" = {
    fg = "orange";
  };
  "constant.character" = {
    fg = "light-green";
  };
  "constant.character.escape" = {
    fg = "light-green";
  };

  # plain: everything that is mostly noise
  keyword = plain;
  "keyword.control" = plain;
  "keyword.control.import" = plain;
  "keyword.control.return" = plain;
  "keyword.directive" = plain;
  "keyword.function" = plain;
  "keyword.operator" = plain;
  variable = plain;
  "variable.builtin" = plain;
  "variable.other.member" = plain;
  "variable.parameter" = plain;
  namespace = plain;
  label = plain;
  attribute = plain;
  special = plain;
  tag = plain;
  operator = dim;
  punctuation = dim;
}
