#!/usr/bin/env node
// verify.mjs — reproducible DoD check for marketplace-mcp-server/core-server.
//
// Run: node test/verify.mjs   (from mcp-server/, or via `npm run verify`)
//
// Checks (DoD items 2-6 from the epic handoff):
//   2. tools/list returns 18 tools (6 core + 7 lsa + 5 manager)
//   3. resources/list returns 17 resources (2 core + 5 lsa + 10 manager)
//   4. calling the "ground-rules" tool returns a body byte-identical to
//      core/skills/ground-rules/SKILL.md
//   5. reading the resource for lsa/knowledge/conventions.md returns
//      content byte-identical to that file
//   6. a malformed SKILL.md (missing frontmatter "name") is skipped, not a
//      crash — proven against test/fixtures/malformed-skill/, not a
//      permanent fake skill under core/lsa/manager
//
// Exits 0 if every check passes, 1 otherwise, printing a PASS/FAIL line per
// check plus the actual values observed.

import { readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";
import { buildServer } from "../src/index.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const MCP_SERVER_DIR = path.resolve(__dirname, "..");
const REPO_ROOT = path.resolve(MCP_SERVER_DIR, "..");

let failures = 0;

function report(label, pass, detail) {
  const status = pass ? "PASS" : "FAIL";
  if (!pass) failures += 1;
  console.log(`${status}  ${label}${detail ? " — " + detail : ""}`);
}

async function main() {
  // --- Checks 2, 3, 4, 5: spawn the real server over a real stdio child
  // process, exactly as an MCP client (Cursor, VS Code, etc.) would. ---
  const transport = new StdioClientTransport({
    command: process.execPath, // node
    args: [path.join(MCP_SERVER_DIR, "src", "index.js")],
    cwd: MCP_SERVER_DIR,
    stderr: "pipe",
  });
  const client = new Client({ name: "verify-script", version: "0.1.0" });
  await client.connect(transport);

  try {
    // Check 2: tools/list == 18
    const toolsResult = await client.listTools();
    const toolNames = toolsResult.tools.map((t) => t.name).sort();
    report(
      "tools/list returns 18 tools",
      toolsResult.tools.length === 18,
      `got ${toolsResult.tools.length}: [${toolNames.join(", ")}]`,
    );

    // Check 3: resources/list == 17
    const resourcesResult = await client.listResources();
    report(
      "resources/list returns 17 resources",
      resourcesResult.resources.length === 17,
      `got ${resourcesResult.resources.length}`,
    );

    // Check 4: ground-rules tool body byte-identical to source SKILL.md
    const groundRulesPath = path.join(
      REPO_ROOT,
      "core",
      "skills",
      "ground-rules",
      "SKILL.md",
    );
    const expectedGroundRules = readFileSync(groundRulesPath, "utf8");
    const toolCallResult = await client.callTool({
      name: "ground-rules",
      arguments: {},
    });
    const actualGroundRules = toolCallResult.content?.[0]?.text ?? "";
    report(
      'calling "ground-rules" tool returns byte-identical body',
      actualGroundRules === expectedGroundRules,
      `expected ${expectedGroundRules.length} bytes, got ${actualGroundRules.length} bytes`,
    );

    // Check 5: lsa/knowledge/conventions.md resource byte-identical
    const conventionsPath = path.join(
      REPO_ROOT,
      "lsa",
      "knowledge",
      "conventions.md",
    );
    const expectedConventions = readFileSync(conventionsPath, "utf8");
    const conventionsResource = resourcesResult.resources.find(
      (r) => r.name === path.join("lsa", "knowledge", "conventions.md"),
    );
    if (!conventionsResource) {
      report(
        "reading lsa/knowledge/conventions.md resource returns byte-identical content",
        false,
        "resource not found in resources/list",
      );
    } else {
      const readResult = await client.readResource({
        uri: conventionsResource.uri,
      });
      const actualConventions = readResult.contents?.[0]?.text ?? "";
      report(
        "reading lsa/knowledge/conventions.md resource returns byte-identical content",
        actualConventions === expectedConventions,
        `expected ${expectedConventions.length} bytes, got ${actualConventions.length} bytes`,
      );
    }
  } finally {
    await client.close();
  }

  // --- Check 6: malformed SKILL.md is skipped, not a crash. Built
  // in-process against test/fixtures/malformed-skill/ (not a permanent
  // fake skill under core/lsa/manager) over a linked in-memory transport,
  // so this also proves startup completes successfully with the bad file
  // present. ---
  const fixtureRoot = path.join(__dirname, "fixtures", "malformed-skill");
  let fixtureOk = true;
  let fixtureDetail = "";
  try {
    const { server: fixtureServer, skills: fixtureSkills } = buildServer(
      fixtureRoot,
      ["fixture-plugin"],
    );
    const [serverTransport, clientTransport] =
      InMemoryTransport.createLinkedPair();
    const fixtureClient = new Client({
      name: "verify-script-fixture",
      version: "0.1.0",
    });
    await Promise.all([
      fixtureServer.connect(serverTransport),
      fixtureClient.connect(clientTransport),
    ]);
    const fixtureTools = await fixtureClient.listTools();
    const registeredNames = fixtureTools.tools.map((t) => t.name).sort();
    fixtureOk =
      fixtureSkills.length === 1 &&
      fixtureSkills[0].name === "good-skill" &&
      registeredNames.length === 1 &&
      registeredNames[0] === "good-skill";
    fixtureDetail = `startup succeeded; registered tools: [${registeredNames.join(", ")}]`;
    await fixtureClient.close();
    await fixtureServer.close();
  } catch (err) {
    fixtureOk = false;
    fixtureDetail = `startup threw: ${err.stack || err}`;
  }
  report(
    "malformed SKILL.md (missing frontmatter name) is skipped, startup does not crash",
    fixtureOk,
    fixtureDetail,
  );

  console.log("");
  if (failures === 0) {
    console.log("ALL CHECKS PASSED");
    process.exit(0);
  } else {
    console.log(`${failures} CHECK(S) FAILED`);
    process.exit(1);
  }
}

main().catch((err) => {
  console.error("verify.mjs crashed:", err.stack || err);
  process.exit(1);
});
