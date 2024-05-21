open Zora

// Testing two different types to make sure `ignoreValue` supports type variance.
zora("Test ignoring values", async t => {
  t->test("Option", async t => {
    t->optionSome(Some(42), ignoreValue)
  })

  t->test("Result", async t => {
    t->resultOk(Ok(42), ignoreValue)
  })
})
