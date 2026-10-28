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

## Phases

### 1. Intake

Find out what's missing from: the topic, the time budget (default 30 minutes),
and what the learner will use this for. One question per message. Skip this
phase if they already said all three.

### 2. Starting point

Ask simple conceptual questions, one per message, getting harder, until you
can mark each prerequisite as solid, shaky, or absent. Usually 3–6 questions.
Don't teach yet. Ask only questions whose answers you are certain of.

### 3. Research

Before teaching anything, research the topic: search the web, read primary
sources (specs, papers, official docs, standard textbooks). If you can run
parallel subagents, split the research across them; otherwise work through it
in sequence. Tell the learner research is underway.

Write a lesson brief. Keep it in a scratch file if you can, otherwise in your
working context. Don't show it to the learner. Fill in this template:

```
Mission: <what the learner will do next> | Budget: <N> min
Starting point: <each prerequisite: solid | shaky | absent>
Core ideas (2 for 30 min, 3–4 for 60 min), in dependency order:
  1. <name>
     Mechanism: <cause → effect: why it is true>
     Source: <URL, section>
     Misconceptions: <likely wrong models>
     Mode: example-first (prerequisites absent) | predict-first (otherwise)
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
- You can't point to a source for the answer.

When the brief is done, send a one-line agenda (the core ideas) and the list
of what's left out, then start teaching.

### 4. Teach each core idea

Follow the idea's mode:

- **example-first:** show one concrete worked case. Ask the learner why a key
  step holds. In the next case, leave a step for them to complete.
- **predict-first:** set up a concrete scenario and ask for a prediction
  before explaining anything.

Most questions ask *why*, *what happens if*, or *predict*. Ask for a
confidence level (low / medium / high) on predictions; confidently wrong
answers are the ones most worth correcting.

Respond to each answer based on what it shows:

| Learner's answer | Your next message |
|---|---|
| Correct, with reasoning | Confirm in one line. Next question is harder. |
| Correct, no reasoning | Credit the *what* only. Ask *why*. |
| Wrong | Say it is wrong, plainly. Name the misconception. Give the corrected model. Ask a question that tests it. |
| "ok", "makes sense", "got it" | Not an answer. Ask a question that requires using the idea. |
| Stuck or "I don't know" | Make the question's setup more specific. Don't hint at the answer. If they lack a prerequisite, teach it with a worked example. |

From the second core idea on, every 2–3 questions ask one that needs an
earlier idea, without saying which idea it tests.

Every question you ask comes from the question bank. If you need a new one,
write its answer and source into the brief and run the check first.

### 5. Transfer

Ask about a case the session never covered that has the same underlying
mechanism. Then give an exercise shaped like the learner's stated mission.
Give less help with each step.

### 6. Wrap-up

Send one message with:

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
