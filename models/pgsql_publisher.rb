module PgsqlPublisher
  class DropDatabase < Jenkins::Tasks::Publisher

    display_name "Drop a PostgreSQL database for the job"

    # Global PostgreSQL account to delete job account
    attr_reader :jenkins_pgsql_user
    attr_reader :jenkins_pgsql_password
    attr_reader :pgsql_server_host
    attr_reader :pgsql_server_port

    # Job PostgreSQL account
    attr_reader :database
    attr_reader :job_pgsql_user


    def initialize(attrs)
      @database       = fix_empty(attrs['database'])
      @job_pgsql_user = fix_empty(attrs['job_pgsql_user']) || default_job_pgsql_user
    end


    def perform(build, launcher, listener)
      pgsql = get_pgsql_connection(launcher)

      drop_database(listener, pgsql)
      drop_user(listener, pgsql)
    end


    private


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


      def drop_database(listener, pgsql)
        listener << "Drop PostgreSQL database for job if exists"

        if database.strip.empty?
          listener << "No database name configured for job.\n"
        else
          pgsql.execute("DROP DATABASE IF EXISTS #{database};")
        end
      rescue PostgreSQL::Error => e
        listener << "PostgreSQL command failed:\n\n#{e.out}"
      end


      def drop_user(listener, pgsql)
        listener << "Drop PostgreSQL user for job if exists"
        #pgsql.execute("REVOKE ALL PRIVILEGES, GRANT OPTION FROM '#{job_pgsql_user}'@'%';")
        #pgsql.execute("DROP USER '#{job_pgsql_user}'@'%';")
        pgsql.execute("DROP USER #{job_pgsql_user};")
      rescue PostgreSQL::Error => e
        listener << "PostgreSQL command failed:\n\n#{e.out}"
      end


      def fix_empty(s)
        s == "" ? nil : s
      end


      def default_job_pgsql_user
        "#{database}_user"
      end

  end
end
