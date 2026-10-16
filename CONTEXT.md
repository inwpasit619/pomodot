# Pomodot

Pomodot is a small floating Pomodoro timer for macOS. This glossary pins down the words the app, its spec, and the agents building it use for time and progress.

## Language

### Time

**Phase**:
One timed block of the timer. There are exactly three kinds: Focus, Short Break, and Long Break.
_Avoid_: Session, interval, round

**Focus**:
The Phase for working, 25 minutes by default.

**Short Break**:
The rest Phase between Pomodoros within a Cycle, 5 minutes by default.

**Long Break**:
The rest Phase that ends a Cycle, 15 minutes by default.

### Progress

**Pomodoro**:
A Focus that ran to completion. A Focus that ended any other way is not a Pomodoro.
_Avoid_: Using "Pomodoro" for any Focus, or for the whole Focus + break pair

**Cycle**:
A run of N Pomodoros (4 by default) that ends with one Long Break. Progress within it is shown as "2/4".
_Avoid_: Round, set, session

**History**:
The record of every Pomodoro (when it ended and how long it was), kept until the user clears it. New Cycle and Reset never touch it; a Focus that wasn't a Pomodoro never enters it.
_Avoid_: Log, sessions, stats (for the stored record itself; "Statistics" is the window that shows it)

**Expected finish**:
The clock time a Phase or a Cycle will end if it runs from now with no further pauses. A Cycle's expected finish is the end of its Long Break.
_Avoid_: ETA, end time (when it could be confused with a Phase's length)

### Surfaces

**Floating Window**:
The small timer window that floats over other apps. It is a compact pill (Phase colour + time) that widens a little while the pointer is on it and expands into a card with every control when clicked. Closing it only hides it; the timer keeps running.
_Avoid_: Widget, HUD, popover, mini window

### Actions

**Skip**:
Ending the current Phase early and moving to the next one. A skipped Focus is not a Pomodoro.

**Reset**:
Putting the current Phase back to its full length, stopped. The Cycle is untouched.
_Avoid_: Using "Reset" for starting over the whole Cycle

**New Cycle**:
Discarding progress in the current Cycle and returning to the first Focus, stopped.
_Avoid_: Reset, restart
