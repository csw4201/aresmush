module AresMUSH  

  module Migrations
    class MigrationBeta74Update
      def require_restart
        false
      end
      
      def migrate
        Global.logger.debug "Add discord secret config."
        config = DatabaseMigrator.read_config_file("secrets.yml")
        config['secrets']['discord'] = {
          'api_token' =>  '',
          'webhooks' => []
        }
        DatabaseMigrator.write_config_file("secrets.yml", config)
        
        Global.logger.debug "Add discord options."
        config = DatabaseMigrator.read_config_file("channels.yml")
        config['channels']['discord_prefix'] = '[D]'
        config['channels']['discord_gravatar_style'] = 'retro'
        DatabaseMigrator.write_config_file("channels.yml", config)
      end 
    end
  end
end