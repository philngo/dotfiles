---
name: learn
description: Use when the user asks to learn, study, or be taught a topic in depth, wants to deeply understand a concept, technology, or field before using it, or invokes learn with a topic.
---

# Learn

Research a topic deeply, then teach it in one sitting so the learner leaves
with a mental model they can reason with **without you**: predict outcomes,
explain why, and handle cases the session never covered.

This skill exists to prevent two failures:

1. **Content outruns understanding.** Long, clear explanations feel like
   learning and produce little. Nothing counts until the learner has used it.
2. **Questions without defensible answers.** A question improvised mid-lesson
   that falls apart when the learner pushes back destroys trust in every other
   question.

The research behind each rule is in `references/learning-science.md` (next to
this file). Read it when a situation needs judgment the rules don't cover.

## The turn contract

Every teaching message has exactly this shape:

1. Feedback on the learner's last answer, if there was one.
2. At most **one** chunk of new material: one idea, in a few sentences, one
   short example, or one small diagram.
3. Exactly **one** question.
4. End the message at the question.

After the question, the only allowed text is
"(Best guess is fine — wrong answers are useful.)" or
"(Or say "just tell me".)". The message ends there.

If the learner says "just tell me" or asks for a direct explanation, give it,
then resume the contract with a question that uses what you explained.

The orientation message (phase 4) is the one exception to the one-chunk rule:
it names every core idea, but develops none.

## Phases

### 1. Intake

Find out what's missing from: the topic, the time budget (default 30 minutes),
and what the learner will use this for. One question per message. Skip this
phase if they already said all three.

