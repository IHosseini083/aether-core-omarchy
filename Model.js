.pragma library

var activePhrases = [
  "Bypassing censorship",
  "Tunneling with MASQUE",
  "Guarding traffic",
  "Routing through WARP",
  "Protecting packets",
  "Stealth encrypted stream",
  "Circumventing filters",
  "Tunneling via Psiphon",
  "Multi-hop onion routing",
  "Guarding exit location",
  "Securing connections"
];

function getHeroPhrase(index) {
  return activePhrases[Math.abs(index) % activePhrases.length];
}

function parseStatus(rawJson) {
  var defaultState = {
    plugin_version: "1.8.0",
    installed: false,
    binary: "",
    binary_version: "",
    core_pinned_version: "",
    core_update_available: false,
    has_cap_net_admin: false,
    running: false,
    pid: "",
    connected: false,
    ip: "",
    colo: "",
    loc: "",
    warp: "",
    latency_ms: 0,
    traffic_up: "",
    traffic_down: "",
    uptime: "",
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
    tor_http: "",
    tor_dir: "",
    tor_bridges: "",
    tor_bridge: "",
    tor_bridge_file: "",
    tor_relays: "",
    tor_relay_ports: "",
    tor_pt: "",
    tor_pt_dir: "",
    tor_country: "",
    psiphon_mode: "auto",
    psiphon_region: "",
    psiphon_bind: "",
    psiphon_http: "",
    psiphon_config: "",
    psiphon_cdn_ips: "",
    psiphon_cdn_sni: "",
    exit_loc: "",
    exit_loc_secs: "",
    stats_enabled: false,
    stats_secs: "",
    access_id: "",
    access_secret: "",
    access_token: "",
    has_access_id: false,
    has_access_secret: false,
    has_access_token: false,
    access_email: "",
    discovered_cores: [],
    zeptun_state: "DISABLED",
    zeptun_available: false,
    zeptun_binary: "",
    zeptun_version: "",
    zeptun_pinned_version: "",
    zeptun_update_available: false,
    zeptun_pid: "",
    zeptun_tun: "zeptun0",
    zeptun_has_cap_net_admin: false,
    zeptun_retries: 0,
    zeptun_uptime_s: 0,
    zeptun_error: "",
    sysroute_enabled: false,
    sysroute_ipv6: false,
    sysroute_dns_mode: "systemd_resolved",
    sysroute_dns_servers: "1.1.1.1, 8.8.8.8",
    sysroute_fake_ip: false,
    sysroute_dns_hijack: true,
    sysroute_preset: "desktop",
    sysroute_mtu: 1500,
    sysroute_udp_mode: "udp",
    sysroute_persistent: false,
    sysroute_exclude: "",
    sysroute_exclude_uids: "",
    sysroute_strict_route: true,
    sysroute_auto_redirect: false,
    sysroute_stack_mode: "userspace",
    sysroute_congestion: "cubic",
    sysroute_tcp_fastopen: false,
    sysroute_offload: true,
    sysroute_io_backend: "auto",
    sysroute_log_level: "warn"
  };

  if (!rawJson || typeof rawJson !== "string") {
    return defaultState;
  }

  try {
    var parsed = JSON.parse(rawJson);
    return {
      plugin_version: String(parsed.plugin_version || "1.7.0"),
      installed: parsed.installed === true,
      binary: String(parsed.binary || ""),
      binary_version: String(parsed.binary_version || ""),
      core_pinned_version: String(parsed.core_pinned_version || ""),
      core_update_available: parsed.core_update_available === true,
      has_cap_net_admin: parsed.has_cap_net_admin === true,
      running: parsed.running === true,
      pid: String(parsed.pid || ""),
      connected: parsed.connected === true,
      ip: String(parsed.ip || ""),
      colo: String(parsed.colo || ""),
      loc: String(parsed.loc || ""),
      warp: String(parsed.warp || ""),
      latency_ms: Number(parsed.latency_ms) || 0,
      traffic_up: String(parsed.traffic_up || ""),
      traffic_down: String(parsed.traffic_down || ""),
      uptime: String(parsed.uptime || ""),
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
      tor_http: String(parsed.tor_http || ""),
      tor_dir: String(parsed.tor_dir || ""),
      tor_bridges: String(parsed.tor_bridges || ""),
      tor_bridge: String(parsed.tor_bridge || ""),
      tor_bridge_file: String(parsed.tor_bridge_file || ""),
      tor_relays: String(parsed.tor_relays || ""),
      tor_relay_ports: String(parsed.tor_relay_ports || ""),
      tor_pt: String(parsed.tor_pt || ""),
      tor_pt_dir: String(parsed.tor_pt_dir || ""),
      tor_country: String(parsed.tor_country || ""),
      psiphon_mode: String(parsed.psiphon_mode || "auto"),
      psiphon_region: String(parsed.psiphon_region || ""),
      psiphon_bind: String(parsed.psiphon_bind || ""),
      psiphon_http: String(parsed.psiphon_http || ""),
      psiphon_config: String(parsed.psiphon_config || ""),
      psiphon_cdn_ips: String(parsed.psiphon_cdn_ips || ""),
      psiphon_cdn_sni: String(parsed.psiphon_cdn_sni || ""),
      exit_loc: String(parsed.exit_loc || ""),
      exit_loc_secs: String(parsed.exit_loc_secs || ""),
      stats_enabled: parsed.stats_enabled === true,
      stats_secs: String(parsed.stats_secs || ""),
      access_id: String(parsed.access_id || ""),
      access_secret: "",
      access_token: "",
      has_access_id: parsed.has_access_id === true,
      has_access_secret: parsed.has_access_secret === true,
      has_access_token: parsed.has_access_token === true,
      access_email: String(parsed.access_email || ""),
      discovered_cores: Array.isArray(parsed.discovered_cores) ? parsed.discovered_cores : [],
      zeptun_state: String(parsed.zeptun_state || "DISABLED"),
      zeptun_available: parsed.zeptun_available === true,
      zeptun_binary: String(parsed.zeptun_binary || ""),
      zeptun_version: String(parsed.zeptun_version || ""),
      zeptun_pinned_version: String(parsed.zeptun_pinned_version || ""),
      zeptun_update_available: parsed.zeptun_update_available === true,
      zeptun_pid: String(parsed.zeptun_pid || ""),
      zeptun_tun: String(parsed.zeptun_tun || "zeptun0"),
      zeptun_has_cap_net_admin: parsed.zeptun_has_cap_net_admin === true,
      zeptun_retries: Number(parsed.zeptun_retries) || 0,
      zeptun_uptime_s: Number(parsed.zeptun_uptime_s) || 0,
      zeptun_error: String(parsed.zeptun_error || ""),
      sysroute_enabled: parsed.sysroute_enabled === true,
      sysroute_ipv6: parsed.sysroute_ipv6 === true,
      sysroute_dns_mode: String(parsed.sysroute_dns_mode || "systemd_resolved"),
      sysroute_dns_servers: String(parsed.sysroute_dns_servers || "1.1.1.1, 8.8.8.8"),
      sysroute_fake_ip: parsed.sysroute_fake_ip === true,
      sysroute_dns_hijack: parsed.sysroute_dns_hijack !== false,
      sysroute_preset: String(parsed.sysroute_preset || "desktop"),
      sysroute_mtu: Number(parsed.sysroute_mtu) || 1500,
      sysroute_udp_mode: String(parsed.sysroute_udp_mode || "udp"),
      sysroute_persistent: parsed.sysroute_persistent === true,
      sysroute_exclude: String(parsed.sysroute_exclude || ""),
      sysroute_exclude_uids: String(parsed.sysroute_exclude_uids || ""),
      sysroute_strict_route: parsed.sysroute_strict_route !== false,
      sysroute_auto_redirect: parsed.sysroute_auto_redirect === true,
      sysroute_stack_mode: String(parsed.sysroute_stack_mode || "userspace"),
      sysroute_congestion: String(parsed.sysroute_congestion || "cubic"),
      sysroute_tcp_fastopen: parsed.sysroute_tcp_fastopen === true,
      sysroute_offload: parsed.sysroute_offload !== false,
      sysroute_io_backend: String(parsed.sysroute_io_backend || "auto"),
      sysroute_log_level: String(parsed.sysroute_log_level || "warn")
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

function torProxyUrl(bind) {
  if (!bind) return "socks5h://127.0.0.1:1820";
  return bind.indexOf("://") !== -1 ? bind : "socks5h://" + bind;
}

function torHttpProxyUrl(bind) {
  if (!bind) return "";
  return bind.indexOf("://") !== -1 ? bind : "http://" + bind;
}

function psiphonProxyUrl(bind) {
  if (!bind) return "socks5h://127.0.0.1:1821";
  return bind.indexOf("://") !== -1 ? bind : "socks5h://" + bind;
}

function psiphonHttpProxyUrl(bind) {
  if (!bind) return "";
  return bind.indexOf("://") !== -1 ? bind : "http://" + bind;
}

function isTor(proto) {
  return proto === "tor" || proto === "tor-reverse" || proto === "tor-only";
}

function isPsiphon(proto) {
  return proto === "psiphon" || proto === "psiphon-reverse" || proto === "psiphon-only";
}

function protocolCategory(proto) {
  if (isTor(proto)) return "tor";
  if (isPsiphon(proto)) return "psiphon";
  if (proto === "wg") return "wg";
  if (proto === "gool") return "gool";
  if (proto === "mim") return "mim";
  return "masque";
}

function protocolLabel(proto, h2) {
  switch (proto) {
    case "masque": return h2 ? "MASQUE (HTTP/2)" : "MASQUE (QUIC)";
    case "wg": return "WireGuard";
    case "gool": return "WARP-in-WARP";
    case "mim": return h2 ? "MIM (HTTP/2)" : "MIM (QUIC)";
    case "tor": return "WARP → Tor";
    case "tor-reverse": return "Tor → WARP";
    case "tor-only": return "Standalone Tor";
    case "psiphon": return "WARP → Psiphon";
    case "psiphon-reverse": return "Psiphon → WARP";
    case "psiphon-only": return "Standalone Psiphon";
    default: return proto || "MASQUE";
  }
}

var COUNTRY_METADATA = {
  "": { flag: "🌐", name: "Worldwide", code: "" },
  "US": { flag: "🇺🇸", name: "United States", code: "US" },
  "DE": { flag: "🇩🇪", name: "Germany", code: "DE" },
  "NL": { flag: "🇳🇱", name: "Netherlands", code: "NL" },
  "SE": { flag: "🇸🇪", name: "Sweden", code: "SE" },
  "GB": { flag: "🇬🇧", name: "United Kingdom", code: "GB" },
  "CH": { flag: "🇨🇭", name: "Switzerland", code: "CH" },
  "FR": { flag: "🇫🇷", name: "France", code: "FR" },
  "CA": { flag: "🇨🇦", name: "Canada", code: "CA" },
  "JP": { flag: "🇯🇵", name: "Japan", code: "JP" },
  "SG": { flag: "🇸🇬", name: "Singapore", code: "SG" },
  "FI": { flag: "🇫🇮", name: "Finland", code: "FI" },
  "PL": { flag: "🇵🇱", name: "Poland", code: "PL" },
  "AT": { flag: "🇦🇹", name: "Austria", code: "AT" },
  "IT": { flag: "🇮🇹", name: "Italy", code: "IT" },
  "ES": { flag: "🇪🇸", name: "Spain", code: "ES" },
  "TR": { flag: "🇹🇷", name: "Turkey", code: "TR" },
  "AU": { flag: "🇦🇺", name: "Australia", code: "AU" },
  "IR": { flag: "🇮🇷", name: "Iran", code: "IR" },
  "RU": { flag: "🇷🇺", name: "Russia", code: "RU" },
  "AZ": { flag: "🇦🇿", name: "Azerbaijan", code: "AZ" }
};

function getCountryFlag(code) {
  if (!code || code === "") return "🌐";
  var c = String(code).trim().toUpperCase();
  if (COUNTRY_METADATA[c]) return COUNTRY_METADATA[c].flag;
  if (c.length === 2 && /^[A-Z]{2}$/.test(c)) {
    var c1 = 0x1F1E6 - 65 + c.charCodeAt(0);
    var c2 = 0x1F1E6 - 65 + c.charCodeAt(1);
    return String.fromCodePoint(c1, c2);
  }
  if (c.charAt(0) === "!") return "🚫";
  return "🚩";
}

function getCountryName(code) {
  if (!code || code === "") return "Worldwide";
  var c = String(code).trim().toUpperCase();
  if (COUNTRY_METADATA[c]) return COUNTRY_METADATA[c].name;
  if (c.charAt(0) === "!") return "Excluding " + c.substring(1);
  return c;
}

function isPresetExitLoc(spec) {
  if (!spec || spec === "") return true;
  if (spec === "DE,SE,NL" || spec === "!IR,AZ,RU") return true;
  var upper = spec.trim().toUpperCase();
  return !!COUNTRY_METADATA[upper];
}

function formatExitLocWithFlag(spec) {
  if (!spec || spec.trim() === "") return "🌐 Worldwide";
  var s = spec.trim();
  if (s.charAt(0) === "!") {
    var blocked = s.substring(1).split(",").map(function(item) {
      var trimmed = item.trim().toUpperCase();
      return getCountryFlag(trimmed) + " " + trimmed;
    }).join(" ");
    return "🚫 Blocked: " + (blocked || s.substring(1));
  }
  if (s.indexOf(",") !== -1) {
    var allowed = s.split(",").map(function(item) {
      var trimmed = item.trim().toUpperCase();
      return getCountryFlag(trimmed) + " " + trimmed;
    }).join(" ");
    return allowed;
  }
  var upper = s.toUpperCase();
  return getCountryFlag(upper) + " " + getCountryName(upper) + " (" + upper + ")";
}

function formatExitLoc(spec) {
  return formatExitLocWithFlag(spec);
}

function formatStats(enabled, secs) {
  if (!enabled) return "Off";
  var s = secs ? parseInt(secs, 10) : 60;
  return "Every " + (s || 60) + "s";
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

    if (/error|failed|fatal|abort|cannot|denied|refused/i.test(line)) {
      col = urgent;
    } else if (/warn|warning|retry|dropping|cooldown|stall/i.test(line)) {
      col = warnCol;
    } else if (/connected|warp=on|success|accepted|handshake complete|listening|tunnel open|psiphon.*tunnel connected|bootstrapped 100%/i.test(line)) {
      col = accent;
    } else if (/^\[plugin\]|launching|psiphon|tor|exit-loc|stats|bytes up|bytes down/i.test(line)) {
      col = infoCol;
    } else if (/^\[\d{4}-\d{2}-\d{2}/.test(line)) {
      col = grayCol;
    }

    out.push("<span style='color:" + col + ";'>" + esc + "</span>");
  }

  return out.join("<br/>");
}
