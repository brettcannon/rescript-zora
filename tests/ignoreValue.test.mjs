// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Zora from "../src/Zora.mjs";
import * as Zora$1 from "zora";

Zora$1.test("Test ignoring values", (async function (t) {
        t.test("Option", (async function (t) {
                return Zora.optionSome(t, 42, Zora.ignoreValue);
              }));
        t.test("Result", (async function (t) {
                return Zora.resultOk(t, {
                            TAG: "Ok",
                            _0: 42
                          }, Zora.ignoreValue);
              }));
      }));

export {
  
}
/*  Not a pure module */