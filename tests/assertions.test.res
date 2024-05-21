open Zora

zora("Test assertions", async t => {
  t->test("With descriptions", async t => {
    t->equal(42, 42, ~msg="Numbers are equal")
    t->notEqual(42, 43, ~msg="Numbers are not equal")
    let x = {"hello": "world"}
    let y = x
    let z = {"hello": "world"}
    t->is(x, x, ~msg="object is object")
    t->is(x, y, ~msg="object is object")
    t->isNot(x, z, ~msg="object is not object with same values")
    t->equal(x, z, ~msg="Object is deep equal")
    t->ok(true, ~msg="boolean is ok")
    t->notOk(false, ~msg="boolean is not ok")
    t->optionNone(None, ~msg="None is None")
    t->optionSome(
      Some(x),
      (t, n) => t->equal(n["hello"], "world", ~msg="option should be hello world"),
    )
    t->resultError(Error(x), (t, n) => t->is(x, n, ~msg="Is Error Result"))
    t->resultOk(Ok(x), (t, n) => t->equal(n["hello"], "world", ~msg="Is Ok Result"))
  })

  t->test("Without descriptions", async t => {
    t->equal(42, 42)
    t->notEqual(42, 43)
    let x = {"hello": "world"}
    let z = {"hello": "world"}
    t->is(x, x)
    t->isNot(x, z)
    t->ok(true)
    t->notOk(false)
    t->optionNone(None)
    // The following functions have no ~msg dur to their check function argument:
    //   optionSome
    //   resultOk
    //   resultError
  })
})
