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
    plugin_version: "2.0.0",
    installed: false,
    binary: "",
    binary_version: "",
    core_pinned_version: "v2.4.0",
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
    fragment_size: "8-16",
    fragment_delay: "2-10",
    extra_args: "",
    quick_reconnect: true,
    mark_enabled: false,
    no_quic_v2: false,
    ech: "off",
    ech_dns: "",
    ech_domain: "",
    no_data_check: false,
    keepalive: 5,
    peer: "",
    gool_peer: "",
    api_fragment: false,
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
    tls_ciphers: "",
    tls13_ciphers: "",
    tls_key_shares: "",
    tls_sigalgs: "",
    enable_grease_sigalgs: false,
    tls_cert_compression: "",
    tls_alps: "",
    tls_trust_anchors: "",
    tls_server_padding: "",
    enable_ech_grease: false,
    disable_ocsp_stapling: false,
    disable_sct: false,
    disable_session_ticket: false,
    disable_extension_permutation: false,
    disable_grease: false,
    tls_verify: "auto",
    api_address: "",
    enroll_address: "",
    api_host: "",
    api_sni: "",
    masque_sni: "",
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
    psiphon_cdn_sets: "",
    psiphon_server_entries: "",
    psiphon_dir: "",
    psiphon_bin: "",
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
    zeptun_pinned_version: "v1.1.3",
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
    sysroute_log_level: "warn",
    sysroute_egress: "",
    sysroute_egress_kind: "warp",
    sysroute_tor_psiphon_warning: ""
  };

  if (!rawJson || typeof rawJson !== "string") {
    return defaultState;
  }

  try {
    var parsed = JSON.parse(rawJson);
    return {
      plugin_version: String(parsed.plugin_version || "2.0.0"),
      installed: parsed.installed === true,
      binary: String(parsed.binary || ""),
      binary_version: String(parsed.binary_version || ""),
      core_pinned_version: String(parsed.core_pinned_version || "v2.4.0"),
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
      fragment_size: String(parsed.fragment_size || "8-16"),
      fragment_delay: String(parsed.fragment_delay || "2-10"),
      extra_args: String(parsed.extra_args || ""),
      quick_reconnect: parsed.quick_reconnect === true,
      mark_enabled: parsed.mark_enabled === true,
      no_quic_v2: parsed.no_quic_v2 === true,
      ech: String(parsed.ech || "off"),
      ech_dns: String(parsed.ech_dns || ""),
      ech_domain: String(parsed.ech_domain || ""),
      no_data_check: parsed.no_data_check === true,
      keepalive: Number(parsed.keepalive) || 5,
      peer: String(parsed.peer || ""),
      gool_peer: String(parsed.gool_peer || ""),
      api_fragment: parsed.api_fragment === true,
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
      tls_ciphers: String(parsed.tls_ciphers || ""),
      tls13_ciphers: String(parsed.tls13_ciphers || ""),
      tls_key_shares: String(parsed.tls_key_shares || ""),
      tls_sigalgs: String(parsed.tls_sigalgs || ""),
      enable_grease_sigalgs: parsed.enable_grease_sigalgs === true,
      tls_cert_compression: String(parsed.tls_cert_compression || ""),
      tls_alps: String(parsed.tls_alps || ""),
      tls_trust_anchors: String(parsed.tls_trust_anchors || ""),
      tls_server_padding: String(parsed.tls_server_padding || ""),
      enable_ech_grease: parsed.enable_ech_grease === true,
      disable_ocsp_stapling: parsed.disable_ocsp_stapling === true,
      disable_sct: parsed.disable_sct === true,
      disable_session_ticket: parsed.disable_session_ticket === true,
      disable_extension_permutation: parsed.disable_extension_permutation === true,
      disable_grease: parsed.disable_grease === true,
      tls_verify: String(parsed.tls_verify || "auto"),
      api_address: String(parsed.api_address || parsed.enroll_address || ""),
      enroll_address: String(parsed.api_address || parsed.enroll_address || ""),
      api_host: String(parsed.api_host || ""),
      api_sni: String(parsed.api_sni || ""),
      masque_sni: String(parsed.masque_sni || ""),
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
      psiphon_cdn_sets: String(parsed.psiphon_cdn_sets || ""),
      psiphon_server_entries: String(parsed.psiphon_server_entries || ""),
      psiphon_dir: String(parsed.psiphon_dir || ""),
      psiphon_bin: String(parsed.psiphon_bin || ""),
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
      zeptun_pinned_version: String(parsed.zeptun_pinned_version || "v1.1.3"),
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
      sysroute_log_level: String(parsed.sysroute_log_level || "warn"),
      sysroute_egress: String(parsed.sysroute_egress || ""),
      sysroute_egress_kind: String(parsed.sysroute_egress_kind || "warp"),
      sysroute_tor_psiphon_warning: String(parsed.sysroute_tor_psiphon_warning || "")
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
  if (proto === "gool-classic") return "gool-classic";
  if (proto === "mim") return "mim";
  return "masque";
}

function protocolLabel(proto, h2) {
  switch (proto) {
    case "masque": return h2 ? "MASQUE (HTTP/2)" : "MASQUE (QUIC)";
    case "wg": return "WireGuard";
    case "gool": return "Gool (WG in MASQUE)";
    case "gool-classic": return "Gool Classic (WIW)";
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

// Human label for the SOCKS endpoint system routing (TUN) feeds traffic into.
// Kind: "warp" (direct transports, reverse and only chains) or "tor"/"psiphon"
// when the engine points at the chained exit's own SOCKS port.
function tunEgressLabel(kind, addr) {
  var name = kind === "tor" ? "Tor" : kind === "psiphon" ? "Psiphon" : "WARP";
  return name + (addr ? " · " + addr : "");
}

function zeptunStateLabel(state, error, available) {  switch (state) {
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

var SCHEMA = [
  // Core
  {
    key: "protocol",
    label: "Transport Protocol",
    category: "core",
    level: "basic",
    type: "enum",
    defaultValue: "masque",
    options: [
      { value: "masque", label: "MASQUE (QUIC / H2)" },
      { value: "wg", label: "WireGuard" },
      { value: "gool", label: "Gool (WireGuard inside MASQUE)" },
      { value: "gool-classic", label: "Gool Classic (WireGuard in WireGuard)" },
      { value: "mim", label: "MIM (MASQUE in MASQUE)" },
      { value: "tor", label: "WARP → Tor (Tor inside WARP)" },
      { value: "tor-reverse", label: "Tor → WARP (Dial WARP through Tor)" },
      { value: "tor-only", label: "Tor Only (Standalone Tor proxy)" },
      { value: "psiphon", label: "WARP → Psiphon (Psiphon inside WARP)" },
      { value: "psiphon-reverse", label: "Psiphon → WARP (Dial WARP through Psiphon)" },
      { value: "psiphon-only", label: "Psiphon Only (Standalone Psiphon proxy)" }
    ],
    description: "Primary egress and obfuscation protocol. Direct WARP modes use Cloudflare edge; Tor and Psiphon route via circumvention networks."
  },
  {
    key: "h2",
    label: "MASQUE over HTTP/2",
    category: "core",
    level: "basic",
    type: "boolean",
    defaultValue: false,
    description: "Use TCP-based HTTP/2 for MASQUE instead of HTTP/3 (QUIC). Useful when UDP or QUIC ports are blocked or throttled by ISP."
  },
  {
    key: "scan",
    label: "Scan Strategy",
    category: "core",
    level: "basic",
    type: "enum",
    defaultValue: "balanced",
    options: [
      { value: "balanced", label: "Balanced — collect a few, keep fastest" },
      { value: "turbo", label: "Turbo — first responder wins" },
      { value: "verified", label: "Verified — measured connect-ip edges" },
      { value: "thorough", label: "Thorough — sweep entire subnet ranges" },
      { value: "ironclad", label: "Ironclad — live data-plane verified" }
    ],
    description: "Endpoint scanning behavior on startup and reconnects."
  },
  {
    key: "noize",
    label: "Noize / Obfuscation Profile",
    category: "core",
    level: "basic",
    type: "enum",
    defaultValue: "firewall",
    options: [
      { value: "firewall", label: "Firewall — default for MASQUE" },
      { value: "balanced", label: "Balanced — default for WireGuard" },
      { value: "light", label: "Light — subtle packet shaping" },
      { value: "gfw", label: "GFW — hardened against deep inspection" },
      { value: "aggressive", label: "Aggressive — maximum packet padding" },
      { value: "off", label: "Off — standard packet stream" }
    ],
    description: "Injects synthetic padding and randomized timing to disguise tunnel handshakes from statistical traffic classification."
  },
  {
    key: "perf",
    label: "System Resource Profile",
    category: "core",
    level: "advanced",
    type: "enum",
    defaultValue: "",
    options: [
      { value: "", label: "Auto — detect from system CPU and RAM" },
      { value: "low", label: "Low — constrained devices and SBCs" },
      { value: "medium", label: "Medium — standard desktop performance" },
      { value: "high", label: "High — multi-core workstations and servers" }
    ],
    description: "Controls worker thread count, memory allocation buffers, and socket concurrency limits."
  },
  {
    key: "log_level",
    label: "Core Log Verbosity",
    category: "core",
    level: "basic",
    type: "enum",
    defaultValue: "info",
    options: [
      { value: "error", label: "Error — fatal and connection errors only" },
      { value: "warn", label: "Warn — warnings and potential issues" },
      { value: "info", label: "Info — standard operational logs" },
      { value: "debug", label: "Debug — detailed diagnostic logs" },
      { value: "trace", label: "Trace — packet and protocol internals" }
    ],
    description: "Verbosity level for daemon output stored in ~/.local/share/omarchy-aether/aether.log."
  },
  {
    key: "quick_reconnect",
    label: "Quick Reconnect",
    category: "core",
    level: "basic",
    type: "boolean",
    defaultValue: true,
    description: "Fast-resume connection using the last verified working Cloudflare gateway without re-running full IP range scans."
  },
  {
    key: "keepalive",
    label: "WireGuard Keepalive Interval",
    category: "core",
    level: "advanced",
    type: "number",
    defaultValue: 5,
    placeholder: "5",
    description: "Persistent keepalive interval in seconds to maintain NAT and stateful firewall state."
  },
  {
    key: "no_data_check",
    label: "Skip Data-Plane Health Check",
    category: "core",
    level: "advanced",
    type: "boolean",
    defaultValue: false,
    description: "Connect without waiting for an end-to-end HTTP payload probe to succeed. Faster connect time but may land on stalled routes."
  },
  {
    key: "no_profile_retry",
    label: "No Obfuscation Profile Retry",
    category: "core",
    level: "advanced",
    type: "boolean",
    defaultValue: false,
    description: "WireGuard scan: abort immediately if chosen obfuscation profile fails instead of attempting fallback profiles."
  },
  {
    key: "validate_secs",
    label: "Data-Plane Validation Timeout",
    category: "core",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "e.g. 5",
    description: "Maximum seconds allowed for live traffic verification probe on startup."
  },
  {
    key: "startup_secs",
    label: "MASQUE Startup Deadline",
    category: "core",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "e.g. 10",
    description: "Overall timeout for MASQUE handshake completion before aborting."
  },
  {
    key: "reconnect_secs",
    label: "Reconnect Backoff Delay",
    category: "core",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "e.g. 2",
    description: "Initial delay in seconds before attempting automated re-connection after unexpected connection loss."
  },
  {
    key: "extra_args",
    label: "Verbatim Core Arguments",
    category: "core",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "--verbose --ironclad-port 80",
    description: "Pass arbitrary command-line arguments directly to the Aether core binary on startup."
  },

  // Network & Ports
  {
    key: "ip",
    label: "IP Protocol Mode",
    category: "network",
    level: "basic",
    type: "enum",
    defaultValue: "v4",
    options: [
      { value: "v4", label: "IPv4 Only" },
      { value: "v6", label: "IPv6 Only" },
      { value: "dual", label: "Dual Stack (IPv4 + IPv6)" }
    ],
    description: "Network layer stack used for inbound proxy bindings and outbound gateway resolution."
  },
  {
    key: "socks_port",
    label: "SOCKS5 Proxy Port",
    category: "network",
    level: "basic",
    type: "number",
    defaultValue: 1819,
    placeholder: "1819",
    description: "Local TCP port on 127.0.0.1 serving SOCKS5 proxy requests."
  },
  {
    key: "http_proxy_port",
    label: "HTTP CONNECT Proxy Port",
    category: "network",
    level: "basic",
    type: "number",
    defaultValue: 0,
    placeholder: "0 (disabled)",
    description: "Local port for HTTP CONNECT proxy listener. Set to 0 to disable."
  },
  {
    key: "dns",
    label: "In-Tunnel DNS Resolvers",
    category: "network",
    level: "basic",
    type: "string",
    defaultValue: "",
    placeholder: "1.1.1.1, 8.8.8.8",
    description: "Custom DNS nameservers consulted inside the tunnel to shield name resolution from ISP snooping."
  },
  {
    key: "upstream",
    label: "Upstream Proxy",
    category: "network",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "socks5://127.0.0.1:9050",
    description: "Forward all tunnel traffic through an external upstream proxy (socks5://, socks5h://, or http:// with port).",
    warning: "Must include protocol scheme and non-zero port. Avoid creating routing loops with local listeners."
  },
  {
    key: "peer",
    label: "Static Peer Address",
    category: "network",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "162.159.192.1:2408",
    description: "Override endpoint discovery and pin an exact IP:port for the tunnel gateway."
  },
  {
    key: "wg_peer",
    label: "WireGuard Peer Address",
    category: "network",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "162.159.193.1:2408",
    description: "Specific peer endpoint used exclusively when WireGuard transport is active."
  },
  {
    key: "gool_peer",
    label: "Gool Peer Address",
    category: "network",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "162.159.192.1:2408",
    description: "Secondary endpoint used for Gool multi-hop routing."
  },
  {
    key: "h2_peer",
    label: "HTTP/2 Peer Address",
    category: "network",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "162.159.192.1:443",
    description: "Dedicated peer address for MASQUE HTTP/2 transport."
  },
  {
    key: "wiw_outer",
    label: "WiW Outer Hop",
    category: "network",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "ip:port",
    description: "Outer WireGuard hop for WireGuard-in-WireGuard (Gool Classic) transport."
  },
  {
    key: "wiw_inner",
    label: "WiW Inner Hop",
    category: "network",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "ip:port",
    description: "Inner WireGuard hop for WireGuard-in-WireGuard transport."
  },
  {
    key: "mim_outer",
    label: "MIM Outer Hop",
    category: "network",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "ip:port",
    description: "Outer MASQUE hop for MASQUE-in-MASQUE nested encryption."
  },
  {
    key: "mim_inner",
    label: "MIM Inner Hop",
    category: "network",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "ip:port",
    description: "Inner MASQUE hop for MASQUE-in-MASQUE nested encryption."
  },
  {
    key: "routes_file",
    label: "Routing CIDR Rules File",
    category: "network",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "/path/to/routes.txt",
    description: "File containing newline-delimited CIDRs or domain patterns to route or bypass."
  },
  {
    key: "route_direct",
    label: "Bypass (Direct) Routes",
    category: "network",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "example.com, 192.168.0.0/16",
    description: "Comma-separated domain names or IP subnets that bypass the tunnel and connect directly."
  },
  {
    key: "route_block",
    label: "Blocklisted Routes",
    category: "network",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "ads.example.com, port:25",
    description: "Comma-separated destinations or port filters to drop entirely at the proxy layer."
  },

  // TLS & Fingerprint Shaping (v2.4.0)
  {
    key: "fragment",
    label: "ClientHello Fragmentation",
    category: "tls",
    level: "basic",
    type: "boolean",
    defaultValue: false,
    description: "Split TLS ClientHello into TCP/TLS records across HTTP/2 and API connections to break SNI deep packet inspection (DPI)."
  },
  {
    key: "fragment_size",
    label: "Fragmentation Byte Range",
    category: "tls",
    level: "basic",
    type: "string",
    defaultValue: "8-16",
    placeholder: "8-16",
    description: "Range in bytes for the first TLS record fragment (v2.4.0 default: 8-16 bytes)."
  },
  {
    key: "fragment_delay",
    label: "Fragmentation Delay (ms)",
    category: "tls",
    level: "basic",
    type: "string",
    defaultValue: "2-10",
    placeholder: "2-10",
    description: "Inter-packet delay range in milliseconds between sending ClientHello fragments."
  },
  {
    key: "ech",
    label: "Encrypted Client Hello (ECH)",
    category: "tls",
    level: "basic",
    type: "enum",
    defaultValue: "off",
    options: [
      { value: "off", label: "Off — standard SNI in ClientHello" },
      { value: "auto", label: "Auto — negotiate ECH via DoH / DNS" }
    ],
    description: "Encrypts the SNI extension inside an outer ClientHello to conceal destination domain names from censors."
  },
  {
    key: "ech_dns",
    label: "ECH DoH Resolver URL",
    category: "tls",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "https://1.1.1.1/dns-query",
    description: "DNS-over-HTTPS resolver queried to fetch ECHConfigs (Type 65 HTTPS records)."
  },
  {
    key: "ech_domain",
    label: "ECH Outer Domain SNI",
    category: "tls",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "cloudflare-ech.com",
    description: "Public outer domain SNI advertised in the unencrypted outer ClientHello."
  },
  {
    key: "enable_ech_grease",
    label: "Enable ECH GREASE",
    category: "tls",
    level: "advanced",
    type: "boolean",
    defaultValue: false,
    description: "Send synthetic ECH extension GREASE payloads when real ECH is not used to prevent protocol ossification."
  },
  {
    key: "tls_verify",
    label: "TLS Certificate Verification",
    category: "tls",
    level: "advanced",
    type: "enum",
    defaultValue: "auto",
    options: [
      { value: "auto", label: "Auto — required for Zero Trust, optional for WARP" },
      { value: "1", label: "Strict — enforce certificate verification on all connections" },
      { value: "0", label: "Disabled — allow self-signed / unverified upstream certificates" }
    ],
    description: "Controls certificate trust validation for outbound TLS connections."
  },
  {
    key: "tls_ciphers",
    label: "TLS 1.2 Cipher Suites",
    category: "tls",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "ECDHE-ECDSA-AES128-GCM-SHA256:...",
    description: "Colon-separated list of enabled TLS 1.2 cipher suites for JA3 fingerprint customization."
  },
  {
    key: "tls13_ciphers",
    label: "TLS 1.3 Cipher Suites",
    category: "tls",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384",
    description: "Order and selection of TLS 1.3 cipher suites (--tls13-ciphers)."
  },
  {
    key: "tls_groups",
    label: "TLS Supported Curves / Groups",
    category: "tls",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "X25519:P-256:P-384",
    description: "Elliptic curves and Diffie-Hellman groups offered during TLS key exchange."
  },
  {
    key: "tls_key_shares",
    label: "TLS Key Shares",
    category: "tls",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "X25519",
    description: "Key share curves sent in the initial ClientHello to avoid HelloRetryRequest roundtrips."
  },
  {
    key: "tls_sigalgs",
    label: "TLS Signature Algorithms",
    category: "tls",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "ecdsa_secp256r1_sha256:rsa_pss_rsae_sha256",
    description: "Supported signature schemes advertised to the server."
  },
  {
    key: "enable_grease_sigalgs",
    label: "GREASE Signature Algorithms",
    category: "tls",
    level: "advanced",
    type: "boolean",
    defaultValue: false,
    description: "Inject GREASE values into signature algorithms extension."
  },
  {
    key: "tls_cert_compression",
    label: "Certificate Compression",
    category: "tls",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "brotli, zstandard",
    description: "Compression algorithms advertised for RFC 8879 certificate compression."
  },
  {
    key: "tls_alps",
    label: "ALPS (Application-Layer Settings)",
    category: "tls",
    level: "advanced",
    type: "enum",
    defaultValue: "",
    options: [
      { value: "", label: "Default — BoringSSL automatic" },
      { value: "new", label: "New ALPS draft" },
      { value: "old", label: "Legacy ALPS draft" }
    ],
    description: "Negotiates HTTP/2 or HTTP/3 settings early during the TLS handshake."
  },
  {
    key: "tls_server_padding",
    label: "TLS Server Name Padding",
    category: "tls",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "e.g. 512",
    description: "Pads the ClientHello length to fixed block boundaries to camouflage domain name length."
  },
  {
    key: "disable_grease",
    label: "Disable TLS GREASE",
    category: "tls",
    level: "advanced",
    type: "boolean",
    defaultValue: false,
    description: "Omit all GREASE extension and cipher values from ClientHello."
  },
  {
    key: "disable_ocsp_stapling",
    label: "Disable OCSP Stapling",
    category: "tls",
    level: "advanced",
    type: "boolean",
    defaultValue: false,
    description: "Do not request OCSP status responses in ClientHello."
  },
  {
    key: "disable_sct",
    label: "Disable SCT (Signed Certificate Timestamps)",
    category: "tls",
    level: "advanced",
    type: "boolean",
    defaultValue: false,
    description: "Do not request Certificate Transparency SCTs in ClientHello."
  },
  {
    key: "disable_session_ticket",
    label: "Disable Session Tickets",
    category: "tls",
    level: "advanced",
    type: "boolean",
    defaultValue: false,
    description: "Do not offer session resumption tickets."
  },
  {
    key: "disable_extension_permutation",
    label: "Disable Extension Permutation",
    category: "tls",
    level: "advanced",
    type: "boolean",
    defaultValue: false,
    description: "Retain static order of TLS extensions instead of randomizing order on each handshake."
  },
  {
    key: "api_address",
    label: "WARP API Endpoint Address",
    category: "tls",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "api.cloudflareclient.com:443",
    description: "Custom IP or host used to register and refresh WARP identity credentials."
  },
  {
    key: "api_host",
    label: "WARP API Host Header",
    category: "tls",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "api.cloudflareclient.com",
    description: "HTTP Host header sent during API registration and quota queries."
  },
  {
    key: "api_sni",
    label: "WARP API SNI",
    category: "tls",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "api.cloudflareclient.com",
    description: "TLS SNI advertised when connecting to WARP enrollment servers."
  },
  {
    key: "masque_sni",
    label: "MASQUE Gateway SNI",
    category: "tls",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "cloudflarewarp.com",
    description: "TLS SNI presented when initiating MASQUE tunnel sessions."
  },

  // Circumvention: Tor & Psiphon
  {
    key: "tor_relays",
    label: "Tor Onionoo Relay Discovery",
    category: "circumvention",
    level: "basic",
    type: "enum",
    defaultValue: "auto",
    options: [
      { value: "auto", label: "Auto — Onionoo relays alongside BridgeDB" },
      { value: "only", label: "Only — use Onionoo relays exclusively" },
      { value: "off", label: "Off — BridgeDB bridges only" }
    ],
    description: "Retrieves fresh unblocked public relay IP endpoints from the Tor Onionoo API."
  },
  {
    key: "tor_relay_ports",
    label: "Tor Relay Allowed Ports",
    category: "circumvention",
    level: "basic",
    type: "enum",
    defaultValue: "web",
    options: [
      { value: "web", label: "Web ports only (80 and 443 — firewall stealth)" },
      { value: "any", label: "Any ports — all running Tor relay ports" }
    ],
    description: "Filters discovered relays to standard web ports to pass restrictive outbound firewalls."
  },
  {
    key: "tor_bridges",
    label: "Tor Bridges Strategy",
    category: "circumvention",
    level: "basic",
    type: "enum",
    defaultValue: "",
    options: [
      { value: "", label: "Auto — try direct Tor first, fall back to bridges" },
      { value: "on", label: "Always use bridges" },
      { value: "off", label: "Never use bridges (direct relays only)" }
    ],
    description: "Determines whether bridge relays (obfs4, meek, snowflake) are required."
  },
  {
    key: "tor_country",
    label: "Tor Bridge Geographic Target",
    category: "circumvention",
    level: "basic",
    type: "string",
    defaultValue: "",
    placeholder: "e.g. ir, ru, cn",
    description: "Country code passed to BridgeDB to select tailored anti-censorship bridges."
  },
  {
    key: "tor_bridge",
    label: "Custom Tor Bridge Line",
    category: "circumvention",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "obfs4 1.2.3.4:443 ...",
    description: "Manually specify one exact Tor bridge line."
  },
  {
    key: "tor_bridge_file",
    label: "Tor Bridge List File",
    category: "circumvention",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "/path/to/bridges.txt",
    description: "Path to a text file containing bridge lines."
  },
  {
    key: "tor_bind",
    label: "Tor SOCKS5 Bind Address",
    category: "circumvention",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "127.0.0.1:1820",
    description: "Local listening endpoint where Tor daemon serves SOCKS5 traffic."
  },
  {
    key: "tor_http",
    label: "Tor HTTP Proxy Bind Address",
    category: "circumvention",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "127.0.0.1:8118",
    description: "Local HTTP proxy endpoint mapped to Tor circuit."
  },
  {
    key: "tor_pt",
    label: "Tor Pluggable Transport",
    category: "circumvention",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "obfs4, lyrebird, snowflake",
    description: "Name or absolute executable path of pluggable transport helper."
  },
  {
    key: "tor_pt_dir",
    label: "Tor PT Executable Directory",
    category: "circumvention",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "/usr/lib/cbt-transports",
    description: "Search path for lyrebird and other transport client binaries."
  },
  {
    key: "psiphon_mode",
    label: "Psiphon Protocol Mode",
    category: "circumvention",
    level: "basic",
    type: "enum",
    defaultValue: "auto",
    options: [
      { value: "auto", label: "Auto — best available egress strategy" },
      { value: "cdn", label: "CDN — fronted meek over CDN only" },
      { value: "direct", label: "Direct — direct SSH / obfuscated TCP" }
    ],
    description: "Connection strategy employed by the psiphon-tunnel-core engine."
  },
  {
    key: "psiphon_region",
    label: "Psiphon Target Region",
    category: "circumvention",
    level: "basic",
    type: "string",
    defaultValue: "",
    placeholder: "DE, US, NL, CH",
    description: "Target country code for Psiphon exit server."
  },
  {
    key: "psiphon_bind",
    label: "Psiphon SOCKS5 Bind Address",
    category: "circumvention",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "127.0.0.1:1821",
    description: "Local listening port for Psiphon core SOCKS5 proxy."
  },
  {
    key: "psiphon_cdn_ips",
    label: "Psiphon CDN Fronting IP List",
    category: "circumvention",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "Comma-separated IPs",
    description: "Known unblocked CDN IP addresses used for domain fronting."
  },
  {
    key: "psiphon_config",
    label: "Psiphon Custom JSON Config",
    category: "circumvention",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "/path/to/psiphon.json",
    description: "Custom configuration JSON passed to psiphon-tunnel-core."
  },

  // Zero Trust
  {
    key: "team",
    label: "Zero Trust Team Name",
    category: "zerotrust",
    level: "basic",
    type: "string",
    defaultValue: "",
    placeholder: "my-team-name",
    description: "Cloudflare Zero Trust organization slug."
  },
  {
    key: "gateway",
    label: "Cloudflare Gateway Inspection",
    category: "zerotrust",
    level: "basic",
    type: "boolean",
    defaultValue: false,
    description: "Enforces organizational gateway security policies and HTTP filtering."
  },
  {
    key: "access_id",
    label: "Service Token Client ID",
    category: "zerotrust",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "xxxx.access",
    description: "Cloudflare Access service token client ID for non-interactive authentication."
  },
  {
    key: "access_secret",
    label: "Service Token Client Secret",
    category: "zerotrust",
    level: "advanced",
    type: "password",
    defaultValue: "",
    placeholder: "••••••••",
    secret: true,
    description: "Cloudflare Access service token secret key."
  },
  {
    key: "access_token",
    label: "Zero Trust Enrollment JWT",
    category: "zerotrust",
    level: "advanced",
    type: "password",
    defaultValue: "",
    placeholder: "••••••••",
    secret: true,
    description: "Ephemeral user enrollment token (JWT)."
  },
  {
    key: "access_email",
    label: "Enrollment User Email",
    category: "zerotrust",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "user@example.com",
    description: "User identity email tied to Cloudflare Access session."
  },

  // System Routing (Zeptun TUN)
  {
    key: "sysroute_enabled",
    label: "System-Wide TUN Routing",
    category: "routing",
    level: "basic",
    type: "boolean",
    defaultValue: false,
    description: "Route entire OS traffic transparently through the Aether SOCKS5 endpoint using Zeptun TUN interface."
  },
  {
    key: "sysroute_preset",
    label: "Routing Network Profile",
    category: "routing",
    level: "basic",
    type: "enum",
    defaultValue: "desktop",
    options: [
      { value: "desktop", label: "Desktop — standard PC setup (high MTU, full offload)" },
      { value: "mobile", label: "Mobile — battery-conscious, lower MTU (1420)" },
      { value: "server", label: "Server — maximum throughput, minimal logging" }
    ],
    description: "Pre-tuned tuning parameters for TUN MTU, socket buffer sizing, and queue discipline."
  },
  {
    key: "sysroute_mtu",
    label: "TUN Device MTU",
    category: "routing",
    level: "basic",
    type: "number",
    defaultValue: 1500,
    placeholder: "1500",
    description: "Maximum transmission unit for the zeptun0 interface. 1500 standard, 1420 or 1280 for mobile/fragmented links."
  },
  {
    key: "sysroute_ipv6",
    label: "Route IPv6 Through TUN",
    category: "routing",
    level: "basic",
    type: "boolean",
    defaultValue: false,
    description: "Capture and proxy IPv6 system traffic. When off, strict routing drops IPv6 to prevent ISP IP leaks."
  },
  {
    key: "sysroute_dns_mode",
    label: "System DNS Capture Mode",
    category: "routing",
    level: "basic",
    type: "enum",
    defaultValue: "systemd_resolved",
    options: [
      { value: "systemd_resolved", label: "systemd-resolved — native integration (~. default route)" },
      { value: "hijack", label: "Hijack — redirect port 53 DNS directly to in-tunnel resolver" },
      { value: "off", label: "Off — do not alter local DNS configuration" }
    ],
    description: "Method used to secure name resolution on Linux and prevent DNS leaks."
  },
  {
    key: "sysroute_dns_servers",
    label: "In-Tunnel DNS IP List",
    category: "routing",
    level: "basic",
    type: "string",
    defaultValue: "1.1.1.1, 8.8.8.8",
    placeholder: "1.1.1.1, 8.8.8.8",
    description: "Upstream DNS resolvers queried by Zeptun engine."
  },
  {
    key: "sysroute_fake_ip",
    label: "Fake-IP Address Pool",
    category: "routing",
    level: "basic",
    type: "boolean",
    defaultValue: false,
    description: "Respond immediately with synthetic 198.18.0.0/15 IPs and resolve domain names remotely over SOCKS5. Recommended for Tor/Psiphon egress."
  },
  {
    key: "sysroute_dns_hijack",
    label: "Hijack Outbound Port 53",
    category: "routing",
    level: "advanced",
    type: "boolean",
    defaultValue: true,
    description: "Trap all outbound UDP/TCP port 53 packets to any IP and divert them to the configured in-tunnel DNS."
  },
  {
    key: "sysroute_strict_route",
    label: "Strict Routing (Leak Protection)",
    category: "routing",
    level: "advanced",
    type: "boolean",
    defaultValue: true,
    description: "Block unproxied traffic families (such as IPv6 when only IPv4 is carried) to guarantee zero leakage."
  },
  {
    key: "sysroute_auto_redirect",
    label: "Kernel TCP Redirection (nftables)",
    category: "routing",
    level: "advanced",
    type: "boolean",
    defaultValue: false,
    description: "Redirect TCP directly inside kernel space via nftables netlink, bypassing userspace TUN device overhead."
  },
  {
    key: "sysroute_exclude",
    label: "Excluded Subnets",
    category: "routing",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "192.168.1.0/24, 10.0.0.0/8",
    description: "IP CIDRs bypassed from the tunnel (LAN, multicast, and Aether endpoints are automatically excluded)."
  },
  {
    key: "sysroute_exclude_uids",
    label: "Excluded Linux UIDs",
    category: "routing",
    level: "advanced",
    type: "string",
    defaultValue: "",
    placeholder: "1000, 1005-1010",
    description: "Keep specific local users or system service accounts off the tunnel."
  },
  {
    key: "sysroute_udp_mode",
    label: "TUN UDP Forwarding Mode",
    category: "routing",
    level: "advanced",
    type: "enum",
    defaultValue: "udp",
    options: [
      { value: "udp", label: "Native UDP (SOCKS5 UDP ASSOCIATE)" },
      { value: "tcp", label: "UDP over TCP (required for Tor/Psiphon)" }
    ],
    description: "How UDP packets entering the TUN are forwarded. Note: Tor and Psiphon only support TCP; native UDP will fail."
  },
  {
    key: "sysroute_stack_mode",
    label: "Network Stack Engine",
    category: "routing",
    level: "advanced",
    type: "enum",
    defaultValue: "userspace",
    options: [
      { value: "userspace", label: "Userspace — full user-space stack" },
      { value: "hybrid", label: "Hybrid — combined kernel / userspace" },
      { value: "system", label: "System — kernel NAT stack" }
    ],
    description: "TCP/IP implementation used to terminate packets from the TUN interface."
  },
  {
    key: "sysroute_congestion",
    label: "TCP Congestion Control",
    category: "routing",
    level: "advanced",
    type: "enum",
    defaultValue: "cubic",
    options: [
      { value: "cubic", label: "Cubic — optimized for broadband" },
      { value: "newreno", label: "NewReno — conservative loss-based" }
    ],
    description: "Algorithm controlling window scaling and retransmission on proxied TCP connections."
  },
  {
    key: "sysroute_tcp_fastopen",
    label: "TCP Fast Open (TFO)",
    category: "routing",
    level: "advanced",
    type: "boolean",
    defaultValue: false,
    description: "Send data directly in initial SYN packets to upstream proxy."
  },
  {
    key: "sysroute_offload",
    label: "Hardware Offload (TSO/USO)",
    category: "routing",
    level: "advanced",
    type: "boolean",
    defaultValue: true,
    description: "Enables virtio-net, segmentation offload, and checksum calculation in kernel."
  },
  {
    key: "sysroute_io_backend",
    label: "Engine Async I/O Backend",
    category: "routing",
    level: "advanced",
    type: "enum",
    defaultValue: "auto",
    options: [
      { value: "auto", label: "Auto — io_uring when available, else epoll" },
      { value: "io_uring", label: "io_uring — modern Linux async I/O" },
      { value: "epoll", label: "epoll — classic Linux event polling" }
    ],
    description: "Low-level system call interface for packet processing."
  },
  {
    key: "sysroute_log_level",
    label: "Zeptun Log Level",
    category: "routing",
    level: "advanced",
    type: "enum",
    defaultValue: "warn",
    options: [
      { value: "warn", label: "Warn — warnings and errors only" },
      { value: "info", label: "Info — connection state transitions" },
      { value: "debug", label: "Debug — detailed packet tracing" },
      { value: "err", label: "Error — errors only" }
    ],
    description: "Log output written to ~/.local/share/omarchy-aether/zeptun.log."
  },
  {
    key: "sysroute_persistent",
    label: "Persistent Auto-Start",
    category: "routing",
    level: "advanced",
    type: "boolean",
    defaultValue: false,
    description: "Automatically re-activate system routing whenever Aether connects."
  }
];

var PRESETS = {
  "default": {
    id: "default",
    name: "Default (Balanced)",
    description: "Standard MASQUE over QUIC with adaptive scan and firewall obfuscation.",
    settings: {
      protocol: "masque",
      h2: "0",
      scan: "balanced",
      noize: "firewall",
      fragment: "0",
      fragment_size: "8-16",
      fragment_delay: "2-10",
      ech: "off",
      ip: "v4"
    }
  },
  "stealth": {
    id: "stealth",
    name: "Maximum Stealth (DPI Bypass)",
    description: "MASQUE HTTP/2 with TLS ClientHello fragmentation, ECH auto-negotiation, and firewall noise.",
    settings: {
      protocol: "masque",
      h2: "1",
      scan: "balanced",
      noize: "firewall",
      fragment: "1",
      fragment_size: "8-16",
      fragment_delay: "2-10",
      ech: "auto",
      enable_ech_grease: "1"
    }
  },
  "speed": {
    id: "speed",
    name: "High Speed / Low Latency",
    description: "MASQUE QUIC (HTTP/3), turbo scan mode, light noise profile, no fragmentation.",
    settings: {
      protocol: "masque",
      h2: "0",
      scan: "turbo",
      noize: "light",
      fragment: "0",
      sysroute_udp_mode: "udp",
      sysroute_congestion: "cubic"
    }
  },
  "tor_multihop": {
    id: "tor_multihop",
    name: "WARP → Tor Multi-Hop",
    description: "Route encrypted WARP tunnel through the Tor onion network on web ports.",
    settings: {
      protocol: "tor",
      tor_relays: "auto",
      tor_relay_ports: "web",
      tor_bridges: ""
    }
  },
  "psiphon_bypass": {
    id: "psiphon_bypass",
    name: "WARP → Psiphon Circumvention",
    description: "Route WARP egress through Psiphon tunnel core with automatic obfuscated CDN and SSH fronting.",
    settings: {
      protocol: "psiphon",
      psiphon_mode: "auto",
      psiphon_region: ""
    }
  }
};

function getCategoryList() {
  return [
    { id: "all", label: "All Settings" },
    { id: "core", label: "Core & Engine" },
    { id: "network", label: "Network & Ports" },
    { id: "tls", label: "TLS & Fingerprint" },
    { id: "circumvention", label: "Tor / Psiphon" },
    { id: "routing", label: "System Routing" },
    { id: "zerotrust", label: "Zero Trust" }
  ];
}

function getSchemaItem(key) {
  for (var i = 0; i < SCHEMA.length; i++) {
    if (SCHEMA[i].key === key) return SCHEMA[i];
  }
  return null;
}

function getSettingValue(aether, key) {
  if (!aether) return undefined;
  if (key === "ip") {
    return aether.ip_mode !== undefined ? aether.ip_mode : aether.ip;
  }
  if (key === "mark") {
    return aether.mark !== undefined ? aether.mark : aether.mark_enabled;
  }
  if (key === "stats") {
    return aether.stats !== undefined ? aether.stats : aether.stats_enabled;
  }
  if (key === "socks_port") {
    if (aether.socks_port !== undefined) return aether.socks_port;
    if (aether.proxy_port !== undefined) return aether.proxy_port;
    if (aether.proxyPort !== undefined) return aether.proxyPort;
    return undefined;
  }
  if (key === "http_proxy_port") {
    if (aether.http_proxy_port !== undefined) return aether.http_proxy_port;
    if (aether.httpProxyPort !== undefined) return aether.httpProxyPort;
    return undefined;
  }
  return aether[key];
}

function levenshtein(a, b) {
  if (a.length === 0) return b.length;
  if (b.length === 0) return a.length;
  var matrix = [];
  for (var i = 0; i <= b.length; i++) matrix[i] = [i];
  for (var j = 0; j <= a.length; j++) matrix[0][j] = j;
  for (var row = 1; row <= b.length; row++) {
    for (var col = 1; col <= a.length; col++) {
      if (b.charAt(row - 1) === a.charAt(col - 1)) {
        matrix[row][col] = matrix[row - 1][col - 1];
      } else {
        matrix[row][col] = Math.min(
          matrix[row - 1][col - 1] + 1,
          matrix[row][col - 1] + 1,
          matrix[row - 1][col] + 1
        );
      }
    }
  }
  return matrix[b.length][a.length];
}

function getItemCorpus(item) {
  if (!item) return "";
  var parts = [
    item.key,
    item.key.replace(/_/g, " "),
    item.label,
    item.description || "",
    item.category || "",
    item.placeholder || ""
  ];
  if (item.options && Array.isArray(item.options)) {
    for (var i = 0; i < item.options.length; i++) {
      var opt = item.options[i];
      if (typeof opt === "object" && opt) {
        if (opt.value !== undefined) parts.push(String(opt.value));
        if (opt.label !== undefined) parts.push(String(opt.label));
      } else if (opt !== undefined && opt !== null) {
        parts.push(String(opt));
      }
    }
  }
  return parts.join(" ").toLowerCase();
}

function matchToken(token, corpus, words) {
  if (corpus.indexOf(token) !== -1) return true;
  var tLen = token.length;
  var maxDist = tLen >= 5 ? 2 : (tLen >= 3 ? 1 : 0);
  if (maxDist === 0) return false;

  for (var i = 0; i < words.length; i++) {
    var word = words[i];
    if (word.length >= 3 && Math.abs(word.length - tLen) <= maxDist) {
      if (levenshtein(token, word) <= maxDist) return true;
    }
  }
  return false;
}

function matchesQuery(item, query) {
  if (!query) return true;
  var cleanQ = query.trim().toLowerCase();
  if (cleanQ === "") return true;
  var corpus = getItemCorpus(item);
  if (corpus.indexOf(cleanQ) !== -1) return true;
  var tokens = cleanQ.split(/[\s,+/]+/).filter(Boolean);
  if (tokens.length === 0) return true;
  var words = corpus.split(/[\s_.,:;/()[\]\-]+/).filter(function(w) { return w.length > 1; });
  for (var i = 0; i < tokens.length; i++) {
    if (!matchToken(tokens[i], corpus, words)) return false;
  }
  return true;
}

function fuzzyScore(item, query) {
  if (!query) return 0;
  var q = query.trim().toLowerCase();
  if (q === "") return 0;
  var key = item.key.toLowerCase();
  var label = item.label.toLowerCase();
  if (key === q) return 1000;
  if (label === q) return 900;
  if (key.indexOf(q) === 0) return 800;
  if (label.indexOf(q) === 0) return 700;
  if (key.indexOf(q) !== -1) return 600;
  if (label.indexOf(q) !== -1) return 500;
  if (item.category && item.category.toLowerCase() === q) return 400;
  if (item.description && item.description.toLowerCase().indexOf(q) !== -1) return 300;
  return 100;
}

function filterSchema(searchQuery, category, showAdvanced, showOnlyModified, aether) {
  var query = (searchQuery || "").trim();
  var out = [];

  for (var i = 0; i < SCHEMA.length; i++) {
    var item = SCHEMA[i];

    if (!showAdvanced && item.level === "advanced") {
      continue;
    }

    var onlyMod = showOnlyModified || category === "modified";
    if (onlyMod && aether) {
      var val = getSettingValue(aether, item.key);
      var hasSec = item.type === "password" ? aether["has_" + item.key] : false;
      if (!isSettingModified(item.key, val, hasSec)) {
        continue;
      }
    }

    if (category && category !== "all" && category !== "modified" && item.category !== category) {
      continue;
    }

    if (query !== "") {
      if (!matchesQuery(item, query)) {
        continue;
      }
    }

    out.push(item);
  }

  if (query !== "") {
    out.sort(function(a, b) {
      return fuzzyScore(b, query) - fuzzyScore(a, query);
    });
  }

  return out;
}

function detectActivePreset(aether) {
  if (!aether) return "";
  var presets = ["default", "stealth", "speed", "tor_multihop", "psiphon_bypass"];
  for (var i = 0; i < presets.length; i++) {
    var id = presets[i];
    var p = PRESETS[id];
    if (!p) continue;
    var match = true;
    for (var k in p.settings) {
      var expected = String(p.settings[k]);
      var actual = getSettingValue(aether, k);
      if (typeof actual === "boolean") {
        actual = actual ? "1" : "0";
      } else {
        actual = actual !== undefined && actual !== null ? String(actual) : "";
      }
      if (actual !== expected) {
        match = false;
        break;
      }
    }
    if (match) return id;
  }
  return "";
}

function getPresetDescription(id) {
  if (id && PRESETS[id]) return PRESETS[id].description;
  return "Custom configuration with user-tuned settings.";
}

function isSettingModified(key, val, hasSecret) {
  var item = getSchemaItem(key);
  if (!item) return false;
  if (item.type === "password") {
    return Boolean(hasSecret);
  }
  var def = item.defaultValue;
  if (item.type === "boolean") {
    var bVal = (val === true || val === "1" || val === 1 || val === "true");
    var bDef = (def === true || def === "1" || def === 1 || def === "true");
    return bVal !== bDef;
  }
  if (item.type === "number") {
    var nVal = (val === undefined || val === null || val === "") ? 0 : Number(val);
    var nDef = (def === undefined || def === null || def === "") ? 0 : Number(def);
    if (isNaN(nVal)) nVal = 0;
    if (isNaN(nDef)) nDef = 0;
    return nVal !== nDef;
  }

  // Normalize defaults that mean the same behavior
  if (key === "tor_relays" && (val === "" || val === "auto") && def === "auto") return false;
  if (key === "tor_relay_ports" && (val === "" || val === "web") && def === "web") return false;
  if (key === "psiphon_mode" && (val === "" || val === "auto") && def === "auto") return false;
  if (key === "ech" && (val === "" || val === "off") && def === "off") return false;
  if (key === "tls_verify" && (val === "" || val === "auto") && def === "auto") return false;
  if (key === "sysroute_dns_mode" && (val === "" || val === "systemd_resolved") && def === "systemd_resolved") return false;
  if (key === "sysroute_stack_mode" && (val === "" || val === "userspace") && def === "userspace") return false;
  if (key === "sysroute_io_backend" && (val === "" || val === "auto") && def === "auto") return false;

  var sVal = val !== undefined && val !== null ? String(val).trim() : "";
  var sDef = def !== undefined && def !== null ? String(def).trim() : "";
  return sVal !== sDef;
}

function countModifiedSettings(aether) {
  if (!aether) return 0;
  var count = 0;
  for (var i = 0; i < SCHEMA.length; i++) {
    var item = SCHEMA[i];
    var val = getSettingValue(aether, item.key);
    var hasSec = item.type === "password" ? aether["has_" + item.key] : false;
    if (isSettingModified(item.key, val, hasSec)) {
      count++;
    }
  }
  return count;
}

