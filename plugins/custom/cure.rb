module AresMUSH
  module Custom
    class CureCmd
      include CommandHandler
      
      attr_accessor :name, :num
      
      def parse_args
        # cure <name>
        self.name = cmd.args ? titlecase_arg(cmd.args) : enactor.name
      end
      
      def required_args
        [ self.name ]
      end
      
      def handle
        char = Character.find_one_by_name(self.name)
        wounds = char.damage.select { |d| d.healing_points > 0 }

        if !wounds
          client.emit_failure("#{name} has no curable wounds.")
          return nil
        end

        rating = FS3Skills.ability_rating(enactor, "Kenning")

        if rating < 2
          client.emit_failure("You do not possess this Advantage.")
          return nil
        end

        if self.name != enactor.name && rating < 3
          client.emit_failure("You do not possess this Advantage.")
          return nil
        end

        luck = enactor.luck.floor

        if luck < 1
          client.emit_failure("You don't have enough Luck.")
          return nil
        end
            
        points = 3

        wounds.each do |d|
         FS3Combat.heal(d, points)
        end

        Global.logger.info "Curing wounds on #{char.name}: healer=#{enactor.name}."

        message = "#{enactor.name} used Cure on #{char.name}."

        Login.emit_ooc_if_logged_in(char, message)

        client.emit_success("#{enactor.name} used Cure on #{char.name}.")
        
        FS3Skills.spend_luck(enactor, "#{enactor.name} used Cure on #{char.name}.", enactor_room.scene)

      end
    end
  end
end