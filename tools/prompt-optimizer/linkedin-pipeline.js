#!/usr/bin/env node
/**
 * LinkedIn Job Hunt Pipeline
 * Usage: node linkedin-pipeline.js "Company" [count]
 *
 * Finds key people at a target company, generates personalized
 * connection request messages, and saves everything to Obsidian vault.
 */

import Anthropic from "@anthropic-ai/sdk";
import OpenAI from "openai";
import { writeFileSync, mkdirSync, existsSync } from "fs";
import { join } from "path";

const COMPANY = process.argv[2];
const COUNT = parseInt(process.argv[3] || "10", 10);
const VAULT = process.env.OBSIDIAN_VAULT || join(process.env.HOME, "Obsidian", "Vault");
const OUTPUT_DIR = join(VAULT, "Job Hunt", "Outreach");

if (!COMPANY) {
  console.error("Usage: node linkedin-pipeline.js <Company> [count]");
  process.exit(1);
}

if (!process.env.ANTHROPIC_API_KEY) {
  console.error("Missing ANTHROPIC_API_KEY");
  process.exit(1);
}

const anthropic = new Anthropic();
const openai = new OpenAI();

// ── Step 1: Research the company + find key people ──────────────────

async function researchCompany() {
  console.log(`\n🔍 Researching ${COMPANY}...`);

  const res = await anthropic.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 4096,
    messages: [
      {
        role: "user",
        content: `Research ${COMPANY} for a job seeker. Return a JSON object (no markdown fences) with this exact structure:

{
  "company": {
    "name": "${COMPANY}",
    "industry": "",
    "hq": "",
    "size": "",
    "recent_news": ["", ""],
    "tech_stack": [""],
    "culture_notes": "",
    "hiring_signals": ""
  },
  "roles_to_target": ["list of ${COUNT} realistic role titles that are commonly hired for at this company"],
  "departments_of_interest": ["engineering", "product", etc],
  "people": [
    {
      "likely_title": "e.g. Engineering Manager",
      "department": "",
      "why_reach_out": "reason this role is strategic to contact",
      "linkedin_search_query": "site:linkedin.com/in ${COMPANY} [title]"
    }
  ]
}

Generate exactly ${COUNT} entries in the "people" array. These should be realistic titles/roles at ${COMPANY} that a job seeker would want to connect with — hiring managers, team leads, recruiters, senior ICs. Mix of levels and departments.`,
      },
    ],
  });

  const text = res.content[0].text.trim();
  try {
    return JSON.parse(text);
  } catch {
    // Try extracting JSON from response
    const match = text.match(/\{[\s\S]*\}/);
    if (match) return JSON.parse(match[0]);
    console.error("Failed to parse research output, raw response:\n", text);
    process.exit(1);
  }
}

// ── Step 2: Generate personalized connection messages ────────────────

async function generateOutreach(research) {
  console.log(`\n✍️  Generating ${research.people.length} outreach messages...`);

  const res = await anthropic.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 8192,
    messages: [
      {
        role: "user",
        content: `You are writing LinkedIn connection request messages for a job seeker targeting ${COMPANY}.

Company context:
${JSON.stringify(research.company, null, 2)}

For each person below, write:
1. A LinkedIn connection request (max 280 chars — this is the LinkedIn limit)
2. A follow-up message (sent after they accept, 2-3 sentences)
3. A cold email subject line + body (3-4 sentences, professional but human)

People to write for:
${JSON.stringify(research.people, null, 2)}

Return a JSON array (no markdown fences) with this structure for each person:
[
  {
    "title": "their title",
    "department": "",
    "connection_request": "280 char max message",
    "followup_message": "",
    "email_subject": "",
    "email_body": "",
    "linkedin_search": "search query to find them"
  }
]

Rules:
- Never be generic. Reference specific company details, recent news, or tech stack.
- Sound like a real human, not a template. Vary tone across messages.
- Don't beg for a job. Lead with genuine interest or a shared context.
- Keep connection requests punchy — they have 280 char limit.`,
      },
    ],
  });

  const text = res.content[0].text.trim();
  try {
    return JSON.parse(text);
  } catch {
    const match = text.match(/\[[\s\S]*\]/);
    if (match) return JSON.parse(match[0]);
    console.error("Failed to parse outreach output");
    return [];
  }
}

