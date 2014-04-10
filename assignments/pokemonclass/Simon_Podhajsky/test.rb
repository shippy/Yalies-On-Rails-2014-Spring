require './pokemon'
require 'minitest/autorun'

class PokemonClassData < MiniTest::Unit::TestCase
  def setup
    @pok = Pokemon.new
    @pik = Pikachu.new
    @bul = Bulbasaur.new
  end
  
  def test_hasDefaultName
    assert_equal('Missingno', @pok.name)
  end
  
  def test_inheritedName
    refute_equal(@pik.name, "Missingno")
    assert_equal(@pik.name, "Pikachu")
 
    refute_equal(@bul.name, "Missingno")
    assert_equal(@bul.name, "Bulbasaur")
  end
  
  def test_currentHealthIsMaxHealth
    # In default case
    assert_equal(@pok.max_health, @pok.current_health)
    
    # In custom setup
    pak = Pokemon.new(10)
    assert_equal(pak.max_health, pak.current_health)
    
    # In case custom setup is out of bounds
    pik = Pokemon.new(1000)
    assert_equal(pik.max_health, pik.current_health)
  end
  
  def test_cannotAssignMaxHealthOutsideBounds
    pok = Pokemon.new(1)
    assert_equal(10, pok.max_health)
    refute_equal(1, pok.max_health)
    pak = Pokemon.new(1000)
    assert_equal(999, pak.max_health)
    refute_equal(1000, pok.max_health)
    # NB: The actual comparison values are implementation dependent
  end

  
  def test_damageInvolvesDefense
    @pok.damage 30
    assert_equal(@pok.current_health, @pok.max_health - (30 - @pok.defense))
  end
  
  def test_negativeDamageFails
    @pok.damage -10
    assert_equal(@pok.current_health, @pok.max_health)
  end
  
  def test_fullHeal
    pok = Pokemon.new(30, 0, 0) # No defense
    pok.damage 20
    refute_equal(pok.current_health, pok.max_health)
    pok.full_heal
    assert_equal(pok.current_health, pok.max_health)
  end
  
  def test_cryOnInit
    assert_output("Yo gabba gabba!\n") { Pokemon.new(30, 1, 20, "Yo gabba gabba!") }
    assert_output("Chu!\n") { Pikachu.new("Pika", "Chu!") }
    assert_output("Saur!\n") { Bulbasaur.new("Bulba", "Saur!") }
  end
  
  def test_defaultCriesOnInit
    assert_output("For the Dark Lord!\n") { Pokemon.new }
    assert_output("Pika pika pika!\n") { Pikachu.new }
    assert_output("Bulba bulba!\n") { Bulbasaur.new }
  end
  
  def test_tailWhip
    assert_equal(30, @bul.defense)
    @pik.tail_whip @bul
    assert_operator(30, :>, @bul.defense)
  end
  
  def test_thunder
    @pik.thunder @bul
    assert_equal(@bul.current_health, @bul.max_health - (@pik.attack * 40 - @bul.defense))
  end
  
  def test_tackle
    @bul.tackle @pik
    assert_equal(@pik.current_health, @pik.max_health - (@bul.attack * 35 - @pik.defense))
  end
  
  def test_berserk
    @pik.set(100) # Maximum health
    assert_equal(@bul.defense, 30)
    @bul.berserk @pik
    assert_equal(@bul.defense, 10)
    assert_equal(@pik.current_health, @pik.max_health - (@bul.attack * 80 - @pik.defense))
    assert_equal(@bul.current_health, @bul.max_health - (@bul.attack * 10 - @bul.defense))
  end
  
  def test_pokemonsDontShareMoves
    assert_raises(NoMethodError) {Pikachu.new.tackle Bulbasaur.new}
    assert_raises(NoMethodError) {Pikachu.new.berserk Bulbasaur.new}
    assert_raises(NoMethodError) {Bulbasaur.new.tail_whip Pikachu.new}
    assert_raises(NoMethodError) {Bulbasaur.new.thunder Pikachu.new}
  end
  
  def test_movesDepletePowerPoints
    att = @pik.moves.first
    pp = att.pp
    @pik.send(att.name, @bul)
    assert_equal(pp - 1, @pik.moves.first.pp)
  end
  
  def test_movesFailAfterPPDepletion
    30.times {@pik.thunder @bul}
    @bul.full_heal
    # Error message triggered
    assert_output("Attack thunder depleted!\n") { @pik.thunder @bul }
    # Other pokemon no longer hurt by attempted attack
    assert_equal(@bul.max_health, @bul.current_health)
  end
  
  def test_pokemonsFaint
    assert_output("Pikachu has fainted!\n") { @pik.damage 1000 }
  end
  
  def test_faintedPokemonsCannotAttack
    @pik.damage 1000
    # Error message triggered
    assert_output("A fainted Pokemon cannot attack!\n") { @pik.thunder @bul }
    # Other pokemon no longer hurt by attempted attack
    assert_equal(@bul.max_health, @bul.current_health)
  end
end