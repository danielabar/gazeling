# App Name Candidates

Checked 2026-10-26. Goal: a name that does not collide with an existing Mac app, an open-source project, or a trademark.

## Decision

**Gazeling** (decided 2026-10-26). Bundle id: `com.danielabar.gazeling`. Reasons: easy to say, works for any character, and clean on every check below. Runner-up was Gazemates.

Still to do by the owner: run the name through the USPTO trademark search (classes 9 and 42) before the first public release, and reserve the GitHub repository name.

## What was checked, and the limits

| Check | How | Limit |
|---|---|---|
| Mac App Store | Apple's public search API (`macSoftware`, US store) | US store only. Does not show apps removed from the store or sold elsewhere. |
| Open source | GitHub repository search by name | Name match only, not usage in the wild. |
| Homebrew | `brew search --casks` | Casks only. |
| Trademark | Web search of public trademark databases (mostly Justia, which mirrors USPTO) | **Not a legal clearance.** I could not query the USPTO database directly. A web search can miss pending, recent or non-US filings. |
| Domain | DNS lookup for `.com` and `.app` | "Not found" in DNS is a hint, not proof the domain is free. It may be registered but unused. |

**Before settling on a name:** run the final choice through the USPTO trademark search (tmsearch.uspto.gov) in class 9 (downloadable software) and class 42, and consider a short consult with a trademark attorney if you ever pay for Developer ID or publish in the Mac App Store. Using a name for a free open-source app carries lower risk than a commercial product, but the same confusion rules apply.

## Important finding: the placeholder "EyeBreak" is not usable

"EyeBreak" and close variants already exist in several places: a Chrome extension called EyeBreak, a Windows app called eyeBreak, an iOS app "Eye Break Monitor", and more. Generic eye-break names are crowded.

Existing Mac and App Store apps in this exact space, to avoid sounding like:

| Name | Notes |
|---|---|
| Look Away | Mac, 20-20-20 reminder |
| Time Out | Mac, break reminders |
| SaveMyEyes | Mac, free, open source |
| Stretchly | Cross-platform, open source |
| Have You Rested? | Mac menu bar, 20-20-20 |
| BlinkFar, FarPause, GazeAway, Blinky, Blinker, EyeBuddy, Intermission | Mac App Store eye-break apps |
| EyeLeo | Windows, the inspiration |
| Screen Break, SitWatcher, Pause, 1Break, Hourlybird | Other break reminders |

## New constraint: the name must work for any character

The app will eventually support other characters (fox, cat and so on), so the name cannot mention owls or hooting. This rules out every owl-based name from the first round: Hootbreak, Gazehoot, Owlbreak, Eyehoot, Far Owl and the rest (kept below for reference only).

Second-round candidates are neutral, mention eyes, gaze or blinking, and several suggest companions.

