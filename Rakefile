def dep(task, *args)
  Rake::Task[task].invoke(*args)
end

desc 'Deploy to web'
task :'web:deploy' => [:ensure_git, :ensure_master, :require_heroku] do
  sh 'git subtree push --prefix server heroku master'
end

task :ensure_git do
  if (`git` rescue nil).nil?
    puts 'git not present.'
    exit!
  end
end

task :ensure_master => :ensure_git do
  unless (`git branch --no-color`.strip rescue '') =~ /^*\s+master$/
    puts 'You must push to production from the master branch.'
    exit!
  end
end

task :require_heroku do
  dep :require_remote, 'heroku', 'git@heroku.com:qcp.git'
end

task :require_remote, [:name, :git_url] => :ensure_git do |t, args|
  unless `git remote` =~ /\b#{args.name}\b/
    sh "git remote add #{args.name} #{args.git_url}"
  end
end
