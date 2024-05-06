open Zora

zoraBlock("Should run some simple blocking tests", t => {
  t->block("should greet", t => {
    t->ok(true, "hello world")
  })

  t->block("should answer question", t => {
    let answer = 42
    t->equal(answer, 42, ~msg="should be 42")
  })
})
