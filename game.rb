require_relative "module"

class Game
  COLORS = %w{red blue white yellow green}
  NATIONALITY = %w{Brit Sweede Dane Norwegian German}
  PETS = %w{dos birds cats horse fish}
  CIGARETTES = ["Pall Malls", "Dunhill", "Blends", "Bluemasters", "Prince"]
  DRINKS = %w{coffee milk beer water}
  VERBS = %w{lives smokes drinks is living keeps}
  PROPERTIES = %w{house owner person man}
  LOOKUP = {"lives" => [:find_house, :find_nationality], "drinks" => [:find_drink]}
  #CONSTANTS_ARRAY = [COLORS, NATIONALITIES, PETS, CIGARETTES, DRINKS, ]
  
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
        res_question = line.split(" ")[-2] 
      else
        # parse_clue returns {property: value}
        res_clues << Game.parse_clue(line.chomp('.'))
      end
    end
    
    [res_question, res_clues]
  end
  
  def self.parse_clue(str)
    result = {}
    words = str.split(' ')
    verbs = Game.find_verbs(str)
    verbs.each do |verb|
      LOOKUP[verb].each do |fun|
       result = result.merge(send(fun, str))
      end
    end
    
    result
  end
  
  
  def self.find_verbs(str)
    str.split(' ').select do |word|
      VERBS.include?(word)
    end
  end
  
  def solve
    
  end
end

# functions declared outside the class
# move them later into a module
def find_drink(str)
  
end

def find_house(str)
  result = {}
  words = str.chomp(".").split(" ")
  words.each_with_index do |word, idx|
    if word == "house"
      house_prop = words[idx - 1]
      if Game::COLORS.include?(house_prop)
        result[:house_color] = house_prop
      else
        result[:house_position] = house_prop
      end
    end
  end
  
  result
end

def find_nationality(str)
  result = {}
  temp = str.split(" ")[1]
  if temp[0].capitalize == temp[0]
    result[:nationality] = temp
  end
  
  result
end

if $PROGRAM_NAME == __FILE__
  str = "The Brit lives in the red house."
  p Game.parse_clue(str)
  
  
end