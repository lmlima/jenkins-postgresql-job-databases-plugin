module PostgreSQLPublisher
  class DropDatabase < Jenkins::Tasks::Publisher

    display_name "Drop a PostgreSQL database for the job"

    # Global PostgreSQL account to delete job account
    attr_reader :jenkins_postgresql_user
    attr_reader :jenkins_postgresql_password
    attr_reader :postgresql_server_host
    attr_reader :postgresql_server_port

    # Job PostgreSQL account
    attr_reader :database
    attr_reader :job_postgresql_user


    def initialize(attrs)
      @database       = fix_empty(attrs['database'])
      @job_postgresql_user = fix_empty(attrs['job_postgresql_user']) || default_job_postgresql_user
    end


    def perform(build, launcher, listener)
      postgresql = get_postgresql_connection(launcher)

      drop_database(listener, postgresql)
      drop_user(listener, postgresql)
    end


    private


      def get_postgresql_connection(launcher)
        get_db_config
        PostgreSQL.new(launcher, jenkins_postgresql_user, jenkins_postgresql_password, postgresql_server_host, postgresql_server_port)
      end


      def get_db_config
        global_config = Java.jenkins.model.Jenkins.getInstance().getDescriptor(PostgreSQLGlobalConfigDescriptor.java_class)

        @jenkins_postgresql_user     = fix_empty(global_config.jenkins_postgresql_user) || 'jenkins'
        @jenkins_postgresql_password = fix_empty(global_config.jenkins_postgresql_password) || 'jenkins'

        @postgresql_server_host = fix_empty(global_config.jenkins_postgresql_server_host) || '127.0.0.1'
        @postgresql_server_port = fix_empty(global_config.jenkins_postgresql_server_port) || '5432'
      end


      def drop_database(listener, postgresql)
        listener << "Drop PostgreSQL database for job if exists"

        if database.strip.empty?
          listener << "No database name configured for job.\n"
        else
          postgresql.execute("DROP DATABASE IF EXISTS #{database};")
        end
      rescue PostgreSQL::Error => e
        listener << "PostgreSQL command failed:\n\n#{e.out}"
      end


      def drop_user(listener, postgresql)
        listener << "Drop PostgreSQL user for job if exists"
        postgresql.execute("REVOKE ALL PRIVILEGES ON DATABASE #{database} FROM #{job_postgresql_user};")
        postgresql.execute("DROP USER #{job_postgresql_user};")
      rescue PostgreSQL::Error => e
        listener << "PostgreSQL command failed:\n\n#{e.out}"
      end


      def fix_empty(s)
        s == "" ? nil : s
      end


      def default_job_postgresql_user
        "#{database}_user"
      end

  end
end
