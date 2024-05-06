// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Zora from "../src/Zora.mjs";
import * as Zora$1 from "zora";
import * as Caml_option from "rescript/lib/es6/caml_option.js";

Zora$1.test("Test assertions", (async function (t) {
        t.test("With descriptions", (async function (t) {
                t.equal(42, 42, "Numbers are equal");
                t.notEqual(42, 43, "Numbers are not equal");
                var x = {
                  hello: "world"
                };
                var z = {
                  hello: "world"
                };
                t.is(x, x, "object is object");
                t.is(x, x, "object is object");
                t.isNot(x, z, "object is not object with same values");
                t.equal(x, z, "Object is deep equal");
                t.ok(true, "boolean is ok");
                t.notOk(false, "boolean is not ok");
                Zora.optionNone(t, undefined, "None is None");
                Zora.optionSome(t, Caml_option.some(x), (function (t, n) {
                        t.equal(n.hello, "world", "option should be hello world");
                      }));
                Zora.resultError(t, {
                      TAG: "Error",
                      _0: x
                    }, "Is Error Result");
                return Zora.resultOk(t, {
                            TAG: "Ok",
                            _0: x
                          }, (function (t, n) {
                              t.equal(n.hello, "world", "Is Ok Result");
                            }));
              }));
        t.test("Without descriptions", (async function (t) {
                t.equal(42, 42);
                t.notEqual(42, 43);
                var x = {
                  hello: "world"
                };
                var z = {
                  hello: "world"
                };
                t.is(x, x);
                t.isNot(x, z);
                t.ok(true);
                t.notOk(false);
                Zora.optionNone(t, undefined, undefined);
                return Zora.resultError(t, {
                            TAG: "Error",
                            _0: x
                          }, undefined);
              }));
      }));

export {
  
}
/*  Not a pure module */