| # | Name | Mac App Store | GitHub | Trademark (web search) | Domains (DNS) | Notes |
|---|---|---|---|---|---|---|
| 1 | **Gazepals** | No match (closest: "PointerPals", a different app) | No repos | Nothing found | `.com` and `.app` not found | Clean on every check. "Pals" suits swappable characters and a friendly tone. Says what it does: guides your gaze. |
| 2 | **Blinkpal** | No exact match (BlinkFar and similar blink apps appear in results) | No repos | Nothing found | `blinkpal.com` registered; `.app` not found | Clean, but sits among many "Blink-" apps, which adds some confusion risk. |
| 3 | **Eyekin** | No match | Two tiny repos, no real usage | Nothing found | `eyekin.com` registered; `.app` not found | Short, invented, character-friendly ("kin"). Less self-explanatory. |
| 4 | **Eyebloom** | No match | Two tiny repos | Nothing found | `eyebloom.com` registered; `.app` not found | Pleasant, but not character-themed. |
| 5 | **Pupilpals** | No exact match | Two tiny repos | Nothing found. Nearby names: PuppetPals (kids' animation app), MyPupilPal (study app). | `pupilpal.com` registered; `.app` not found | "Pupil" also means student, and it sits close to PuppetPals. |
| 6 | **Softgaze** | No match | Two unrelated repos | Nothing found for the exact name | `softgaze.com` registered; `.app` not found | Clean, calm, but no character feel. |
| 7 | **Irisbreak** | No exact match (BlinkBreaks, EyeProtector, similar names appear) | None | Nothing found for the exact name | `.com` and `.app` not found | Risky: **Iris** is a known eye-comfort app brand, and a separate app named "Break" exists. Not recommended. |

**Ruled out in round two:**

| Name | Reason |
|---|---|
| Peepers | Registered `.com` and `.app`, a 101-star GitHub project, and an established name in reading glasses. |
| Winkle, Glimmer, Faraway, Oculo | Very common names with many projects and registered domains. |
| Blinkwise | GitHub project with the same name, and `.com` and `.app` registered. |
| Blinkbud | Registered `.com` and next to BlinkFar-type apps. |
| Lookwell | `.com` and `.app` both registered, and generic. |
| Eyeglow | Next to existing eye-care apps ("Red Light For Your Eyes"), `.com` registered. |
| Eyeroost | Clean, but "roost" implies a bird. |
| Gazely | `.com` and `.app` registered, close to GazeAway. |

## Round 3: easier to say than "Gazepals"

"Gazepals" has an awkward z-then-p join. The fixes below keep the gaze + companions idea but end each syllable on a sound that flows into the next. Pronunciation hints in brackets.

| # | Name | Say it | Mac App Store | GitHub | Trademark (web search) | Domains (DNS) | Notes |
|---|---|---|---|---|---|---|---|
| 1 | **Gazeling** | GAYZ-ling | None | One tiny repo `gazelinger` (CoughDrop, an assistive-communication project, 0 stars) | Nothing found | `.com` and `.app` not found | "-ling" means a small creature (duckling), so it suits any character. "z" flows straight into "l". Clean. |
| 2 | **Gazemates** | GAYZ-mates | No match (only the unrelated "PointerPals") | None | Nothing found | `.com` and `.app` not found | "z" into "m" is easy. Friendly, plural like Gazepals. Clean. |
| 3 | **Gazekin** | GAYZ-kin | None | One unrelated repo (`gazeking`, 1 star) | Nothing found | `.com` and `.app` not found | Short and gentle. Slightly less obvious in meaning. Clean. |
| 4 | **Glanceling** | GLANS-ling | None | None | Nothing found | `.com` and `.app` not found | Very distinctive, but longer and "ns-l" is not much easier. |
| 5 | **Gazebuddy** | GAYZ-buddy | Next to EyeBuddy and GazeAway | None | Nothing found | `.com` and `.app` not found | Easy to say, but too close to EyeBuddy. Not recommended. |
| 6 | **Blinkling** | BLINK-ling | Next to BlinkFar, Blinker, Blinkoo | Nine repos, mostly unrelated | Nothing found for the exact name. "Blink" is a crowded trademark family. | `.app` not found; `.com` unclear | Cute, but in a crowded "Blink-" space. Not recommended. |

**Ruled out:** Gazie (an existing open-source ERP called GAzie, and `gazie.com` is registered), Lookling (both domains registered), Eyeling (a 19-star open-source project, `.com` registered), Gazeful (`.com` registered, near Gaze Guard and GazeAway), Gazeby (clean but means nothing).

**Recommendation:** **Gazeling**, with **Gazemates** as the runner-up. Both are clean on every check I could run, and both work whatever the character. The plural reads well in the app: "Meet your Gazelings", the owl being the first.

## Earlier candidates (owl-specific; no longer eligible)

These were ranked by how clean the checks came out. Kept for the record.

| # | Name | Mac App Store | GitHub | Trademark (web search) | Domains (DNS) | Notes |
|---|---|---|---|---|---|---|
| 1 | **Hootbreak** | No match | No repos | Nothing found | `.com` and `.app` not found | Clean on every check. Says what it is. Slight echo of the "Hoot" family (below). |
| 2 | **Gazehoot** | No match for the exact name. Search returns only unrelated eye apps (EyeBuddy, GazeAway). | No repos | Nothing found | `.com` and `.app` not found | Clean. Close to GazeAway in sound, not in spelling. |
| 3 | **Owlbreak** | No match | One tiny repo `OwlBreak` (0 stars, no description) | Nothing found | `.com` and `.app` not found | Clean commercially; a small repo with the same name exists. Low risk, but not zero. |
| 4 | **Eyehoot** | No match for the exact name | None under `eyehoot` | Nothing found | `.com` and `.app` not found | Your existing project's name. Clean, and keeps continuity with eye-hoot. Similar to Hootbreak on "Hoot". |
| 5 | **Far Owl** | No match | No repos | Nothing found. A pending "FUR & FOWL" filing (hunting-call software) is a different mark. | `farowl.com` is registered | Short, hints at "look far." `.com` taken, `.app` not found. |
| 6 | **Wise Eyes** | No match | Three tiny, empty repos | WISEEYES for eyewear was cancelled in 2017 (one had an owl design). A WISEEYE mark for surveillance sensors exists. Eye-care businesses use "Wise Eyes". | `wiseeyes.com` and `.app` both registered | Risky: generic phrase, eyewear/optical use, and the cancelled mark had an owl. Not recommended. |
| 7 | **Softgaze** | No match | Two unrelated repos | Nothing found for the exact name. A "myGaze" eye-tracking mark exists in Canada. | `softgaze.com` registered | Pleasant, but not owl-themed. |

## Names ruled out

| Name | Reason |
|---|---|
| **EyeBreak** | Already used by several apps (see above). |
| **Owlet** | Four Mac App Store apps share the name (BirdBrain Technologies). Also the name of a well-known baby-monitor company. |
| **Nictate** | A Mac menu bar app with this exact name exists on GitHub. |
| **Strix** | Three Mac App Store apps, and a very large open-source project (about 72,000 stars). |
| **Hoot** | Mac App Store app "Hoot – Smart Menu Bar Widgets" and a registered HOOT software mark (Intrado, class 9). |
| **Hootly** | Collides with `Hoot` apps. `hootly.com` and `.app` are registered. |
| **Perch** | Several Mac App Store apps. |
| **Blinkhoot** | No exact match, but sits next to BlinkFar, Blink: 20-20-20 Timer and similar. Adds confusion. |
| **Minerva** | Common name, an existing Mac App Store app, many trademark owners. |
| **Eyrie** | No Mac app found, but 123 GitHub repos use the name. Not distinctive. |
| **Tawny** | 211 GitHub repos, including a notable OWL ontology library. Not distinctive and ambiguous. |

## A caution about names starting with "Hoot"

Hootsuite is a very well-known software brand, and a registered HOOT mark (Intrado) covers meeting software in class 9. I found no dispute over similar "Hoot-" names, and an owl app is far from social media management or conferencing, so the risk looks low. But it is the main reason to prefer a name where "hoot" is part of a compound that clearly says "break" or "gaze" (Hootbreak, Gazehoot) over a bare "Hoot".

## Recommendation

1. **Gazeling** (see round 3): clean on every check, easy to say, and character-neutral.
2. **Gazemates** as runner-up.
3. **Gazepals** is still clean, but harder to say.

None of these is cleared legally. Run the USPTO search before committing, and register the matching GitHub repository name early.

## Unrelated naming points

- **Bundle identifier:** reverse-DNS, for example `com.danielabar.gazeling`. Using your GitHub name avoids needing a domain. This id is hard to change once users have settings saved.
- **Owl character:** avoid green owls and anything resembling the Duolingo owl. This is about the artwork, not the name.
