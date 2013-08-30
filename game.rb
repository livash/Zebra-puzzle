require_relative "module"

class Game
  COLORS = %w{red blue white yellow green}
  NATIONALITY = %w{Brit Sweede Dane Norwegian German}
  PETS = %w{dos birds cats horse fish}
  CIGARETTES = ["Pall Malls", "Dunhill", "Blends", "Bluemasters", "Prince"]
  DRINKS = %w{coffee milk beer water}
  VERBS = %w{lives smokes drinks living keeps raises}
  NOUNS = %w{house owner person man}
  LOOKUP = {"lives" => [:find_house, :find_nationality], 
    "drinks" => [:find_drink, :find_nationality],
    "smokes" => [:find_cigarettes, :find_nationality],
    "keeps" => [:find_pets, :find_nationality],
    "raises" => [:find_pets, :find_nationality],
    "living" => [:find_house]
  }
    
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
    
    # ADDITIONAL CLUE PARSING NEEDS TO BE DONE
    # search through the nouns for a clue
    # to find additional properties to add to result
    
    result
  end
  
  
  def self.find_verbs(str)
    str.split(' ').select do |word|
      VERBS.include?(word)
    end
  end
  
  def solve
    #here I will be merging clues
    # each clue is a hash
    # when the number of hashes reaches five
    # I can look for the asnwer by asking a question
    # clue.pet == "fish" or clue.pet == nil
    result = []
    @clues.each do |clue|
      temp_clues = @clues - [clue]
      clue.each do |key, value|
        temp_clues.each do |temp_clue|
          # merge two clues
          result << clue.merge(temp_clue) if temp_clue[key] == value
        end
      end
    end
    puts "RESULT >>>>>>>>>>"
    puts result
    
    result
  end
    
end

# functions declared outside the class
# move them later into a module
def find_pets(str)
  result = {}
  words = str.chomp(".").split(" ")
  words.each_with_index do |word, idx|
    if (word == "keeps" || word == "raises") and words[idx + 1] != "a"
      result[:pet] = words[idx + 1]
    elsif word == "keeps" and words[idx + 1] == "a"
      result[:pet] = words[idx + 2]
    end
  end
  
  result
end

def find_cigarettes(str)
  result = {}
  words = str.chomp(".").split(" ")
  words.each_with_index do |word, idx|
    if word == "smokes" and words[idx + 1] != "Pall"
      result[:cigarettes] = words[idx + 1]
    elsif word == "smokes" and words[idx + 1] == "Pall"
      result[:cigarettes] = "Pall Mall"
    end
  end
  
  result
end

def find_drink(str)
  result = {}
  words = str.chomp(".").split(" ")
  words.each_with_index do |word, idx|
    if word == "drinks"
      result[:drinks] = words[idx + 1]
    end
  end
  
  result
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
  return result if (str.split(" ").include?("man") || str.split(" ").include?("who"))
  temp = str.split(" ")[1]
  if temp[0].capitalize == temp[0]
    result[:nationality] = temp
  end
  
  result
end

if $PROGRAM_NAME == __FILE__
  str = "The Brit lives in the red house."
  p Game.parse_clue(str)
  
  str2 = "The man who smokes Blends has a neighbor who drinks water."
  p Game.parse_clue(str2)
  str3 = "The man who smokes Blends lives next to the one who keeps cats."
  p Game.parse_clue(str3)
  str4 = "The man living in the center house drinks milk."
  p Game.parse_clue(str4)
  
end