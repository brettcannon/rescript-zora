open Zora

zora("should skip some tests", async t => {
  t->skip("broken test", async t => {
    t->fail(~msg="Test is broken")
  })

  t->blockSkip("also broken", t => {
    t->fail(~msg="Test is broken, too")
  })
})