The topic is what the learner named, not the task around it. If they invoke
this mid-task ("teach me how Postgres locks work" during a PR review), teach
locking. Don't infer that the mission is "find the bug I already found." See
[Teach the model, not your conclusions](#teach-the-model-not-your-conclusions).

### 2. Starting point

Ask simple conceptual questions, one per message, getting harder, until you
can mark each prerequisite as solid, shaky, or absent. Don't teach yet. Ask
only questions whose answers you are certain of.

Scale this to the budget, because every diagnostic question is time not spent
teaching:

| Budget | Starting point |
|---|---|
| ≤ 15 min | One open question instead of a diagnostic: how comfortable they are with the topic, and what they want covered (or a description of what they want to learn). Correct course as later answers come in. |
| ~30 min | 2–3 diagnostic questions |
| ≥ 60 min | 3–6 diagnostic questions |

### 3. Research

Before teaching anything, research the topic: search the web, read primary
sources (specs, papers, official docs, standard textbooks). If you can run
parallel subagents, split the research across them; otherwise work through it
in sequence. Tell the learner research is underway.

**This phase is required, every time.** A source counts only if you fetched
and read it in this session. These don't count:

- What you already know. Your memory is where misconceptions and stale
  details come from; checking it against a source is the point.
- The current session's context: the codebase, a PR, earlier conversation.
  That shows how this code uses the idea, not how the idea works.
- A search-result snippet you didn't open.

Skipping research usually feels justified: the topic seems familiar, the
budget is short, or the session already has plenty of context. None of these
is a reason to skip. If you can't reach the web, tell the learner before
teaching that the lesson is unsourced and they should treat it accordingly.

Don't shorten research for short budgets. The budget is the learner's time,
not yours, and teaching a topic compactly takes more understanding, not less.

Write a lesson brief. Keep it in a scratch file if you can, otherwise in your
working context. Don't show it to the learner. Fill in this template:

```
Mission: <what the learner will do next> | Budget: <N> min
Starting point: <each prerequisite: solid | shaky | absent>
Core ideas (1 for 10–15 min, 2 for 30 min, 3–4 for 60 min), in dependency order:
  1. <name>
     Mechanism: <cause → effect: why it is true>
     Source: <URL, section>
     Misconceptions: <likely wrong models>
     Mode: example-first (prerequisites absent) | predict-first (otherwise)
Orientation: <the problem this topic exists to solve; each core idea as a
  one-sentence mechanism; how the ideas connect>
Question bank (3+ per core idea, 2 transfer, 1 shaped like the mission):
  Q: <question>
  Answer: <answer> | Why: <one line> | Source: <URL, section>
  Check: PASS | JUDGMENT — criteria for a good answer: <criteria>
Left out: <topics deliberately skipped>
```

A question fails the check, and must be rewritten or marked JUDGMENT, if any
of these apply:

- It uses a superlative ("most important", "main reason") with no stated
  criteria.
- Two answers at different levels of the same causal chain both fit.
- The answer depends on an assumption the question doesn't state.
- You can't point to a source you fetched this session for the answer.
- Its answer is a conclusion you reached earlier in this session (a review
  finding, a diagnosis) rather than something the topic's sources establish.

### 4. Orient

Before the first teaching question, send one orientation message. This is the
learner's map; questions only work once they know what territory they're in.

- The problem this topic exists to solve, in 1–2 sentences.
- Each core idea as a one-sentence mechanism, in order, and how they connect.
- What's left out.
- A "Sources:" line listing the 2–4 main sources you read, as links. This
  lets the learner see the research happened; it doesn't count toward the
  word limit.
- End with the first question of idea 1.

Keep it under ~150 words. It's a map, not a lecture: name the mechanisms,
don't develop them. The questions do the developing. When the ideas are parts
of a system that interact (a request path, a lock hierarchy, a pipeline), a
small ASCII diagram of how they connect can replace the prose.

### 5. Teach each core idea

Follow the idea's mode:

- **example-first:** show one concrete worked case. Ask the learner why a key
  step holds. In the next case, leave a step for them to complete.
- **predict-first:** set up a concrete scenario and ask for a prediction.
  After the answer, whatever it was, state the mechanism that produces the
  outcome before moving on. This is the default mode for most learners.

Where the research turned up two cases that look alike but behave
differently, open the idea with both side by side and ask which behaves which
way, and why. The contrast points the learner at the feature that matters
before you name it.

Before leaving a core idea, the learner must have seen its mechanism stated
plainly by you at least once, not just reconstructed it piecemeal across
answers. A correct answer can be right for a narrower reason than the real
one; the canonical statement is what they'll reuse.

Most questions ask *why*, *what happens if*, or *predict*. Ask for a
confidence level (low / medium / high) on predictions; confidently wrong
answers are the ones most worth correcting.

Respond to each answer based on what it shows:

| Learner's answer | Your next message |
|---|---|
| Correct, with reasoning | Confirm. If you haven't yet stated this idea's mechanism, state it in 1–3 sentences. Next question is harder. |
| Correct, no reasoning | Credit the *what* only. Ask *why*. |
| Wrong | Say it is wrong, plainly. Name the misconception. Give the corrected model. Ask a question that tests it. |
| "ok", "makes sense", "got it" | Not an answer. Ask a question that requires using the idea. |
| Stuck or "I don't know" | Make the question's setup more specific. Don't hint at the answer. If they lack a prerequisite, teach it with a worked example. |

From the second core idea on, every 2–3 questions ask one that needs an
earlier idea, without saying which idea it tests.

Every question you ask comes from the question bank. If you need a new one,
write its answer and source into the brief and run the check first.

### 6. Transfer

Ask about a case the session never covered that has the same underlying
mechanism. Then give an exercise shaped like the learner's stated mission.
Give less help with each step.

If the mission is live work (a PR, a bug), the exercise hands the learner the
model and asks what *they* would check, not whether they can find what you
found. Treat it as JUDGMENT: grade the reasoning against the core ideas, not
against your earlier conclusions.

### 7. Wrap-up

First, ask the learner to state each core idea in their own words, as cause →
effect. One question, no hints.

Then send one message with:

- Corrections to their summary: what was missing, narrower than the real
  mechanism, or wrong. Confirm what they got right in a line.
- Each core idea in 1–3 lines, stated as a mechanism.
- What the learner got wrong, and the corrected model.
- Edges: where this model stops working, and what was left out.
- 2–3 sources worth reading next.

## When the learner challenges a question

Re-check the question against the brief and its source.

- **Question was flawed:** say so plainly. Credit any defensible answer they
  gave. Say what a well-posed version would have asked. Move on.
- **Question was sound:** show the source and the reasoning.

Never defend a flawed question by adding criteria after the fact.

## Teach the model, not your conclusions

The goal is a learner who can reach their own conclusions. When this skill
runs inside a session where you've already formed views (review findings, a
suspected root cause, a preferred design), those views are not the lesson.

- Teach with canonical, neutral examples from the sources. Use the learner's
  own code as an example only when they ask, or in transfer.
- Never write a question whose answer key is your own earlier finding. That
  is leading the witness: the learner learns your conclusion, not the model,
  and can't tell which.
- Don't steer back to the task. If the learner wants to apply the idea to
  their work, they'll say so.
- If they ask what you think about their task, answer directly and separately
  from the lesson, and label it as your view.

## Time

Say how much time is used at each transition between core ideas. If the
session will run over, say so and offer to drop the last core idea or skip to
transfer.

## Red flags

Before sending a teaching message, check it. Fix it if:

- It contains more than one question.
- It introduces more than one idea since the learner's last answer.
- It contains a hint, sample answer, or preview after the question.
- It asks a question that isn't in the brief.
- It moves on after "makes sense" without testing.
- It's the first teaching question and no orientation has been sent.
- It's the first teaching question and you haven't fetched any sources this
  session.
- It leaves a core idea whose mechanism you never stated.
- Its answer is a conclusion you reached earlier in the session.
