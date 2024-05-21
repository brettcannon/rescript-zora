# rescript-zora: Lightning-fast unit tests

This package provides [ReScript](https://rescript-lang.org/) bindings for the
[Zora](https://github.com/lorenzofox3/zora) testing framework. ReScript and Zora
go very well together because they have a common mission of SPEED.

In the interest of maintaining that speed, this package is asynchronous by
default, though you can create blocking tests if you prefer.

This package mostly just binds directly to Zora, but there are a couple
niceties to help work with ReScript promises and the standard library.

## If you've used older versions of this package

### 3 → 4

The code was updated to ReScript 11.

Nearly all check functions have gained an optional `~msg` argument for passing
in the message for the check. This makes the message optional, defaulting to
what Zora provides as a message.

The `resultError` function now accepts a check function to verify the value
contained by the `Error`.

There is a new `ignoreValue` check function to pass to the `option*` and
`result*` functions when the values are inconsequential and the type of variant
is the purpose of the test.

### 2 → 3

I've migrated everything to async/await syntax and it now requires
ReScript 10.1. You'll need to convert any non-blocking tests in your
existing codebase to return promise or define them with async, but
you don't need to throw `done()` calls in all your async tests.

## Installation

_Note: If you don't have a ReScript 9.1.1 project initialized already, the
fastest way to get one is with `npx rescript init myproject`._

Install [zora](https://github.com/lorenzofox3/zora) and this package:

```
npm install --save-dev @dusty-phillips/rescript-zora
```

Add `@dusty-phillips/rescript-zora` as a dependency in your `rescript.json`:

```
"bs-dev-dependencies": ["@dusty-phillips/rescript-zora"]
```

## Suggested configuration

Recent versions of node seem to cooperate better if you explicitly use the .mjs or
.cjs suffix for your files. So you'll want your `rescript.json` to contain either:

- suffix: `.mjs` and module: `esmodule`
- suffix: `.cjs` and module: `commonjs`

I use `.mjs` in this configuration, but I have tested it with `.cjs` and it seems
to work.

You'll probably also want to add the following `package-specs` configuration to
your `rescript.json`:

```json
  "suffix": ".mjs",
  "package-specs": {
    "module": "esmodule",
    "in-source": true
  },
```

If you like to keep your tests separate from your source code, you'll need to
add that directory so ReScript will compile your test files:

```json
  "sources": [
    {
      "dir": "src",
      "subdirs": true
    },
    { "dir": "tests", "subdirs": true, "type": "dev" }
  ],
```

So a minimal `rescript.json` might look like this:

```json
{
  "name": "myproject",
  "version": "2.0.0",
  "suffix": ".mjs",
  "sources": [
    {
      "dir": "src",
      "subdirs": true
    },
    { "dir": "tests", "subdirs": true, "type": "dev" }
  ],
  "package-specs": {
    "module": "esmodule",
    "in-source": true
  },
  "bs-dev-dependencies": ["@dusty-phillips/rescript-zora"]
}
```

## Stand-alone test

The simplest possible Zora test looks like this:

```rescript
// tests/simple.test.res
open Zora

zoraBlock("should run a test synchronously", t => {
  let answer = 3.14
  t->equal(answer, 3.14, ~msg="Should be a tasty dessert")
})
```

Building this with ReScript will output a `tests/simple.mjs` file that
you can run directly with `node`:

```tap
╰─○ node tests/standalone.js
TAP version 13
# should run a test asynchronously
ok 1 - Should answer the question
# should run a test synchronously
ok 2 - Should be a tasty dessert
1..2

# ok
# success: 2
# skipped: 0
# failure: 0
```

This output is in [Test Anything Protocol](https://testanything.org/) format.
The [zora docs](https://github.com/lorenzofox3/zora) go into more detail on how
it works with Zora.

## Combining tests

You can include multiple `zoraBlock` statements, or you can pass the `t` value
into the `block` function:

```rescript
open Zora

zoraBlock("Should run some simple blocking tests", t => {
  t->block("should greet", t => {
    t->ok(true, ~msg="hello world")
  })

  t->block("should answer question", t => {
    let answer = 42
    t->equal(answer, 42, ~msg="should be 42")
  })
})
```

## Running tests in parallel (async)

The `Block` in `zoraBlock` indicates that this is a blocking test. It's faster
to run multiple independent tests in parallel:

```rescript
// tests/standaloneParallel.res

open Zora

zora("should run a test asynchronously", async t => {
  let answer = 42
  t->equal(answer, 42, ~msg="Should answer the question")
})

zora("should run a second test at the same time", async t => {
  let answer = 3.14
  t->equal(answer, 3.14, ~msg="Should be a tasty dessert")
})
```

Note the absence of `zoraBlock`, and the presence of `async`. You can
await other promises inside the test if you want.

## Combining parallel tests

You can nest parallel async tests inside a blocking or non-blocking test, and
run blocking tests alongside parallel tests:

```rescript
// parallel.test.res
open Zora

let wait = (amount: int) => {
  Js.Promise2.make((~resolve, ~reject) => {
    reject->ignore
    Js.Global.setTimeout(_ => {
      resolve(. Js.undefined)
    }, amount)->ignore
  })
}

zora("Some Parallel Tests", async t => {
  let state = ref(0)

  t->test("parallel 1", async t => {
    {await wait(10)}-> ignore
    t->equal(state.contents, 1, ~msg="parallel 2 should have incremented by now")
    state.contents = state.contents + 1
    t->equal(state.contents, 2, ~msg="parallel 1 should increment")
  })

  t->test("parallel 2", async t => {
    t->equal(state.contents, 0, ~msg="parallel 2 should be the first to increment")
    state.contents = state.contents + 1
    t->equal(state.contents, 1, ~msg="parallel 2 should increment")
  })

  t->test("parallel 3", async t => {
    {await wait(20)}->ignore
    t->equal(state.contents, 2, ~msg="parallel 1 and 2 should have incremented by now")
    state.contents = state.contents + 1
    t->equal(state.contents, 3, ~msg="parallel 3 should increment last")
  })
})
```

This is the default and preferred test setup (zora and test) to take advantage of
parallelism for speed. Note that you can combine parallel and blocking tests
in the same `zora` or `zoraBlocking` block as well.

## Test runner

You probably don't want to run each of your test files using separate `node`
commands, though. You can use any TAP compliant test runner ([see
here](https://github.com/sindresorhus/awesome-tap) for a list), but your best
bet is probably to use Zora's bundled
[pta](https://github.com/lorenzofox3/zora/tree/master/pta) runner with
[onchange](https://github.com/Qard/onchange) for watching for file changes:

```plaintext
npm install --save-dev pta onchange
```

With these installed, you can set the `test` command in your `scripts` as follows:

```json
  "test": "onchange --initial '{tests,src}/*.js' -- pta 'tests/*.test.js'",
```

Or, if you prefer to keep your tests alongside your code in your `src` folder:

```json
  "test": "onchange --initial 'src/*.js' -- pta 'src/*.test.js'",
```

Now `npm test` will do what you expect: run a test runner and watch for file
changes.

## Skip, only, and fail

Zora exposes functions to skip tests if you need to. If you have a failing
test, just replace the call to `Zora.test` with a call to `Zora.skip`. Or, if
you're running blocking tests, replace `Zora.block` with `Zora.blockSkip`.

For example:

```rescript
open Zora

zora("should skip some tests", t => {
  t->skip("broken test", t => {
    t->fail(~msg="Test is broken")
  })

  t->blockSkip("also broken", t => {
    t->fail(~msg="Test is broken, too")
  })

})
```

The above also illustrates the use of the `Zora.fail` assertion to force a test
to be always failing.

If you want to run and debug a single test, you can run it in `only` mode. As
with skip, change the test's name from `test` to `only` or `block` to
`blockOnly`. You must also change the top level `zora`/`zoraBlock` to
`zoraOnly`/`zoraBlockOnly`.

```rescript
open Zora

zoraOnly("should skip some tests", t => {
  t->only("only run this test", t => {
    t->ok(true, ~msg="Only working test")
  })

  t->test("don't run this test", t => {
    t->fail(~msg="Test is broken")
  })

})
```

However, `only` tests are intended only in development mode and zora will fail
by default if you try to run one. To run in only mode, you can run:

```shell
npm test -- --only
```

or

```shell
ZORA_ONLY=true npm test
```

If you use this feature a lot, you could also consider putting additional test
commands in your `package.json` scripts, one for local only development and one
for CI:

```json
"test": "onchange --initial '{tests,src}/*.js' -- pta 'tests/*.test.js'",
"test:only": "onchange --initial '{tests,src}/*.js' -- pta --only 'tests/*.test.js'",
"test:ci": "pta 'tests/*.test.js'",
```

## Assertions

This library models all the default assertions provided by Zora except for
those dealing with raising exceptions, which don't map neatly to ReScript
exceptions. There are additional bindings for checking if a ReScript `option`
is `Some()` or `None` or if a `Result` is `Ok()` or `Error()` and asserting
on the value therein (except for `None` as there is no value to check). A
`ignoreValue` function is provided in those instances where asserting on the
value is unimportant.

In the interest of avoiding bloat, I do not intend to add a lot of other
ReScript-specific assertions.

```rescript
//tests/assertions.test.res
open Zora

zora("Test assertions", t => {
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
  t->optionSome(Some(x), (t, n) => t->equal(n["hello"], "world", ~msg="option should be hello world"))
  t->resultError(Error(x), (t, n) => t->equal(n["hello"], "world", ~msg="Is Error Result"))
  t->resultOk(Ok(x), (t, n) => t->equal(n["hello"], "world", ~msg="Is Ok Result"))
})
```

## Running in the browser

Zora supports running tests in the browser, but I have not tested it with this
ReScript implementation. I am open to PRs that will make this ReScript
implementation work in the browser if changes are required.

## Source Maps

The biggest problem with this library is that test failures point to the lines
in the compiled js files instead of ReScript itself. If someone knows how to
configure ReScript and zora to use source maps, I'd love a PR.

## Contributing

PRs are welcome.

## Releasing

This is for my reference

- update the version in `rescript.json`
- `npx np`
