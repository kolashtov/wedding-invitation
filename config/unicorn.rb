deploy_to  = File.expand_path("../", File.dirname(__FILE__))
rails_root = "#{deploy_to}"
pid_file   = "#{deploy_to}/shared/unicorn/pids/unicorn.pid"
socket_file= "#{deploy_to}/shared/unicorn/unicorn.sock"
log_file   = "#{rails_root}/log/unicorn.log"
err_log    = "#{rails_root}/log/unicorn_error.log"
old_pid    = pid_file + '.oldbin'


worker_processes 2
 
preload_app true
 
timeout 43200
 
listen socket_file, :backlog => 1024
listen 8097, :tcp_nopush => true
pid pid_file

stderr_path err_log
stdout_path log_file

#GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=) #only from ree
 
before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{rails_root}/Gemfile"
end

before_fork do |server, worker|
    defined?(ActiveRecord::Base) and
        ActiveRecord::Base.connection.disconnect!
  # 0 downtime deploy.
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      print "KILL #{File.read(old_pid).to_i}"
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
 
after_fork do |server, worker|
    defined?(ActiveRecord::Base) and
        ActiveRecord::Base.establish_connection
end
