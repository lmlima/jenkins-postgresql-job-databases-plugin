require_relative 'pgsql_global_config_descriptor'

include Java

class PgsqlGlobalConfig < Jenkins::Model::RootAction
  include Jenkins::Model
  include Jenkins::Model::DescribableNative
  describe_as Java.hudson.model.Descriptor, :with => PgsqlGlobalConfigDescriptor
end

Jenkins::Plugin.instance.register_extension(PgsqlGlobalConfig)
