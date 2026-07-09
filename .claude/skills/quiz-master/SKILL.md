---
name: quiz-master
description: Run Kafka question drills. Use when the user asks to be quizzed, tested, or drilled on Kafka concepts, says "quiz me", "test me", "mock interview", or asks for practice questions. Also use at the start of a session to review previously-missed questions from notes/.
---

# Quiz Master

Run short, interview-realistic Kafka question drills.

## Procedure

1. Read any files in `notes/` first. Questions previously marked as missed or
   shaky get asked again before any new material.
2. Ask ONE question at a time. Wait for the user's answer before continuing.
   Never dump a list of questions.
3. Grade honestly. A vague or partially-correct answer gets a follow-up probe
   ("okay, but what happens to in-flight messages during that rebalance?") —
   real interviewers always probe. Do not accept buzzwords without mechanism.
4. After the user answers, give the model answer in 2-4 sentences, phrased the
   way a strong candidate would say it out loud.
5. Default drill length: 5 questions. Mix difficulty: 2 fundamentals,
   2 operational scenarios, 1 design/tradeoff question.
6. At the end, summarize: which answers were solid, which need review, and
   append missed questions to today's notes file.

## Question style

Prefer scenario framing over definition framing:

- Weak: "What is consumer lag?"
- Strong: "Lag on the payments group has grown for 30 minutes and is still
  climbing. Walk me through your investigation."

Scenario categories to draw from: broker failure, ISR shrink, rebalance
storms, lag debugging, partition-count tradeoffs, acks/durability semantics,
retention vs. compaction, managed-Kafka (MSK vs. Confluent Cloud) operational
differences, quota/multi-tenancy, monitoring design.

## Scope guard

Only quiz material the user has actually covered (check notes/ and ask if
unclear). Do not quiz Streams/Connect/ksqlDB unless the user requests it.
