.pragma library

var activePhrases = [
  "Bypassing censorship",
  "Tunneling with MASQUE",
  "Guarding traffic",
  "Routing through WARP",
  "Protecting packets",
  "Stealth encrypted stream",
  "Circumventing filters",
  "Securing connections"
];

function getHeroPhrase(index) {
  return activePhrases[Math.abs(index) % activePhrases.length];
}

function parseStatus(rawJson) {
  var defaultState = {
    installed: false,
    binary: "",
    binary_version: "",
    has_cap_net_admin: false,
    running: false,
    pid: "",
    connected: false,
    ip: "",
    colo: "",
    loc: "",
    warp: "",
    latency_ms: 0,
    proxy_port: 1819,
    http_proxy_port: 0,
    system_proxy: false,
    protocol: "masque",
    scan: "balanced",
    noize: "firewall",
    ip_mode: "v4",
    h2: false,
    fragment: false,
    quick_reconnect: true,
    mark_enabled: false,
    discovered_cores: []
  };

  if (!rawJson || typeof rawJson !== "string") {
    return defaultState;
  }

  try {
    var parsed = JSON.parse(rawJson);
    return {
      installed: parsed.installed === true,
      binary: String(parsed.binary || ""),
      binary_version: String(parsed.binary_version || ""),
      has_cap_net_admin: parsed.has_cap_net_admin === true,
      running: parsed.running === true,
      pid: String(parsed.pid || ""),
      connected: parsed.connected === true,
      ip: String(parsed.ip || ""),
      colo: String(parsed.colo || ""),
      loc: String(parsed.loc || ""),
      warp: String(parsed.warp || ""),
      latency_ms: Number(parsed.latency_ms) || 0,
      proxy_port: Number(parsed.proxy_port) || 1819,
      http_proxy_port: Number(parsed.http_proxy_port) || 0,
      system_proxy: parsed.system_proxy === true,
      protocol: String(parsed.protocol || "masque"),
      scan: String(parsed.scan || "balanced"),
      noize: String(parsed.noize || "firewall"),
      ip_mode: String(parsed.ip_mode || "v4"),
      h2: parsed.h2 === true,
      fragment: parsed.fragment === true,
      quick_reconnect: parsed.quick_reconnect === true,
      mark_enabled: parsed.mark_enabled === true,
      discovered_cores: Array.isArray(parsed.discovered_cores) ? parsed.discovered_cores : []
    };
  } catch (e) {
    return defaultState;
  }
}

function formatLatency(ms) {
  if (!ms || ms <= 0) return "--";
  return ms + " ms";
}

function formatColo(colo, loc) {
  if (!colo) return loc ? loc : "Unknown";
  if (loc && loc !== colo) return colo + " (" + loc + ")";
  return colo;
}

function socksUrl(port) {
  var p = port || 1819;
  return "socks5h://127.0.0.1:" + p;
}

function httpProxyUrl(port) {
  if (!port || port <= 0) return "";
  return "http://127.0.0.1:" + port;
}

function exportEnv(port) {
  var u = socksUrl(port);
  return "export all_proxy=" + u + " http_proxy=" + u + " https_proxy=" + u;
}

function curlSnippet(port) {
  var u = socksUrl(port);
  return "curl -x " + u + " https://www.cloudflare.com/cdn-cgi/trace";
}

function cleanLogLines(rawText) {
  if (!rawText) return "";
  // Strip ANSI color codes if any
  return String(rawText).replace(/\x1B\[[0-9;]*[mK]/g, "");
}
