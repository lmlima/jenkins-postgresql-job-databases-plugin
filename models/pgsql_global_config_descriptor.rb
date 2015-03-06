include Java

java_import Java.hudson.BulkChange
java_import Java.hudson.model.listeners.SaveableListener

# java_import Java.java.util.logging.Logger
# java_import Java.java.util.logging.Level

class PgsqlGlobalConfigDescriptor < Jenkins::Model::DefaultDescriptor

  attr_accessor :jenkins_pgsql_user
  attr_accessor :jenkins_pgsql_password
  attr_accessor :jenkins_pgsql_server_host
  attr_accessor :jenkins_pgsql_server_port


  def initialize(*)
    super
    load

    # logger.info "=========== MysqlGlobalConfigDescriptor initialize ==================="
    # logger.info "jenkins_pgsql_user        : #{jenkins_pgsql_user}"
    # logger.info "jenkins_pgsql_password    : #{jenkins_pgsql_password}"
    # logger.info "jenkins_pgsql_server_host : #{jenkins_pgsql_server_host}"
    # logger.info "jenkins_pgsql_server_port : #{jenkins_pgsql_server_port}"
  end


  # @see hudson.model.Descriptor#load()
  def load
    return unless configFile.file.exists()
    from_xml(File.read(configFile.file.canonicalPath))
  end


  # @see hudson.model.Descriptor#save()
  def save
    return if BulkChange.contains(self)

    begin
      File.open(configFile.file.canonicalPath, 'wb') { |f| f.write(to_xml) }
      SaveableListener.fireOnChange(self, configFile)
    rescue => e
      logger.log(Level::SEVERE, "Failed to save #{configFile}: #{e.message}")
    end
  end


  def configure(req, form)
    parse(form)

    # logger.info "=========== MysqlGlobalConfigDescriptor configure ==================="
    # logger.info "form          : #{form.inspect}"
    # logger.info "getId         : #{getId()}"
    # logger.info "getConfigFile : #{getConfigFile()}"

    save
    true
  end


  private


    def logger
      @logger ||= Logger.getLogger(PgsqlGlobalConfigDescriptor.class.name)
    end


    def from_xml(xml)
      @jenkins_pgsql_user = xml.scan(/<jenkins_pgsql_user>(.*)<\/jenkins_pgsql_user>/).flatten.first
      @jenkins_pgsql_password = xml.scan(/<jenkins_pgsql_password>(.*)<\/jenkins_pgsql_password>/).flatten.first
      @jenkins_pgsql_server_host = xml.scan(/<jenkins_pgsql_server_host>(.*)<\/jenkins_pgsql_server_host>/).flatten.first
      @jenkins_pgsql_server_port = xml.scan(/<jenkins_pgsql_server_port>(.*)<\/jenkins_pgsql_server_port>/).flatten.first
    end


    def to_xml
      str = ""
      str << "<?xml version='1.0' encoding='UTF-8'?>\n"
      str << "<#{id} plugin=\"pgsql-job-databases\">\n"
      str << "  <jenkins_pgsql_user>#{jenkins_pgsql_user}</jenkins_pgsql_user>\n"
      str << "  <jenkins_pgsql_password>#{jenkins_pgsql_password}</jenkins_pgsql_password>\n"
      str << "  <jenkins_pgsql_server_host>#{jenkins_pgsql_server_host}</jenkins_pgsql_server_host>\n"
      str << "  <jenkins_pgsql_server_port>#{jenkins_pgsql_server_port}</jenkins_pgsql_server_port>\n"
      str << "</#{id}>\n"
      str
    end


    def parse(form)
      @jenkins_pgsql_user        = form["jenkins_pgsql_user"]
      @jenkins_pgsql_password    = form["jenkins_pgsql_password"]
      @jenkins_pgsql_server_host = form["jenkins_pgsql_server_host"]
      @jenkins_pgsql_server_port = form["jenkins_pgsql_server_port"]
    end

end
