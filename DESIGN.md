# Designing SemSolver

## Parsing the dataset

Although it wasn't too hard to track down the dataset that Semantle uses, actually parsing that dataset was a different issue.  I couldn't find a reference for the file format, and the Python `word2vec` code was a bit obtuse.

### As converted text

Initially, I used a modified version of [convertvec](https://github.com/marekrei/convertvec) to convert the binary file to a text representation.  This was a lengthy process that took several minutes and many gigabytes of disk space.

In order to reduce parsing time, the Elixir code would only read the word and the entire coordinate set (i.e. the rest of the line), dumping the unparsed coordinates into the `Word` structure and only parsing them on demand.  This helped alleviate a lot of the parsing overhead — especially when we're just skimming through the data for specific words (during the "find guessed words" phase), and only care about the coordinates of those specific words.

Later, I realised this also had the advantage that I could reduce the size of the wordset using `grep`, limiting it to just lowercase words with no punctuation — a set of only 156,268 words out of the set's nominal 3,000,000 words, further reducing our overhead.  However, most of these common English words were at the top of the file anyway — and since `SemSolver` only returns the first matching word it finds, it generally does not need to dig very deep into the dataset to find what it's after.

### As binary data

Eventually, long after the rest of the solver was made, I finally revisited this and — using the `convertvec` source code as a reference — managed to read the `.bin.gz` directly, with no external parsing or decompression required.

The dataset starts with a header, in plain text format, with the number of rows (words) and number of columns (coordinate dimensions, a.k.a. `size`), separated by spaces.  Each row then contains a word, a space separator, and a total of `size` IEEE 754 floating point numbers in 32-bit (4-byte) binary format.  Since the Google dataset uses `size=300`, that means 1200 bytes of coordinate data per word.

Since the words are of variable length, I needed to find an efficient way to read them.  Reading a single character at a time is fine for C, but too slow in a high-level functional language like Elixir.  And over-reading and seeking backwards is not a realistic option when we're dynamically `gunzip`ping its data as we go.  Thankfully, since we know the coordinates block will always be 1200 bytes long, we can just read the first 1200 bytes, split it into a word and partial coordinates data, and then read the remaining coordinates data in a precise smaller read.

(In theory, we should read twice, since the maximum word length is 2000 bytes according to `convertvec`.  In practice, the longest word in the Google dataset is still under 100 bytes, so I didn't bother adding a second read.)

Of course, going back to raw binary data meant I didn't get the advantage of a smaller dataset.  But it also makes for a lot less setup cost, and eliminating the overhead of parsing text-based floating points made up for the increased dataset size.  Besides, most of those common words are at the top of the dataset anyway — the bottom consists of obscure multi-word phrases (presumably Google search terms) like `tongue_wagging_bassist`.

**Note:** Always use `IO.binread/2` for raw binary data!  Part of my earlier problems parsing the data was that `IO.read/2` was inserting a bunch of unexpected bytes — this became clear when I realised I was asking for 1200 bytes and actually getting 1515!

### Parsing at compile time

I did some experiments with loading the dataset at compile time, storing it in a module attribute, and using it at runtime that way.  But the compile times were atrocious, even when I used the filtered dataset.  (The unfiltered one took so long to compile that I gave up, especially since it was reaching 60+ GB of RAM usage at times.)

Even once compiled, there were still performance issues.  If I used a `Map` to index the words, then "known word" lookups were ultra-fast, but iterating through the dataset to find the target word was very slow — probably because it was no longer in "common words first" order.  If I stored it as a list, then matching was quite fast, but ultimately it still didn't provide enough of a performance boost to offset the terrible compile time.  (Even worse, you need to compile the datasets separately in `dev` and `test` environments.)

## Solving efficiently

This was actually the easy part.  There's two steps to any given solve, assuming you have a list of guessed words and their distance scores (note: **NOT** their top-1000 rank):

1. Find the guessed words in the dataset to get their coordinates.
2. Find word(s) whose distances to the guessed words match their distance scores.

For most words you might guess in a Semantle (and definitely for most solution words!), it turns out that both of these can be done really fast **so long as you don't do an exhaustive search**.  That's because (as per above) the Google dataset is sorted in a "common words first" order, so searches are typically very fast, so long as your search "short circuits" and exits as soon as it has what it needs.  This is why the solver just finds the first matching word and then stops.

Thus, step #1 (the "find phase") runs incredibly fast, since it just needs to locate those words in the dataset, and we don't even bother parsing the coordinates for all the words we skip.  Armed with a "search list" of words to find, we can retrieve them all in a single (partial) pass through the dataset — and by deleting words from the search list as we find them, we not only reduce the number of comparisons we need to do, we also have a clear indication of when we're done (i.e. when the search list is empty).

Step #2 (the "match phase") generally takes longer (2x to 20x or more), since it involves parsing and comparing the scores of every word in the dataset until it finds a matching target word.  Granted, this also greatly depends on how common the target word is — if you're looking for a common word with very uncommon guess words, the match phase might actually be faster.

Of course, both steps become incredibly slow if they're having trouble finding what they're after and have to exhaustively search the whole dataset.  If step #1 is taking a long time (or fails), check your guess spelling.  If it's step #2 taking a long time (or failing), check for typos in your scores.

### Parallel operation

In the ["splitter" branch](https://github.com/wisq/sem_solver/tree/splitter), I experimented with having many different processes load the dataset in parallel in both of the phases above.  The idea was that a top-level stream would pick `n` different file offsets to start (& stop) reading at, re-align those starting points so they occurred between words (i.e. on newlines), and emit a stream of streams that could then be read via [`Task.async_stream/3`](https://hexdocs.pm/elixir/1.13/Task.html#async_stream/3).

This was a minor speed increase, cutting the phase #2 operation time down by about half, in part because all the coordinate parsing and vector math operations were now happening in parallel.  However, it dramatically _increased_ the phase #1 time, since that phase was already very simple (and very order-dependent), and short-circuiting the search (i.e. removing words as we found them) was no longer possible.

Ultimately, the extra complexity wasn't worth it — especially if you're already trying to run multiple guesses in parallel, like we do in the test suite — and I dropped this approach.  (Plus it wouldn't have allowed us to switch to reading the gzipped binary dataset.)

In a more general sense, my feeling is that parallelisation is great if you really do need to run through the entire dataset — but most of `SemSolver`'s performance stems from short-circuiting an ideally-ordered dataset, and that becomes much more difficult when parallelised, so the gains aren't really worth it overall.
