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

let ignoreValue = (zora: t, _value: 'unimportant): unit => {
  // Needs to make _some_ check in order to increment the test count.
  zora->ok(true, ~msg="value is inconsequential")
}

let optionNone = (zora: t, actual: option<'a>, ~msg: option<testMessage>=?) => {
  let defaultMessage = "Expected None value, got Some"

  zora->ok(actual->Option.isNone, ~msg=msg->Option.getOr(defaultMessage))
}

let optionSome = (zora: t, actual: option<'a>, check: (t, 'a) => unit) => {
  switch actual {
  | None => zora->fail(~msg="Expected Some value, got None")
  | Some(value) => zora->check(value)
  }
}

let resultError = (zora: t, actual: result<'a, 'b>, check: (t, 'a) => unit) => {
  switch actual {
  | Ok(_) => zora->fail(~msg="Expected Error value, got Ok")
  | Error(value) => zora->check(value)
  }
}

let resultOk = (zora: t, actual: result<'a, 'b>, check: (t, 'a) => unit) => {
  switch actual {
  | Error(_) => zora->fail(~msg="Expected Ok value, got Error")
  | Ok(value) => zora->check(value)
  }
}
