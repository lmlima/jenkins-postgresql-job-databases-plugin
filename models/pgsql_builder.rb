module PgsqlBuilder
  class CreateDatabase < Jenkins::Tasks::BuildWrapper

    display_name "Create a PostgreSQL database for the job"

    # Global PostgreSQL account to create job account
    attr_reader :jenkins_pgsql_user
    attr_reader :jenkins_pgsql_password
    attr_reader :pgsql_server_host
    attr_reader :pgsql_server_port

    # Job PostgreSQL account
    attr_reader :database
    attr_reader :job_pgsql_user
    attr_reader :job_pgsql_password


    def initialize(attrs)
      @database           = fix_empty(attrs['database'])
      @job_pgsql_user     = fix_empty(attrs['job_pgsql_user']) || default_job_pgsql_user
      @job_pgsql_password = fix_empty(attrs['job_pgsql_password']) || default_job_pgsql_password
    end


    def setup(build, launcher, listener)
      ## Get global config here as it's called for each build
      ## whereas in initialize it's called only once...
      pgsql = get_pgsql_connection(launcher)

      listener << "Ensuring PostgreSQL database for job exists"

      if database.strip.empty?
        listener << "No database name configured for job.\n"
        build.abort
        return
      end

      #pgsql.execute("CREATE DATABASE IF NOT EXISTS #{database};")
      pgsql.execute("CREATE DATABASE #{database};")

      #pgsql.execute("GRANT ALL ON #{database}.*" +
      #              " TO '#{job_pgsql_user}'@'%'" +
      #              " IDENTIFIED BY '#{job_pgsql_password}';")
      pgsql.execute("CREATE USER #{job_pgsql_user}" +
                    " WITH PASSWORD '#{job_pgsql_password}';" +
                    "GRANT ALL PRIVILEGES ON DATABASE #{database}" +
                    " TO #{job_pgsql_user};")

      build.env['PGSQL_DATABASE'] = database
      build.env['PGSQL_USER']     = job_pgsql_user
      build.env['PGSQL_PASSWORD'] = job_pgsql_password
      build.env['PGSQL_HOST']     = pgsql_server_host
      build.env['PGSQL_PORT']     = pgsql_server_port
    rescue PostgreSQL::Error => e
      listener << "PostgreSQL command failed:\n\n#{e.out}"
      build.abort
    end


    private


      def fix_empty(s)
        s == "" ? nil : s
      end


      def get_pgsql_connection(launcher)
        get_db_config
        PostgreSQL.new(launcher, jenkins_pgsql_user, jenkins_pgsql_password, pgsql_server_host, pgsql_server_port)
      end


      def get_db_config
        global_config = Java.jenkins.model.Jenkins.getInstance().getDescriptor(PgsqlGlobalConfigDescriptor.java_class)

        @jenkins_pgsql_user     = fix_empty(global_config.jenkins_pgsql_user) || 'jenkins'
        @jenkins_pgsql_password = fix_empty(global_config.jenkins_pgsql_password) || 'jenkins'

        @pgsql_server_host = fix_empty(global_config.jenkins_pgsql_server_host) || '127.0.0.1'
        @pgsql_server_port = fix_empty(global_config.jenkins_pgsql_server_port) || '5432'
      end


      def default_job_pgsql_user
        "#{database}_user"
      end


      def default_job_pgsql_password
        "#{database}_jenkins_password"
      end

  end
end
