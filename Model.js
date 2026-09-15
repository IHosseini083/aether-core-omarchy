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
    running: false,
    connected: false,
    ip: "",
    colo: "",
    loc: "",
    warp: "",
    latency_ms: 0,
    proxy_port: 1819,
    system_proxy: false
  };

  if (!rawJson || typeof rawJson !== "string") {
    return defaultState;
  }

  try {
    var parsed = JSON.parse(rawJson);
    return {
      installed: parsed.installed === true,
      binary: String(parsed.binary || ""),
      running: parsed.running === true,
      connected: parsed.connected === true,
      ip: String(parsed.ip || ""),
      colo: String(parsed.colo || ""),
      loc: String(parsed.loc || ""),
      warp: String(parsed.warp || ""),
      latency_ms: Number(parsed.latency_ms) || 0,
      proxy_port: Number(parsed.proxy_port) || 1819,
      system_proxy: parsed.system_proxy === true
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

function exportEnv(port) {
  var u = socksUrl(port);
  return "export all_proxy=" + u + " http_proxy=" + u + " https_proxy=" + u;
}

function curlSnippet(port) {
  var u = socksUrl(port);
  return "curl -x " + u + " https://www.cloudflare.com/cdn-cgi/trace";
}
