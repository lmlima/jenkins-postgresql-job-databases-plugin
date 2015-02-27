require_relative 'postgresql_global_config_descriptor'

include Java

class PostgreSQLGlobalConfig < Jenkins::Model::RootAction
  include Jenkins::Model
  include Jenkins::Model::DescribableNative
  describe_as Java.hudson.model.Descriptor, :with => PostgreSQLGlobalConfigDescriptor
end

Jenkins::Plugin.instance.register_extension(PostgreSQLGlobalConfig)
