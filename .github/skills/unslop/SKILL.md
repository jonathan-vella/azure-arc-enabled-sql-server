---
name: unslop
description: Remove AI writing patterns from markdown docs, comments, and PR text. Apply to every prose edit in this repository.
---

# Unslop

Edit prose to remove AI writing patterns while keeping the meaning. Adapted from the `unslop` skill in
[cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack/skills/unslop). Rule numbers match the source so they
can be cited.

## Process

1. Scan the text for the patterns below.
2. Rewrite each hit. Keep facts, commands, and code unchanged.
3. Run `.github/scripts/check-docs.ps1` to catch the mechanical patterns (em dashes, emojis, curly quotes).

## Content and language

- **3. Trailing -ing phrases** ("ensuring...", "highlighting..."). Delete them or state the concrete effect.
- **5. Vague attribution** ("experts say"). Name the source or delete the claim.
- **7. AI vocabulary** (additionally, crucial, delve, enhance, landscape, pivotal, seamless, robust, comprehensive).
  Use a plain word.
- **8. Fancy "is"** ("serves as", "boasts", "features"). Write "is" or "has".
- **9. "Not just X, but Y."** State the point directly.
- **10. Forced groups of three.** Use the real number of items.
- **11. Synonym cycling.** Pick one term and repeat it.
- **12. False ranges** ("from X to Y" with no scale). List the items.

## Style

- **13. No em dashes.** Use a period or a comma. Also avoid en dashes and hyphens used as dashes.
- **14. Colons** only before a list, a code block, or an example. Not as a mid-sentence connector.
- **15. Bold** is for UI labels the reader must click and for warnings. Do not bold every product name.
- **16. Inline-header lists.** Convert "**Performance:** performance improved" bullets to prose or a table.
- **17. Sentence-case headings.**
- **18. No decorative emojis.** The one exception in this repository is ⚠️ to mark a preview feature.
- **19. Straight quotes.**

## Filler and jargon

- **20. Chatbot phrases** ("I hope this helps", "Let me know if").
- **22. Sycophancy** ("Great question").
- **23. Filler.** "In order to" becomes "to". Delete "it is important to note that".
- **24. Hedging.** One hedge per claim at most.
- **25. Generic conclusions.** End with the next step or a fact.
- **26. Abstract metaphor nouns** (substrate, vector, surface, nexus, paradigm, north star). Use the concrete word.

## Plain speech

- **27. Name the mechanism or number**, not the feeling. If a sentence could appear unchanged in another project's docs,
  cut it.
- **28. One idea per sentence.** Split dense sentences.
- **29. Active voice.** Name the actor: "the script creates the resource group".
- **30. Cut adverbs.** Use a stronger verb or the measured value.
- **31. Plain words.** "use" not "utilize" or "leverage"; "many" not "numerous".
- **32. No mannered prose.** Say the literal thing.
- **33. No over-compression.** Keep articles and verbs. Spell out arrows and abbreviations.

## Repository conventions that override the source rules

- Keep GitHub callouts (`> [!NOTE]`, `> [!IMPORTANT]`, `> [!WARNING]`). They are structure, not decoration.
- Use "Microsoft Entra ID", never "Azure AD" or "AAD".
- Product name: "SQL Server enabled by Azure Arc". "Azure Arc-enabled SQL Server" is acceptable in titles.
- Do not change script names, parameter names, resource names, or quoted Microsoft Learn titles.
- Technical terms in code spans and tables keep their exact spelling.
