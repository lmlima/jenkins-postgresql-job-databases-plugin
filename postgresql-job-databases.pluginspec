Jenkins::Plugin::Specification.new do |plugin|
  plugin.name = 'postgresql-job-databases'
  plugin.display_name = 'PostgrSQL Job Databases'
  plugin.version = '0.0.1'
  plugin.description = 'Automatically create and delete a PostgreSQL database for a job.'

  plugin.url = 'https://github.com/lmlima/jenkins-postgresql-job-databases-plugin'
  plugin.developed_by 'Leandro Muniz de Lima', 'leandro.m.lima@ufes.br'
  plugin.uses_repository :github => 'lmlima/jenkins-postgresql-job-databases-plugin'

  plugin.depends_on 'ruby-runtime', '0.12'
end
