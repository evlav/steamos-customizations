-- HDMI output is always plugged in card 0 (HD_Audio Generic)
-- We always give higher priority to nodes from that card

table.insert (alsa_monitor.rules, {
  matches = {
    {
      -- Matches all sources from card HD-Audio Generic
      { "node.name", "matches", "alsa_input.*" },
      { "alsa.card_name", "matches", "HD-Audio Generic" },
    },
    {
      -- Matches all sinks from card HD-Audio Generic
      { "node.name", "matches", "alsa_output.*" },
      { "alsa.card_name", "matches", "HD-Audio Generic" },
    },
  },
  apply_properties = {
    ["priority.driver"]        = 900,
    ["priority.session"]       = 900,
  }
})
