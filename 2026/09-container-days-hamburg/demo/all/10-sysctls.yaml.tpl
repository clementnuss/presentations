
# yaml-language-server: $schema=https://raw.githubusercontent.com/siderolabs/talos/refs/heads/release-1.12/website/content/v1.12/schemas/config.schema.json
machine:
  sysctls:
    # keepalive settings aligned with firewall timeouts
    net.ipv4.tcp_keepalive_time: "600"
    net.ipv4.tcp_keepalive_intvl: "75"
    net.ipv4.tcp_keepalive_probes: "9"

{{ if index .Node.Data "allow_ptrace" }}
    # allow processes to ptrace child processes. cf https://.../kubernetes/support/-/work_items/663
    kernel.yama.ptrace_scope: "1"
{{ end }}
