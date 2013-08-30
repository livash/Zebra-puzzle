
class Game
  attr_accessor :question, :clues 
  
  def initialize(str="")
    @question, @clues = Game.parse_data(str)
  end
  
  def self.parse_data(str)
    
  end
  
  def method_name
    
  end
end