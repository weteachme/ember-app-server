pidfile '/data/ember-app/tmp/puma.pid'
state_path '/data/ember-app/tmp/puma.state'
stdout_redirect '/data/ember-app/log/puma.log', '/data/ember-app/log/puma.log', true
threads 2, 2
bind 'tcp://0.0.0.0:3000'
workers 2