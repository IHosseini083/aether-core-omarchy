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
    protocol: "masque",
    scan: "balanced",
    noize: "firewall",
    ip_mode: "v4",
    h2: false,
    fragment: false,
    fragment_size: "16-32",
    fragment_delay: "2-10",
    extra_args: "",
    quick_reconnect: true,
    mark_enabled: false,
    no_quic_v2: false,
    ech: "off",
    no_data_check: false,
    keepalive: 5,
    peer: "",
    wiw_outer: "",
    wiw_inner: "",
    mim_outer: "",
    mim_inner: "",
    dns: "",
    team: "",
    gateway: false,
    upstream: "",
    route_direct: "",
    route_block: "",
    log_level: "info",
    wg_peer: "",
    h2_peer: "",
    no_profile_retry: false,
    validate_secs: "",
    startup_secs: "",
    reconnect_secs: "",
    perf: "",
    tls_groups: "",
    routes_file: "",
    tor_bind: "",
    tor_dir: "",
    tor_bridges: "",
    tor_bridge: "",
    tor_pt: "",
    tor_pt_dir: "",
    tor_country: "",
    access_id: "",
    access_secret: "",
    access_token: "",
    access_email: "",
    discovered_cores: [],
    zeptun_state: "DISABLED",
    zeptun_available: false,
    zeptun_binary: "",
    zeptun_pid: "",
    zeptun_tun: "zeptun0",
    zeptun_has_cap_net_admin: false,
    zeptun_retries: 0,
    zeptun_uptime_s: 0,
    zeptun_error: "",
    sysroute_enabled: false,
    sysroute_ipv6: false,
    sysroute_dns_mode: "systemd_resolved",
    sysroute_udp_mode: "udp",
    sysroute_persistent: false,
    sysroute_exclude: ""
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
      protocol: String(parsed.protocol || "masque"),
      scan: String(parsed.scan || "balanced"),
      noize: String(parsed.noize || "firewall"),
      ip_mode: String(parsed.ip_mode || "v4"),
      h2: parsed.h2 === true,
      fragment: parsed.fragment === true,
      fragment_size: String(parsed.fragment_size || "16-32"),
      fragment_delay: String(parsed.fragment_delay || "2-10"),
      extra_args: String(parsed.extra_args || ""),
      quick_reconnect: parsed.quick_reconnect === true,
      mark_enabled: parsed.mark_enabled === true,
      no_quic_v2: parsed.no_quic_v2 === true,
      ech: String(parsed.ech || "off"),
      no_data_check: parsed.no_data_check === true,
      keepalive: Number(parsed.keepalive) || 5,
      peer: String(parsed.peer || ""),
      wiw_outer: String(parsed.wiw_outer || ""),
      wiw_inner: String(parsed.wiw_inner || ""),
      mim_outer: String(parsed.mim_outer || ""),
      mim_inner: String(parsed.mim_inner || ""),
      dns: String(parsed.dns || ""),
      team: String(parsed.team || ""),
      gateway: parsed.gateway === true,
      upstream: String(parsed.upstream || ""),
      route_direct: String(parsed.route_direct || ""),
      route_block: String(parsed.route_block || ""),
      log_level: String(parsed.log_level || "info"),
      wg_peer: String(parsed.wg_peer || ""),
      h2_peer: String(parsed.h2_peer || ""),
      no_profile_retry: parsed.no_profile_retry === true,
      validate_secs: String(parsed.validate_secs || ""),
      startup_secs: String(parsed.startup_secs || ""),
      reconnect_secs: String(parsed.reconnect_secs || ""),
      perf: String(parsed.perf || ""),
      tls_groups: String(parsed.tls_groups || ""),
      routes_file: String(parsed.routes_file || ""),
      tor_bind: String(parsed.tor_bind || ""),
      tor_dir: String(parsed.tor_dir || ""),
      tor_bridges: String(parsed.tor_bridges || ""),
      tor_bridge: String(parsed.tor_bridge || ""),
      tor_pt: String(parsed.tor_pt || ""),
      tor_pt_dir: String(parsed.tor_pt_dir || ""),
      tor_country: String(parsed.tor_country || ""),
      access_id: String(parsed.access_id || ""),
      access_secret: String(parsed.access_secret || ""),
      access_token: String(parsed.access_token || ""),
      access_email: String(parsed.access_email || ""),
      discovered_cores: Array.isArray(parsed.discovered_cores) ? parsed.discovered_cores : [],
      zeptun_state: String(parsed.zeptun_state || "DISABLED"),
      zeptun_available: parsed.zeptun_available === true,
      zeptun_binary: String(parsed.zeptun_binary || ""),
      zeptun_pid: String(parsed.zeptun_pid || ""),
      zeptun_tun: String(parsed.zeptun_tun || "zeptun0"),
      zeptun_has_cap_net_admin: parsed.zeptun_has_cap_net_admin === true,
      zeptun_retries: Number(parsed.zeptun_retries) || 0,
      zeptun_uptime_s: Number(parsed.zeptun_uptime_s) || 0,
      zeptun_error: String(parsed.zeptun_error || ""),
      sysroute_enabled: parsed.sysroute_enabled === true,
      sysroute_ipv6: parsed.sysroute_ipv6 === true,
      sysroute_dns_mode: String(parsed.sysroute_dns_mode || "systemd_resolved"),
      sysroute_udp_mode: String(parsed.sysroute_udp_mode || "udp"),
      sysroute_persistent: parsed.sysroute_persistent === true,
      sysroute_exclude: String(parsed.sysroute_exclude || "")
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

function zeptunStateLabel(state, error, available) {
  switch (state) {
    case "RUNNING": return "System routing active";
    case "STARTING": return "Starting system routing…";
    case "STOPPING": return "Stopping system routing…";
    case "FAILED": return "System routing failed" + (error ? " — " + error : "");
    case "STOPPED": return "System routing stopped";
    default: return available ? "Zeptun ready (not routing)" : "Zeptun unavailable";
  }
}

function zeptunStateColor(state, accent, urgent, foreground, dim) {
  switch (state) {
    case "RUNNING": return accent;
    case "STARTING":
    case "STOPPING": return foreground;
    case "FAILED": return urgent;
    default: return dim;
  }
}

function cleanLogLines(rawText) {
  if (!rawText) return "";
  return String(rawText).replace(/\x1B\[[0-9;]*[mK]/g, "");
}

function colorizeLogsToHtml(rawText, accentHex, urgentHex) {
  if (!rawText) return "<span style='color:#777;'>(No recent log entries)</span>";
  var cleaned = cleanLogLines(rawText);
  var lines = cleaned.split("\n");
  var out = [];

  var accent = accentHex || "#7aa2f7";
  var urgent = urgentHex || "#f7768e";
  var warnCol = "#e0af68";
  var infoCol = "#7dcfff";
  var grayCol = "#6c7086";

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    if (!line) continue;

    var esc = line.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    var col = "#c0caf5";

    if (/error|failed|fatal|abort|cannot|denied/i.test(line)) {
      col = urgent;
    } else if (/warn|warning|retry|dropping|cooldown/i.test(line)) {
      col = warnCol;
    } else if (/connected|warp=on|success|accepted|handshake complete|listening/i.test(line)) {
      col = accent;
    } else if (/^\[plugin\]|launching/i.test(line)) {
      col = infoCol;
    } else if (/^\[\d{4}-\d{2}-\d{2}/.test(line)) {
      col = grayCol;
    }

    out.push("<span style='color:" + col + ";'>" + esc + "</span>");
  }

  return out.join("<br/>");
}
