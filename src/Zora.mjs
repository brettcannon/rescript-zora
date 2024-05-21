// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Option from "@rescript/core/src/Core__Option.mjs";

function ignoreValue(zora, _value) {
  zora.ok(true, "value is inconsequential");
}

function optionNone(zora, actual, msg) {
  zora.ok(Core__Option.isNone(actual), Core__Option.getOr(msg, "Expected None value, got Some"));
}

function optionSome(zora, actual, check) {
  if (actual !== undefined) {
    return check(zora, Caml_option.valFromOption(actual));
  } else {
    zora.fail("Expected Some value, got None");
    return ;
  }
}

function resultError(zora, actual, check) {
  if (actual.TAG !== "Ok") {
    return check(zora, actual._0);
  }
  zora.fail("Expected Error value, got Ok");
}

function resultOk(zora, actual, check) {
  if (actual.TAG === "Ok") {
    return check(zora, actual._0);
  }
  zora.fail("Expected Ok value, got Error");
}

export {
  ignoreValue ,
  optionNone ,
  optionSome ,
  resultError ,
  resultOk ,
}
/* No side effect */
