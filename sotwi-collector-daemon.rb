require 'daemons'

Daemons.run(
  'sotwi-collector.rb',
  dir: File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'current','tmp', 'pids')),
  dir_mode: :normal,
  log_output: true,
  monitor: true,
  monitor_interval: 10,
)
