module PostgresqlBuilder
  class CreateDatabase < Jenkins::Tasks::BuildWrapper

    display_name "Create a PostgreSQL database for the job"

    # Global PostgreSQL account to create job account
    attr_reader :jenkins_postgresql_user
    attr_reader :jenkins_postgresql_password
    attr_reader :postgresql_server_host
    attr_reader :postgresql_server_port

    # Job PostgreSQL account
    attr_reader :database
    attr_reader :job_postgresql_user
    attr_reader :job_postgresql_password


    def initialize(attrs)
      @database           = fix_empty(attrs['database'])
      @job_postgresql_user     = fix_empty(attrs['job_postgresql_user']) || default_job_postgresql_user
      @job_postgresql_password = fix_empty(attrs['job_postgresql_password']) || default_job_postgresql_password
    end


    def setup(build, launcher, listener)
      ## Get global config here as it's called for each build
      ## whereas in initialize it's called only once...
      postgresql = get_postgresql_connection(launcher)

      listener << "Ensuring PostgreSQL database for job exists"

      if database.strip.empty?
        listener << "No database name configured for job.\n"
        build.abort
        return
      end

      ## If database already exist, it will throw an error
      postgresql.execute("CREATE DATABASE #{database};")

      postgresql.execute( "CREATE USER #{job_postgresql_user}" +
                    " WITH PASSWORD '#{job_postgresql_password}';" +
                    "GRANT ALL PRIVILEGES ON DATABASE #{database}" +
                    " TO #{job_postgresql_user};")

      build.env['PGSQL_DATABASE'] = database
      build.env['PGSQL_USER']     = job_postgresql_user
      build.env['PGSQL_PASSWORD'] = job_postgresql_password
      build.env['PGSQL_HOST']     = postgresql_server_host
      build.env['PGSQL_PORT']     = postgresql_server_port
    rescue PostgreSQL::Error => e
      listener << "PostgreSQL command failed:\n\n#{e.out}"
      build.abort
    end


    private


      def fix_empty(s)
        s == "" ? nil : s
      end


      def get_postgresql_connection(launcher)
        get_db_config
        PostgreSQL.new(launcher, jenkins_postgresql_user, jenkins_postgresql_password, postgresql_server_host, postgresql_server_port)
      end


      def get_db_config
        global_config = Java.jenkins.model.Jenkins.getInstance().getDescriptor(PostgreSQLGlobalConfigDescriptor.java_class)

        @jenkins_postgresql_user     = fix_empty(global_config.jenkins_postgresql_user) || 'jenkins'
        @jenkins_postgresql_password = fix_empty(global_config.jenkins_postgresql_password) || 'jenkins'

        @postgresql_server_host = fix_empty(global_config.jenkins_postgresql_server_host) || '127.0.0.1'
        @postgresql_server_port = fix_empty(global_config.jenkins_postgresql_server_port) || '3306'
      end


      def default_job_postgresql_user
        "#{database}_user"
      end


      def default_job_postgresql_password
        "#{database}_jenkins_password"
      end

  end
end
