# SemSolver

Solve any [Semantle](https://semantle.novalis.org/) puzzle in as few guesses as possible.

I've not extensively tested SemSolver with other Semantle results, but so far it's been able to solve everything with just two guesses.

## Why?

No, I don't actually use this to solve Semantle puzzles.  In fact, given that a daily Semantle is pretty useless if you already know the answer, I only ever run this on a Semantle that I've already solved.

Semantle was partially inspired by Wordle.  Many programmers (myself included) saw Wordle and immediately wondered, "How efficient a Wordle solver can I write?"  This is me doing the same thing for Semantle, and also learning a bit more about my favourite language (and especially [Streams](https://hexdocs.pm/elixir/Stream.html)) in the process.

Of course, Semantle gives much more precise feedback than Wordle does, and both the source code and the dataset it uses are publicly available.  As such, the challenge of designing an efficient Semantle solver is much less about information theory ("how few guesses do I need?"), and much more about data handling ("can I search a 3.6GB dataset in a reasonable amount of time and memory usage?").  If you're curious about the process that led to this solution, check out [my design notes](/DESIGN.md).

On a more practical level, it should be fairly easy to turn this into a "hint engine" — if you're stuck on a particular Semantle, it could find a word around a given score to help you out a bit.  (Maybe I'll do that the next time I get stuck.)

## Setup

Just run `mix deps.get` and `mix compile`.  The appropriate dataset (~1.7 GB) will be downloaded automatically.

The test suite (`mix test`) can also be used to run some basic tests against known Semantle puzzles.

## Usage

Currently there's no command-line interface.  Instead, you can solve puzzles by running `iex -S mix` and running `SemSolver.solve(guesses)`, where `guesses` is a mapping of guess words to scores.  (The scores are the two-decimal-digit numbers from the "similarity" column, and NOT the "top 1000" word ranks.)

For example, here's my (totally human) guess history for Semantle #43: ![Semantle 43](https://i.wisq.net/semantle_43.png)

And here's how fast I could've solved that with `SemSolver`:

```
iex(1)> SemSolver.solve(orbit: 4.64)
[debug] Found 1 reference words in 128ms
[debug] Matched "action" in 32ms
[debug] Total solve time was 166ms
#Word<"action">
```

Well that's not right.  Sometimes one guess is enough, but since the Semantle page only gives you two digits of precision to your answers, usually it takes a second word to triangulate the target word.  Let's try adding my second guess:

```
iex(2)> SemSolver.solve(orbit: 4.64, massive: 1.71)
[debug] Found 2 reference words in 122ms
[debug] Matched "greet" in 589ms
[debug] Total solve time was 711ms
#Word<"greet">
```

That's more like it.
