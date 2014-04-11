require 'pry'

class Attack
  attr_accessor :name, :opp_damage, :self_damage, :self_defense_effect, :opp_defense_effect
  attr_accessor :pp, :pp_max, :full_heal
  
  def initialize(name, opp_damage, self_damage = 0, sde = 0, ode = 0, pp = 3, full_heal = false)
    @name = name
    @opp_damage = opp_damage
    @self_damage = self_damage
    @self_defense_effect = sde
    @opp_defense_effect = ode
    @pp = pp
    @pp_max = pp
    @full_heal = full_heal
    
    # TODO: allow a code block to be passed for passive evaluation, later
  end
  
  def restore_pp
    @pp = @pp_max
  end
end

class Pokemon
  attr_accessor :name, :max_health, :current_health, :attack, :defense
  attr_reader :cry, :moves
  
  def initialize(max_health = 30, attack = 1, defense = 20, cry = "For the Dark Lord!", name = "Missingno")
    @name = name
    @cry = cry
    if max_health < 10
      @max_health = 10
    elsif max_health > 999
      @max_health = 999
    else
      @max_health = max_health
    end
    @current_health = @max_health
    
    @attack = attack
    @defense = defense
    
    @moves = []
    
    puts @cry
  end
  
  alias_method :set, :initialize
  public :set
  
  def damage(amt)
    dmg = amt - @defense
    if dmg > 0
      @current_health -= dmg
    end
    
    if @current_health <= 0
      puts "#{@name} has fainted!"
    end
  end
  
  def full_heal
    @current_health = @max_health
  end
  
  def affect_defense(amt)
    @defense += amt
    if @defense < 0
      @defense = 0
    end
  end
  
  def add_attack(attack)
    @moves << attack
    
    define_singleton_method attack.name do |target|
      index = @moves.find_index(attack)
      if self.current_health <= 0
        puts "A fainted Pokemon cannot attack!"
      elsif (@moves[index].pp > 0)
        puts "Attack #{attack.name} deployed by #{@name}!"
        
        # Effects on opponent
        target.affect_defense(attack.opp_defense_effect) if attack.opp_defense_effect != 0
        target.damage(@attack * attack.opp_damage) if attack.opp_damage != 0

        # Effects on self
        self.affect_defense(attack.self_defense_effect) if attack.self_defense_effect != 0
        self.damage(@attack * attack.self_damage) if attack.self_damage != 0
                        
        self.full_heal if attack.full_heal
        
        # Attack depletion
        @moves[index].pp -= 1
      else
        puts "Attack #{attack.name} depleted!"
      end
    end
  end
end

class Pikachu < Pokemon
  def initialize(name = self.class.name, cry = "Pika pika pika!")
    self.set(45, 1.2, 30, cry, name)
    self.add_attack Attack.new(:tail_whip, 0, 0, 0, -1, 30)
    self.add_attack Attack.new(:thunder, 40, 0, 0, 0, 30)
  end
end

class Bulbasaur < Pokemon
  def initialize(name = self.class.name, cry = "Bulba bulba!")
    self.set(45, 1.2, 30, cry, name)
    self.add_attack Attack.new(:tackle, 35, 0, 0, 0, 35)
    self.add_attack Attack.new(:berserk, 80, 10, -20, 0, 5)
  end
end