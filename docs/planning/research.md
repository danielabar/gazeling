# Research: Evidence Behind Eye-Break Exercises

First-pass literature review, 2026-10-26. Purpose: decide which exercises go in the app and what the "Why this works" screen can honestly claim.

## Final decision

Decided 2026-10-26, after reviewing the findings below.

**Ship every exercise listed in this document.** The research is background, not a filter. We are not tying each exercise to a specific article, and an exercise without a trial behind it still stays in. Reasons:

- The app is a **lifetime habit tool**, not a one-time fix. Both reminder-based studies below point the same way: benefits last only while the habit continues.
- The product owner used the EyeLeo web app for years and found it helped a lot.
- The exercises are low risk and cheap, and the break itself (looking away from the screen, moving, blinking fully) is the main benefit.

**Exercise set for v1**

| Exercise | Notes |
|---|---|
| Full blink with gentle squeeze | In every break. Best-supported item. About 15 reps. |
| Look far away / out the window | Short breaks. |
| Eyes side to side | |
| Eyes up and down | |
| Eyes around, left | |
| Eyes around, right | |
| Palming (cup hands over closed eyes) | |
| Stand up and walk | The long break. |
| Eyes-closed rest (about 15–20 s) | Optional filler. |

Exercises are configuration data, so more can be added later.

**What the app says about the research**

- The About / "Why this works" screen gives a **general summary** with a few key references (for example the blink-training RCTs and the Singh 2022 review). It does not need a citation per exercise.
- Keep claims modest. Do not say "clinically proven." Suitable wording: regular breaks, full blinking and looking into the distance are common clinical advice for screen users, and blink training has trial support. Say that benefits depend on keeping the habit.
- Include a short note to see an eye doctor if blur, double vision or headaches persist.

**Left out of v1:** vergence therapy (a treatment for a diagnosed condition), acupressure exercises, and supplements. Warm compress is mentioned in the About screen only, not as an animated exercise.

**Break schedule defaults**

