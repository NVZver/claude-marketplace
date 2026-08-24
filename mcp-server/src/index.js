#!/usr/bin/env node
// marketplace-mcp-server — local stdio MCP server.
//
// At startup this reads core/skills/, core/knowledge/, lsa/skills/,
// lsa/knowledge/, manager/skills/, manager/knowledge/ from this repo and
// registers:
//   - one MCP tool per SKILL.md (tool name = frontmatter `name`, tool
//     description = frontmatter `description`, tool call returns the
//     file's body unchanged)
//   - one MCP resource per knowledge/*.md file (resource content = file
//     content unchanged)
//   - one MCP prompt per first-slice agent file (manager/agents/
//     product-manager.md, manager/agents/project-manager.md,
//     lsa/agents/orchestrator.md — prompt name = frontmatter `name`, prompt
//     description = frontmatter `description`, prompt content = the file's
//     body returned unchanged when requested)
//
// Transport: stdio only. No network listener, no outbound network or LLM
// calls — this process is a passthrough/registration layer, not an agent.
// A prompt callback returns the agent file's body as prompt message text;
// it never invokes an LLM, dispatches a sub-agent, or makes any outbound
// network call — the connecting client's own agent loop runs the returned
// instructions, not this server.
//
// See .lsa/features/marketplace-mcp-server/core-server/ for the grounded
// spec the tool/resource behavior implements, and
// .lsa/features/marketplace-mcp-server/agent-prompts/ for the prompt
// behavior this file also implements.

import { fileURLToPath } from "node:url";
import path from "node:path";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  PLUGINS,
  AGENT_FILES,
  scanSkills,
  scanKnowledge,
  scanAgents,
} from "./registry.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
// mcp-server/src/index.js -> repo root is two levels up.
const REPO_ROOT = path.resolve(__dirname, "..", "..");

export function buildServer(
  repoRoot = REPO_ROOT,
  plugins = PLUGINS,
  agentFiles = AGENT_FILES,
) {
  const server = new McpServer({
    name: "marketplace-mcp-server",
    version: "0.1.0",
  });

  const skills = scanSkills(repoRoot, plugins);
  for (const skill of skills) {
    server.registerTool(
      skill.name,
      { description: skill.description },
      async () => ({
        content: [{ type: "text", text: skill.read() }],
      }),
    );
  }

  const knowledgeFiles = scanKnowledge(repoRoot, plugins);
  for (const kf of knowledgeFiles) {
    server.registerResource(
      kf.relPath,
      kf.uri,
      { title: kf.relPath, mimeType: "text/markdown" },
      async (uri) => ({
        contents: [
          {
            uri: uri.href,
            mimeType: "text/markdown",
            text: kf.read(),
          },
        ],
      }),
    );
  }

  const agents = scanAgents(repoRoot, agentFiles);
  for (const agent of agents) {
    server.registerPrompt(
      agent.name,
      { title: agent.name, description: agent.description },
      // No arguments, no LLM/network call: this callback only reads the
      // agent file's body off disk and hands it back as prompt message
      // text. Running the instructions it contains is the connecting
      // client's own agent loop's job, not this server's.
      async () => ({
        messages: [
          {
            role: "user",
            content: { type: "text", text: agent.read() },
          },
        ],
      }),
    );
  }

  process.stderr.write(
    `[marketplace-mcp-server] registered ${skills.length} tools, ${knowledgeFiles.length} resources, ${agents.length} prompts from ${plugins.join(", ")}\n`,
  );

  return { server, skills, knowledgeFiles, agents };
}

async function main() {
  const { server } = buildServer();
  const transport = new StdioServerTransport();
  await server.connect(transport);
  process.stderr.write("[marketplace-mcp-server] ready on stdio\n");
}

// Only auto-start when run directly (not when imported by the verify script).
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((err) => {
    process.stderr.write(`[marketplace-mcp-server] fatal: ${err.stack || err}\n`);
    process.exit(1);
  });
}
