type t
type zoraTest = t => promise<unit>
type zoraTestBlock = t => unit
type testTitle = string
type testMessage = string

@module("zora") external zora: (string, zoraTest) => unit = "test"
@module("zora") external zoraBlock: (string, zoraTestBlock) => unit = "test"
@module("zora") external zoraOnly: (string, zoraTest) => unit = "only"
@module("zora") external zoraBlockOnly: (string, zoraTestBlock) => unit = "only"

@send external test: (t, testTitle, zoraTest) => unit = "test"
@send external block: (t, testTitle, zoraTestBlock) => unit = "test"

@send external skip: (t, testTitle, zoraTest) => unit = "skip"
@send external only: (t, testTitle, zoraTest) => unit = "only"
@send external blockSkip: (t, testTitle, zoraTestBlock) => unit = "skip"
@send external blockOnly: (t, testTitle, zoraTestBlock) => unit = "only"

@send external equal: (t, 't, 't, ~msg: testMessage=?) => unit = "equal"
@send external notEqual: (t, 't, 't, ~msg: testMessage=?) => unit = "notEqual"
@send external is: (t, 't, 't, ~msg: testMessage=?) => unit = "is"
@send external isNot: (t, 't, 't, ~msg: testMessage=?) => unit = "isNot"
@send external ok: (t, bool, ~msg: testMessage=?) => unit = "ok"
@send external notOk: (t, bool, ~msg: testMessage=?) => unit = "notOk"
@send external fail: (t, ~msg: testMessage=?) => unit = "fail"

let optionNone = (zora: t, actual: option<'a>, ~msg: option<testMessage>=?) => {
  switch msg {
  | Some(description) => zora->ok(actual->Option.isNone, ~msg=description)
  | None => zora->ok(actual->Option.isNone)
  }
}
let optionSome = (zora: t, actual: option<'a>, check: (t, 'a) => unit) => {
  switch actual {
  | None => zora->fail(~msg="Expected Some value, got None")
  | Some(value) => zora->check(value)
  }
}

let resultError = (zora: t, actual: result<'a, 'b>, message: testMessage) => {
  zora->ok(actual->Result.isError, ~msg=message)
}
let resultOk = (zora: t, actual: result<'a, 'b>, check: (t, 'a) => unit) => {
  switch actual {
  | Error(_) => zora->fail(~msg="Expected ok value, got error")
  | Ok(value) => zora->check(value)
  }
}
