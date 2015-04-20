worker_processes 6

root = "/home/deployer/apps/shuiguoshe_production/current"
working_directory root
# shared_root = "/home/deployer/apps/shuiguoshe/shared"

listen "/tmp/unicorn.shuiguoshe.sock", :backlog => 64
listen 4096, :tcp_nopush => false

timeout 30

pid "#{root}/tmp/pids/unicorn_shuiguoshe.pid"

stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

# listen "/tmp/unicorn.keke_official_website.sock"

# To save some memory and improve performance
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_exec do |_|  
  ENV["BUNDLE_GEMFILE"] = File.join(root, 'Gemfile')  
end  

before_fork do |server, worker|  
  # 参考 http://unicorn.bogomips.org/SIGNALS.html  
  # 使用USR2信号，以及在进程完成后用QUIT信号来实现无缝重启  
  old_pid = root + '/tmp/pids/unicorn_shuiguoshe.pid.oldbin'  
  if File.exists?(old_pid) && server.pid != old_pid  
    begin  
      Process.kill("QUIT", File.read(old_pid).to_i)  
    rescue Errno::ENOENT, Errno::ESRCH  
      # someone else did our job for us  
    end  
  end  

  # the following is highly recomended for Rails + "preload_app true"  
  # as there's no need for the master process to hold a connection  
  defined?(ActiveRecord::Base) and  
    ActiveRecord::Base.connection.disconnect!  
end  

after_fork do |server, worker|  
  # 禁止GC，配合后续的OOB，来减少请求的执行时间  
  GC.disable  
  # the following is *required* for Rails + "preload_app true",  
  defined?(ActiveRecord::Base) and  
    ActiveRecord::Base.establish_connection  
end 

