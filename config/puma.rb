workers Integer(ENV['PUMA_WORKERS'] || 3)
threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 12)

preload_app!

rackup                DefaultRackup
#port                 ENV['port_cbmodels'] || 3001
daemonize             true
bind                  "unix:///www/run/cbmodels.sock"

#control app considered broken right now (puma github)
#activate_control_app  "unix:///www/run/cbmodelsctl.sock"

pidfile               '/www/run/cbmodels.pid'

#state file considered broken right now (puma github)
#state_path            "/www/run/cbmodels.state"

stdout_redirect       "/www/log/cbmodels.stdout.log", "/www/log/cbmodels.stderr.log"

environment           ENV['env_cbmodels'] || 'production'  

on_worker_boot do

end