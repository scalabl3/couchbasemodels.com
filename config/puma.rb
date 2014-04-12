workers Integer(ENV['PUMA_WORKERS'] || 3)
threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 12)

preload_app!

rackup      DefaultRackup
port        ENV['port_cbmodels'] || 3000
environment ENV['env_cbmodels'] || 'development'

on_worker_boot do

end