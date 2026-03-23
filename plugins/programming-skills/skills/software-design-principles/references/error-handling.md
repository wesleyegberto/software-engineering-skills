# Error Handling

---

## Types of Errors

Two fundamental categories:

| Type | Definition | How to handle |
|------|-----------|---------------|
| **Recoverable error** | Planned/expected in the program's flow (validation failures, connection timeouts, missing files) | Catch and handle — retry, transform, clean up, redirect, or suppress |
| **Bug** | Unexpected error that may not be noticed immediately; cannot be fixed without a code change and deploy | Let it propagate — abort the operation, do not silently swallow |

> Don't catch errors you don't intend to handle. Catching an error you cannot act on hides the problem and makes debugging harder.

### Systemic vs Domain Errors

| Kind | Meaning | Response |
|------|---------|----------|
| **Systemic error** | Infrastructure/system-level problem (network, DB, disk) | Handle or route around it; abort if nothing can be done |
| **Domain error** | Bad input or violated business rule | Return or throw a specific error the caller can act on; the operation can be retried after correction |

---

## When and Where to Handle an Error

> Errors need to be handled at the lowest level at which an informed decision can be made as to their disposition.

Let errors bubble up the call stack until they reach a point that has enough context
to decide what to do. A low-level utility reading a file should not decide whether
the application should retry, alert the user, or abort — that decision belongs to the
caller that understands the use case.

> There is no "fail fast" when the system simply must continue to operate.
> Error detection, trapping, and correction need to occur at the lowest possible level,
> as close to the source of error as can be had.
> The lowest level of decision making that can accommodate an error needs to do so in
> order to keep the system operational despite problems.

**Five valid reasons to catch an error:**

| # | Action | Appropriateness |
|---|--------|----------------|
| 1 | Solve the cause and **retry** the operation | Responsible |
| 2 | **Transform** into a different error type and re-throw | Responsible |
| 3 | **Clean up** partial state and re-throw | Responsible |
| 4 | **Redirect** the error elsewhere and continue | Situational |
| 5 | **Suppress** the error and continue | Rarely appropriate — document why |

Options 1–3 are the most defensible choices. Options 4–5 require careful justification.

---

## Error Types and Flow Control

### Throw Specific, Not Generic

Throw specific error types rather than generic ones (`Exception`, `Error`, `RuntimeException`).
Specific types:
- Make the intent explicit at the throw site
- Enable callers to catch selectively (catch the precise type they can handle)
- Produce more actionable stack traces during incident analysis

### Exceptions Are Not Flow Control

> An exception should say *what* happened, not *how* or *why* it happened.

Using exceptions for normal control flow (e.g., using `FileNotFoundException` to check
if a file exists, or using exceptions to exit a loop) conflates error conditions with
expected paths. This:
- Obscures intent — readers cannot tell whether a `catch` block is handling an error
  or a normal branch
- Degrades performance in runtimes where exception creation is expensive
- Makes the code harder to reason about and test

**Exceptions can legitimately signal pre-condition violations** to enforce a contract:
if a method's preconditions are not met, throwing is appropriate — it signals a
programming error, not a business condition.

### Checked Exceptions (Java-specific nuance)

> Checked exceptions have great value; however, they are frequently overused.
> In particular, they should never be used for programming errors, but absolutely
> should be used for resource errors and for flow control.
> Checked exceptions allow the compiler to guide you. — Russell Gold

**Risk of overuse:** Checked exceptions create a dependency between a method and *all*
of its direct and indirect callers. Any change to what exception is thrown forces
changes up the entire call chain. Use checked exceptions for conditions the immediate
caller is realistically expected to handle.

---

## Exceptions as Conditions (Goodenough, 1970)

Exceptions can derive from *normal conditions*, not only errors.

**Example:** After reading a file, signalling that the returned content is the last
block in the file — the next read would result in an EOF condition. This is not an
error; it is a state transition.

Goodenough's insight: exception-handling mechanisms are a general *condition signalling*
mechanism, not just an error propagation tool. Understanding this distinction helps
design cleaner APIs that communicate state changes without polluting return types.

---

## Design Implications for Code Review

When reviewing error handling, check:

- [ ] Are errors caught only where there is something meaningful to do with them?
- [ ] Do catch blocks handle one specific error type, not a broad `Exception`?
- [ ] Is the catch block taking one of the five valid actions (retry, transform, clean up, redirect, suppress)?
- [ ] Are suppressed errors at least logged with context?
- [ ] Are exceptions used for error signalling, not normal flow control?
- [ ] Are thrown exceptions specific enough to be caught selectively by callers?
- [ ] Is the error type (systemic vs domain) appropriate for the layer throwing it?
- [ ] Does catching a checked exception here make sense, or does it create unnecessary coupling up the call chain?

---

## References

- [Category Exception — C2 Wiki](https://wiki.c2.com/?CategoryException)
- [Exception Patterns — C2 Wiki](https://wiki.c2.com/?ExceptionPatterns)
- [The Error Model — Joe Duffy (2016)](https://joeduffyblog.com/2016/02/07/the-error-model/)
- [The Zen of Erlang — Fred Hebert](https://ferd.ca/the-zen-of-erlang.html)
- Papers:
  - [Exception Handling: Issues and a Proposed Notation — Goodenough (1975)](https://web.eecs.umich.edu/~weimerw/2006-615/reading/goodenough-exceptions.pdf)
  - [Exception Handling in CLU — Liskov & Snyder](http://csg.csail.mit.edu/pubs/memos/Memo-155/Memo-155-3.pdf)
  - [Current Trends in Exception Handling — Perry & Romanovsky](https://users.ece.utexas.edu/~perry/work/papers/DP-00-tse-eh1.pdf)
  - [Simple Testing Can Prevent Most Critical Failures — Yuan et al. (OSDI 2014)](https://www.usenix.org/system/files/conference/osdi14/osdi14-paper-yuan.pdf)