No trial supports these exact numbers (see [Open questions for the schedule](#open-questions-for-the-schedule)). They follow the widely used 20-20-20 convention and the original brainstorm, and all of them are user-configurable.

| Setting | Default |
|---|---|
| Short break | Every **20 minutes** of computer use, lasting **20 seconds** |
| Long break | Every **60 minutes** of computer use, lasting **5 minutes** (replaces that hour's short break) |
| Heads-up before a break | Gentle notification about **30 seconds** ahead, with Skip and Postpone |
| Reading time | Short breaks start with a 5 s lead-in: the instruction shows and the countdown holds at the full length, then the break runs for its set length (added 2026-11-01). Long break has none |
| Exercise choice, short break | One exercise per break, taken from the enabled short-break exercises in rotation (no immediate repeats) |
| Exercise choice, long break | **Stand up and walk, for the whole 5 minutes** (changed 2026-10-26: chaining eye exercises for 5 minutes could make people dizzy) |
| Away from the computer | If there is no keyboard or mouse input for 5 minutes, both timers reset (changed 2026-11-01 from "idle as long as a break": reading or watching without input is not rest) |
| Strict mode | Off. Skip and Esc always work. |

**Configuration**

- Intervals and durations for short and long breaks, and whether long breaks are on.
- **Per-exercise on/off.** Any exercise can be excluded, for example someone who cannot walk away from the desk, or finds palming awkward.
- No per-exercise break type. Decided 2026-10-26: "Stand up and walk" is the only long-break exercise and all the others are short-break exercises. The user can only switch an exercise off.
- If every exercise for a break type is excluded, that break type is turned off and the settings screen says so. It never shows an empty break.
- Defaults live in the exercise data file, so adding an exercise later needs no code change.

The idle reset, the 30-second heads-up and the "no immediate repeats" rotation are my additions beyond the brainstorm. Change them if you disagree.

## How to read this

**Sourcing.** Every study below was read as a PubMed/Europe PMC abstract, retrieved in this session. Numbers come from those abstracts, not full texts. Items I could not retrieve are listed under [Not yet verified](#not-yet-verified) and are not used as evidence.

**Evidence grades** (my judgement, for app labelling):

| Grade | Meaning |
|---|---|
| **Moderate** | Several randomized trials, consistent direction, but small and short. |
| **Low** | One or two small trials, or uncontrolled / mixed results. |
| **Rationale only** | Plausible mechanism, no trial that isolates the exercise. |
| **None found** | No trial found in this search. |

## Headline findings

1. **No computer-eye-strain intervention has high-certainty evidence.** A 2022 systematic review and meta-analysis of 45 RCTs (4,497 participants) found no high-certainty support for any therapy it analyzed (Singh et al., *Ophthalmology*, [doi:10.1016/j.ophtha.2022.05.009](https://doi.org/10.1016/j.ophtha.2022.05.009)). It covered lenses, blue-blocking glasses and supplements. It did not report on exercises or breaks in the abstract I retrieved. Rosenfield's 2011 review reached a similar conclusion: treatment efficacy is unproven ([doi:10.1111/j.1475-1313.2011.00834.x](https://doi.org/10.1111/j.1475-1313.2011.00834.x)).
2. **Blinking exercises are the best-supported exercise.** Several RCTs show fewer incomplete blinks and better dry-eye symptoms. The effect fades within about two weeks of stopping.
3. **The 20-20-20 rule has weak support.** Reminder-based use reduced symptoms in one small uncontrolled study. A controlled test of 20-second breaks found no symptom effect.
4. **Most classic "eye exercises" (side to side, up and down, circles, palming) have no isolated trial.** Evidence exists only for bundled programs, mostly small, from outside the best-controlled literature.
5. **Vergence (convergence) training works for convergence insufficiency**, a specific diagnosed condition. It is not shown to help general eye strain.

## The problem the app addresses

- **Prevalence.** A meta-analysis of 103 cross-sectional studies (66,577 participants) estimated computer vision syndrome (CVS) prevalence at 69% (95% CI 62.3–75.3), with very high heterogeneity (I² = 99.7%, range 12–97%). Definitions vary by study. Ccami-Bernal et al., *J Optom* 2024, [doi:10.1016/j.optom.2023.100482](https://doi.org/10.1016/j.optom.2023.100482).
- **Dry eye in screen workers.** In 561 Japanese VDT users, 58.6% met revised Asia Dry Eye Society criteria (up from 11.6% under the older criteria). Cross-sectional. Yamanishi et al., *Cornea* 2020, [doi:10.1097/ico.0000000000002218](https://doi.org/10.1097/ico.0000000000002218).
- **Blink interval versus tear stability.** In 858 VDT workers, about 80% had a blink interval longer than their tear break-up time (TBUT), meaning the tear film breaks up before the next blink. Uchino et al., *Int J Ophthalmol* 2018, [doi:10.18240/ijo.2018.10.18](https://doi.org/10.18240/ijo.2018.10.18).
- **Mechanism per Rosenfield (2011).** Dry-eye symptoms are greater during computer use. Likely causes are reduced blink rate and amplitude, and more corneal exposure when the monitor sits in primary (straight-ahead) gaze.
- **Blink rate versus blink completeness.** A 2026 narrative review notes that lower blink rate on screens appears driven mostly by cognitive demand rather than the screen, since matched digital and printed reading showed no rate difference. Incomplete blinking was higher on the digital device. Saleh, *Cureus* 2026, [doi:10.7759/cureus.114181](https://doi.org/10.7759/cureus.114181). I did not read the underlying studies.

This supports the app's framing: **blink completeness** is the best-evidenced target, more than blink count. The "blink 20 times" idea in the brainstorm should be reframed as *full* blinks, ideally with a squeeze (see below).

---

## Exercise-by-exercise

### 1. Full blinking / blink training: **Moderate**

| Study | Design | Result |
|---|---|---|
| Wolffsohn et al., *Cont Lens Anterior Eye* 2025, [doi:10.1016/j.clae.2025.102453](https://doi.org/10.1016/j.clae.2025.102453) | RCT, n=98 (optimisation) + n=28 (efficacy), dry eye, app-guided, 2 weeks | Blinking exercises reduced symptoms (p<0.01). Adding a **squeeze** step cut symptom frequency (p<0.01). Best routine: **15 repetitions, 3×/day**. In the efficacy arm: symptom severity (p=0.001), frequency (p=0.027), incomplete blinks (p<0.001) and conjunctival staining (p=0.041) all fell. Most readings **returned to baseline 2 weeks after stopping**. |
| Arita et al., *Ocul Surf* 2025, [doi:10.1016/j.jtos.2025.02.003](https://doi.org/10.1016/j.jtos.2025.02.003) | RCT, n=100, dry eye, 3 days. Artificial tears ± blinking exercises 5×/day | Exercise group improved on SPEED symptom score, eye-strain and discomfort VAS, eyelid opening height, tear stability and incomplete-blink rate versus tears alone. |
| Kim et al., *Cont Lens Anterior Eye* 2021, [doi:10.1016/j.clae.2020.04.014](https://doi.org/10.1016/j.clae.2020.04.014) | Uncontrolled before/after, n=41 completers, 4 weeks. **10-second blink cycle every 20 minutes** (average 25.6 cycles/day) | DEQ-5 11→7, OSDI 36→22, NIBUT 6.5→8.1 s, incomplete blinks 54%→34%. No change in tear meniscus height or lipid layer. No control group. |
| Ashwini et al., *Indian J Ophthalmol* 2021, [doi:10.4103/ijo.ijo_3405_20](https://doi.org/10.4103/ijo.ijo_3405_20) | Single-blind RCT, n=46, computer users with dry eye. Blink-reminder bars 8/min vs 1/min control, 15 days | OSDI improved (p=0.021) and blink rate rose (p=0.049) in the 8/min group. Authors report the blink-rate gain persisted one month after stopping. |
| Sadhwani et al., *Cureus* 2024, [doi:10.7759/cureus.67653](https://doi.org/10.7759/cureus.67653) | Single-blind RCT, n=38, CVS, 6 months | Abstract was truncated in my retrieval; results not read. |

**Takeaways for the app**
- Include it. Prescribe a **deliberate full blink, with a gentle squeeze**, about 15 repetitions. Kim's 10-second cycle every 20 minutes is a lighter alternative, but uncontrolled.
- Effects are short-lived, so regular repetition matters. Say so honestly in the app.
- Caveats: all trials are small and short, and most enrolled people who already had dry eye.

### 2. 20-20-20 rule / regular short breaks: **Low**

- **Talens-Estarelles et al.**, *Cont Lens Anterior Eye* 2023, [doi:10.1016/j.clae.2022.101744](https://doi.org/10.1016/j.clae.2022.101744). Single group (n=29 symptomatic computer users, no control), two weeks of webcam-driven reminders. Digital eye strain and dry-eye symptoms fell (p≤0.045) but **the improvement was gone one week after the reminders stopped**. No change in tear film or most binocular measures. Users took more, but shorter, breaks.
- **Johnson & Rosenfield**, *Optom Vis Sci* 2023, [doi:10.1097/opx.0000000000001971](https://doi.org/10.1097/opx.0000000000001971). n=30 young adults, 40-minute demanding tablet task, 20-second breaks every 5, 10, 20 or 40 minutes. Symptoms rose in all conditions, with **no effect of break schedule on symptoms (p=0.70), reading speed or accuracy**. The authors state there is little peer-reviewed evidence for the rule's specific numbers.
- Related, non-ocular: a 2015 experiment (n=150) found a short rest break restored vigilance performance and lowered workload (Arrabito et al., *Hum Factors*, [doi:10.1177/0018720815598433](https://doi.org/10.1177/0018720815598433)). This supports breaks for attention generally, not eye health.

**Takeaways for the app**
- The *number* "20 minutes / 20 seconds" is convention, not an evidence-derived threshold. The app should not claim otherwise.
- A reminder system plausibly works through behaviour: it gets people to take breaks and, in Talens-Estarelles, to blink and look away. Symptom benefit appears to need the reminders to continue.
- Reasonable defaults, with configurable intervals, are the right design.

### 3. Look at something far away (window / distance gaze): **Rationale only**

- This is the "20 feet" part of the 20-20-20 rule. It is meant to relax accommodation (focusing effort) after near work.
- I found no trial isolating distance gaze as an intervention. In the Talens-Estarelles study, accommodative facility improved (p=0.010) while other binocular measures did not change.
- Keep it as the framing for the longer break. Label as "common clinical advice, limited direct evidence."

### 4. Eye movements: side to side, up and down, circles: **None found (isolated)**

- No trial found testing these alone for eye strain.
- They appear inside bundled programs:
  - **I-Exercises** (Shah et al., *Cureus* 2026, [doi:10.7759/cureus.115148](https://doi.org/10.7759/cureus.115148)): RCT, n=40 myopic students, no-intervention control, 3 weeks. Improved several fatigue symptoms (tired eyes, eyestrain, blurred vision, difficulty focusing). No difference for dry, red or burning eyes. Small, unblinded, self-reported.
  - **Sports vision training** (Zhong & Gao, *Front Neurosci* 2026, [doi:10.3389/fnins.2026.1878323](https://doi.org/10.3389/fnins.2026.1878323)): RCT, n=200, 12 weeks. CVS-positive rate fell from 76% to 44% (men) and 72% to 38% (women) versus small non-significant change in controls, who got 20-20-20 advice. The programme combined eye, neck, shoulder and back movements, reaction tasks and strobe glasses, so the eye movements cannot be separated out.
  - **Yoga ocular exercises** (Gupta & Aparna, *Int J Yoga* 2020, [doi:10.4103/ijoy.ijoy_26_19](https://doi.org/10.4103/ijoy.ijoy_26_19)): n=32 optometry students, 6 weeks. Eye-fatigue score fell in the exercise group (p=0.003) and rose in controls (p=0.044). Very small, student sample.
- Reasonable role in the app: these give the owl something to animate and give the user a reason to look away from the screen. The honest label is "traditional / low evidence; no known harm."

### 5. Palming / cupping the eyes: **None found**

- No completed trial found. A randomized trial of palming (alone and with traditional Chinese medicine therapies) for digital eye strain is registered with a published protocol and no results yet (Dave et al., 2026, [doi:10.1177/19336586251396326](https://doi.org/10.1177/19336586251396326)).
- Closest evidence, all indirect:
  - **Thai yoga facial massage** (Chen et al., *Complement Ther Med* 2025, [doi:10.1016/j.ctim.2025.103270](https://doi.org/10.1016/j.ctim.2025.103270)): RCT, n=32, versus eyes-closed rest. Large reported improvements in CVS-Q, near point of convergence and accommodation amplitude. Small, unblinded. This is massage, not palming.
  - **Trataka plus cold eye pack** (Saoji et al., *J Integr Complement Med* 2024, [doi:10.1089/jicm.2023.0175](https://doi.org/10.1089/jicm.2023.0175)): three-arm RCT, n=300 IT workers, waitlist control, 2 weeks. Both active arms beat waitlist on self-rated visual fatigue, with no difference between them. No active placebo, so expectation effects are not excluded. Trataka is fixed gazing at a candle flame, so it is not the same as palming either.
- A reasonable argument for keeping it: closing the eyes in the dark gives a real rest from screen light and may encourage a slower, fuller blink afterwards. That is speculation. Label it "relaxation; not clinically tested."

### 6. Warm compress / eyelid warming: **Low to moderate (for meibomian gland dysfunction)**

- **Ballesteros-Sánchez et al.**, *Ocul Surf* 2025, [doi:10.1016/j.jtos.2025.02.008](https://doi.org/10.1016/j.jtos.2025.02.008). Meta-analysis of 7 RCTs (367 patients). Overall efficacy did not significantly favour warming devices over controls or warm towels, but devices improved OSDI and non-invasive tear break-up time versus controls.
- **Pang et al.**, *Cornea* 2019, [doi:10.1097/ico.0000000000001907](https://doi.org/10.1097/ico.0000000000001907). 4 RCTs (385 patients): a single 12-minute vectored thermal pulsation treatment beat traditional warm compresses at 2–4 weeks and for OSDI at 3 months.
- **Contact-lens dry eye meta-analysis** (Ballesteros-Sánchez et al. 2026, [doi:10.1007/s44402-026-00024-4](https://doi.org/10.1007/s44402-026-00024-4)): warming improved OSDI versus no treatment (4 RCTs), with warm compresses comparable to LipiFlow.
- This is a treatment for a diagnosed condition and takes minutes with a heated pack. It does not fit a 20-second overlay break. Possible as an optional "evening routine" tip in the About screen, not as an animated exercise.

### 7. Vergence / convergence training: **Strong for convergence insufficiency only**

- **CITT-ART** (CITT-ART Investigator Group, *Optom Vis Sci* 2019, [doi:10.1097/opx.0000000000001443](https://doi.org/10.1097/opx.0000000000001443)). Placebo-controlled RCT, 311 children with symptomatic convergence insufficiency. 16 weeks of **office-based** vergence/accommodative therapy improved near point of convergence (−4.2 cm versus placebo) and positive fusional vergence (+14.4Δ versus placebo). **Symptom scores did not differ from placebo** (difference 1.5 points, p=0.21). One-year follow-up showed the convergence gains held ([doi:10.1111/opo.13378](https://doi.org/10.1111/opo.13378)).
- **Serna et al.**, *J AAPOS* 2011, [doi:10.1016/j.jaapos.2010.11.023](https://doi.org/10.1016/j.jaapos.2010.11.023). Retrospective review, 42 patients, home computer orthoptics plus push-ups; 64% reported symptom resolution. Uncontrolled.
- Not recommended for the app: it is supervised therapy for a specific diagnosis, unsuited to a generic reminder. A "see an eye doctor if blur, double vision or headaches persist" note is worth including.

### 8. Acupressure eye exercises (China-style): **Low**

- Chen et al., *Risk Manag Healthc Policy* 2024, [doi:10.2147/rmhp.s467570](https://doi.org/10.2147/rmhp.s467570): n=134 schoolchildren, uncontrolled, accommodative amplitude rose in the short term and "high-quality" exercise performance was associated with less visual fatigue. Liu et al., *Transl Vis Sci Technol* 2025, [doi:10.1167/tvst.14.7.20](https://doi.org/10.1167/tvst.14.7.20): n=55, randomized with sham and eyes-closed groups, measured retinal and choroidal changes, not symptoms.
- Out of scope for v1. It requires hand-on-face technique and the evidence is for children and surrogate measures.

---

## Exercises you did not list, with evidence

| Idea | Evidence | Verdict for the app |
|---|---|---|
| **Squeeze-blink** (hold eyes gently shut 1–2 s) | Part of the best-supported blink routine (Wolffsohn 2025). | **Add.** Fold into the blinking exercise rather than a separate one. |
| **Timed blink cycle** (e.g. 10 s of deliberate blinks every 20 min) | Kim 2021, uncontrolled. | **Add** as the short-break blink exercise. |
| **Gentle eyes-closed rest** (about 15–20 s) | Used as the *control* in the yoga-massage RCT, so effect unknown. | Optional; rest is cheap and harmless. |
| **Warm compress / lid warming** | See section 6. | Mention in About; not an overlay exercise. |
| **Cold eye pack** | One RCT arm (Saoji 2024), self-rated, waitlist control. | Mention only. |
| **Outdoor time** (children) | Cluster RCT of 6,295 schoolchildren in Shanghai: adding 40 min outdoor time per school day cut 2-year myopia incidence by 16% (IRR 0.84, 95% CI 0.72–0.99) (He et al., *Ophthalmology* 2022, [doi:10.1016/j.ophtha.2022.06.024](https://doi.org/10.1016/j.ophtha.2022.06.024)). A 2024 meta-analysis found higher outdoor time associated with lower myopia onset (OR 0.53) but a weaker, debated effect on progression in children who already have myopia (Li et al., *Ophthalmic Res* 2024, [doi:10.1159/000539229](https://doi.org/10.1159/000539229)). | Strong for children's myopia, which is not this app's audience. Do not claim it for adult eye strain. |
| **Oral omega-3** | Low-certainty evidence it reduces dry-eye symptoms in computer users (2 RCTs, Singh 2022). A 2026 review notes a large randomized trial found omega-3 ineffective for dry eye in general (Saleh 2026). | Conflicting. Not an exercise; leave out. |
| **Blue-light glasses, berry extracts, multifocal lenses** | No visual-fatigue benefit in Singh 2022. | Not applicable, but useful for a myth-busting section. |
| **Monitor position (lower gaze)** | Mechanism only (Rosenfield 2011: primary-gaze monitors increase corneal exposure). No intervention trial retrieved. | Candidate for a tip. Needs verification. |

## Suggested v1 exercise set and honest labels

This was the proposal; see [Final decision](#final-decision) for what was agreed (all exercises kept).

| Exercise | Break type | Label |
|---|---|---|
| Full blink with gentle squeeze (about 15 reps) | Short | Evidence: **Moderate** |
| Look far away (window or across the room) | Short and long | Evidence: **Rationale only**; standard clinical advice |
| Eyes side to side / up and down / circles | Short | Evidence: **Low**; traditional; no known harm |
| Palming (cup hands over closed eyes) | Short | Evidence: **None found**; relaxation |
| Stand up and walk | Long | Evidence: **None found for the eyes**; general rest and circulation. Not tested here. |

I recommend putting the blink exercise in **every** break, since it has the best evidence and fits any duration.

## Open questions for the schedule

- **20 minutes / 20 seconds.** No trial supports these exact numbers (Johnson & Rosenfield 2023 found no effect of 20-second breaks at 5, 10, 20 or 40 minute intervals). Treat as user-configurable defaults.
- **The hourly 5-minute break.** I found nothing on optimal long-break length for eye outcomes. This is a gap, not a finding.
- **Does the app help once reminders stop?** Both reminder-based studies suggest benefit lasts only while the intervention continues. Consistent with the app being a habit tool, not a one-time fix.

## Not yet verified

I could not retrieve or confirm these in this session. They should not appear in the app until checked.

- **TFOS Lifestyle Report on the digital environment (2023).** Likely the most authoritative overview. Cited by the Saleh 2026 review. Read before writing the About screen.
- **The CITT (2008) trial** comparing office-based therapy, home push-ups and placebo for convergence insufficiency. I believe pencil push-ups did worse than office-based therapy but have not confirmed it.
- **Blink rate on screens** (commonly cited as dropping from about 15–20 per minute to about 5–7). I did not retrieve a primary source. Saleh 2026 says the drop is driven mostly by cognitive demand.
- **Endorsements of the 20-20-20 rule by the American Optometric Association and the American Academy of Ophthalmology.** Mentioned by secondary sources only.
- **Specific percentages ("58% symptom reduction", "47% improvement")** circulating in consumer eye-exercise articles. I could not trace them to a primary study. Do not use.
- **Full texts.** Everything here comes from abstracts. Sample sizes and p-values are as reported there.
- **Search coverage.** I used web search plus Europe PMC. This is not a systematic review. Cochrane and the major guidelines (AAO Preferred Practice Patterns, for example) were not checked.

## Suggested next steps

1. Optional: read the TFOS Lifestyle digital environment report before writing the About screen.
2. Move on to `plan.md`.
