
class Game
  COLORS = %w{red blue white yellow}
  NATIONALITY = %w{Brit Sweede Dane Norwegian German}
  PETS = %w{dos birds cats horse fish}
  CIGARETTE_BRAND = ["Pall Malls", "Dunhill", "Blends", "Bluemasters", "Prince"]
  DRINKS = %w{coffee milk beer water}
  attr_accessor :question, :clues 
  
  def initialize(str="")
    data = Game.parse_data(str)
    @question = data.first
    @clues = data.last
  end
  
  def self.parse_data(str)
    res_question = ""
    res_clues = []
    lines = str.split("\n")
    lines.each_with_index do |line, idx|
      if idx == 0
        res_question = lines.split(" ")[-2] 
      else
        # parse_clue returns {property: value}
        res_clues << Game.parse_clue(line)
      end
    end
    
    [res_question, res_clues]
  end
  
  def self.parse_clue(str)
    
  end
end