#!/usr/bin/env node
// verify.mjs — reproducible DoD check for marketplace-mcp-server/core-server
// and marketplace-mcp-server/agent-prompts.
//
// Run: node test/verify.mjs   (from mcp-server/, or via `npm run verify`)
//
// Checks (DoD items 2-6 from the core-server epic handoff):
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
// Checks added for the agent-prompts epic (DoD items 1-5 there):
//   7. prompts/list returns exactly 3 prompts: product-manager,
//      project-manager, orchestrator — and tools/list (18) and
//      resources/list (17) are unaffected
//   8. requesting the "project-manager" prompt returns content
//      byte-identical to manager/agents/project-manager.md
//   9. static check: no outbound network / LLM SDK usage in the prompt
//      registration/serving code path (src/index.js, src/registry.js)
//   10. a malformed agent file (missing frontmatter "name") is skipped, not
//       a crash — proven against test/fixtures/malformed-agent/, not a
//       permanent fake agent under manager/lsa
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

    // Check 7: prompts/list == 3 (product-manager, project-manager,
    // orchestrator), and the existing tools/resources counts (already
    // asserted above) are unaffected by adding prompt registration.
    const promptsResult = await client.listPrompts();
    const promptNames = promptsResult.prompts.map((p) => p.name).sort();
    const expectedPromptNames = [
      "orchestrator",
      "product-manager",
      "project-manager",
    ];
    report(
      "prompts/list returns exactly 3 prompts (product-manager, project-manager, orchestrator)",
      promptsResult.prompts.length === 3 &&
        promptNames.join(",") === expectedPromptNames.join(","),
      `got ${promptsResult.prompts.length}: [${promptNames.join(", ")}]`,
    );

    // Check 8: requesting the "project-manager" prompt returns content
    // byte-identical to manager/agents/project-manager.md.
    const projectManagerPath = path.join(
      REPO_ROOT,
      "manager",
      "agents",
      "project-manager.md",
    );
    const expectedProjectManager = readFileSync(projectManagerPath, "utf8");
    const promptResult = await client.getPrompt({ name: "project-manager" });
    const actualProjectManager =
      promptResult.messages?.[0]?.content?.text ?? "";
    report(
      'requesting the "project-manager" prompt returns byte-identical content',
      actualProjectManager === expectedProjectManager,
      `expected ${expectedProjectManager.length} bytes, got ${actualProjectManager.length} bytes`,
    );
  } finally {
    await client.close();
  }

  // --- Check 9: static check — no outbound network / LLM SDK usage
  // anywhere in the code path that registers or serves prompts
  // (src/index.js, src/registry.js). Same static-check style already
  // proven for the tool/resource requirements in the core-server epic's
  // reconcile pass (grep for fetch/http/net/known LLM SDK names), applied
  // in-process here so it's part of the one reproducible entry point. ---
  {
    const NETWORK_CALL_PATTERN =
      /\bfetch\s*\(|https?\.request|\baxios\b|XMLHttpRequest|WebSocket|\bnet\.(connect|createConnection)|\bhttp\.createServer|\banthropic\b|\bopenai\b/i;
    const filesToCheck = [
      path.join(MCP_SERVER_DIR, "src", "index.js"),
      path.join(MCP_SERVER_DIR, "src", "registry.js"),
    ];
    const offenders = [];
    for (const f of filesToCheck) {
      const src = readFileSync(f, "utf8");
      if (NETWORK_CALL_PATTERN.test(src)) offenders.push(f);
    }
    report(
      "no outbound network / LLM SDK call in src/index.js or src/registry.js",
      offenders.length === 0,
      offenders.length === 0
        ? "no match for fetch/http/net/axios/websocket/anthropic/openai patterns"
        : `pattern matched in: ${offenders.join(", ")}`,
    );
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

  // --- Check 10: malformed agent file (missing frontmatter "name") is
  // skipped, not a crash. Built in-process against
  // test/fixtures/malformed-agent/ (not a permanent fake agent under
  // manager/lsa) over a linked in-memory transport — proves both the skip
  // and that startup completes successfully with the bad file present. ---
  const agentFixtureRoot = path.join(__dirname, "fixtures", "malformed-agent");
  let agentFixtureOk = true;
  let agentFixtureDetail = "";
  try {
    const {
      server: agentFixtureServer,
      agents: agentFixtureAgents,
    } = buildServer(agentFixtureRoot, [], ["good-agent.md", "bad-agent.md"]);
    const [serverTransport, clientTransport] =
      InMemoryTransport.createLinkedPair();
    const agentFixtureClient = new Client({
      name: "verify-script-agent-fixture",
      version: "0.1.0",
    });
    await Promise.all([
      agentFixtureServer.connect(serverTransport),
      agentFixtureClient.connect(clientTransport),
    ]);
    const agentFixturePrompts = await agentFixtureClient.listPrompts();
    const registeredPromptNames = agentFixturePrompts.prompts
      .map((p) => p.name)
      .sort();
    agentFixtureOk =
      agentFixtureAgents.length === 1 &&
      agentFixtureAgents[0].name === "good-agent" &&
      registeredPromptNames.length === 1 &&
      registeredPromptNames[0] === "good-agent";
    agentFixtureDetail = `startup succeeded; registered prompts: [${registeredPromptNames.join(", ")}]`;
    await agentFixtureClient.close();
    await agentFixtureServer.close();
  } catch (err) {
    agentFixtureOk = false;
    agentFixtureDetail = `startup threw: ${err.stack || err}`;
  }
  report(
    "malformed agent file (missing frontmatter name) is skipped, startup does not crash",
    agentFixtureOk,
    agentFixtureDetail,
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
