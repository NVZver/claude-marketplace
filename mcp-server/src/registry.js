// registry.js
//
// Reads this repo's SKILL.md and knowledge/*.md files directly off disk and
// builds the tool/resource registration lists the server needs.
//
// Zero content duplication: every function here reads the source file at
// call time (or at the startup scan) and hands back the file's own bytes
// unchanged. Nothing is copied, embedded, or paraphrased into this module.

import { readFileSync, readdirSync, statSync } from "node:fs";
import path from "node:path";
import matter from "gray-matter";

/**
 * The plugin roots this epic is scoped to. prompt-engineer and observer are
 * explicitly out of scope for marketplace-mcp-server/core-server (see the
 * parent pitch's "First-slice scope" gate decision).
 */
export const PLUGINS = ["core", "lsa", "manager"];

/**
 * The first-slice agent files this epic registers as MCP prompts, as paths
 * relative to the repo root. Unlike skills/knowledge (scanned directories),
 * agents are an explicit, fixed list — the pitch's confirmed first-slice
 * scope (core+lsa+manager), not "every agents/*.md in every plugin".
 */
export const AGENT_FILES = [
  "manager/agents/product-manager.md",
  "manager/agents/project-manager.md",
  "lsa/agents/orchestrator.md",
];

/**
 * List immediate subdirectories of `dir` (skill directories are one level
 * deep: core/skills/<skill-name>/SKILL.md). Returns [] if `dir` doesn't
 * exist rather than throwing, so a plugin with no skills/knowledge dir is
 * simply skipped.
 */
function listDirs(dir) {
  try {
    return readdirSync(dir, { withFileTypes: true })
      .filter((e) => e.isDirectory())
      .map((e) => e.name)
      .sort();
  } catch (err) {
    if (err.code === "ENOENT") return [];
    throw err;
  }
}

function listMarkdownFiles(dir) {
  try {
    return readdirSync(dir, { withFileTypes: true })
      .filter((e) => e.isFile() && e.name.endsWith(".md"))
      .map((e) => e.name)
      .sort();
  } catch (err) {
    if (err.code === "ENOENT") return [];
    throw err;
  }
}

/**
 * Scan <repoRoot>/<plugin>/skills/*\/SKILL.md for every plugin in `plugins`
 * and return one descriptor per file that has valid frontmatter.
 *
 * A SKILL.md missing the required `name` or `description` frontmatter key
 * is skipped (logged to stderr) rather than raising — requirement 7 /
 * server-startup.feature "Skips a malformed skill file without crashing
 * startup".
 *
 * Each descriptor's `read()` re-reads the file from disk on every call, so
 * a change to the source file is reflected on the next server start with
 * no regen step (this is the whole point of this epic).
 */
export function scanSkills(repoRoot, plugins = PLUGINS) {
  const found = [];
  for (const plugin of plugins) {
    const skillsDir = path.join(repoRoot, plugin, "skills");
    for (const skillName of listDirs(skillsDir)) {
      const filePath = path.join(skillsDir, skillName, "SKILL.md");
      try {
        statSync(filePath);
      } catch {
        continue; // no SKILL.md in this directory — not a skill
      }
      const raw = readFileSync(filePath, "utf8");
      let parsed;
      try {
        parsed = matter(raw);
      } catch (err) {
        process.stderr.write(
          `[marketplace-mcp-server] skipping ${filePath}: frontmatter parse error: ${err.message}\n`,
        );
        continue;
      }
      const { name, description } = parsed.data ?? {};
      if (typeof name !== "string" || name.trim() === "") {
        process.stderr.write(
          `[marketplace-mcp-server] skipping ${filePath}: missing frontmatter "name"\n`,
        );
        continue;
      }
      if (typeof description !== "string" || description.trim() === "") {
        process.stderr.write(
          `[marketplace-mcp-server] skipping ${filePath}: missing frontmatter "description"\n`,
        );
        continue;
      }
      found.push({
        plugin,
        skillName,
        name,
        description,
        filePath,
        // Re-read on every call — no caching of file content, so the
        // server always serves what is on disk right now.
        read: () => readFileSync(filePath, "utf8"),
      });
    }
  }
  return found;
}

/**
 * Read each file in `agentFiles` (relative to `repoRoot`) and return one
 * descriptor per file that has valid frontmatter.
 *
 * Same validation contract as `scanSkills`: an agent file missing the
 * required `name` or `description` frontmatter key is skipped (logged to
 * stderr) rather than raising — requirement 4 /
 * prompt-startup.feature "Skips a malformed agent file without crashing
 * startup". A listed file that doesn't exist on disk is likewise skipped
 * silently, so a test fixture root that only has some of the listed files
 * doesn't need every path to be present.
 *
 * Each descriptor's `read()` re-reads the file from disk on every call, so
 * a change to the source file is reflected on the next server start with
 * no regen step — same zero-copy contract as scanSkills/scanKnowledge.
 */
export function scanAgents(repoRoot, agentFiles = AGENT_FILES) {
  const found = [];
  for (const relPath of agentFiles) {
    const filePath = path.join(repoRoot, relPath);
    try {
      statSync(filePath);
    } catch {
      continue; // listed file doesn't exist here — not an error, just skip
    }
    const raw = readFileSync(filePath, "utf8");
    let parsed;
    try {
      parsed = matter(raw);
    } catch (err) {
      process.stderr.write(
        `[marketplace-mcp-server] skipping ${filePath}: frontmatter parse error: ${err.message}\n`,
      );
      continue;
    }
    const { name, description } = parsed.data ?? {};
    if (typeof name !== "string" || name.trim() === "") {
      process.stderr.write(
        `[marketplace-mcp-server] skipping ${filePath}: missing frontmatter "name"\n`,
      );
      continue;
    }
    if (typeof description !== "string" || description.trim() === "") {
      process.stderr.write(
        `[marketplace-mcp-server] skipping ${filePath}: missing frontmatter "description"\n`,
      );
      continue;
    }
    found.push({
      relPath,
      name,
      description,
      filePath,
      // Re-read on every call — no caching of file content, so the
      // server always serves what is on disk right now.
      read: () => readFileSync(filePath, "utf8"),
    });
  }
  return found;
}

/**
 * Scan <repoRoot>/<plugin>/knowledge/*.md for every plugin in `plugins` and
 * return one descriptor per Markdown file found. Every file found is
 * registered — knowledge files have no frontmatter contract to validate.
 */
export function scanKnowledge(repoRoot, plugins = PLUGINS) {
  const found = [];
  for (const plugin of plugins) {
    const knowledgeDir = path.join(repoRoot, plugin, "knowledge");
    for (const fileName of listMarkdownFiles(knowledgeDir)) {
      const filePath = path.join(knowledgeDir, fileName);
      const relPath = path.join(plugin, "knowledge", fileName);
      found.push({
        plugin,
        fileName,
        filePath,
        relPath,
        uri: `repo:///${relPath}`,
        read: () => readFileSync(filePath, "utf8"),
      });
    }
  }
  return found;
}