// ── Step 3: Generate a strategic outreach plan ──────────────────────

async function generateStrategy(research, outreach) {
  console.log(`\n🎯 Building outreach strategy...`);

  const res = await openai.chat.completions.create({
    model: "gpt-4o",
    messages: [
      {
        role: "user",
        content: `Based on this research about ${COMPANY}, create a 2-week outreach execution plan.

Company: ${JSON.stringify(research.company)}
Number of contacts: ${outreach.length}
Departments: ${JSON.stringify(research.departments_of_interest)}

Return a concise markdown plan with:
- Week 1 and Week 2 breakdown
- Who to reach out to first and why (prioritize by likelihood of response)
- Best days/times to send LinkedIn requests
- What to post on your own LinkedIn to signal interest (2-3 post ideas)
- Red flags to watch for
- How to follow up without being annoying

Keep it actionable, not fluffy. Max 500 words.`,
      },
    ],
  });

  return res.choices[0].message.content;
}

// ── Step 4: Save to Obsidian vault ──────────────────────────────────

function saveToObsidian(research, outreach, strategy) {
  mkdirSync(OUTPUT_DIR, { recursive: true });

  const date = new Date().toISOString().split("T")[0];
  const filename = `${COMPANY} - Outreach ${date}.md`;
  const filepath = join(OUTPUT_DIR, filename);

  const md = `---
company: ${research.company.name}
industry: ${research.company.industry}
date: ${date}
contacts: ${outreach.length}
status: not-started
tags: [job-hunt, outreach, ${COMPANY.toLowerCase().replace(/\s+/g, "-")}]
---

# ${research.company.name} — Outreach Plan

## Company Intel
- **Industry:** ${research.company.industry}
- **HQ:** ${research.company.hq}
- **Size:** ${research.company.size}
- **Tech Stack:** ${(research.company.tech_stack || []).join(", ")}
- **Culture:** ${research.company.culture_notes}
- **Hiring Signals:** ${research.company.hiring_signals}

### Recent News
${(research.company.recent_news || []).map((n) => `- ${n}`).join("\n")}

---

## Outreach Strategy
${strategy}

---

## Connection Messages

${outreach
  .map(
    (p, i) => `### ${i + 1}. ${p.title} (${p.department})

**Find them:** \`${p.linkedin_search}\`

**Connection Request** (${p.connection_request.length}/280 chars):
> ${p.connection_request}

**Follow-up Message:**
> ${p.followup_message}

**Cold Email:**
- **Subject:** ${p.email_subject}
> ${p.email_body}

---`
  )
  .join("\n\n")}

## Tracking

| # | Title | Platform | Sent | Accepted | Replied | Notes |
|---|-------|----------|------|----------|---------|-------|
${outreach.map((p, i) => `| ${i + 1} | ${p.title} | LinkedIn | ⬜ | ⬜ | ⬜ | |`).join("\n")}
`;

  writeFileSync(filepath, md);
  return filepath;
}

// ── Main ────────────────────────────────────────────────────────────

async function main() {
  console.log(`\n🚀 LinkedIn Pipeline: ${COMPANY} (${COUNT} contacts)`);
  console.log(`📁 Output: ${OUTPUT_DIR}\n`);

  const research = await researchCompany();
  console.log(`   ✓ Company researched: ${research.company.industry}, ${research.company.size}`);

  const outreach = await generateOutreach(research);
  console.log(`   ✓ ${outreach.length} outreach messages generated`);

  const strategy = await generateStrategy(research, outreach);
  console.log(`   ✓ Strategy plan created`);

  const filepath = saveToObsidian(research, outreach, strategy);
  console.log(`\n✅ Saved to: ${filepath}`);
  console.log(`\n📋 Copying first connection request to clipboard...`);

  if (outreach.length > 0) {
    const { execSync } = await import("child_process");
    execSync(`echo ${JSON.stringify(outreach[0].connection_request)} | pbcopy`);
    console.log(`   "${outreach[0].connection_request.slice(0, 60)}..."`);
  }

  console.log(`\n🎯 Open Obsidian → Job Hunt → Outreach to see the full plan`);
}

main().catch((err) => {
  console.error("\n❌ Pipeline failed:", err.message);
  process.exit(1);
});
