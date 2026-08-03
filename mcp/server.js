#!/usr/bin/env node
// Not hosted — this is meant to be run locally (see the connect snippet on
// features/agent-data-plane-mcp.md). Its tool list is read from
// openapi/plane-v1.yaml's x-mcp-tool operations at startup rather than
// hand-typed here, so it can never drift from the spec or the docs table
// generated from the same file. Every call is proxied as a REST request to
// PLANE_MCP_BASE_URL — by default the local Prism mock from Story 10.5
// (http://127.0.0.1:4010), so the whole stack runs with no key and no
// hosted endpoint. Point it at a real base URL and key once you have one.

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { load } from "js-yaml";
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { ListToolsRequestSchema, CallToolRequestSchema } from "@modelcontextprotocol/sdk/types.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SPEC_PATH = path.join(__dirname, "..", "openapi", "plane-v1.yaml");
const BASE_URL = process.env.PLANE_MCP_BASE_URL || "http://127.0.0.1:4010";

const spec = load(readFileSync(SPEC_PATH, "utf8"));

function resolveRef(ref) {
  return ref
    .replace(/^#\//, "")
    .split("/")
    .reduce((node, key) => node[key], spec);
}

function resolveParam(param) {
  return param.$ref ? resolveRef(param.$ref) : param;
}

// MCP has no request headers, so a header parameter reaches a tool only under
// the argument name it declares in x-mcp-arg — the same rule `rake mcp:manifest`
// applies when it generates the documented argument lists. A header parameter
// declaring none contributes no argument at all: surfacing it under its header
// spelling would advertise an argument this server then silently dropped.
function mcpArgName(param) {
  return param.in === "header" ? param["x-mcp-arg"] : param.name;
}

// One entry per operation carrying x-mcp-tool: the single source of truth
// this server, the docs table, and mcp-tool-table-generated all read.
const TOOLS = [];
for (const methods of Object.values(spec.paths)) {
  for (const [method, op] of Object.entries(methods)) {
    if (!op || typeof op !== "object" || !op["x-mcp-tool"]) continue;

    const route = Object.keys(spec.paths).find((r) => spec.paths[r][method] === op);
    const params = (op.parameters || []).map(resolveParam);

    const properties = {
      plane_api_key: {
        type: "string",
        description: "Your SignalsAPI API key — the same one the REST surface takes as X-API-Key.",
      },
    };
    const required = ["plane_api_key"];

    for (const param of params) {
      const argName = mcpArgName(param);
      if (!argName) continue;

      properties[argName] = { ...(param.schema || { type: "string" }), description: param.description };
      if (param.required) required.push(argName);
    }

    const bodySchema = op.requestBody?.content?.["application/json"]?.schema;
    if (bodySchema) {
      for (const [name, propSchema] of Object.entries(bodySchema.properties || {})) {
        properties[name] = propSchema;
        if ((bodySchema.required || []).includes(name)) required.push(name);
      }
    }

    TOOLS.push({
      name: op["x-mcp-tool"],
      description: op.description || op.summary,
      method: method.toUpperCase(),
      route,
      pathParamNames: params.filter((p) => p.in === "path").map((p) => p.name),
      queryParamNames: params.filter((p) => p.in === "query").map((p) => p.name),
      headerParams: params
        .filter((p) => p.in === "header" && mcpArgName(p))
        .map((p) => ({ header: p.name, arg: mcpArgName(p) })),
      bodyParamNames: bodySchema ? Object.keys(bodySchema.properties || {}) : [],
      inputSchema: { type: "object", properties, required },
    });
  }
}

function buildUrl(tool, args) {
  let url = tool.route;
  for (const name of tool.pathParamNames) {
    url = url.replace(`{${name}}`, encodeURIComponent(args[name]));
  }

  const query = new URLSearchParams();
  for (const name of tool.queryParamNames) {
    if (args[name] !== undefined) query.set(name, args[name]);
  }
  const qs = query.toString();

  return `${BASE_URL}${url}${qs ? `?${qs}` : ""}`;
}

const server = new Server({ name: "signalsapi-plane", version: "1.0.0" }, { capabilities: { tools: {} } });

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: TOOLS.map(({ name, description, inputSchema }) => ({ name, description, inputSchema })),
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const tool = TOOLS.find((t) => t.name === request.params.name);
  if (!tool) {
    return { content: [{ type: "text", text: `unknown tool: ${request.params.name}` }], isError: true };
  }

  const args = request.params.arguments || {};
  const body = tool.bodyParamNames.length
    ? Object.fromEntries(tool.bodyParamNames.filter((name) => args[name] !== undefined).map((name) => [name, args[name]]))
    : undefined;

  const headers = {
    "X-API-Key": args.plane_api_key,
    ...(body ? { "Content-Type": "application/json" } : {}),
  };
  for (const { header, arg } of tool.headerParams) {
    if (args[arg] !== undefined) headers[header] = args[arg];
  }

  const response = await fetch(buildUrl(tool, args), {
    method: tool.method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });

  const text = await response.text();
  return { content: [{ type: "text", text }], isError: !response.ok };
});

await server.connect(new StdioServerTransport());
