# Port Notes

As we're going through the port from Javascript to Swift, we'll use
this file to keep track of notes. Currently we outline our high level
plan and identify the risks that we have observed so far.

The good news is that from a preliminary inspection, the functions
that I've looked at in detail are pure functions, meaning that they
take inputs and produce an output without any side effects. All of the
state handling is on the native Swift side in Trio (at least so
far). Pure functions will be easier to test and less risky to port
incrementally.

## Plan

At the highest level, our plan is to first do a line-by-line port of
the Javascript implementation to build confidence that it works, then
to make it more "Swift-y" after we have confidence in the logic. Doing
a line-by-line port first makes it easier for us to debug, but we will
use more idiomatic Swift patterns where it makes sense.

Also, we plan to release this as a SPM so that other iOS / OpenAPS
systems can pick up this library, if it makes sense. But I'm open to
something different if people have strong opinions here.

Our plan is:

1. Port one function at a time. The functions are `iob`, `meal`,
`autotunePrepare`, `autotuneRun`, `determineBasal`, `autosense`,
`exportDefaultPreferences`, and `makeProfile`.

2. For each function, the process will be:
  - Write the code in Swift
  - Port the Javascript tests to Swift to confirm they work
  - Write new unit tests to get full code coverage (ideally)
  - Run the native function in Trio in a shadow mode, where we compute the results and simply compare with the Javascript implementation, logging any differences.

3. We should run each function in shadow mode for a week without any
inconsistencies before considering moving it to live execution. After
we move to live execution of a native function, we should continue to
run the Javascript implementation in shadow mode for 2 weeks to
continue to check for inconsistencies.

4. Once all functions are running natively and without inconsistencies
for two weeks, we can remove the Javascript implementation. After we
remove the Javascript implementation, we will consider the
line-by-line port to be complete, and can make decisions about any
further changes we'd like to make to the Swift implementation to
improve maintainability.

## Risks

Here is a list of where we think bugs might crop up, so we're writing
them down to make sure we can keep an eye on it.

- **Javascript pass-by-reference.** Javascript uses pass-by-reference
    semantics, so if code modifies an input parameter then that value
    is changed. In our Swift port, we instead use pass-by-value
    semantics, trying to carefully navigate any visible changes that
    can come from modifications, which does happen in OpenAPS.

- **Javascript dynamic properties.** Javascript can add properties on
    the fly, which is hard to get right. Our plan is to use static
    typing and make sure that we include properties that Javascript
    would generate dynamically, but this is a potential source of
    inconsistencies.

- **var now = new Date();** There are several places where the
    Javascript implementation gets the current time using `new
    Date()`. This style of time management can lead to issues if we're
    right at a boundary when it runs. Since this is how the Javascript
    is implemented we use it too, but we'll want to fix that soon.

- **Double vs Decimal.** Ideally, in Swift we'd use the Decimal class
    for floating point computation, as the rest of Trio does. However,
    our goal is to match the current Javascript implementation, so we
    went for Double since this is the same as a Javascript Number.

- **Floating point math.** Floating point math in general is non
    associative, meaning that it is extremely difficult to port
    floating point math perfectly. There is a lot of rounding in the
    code that should help, but it's something to keep an eye on.

- **Trio-specific inputs.** There are places where the Trio
    implementation it a little different than what the Javascript
    expects. An example is `BasalProfileEntry` doesn't have an `i`
    property, so the sorting function for these entries in Javascript
    is a no-op, so we excluded it.

- **Preferences -> Profile.** The Javascript implementation copies
    input properties into the Profile if they exist. In Trio, in
    Javascript we copy the Preferences to the input for this
    purpose. In this library, we do this copy by hard-coding all
    properties that have the same CodingKeys, but this was a manual
    process and something we need to remember to change if either
    Profile or Preferences changes. We'll fix this with v2, but for
    now this was the cleanest way I could come up with for handling it
    in Swift. See the Profile extension that implements `update` for
    more details.

## Current TBD

The biggest item we need to figure out is how to do the logging for
inconsistencies within Trio. My preference is to log the inputs and
outputs for any inconsistencies found, and to keep some high level
stats on how often the comparison has been done. Plus, we should have
a way for people to opt-out if they want, but it's important that we
have logging turned on by default to get the data we need.

Also, if any of the prepare Javascript, the oref library, or the
Models we copied have changed with Trio 1.0, we should switch over to
it ASAP.

## Sources

For our port, we're using:

- trio-oref git SHA: 363fd116bf69d728502a46f1df0f842a05944c7b

- Trio git SHA: d97ee5e87613e0609f86c71bf6a420f7c6207f83