require_relative "module"
require_relative "house"

class Game
  COLORS = %w{red blue white yellow green}
  NATIONALITY = %w{Brit Sweede Dane Norwegian German}
  PETS = %w{dos birds cats horse fish}
  CIGARETTES = ["Pall Malls", "Dunhill", "Blends", "Bluemasters", "Prince"]
  DRINKS = %w{coffee milk beer water}
  VERBS = %w{lives smokes drinks living keeps raises is}
  NOUNS = %w{owner person man neighbor} #house
  CLUE_SPLITTING_WORDS = %w{next neighbor}
  POSITION = %w{left right center first last next}
  LOOKUP = {
    "lives"  => [:find_house, :find_nationality], 
    "drinks" => [:find_drink, :find_nationality, :find_house],
    "smokes" => [:find_cigarettes, :find_nationality, :find_house],
    "keeps"  => [:find_pets, :find_nationality],
    "raises" => [:find_pets, :find_nationality],
    "living" => [:find_house],
    "is"     => [:complex_parse],
    
    "house"  => [:find_house],
    "owner"  => [],
    "person" => [],
    "man"    => [],
    "neighbor" => []
  }
    
  attr_accessor :question, :clues, :houses 
  
  def initialize(str="")
    @question = Game.parse_data_for_question(str)
    @clues = Game.parse_data_for_clues(str)
    @houses = []
  end
  
  def self.parse_data_for_clues(str)
    result_clues = []
    lines = str.split("\n")
    lines.each_with_index do |line, idx|
      next if idx == 0
      # parse_clue returns {property: value}
      result_clues << Game.parse_clue(line.chomp('.'))  
    end
    
    result_clues
  end
  
  def self.parse_data_for_question(str)
    property = str.split("\n").first.chomp("?").split(" ").last
    return {:pet        => property} if PETS.include?(property)
    return {:drinks     => property} if DRINKS.inlcude?(property)
    return {:cigarettes => property} if CIGARETTES.include?(property)
    
    {}
  end
  
  def self.parse_clue(str)
    result = {}
    subject = ""
    object = ""
    words = str.chomp(".").split(" ")
    CLUE_SPLITTING_WORDS.each do |split_word|
      if words.include?(split_word)
        #process subject
        subject = str.split(split_word).first
        result = result.merge(Game.parse_clue(subject))
        result[:position_to_neighbor] = split_word
        result[:position_to_neighbor] = "next" if split_word == "neighbor"
        #process object
        object = str.split(split_word).last
        temp_result = Game.parse_clue(object)
        result = result.merge(reverse_role(temp_result))
      end
    end
    
    #1. Look through verbs in a clue
    if subject == "" and object == ""
      verbs = Game.find_verbs(str)
      verbs.each do |verb|
        LOOKUP[verb].each do |fun|
          result = result.merge(send(fun, str))
        end
      end

      if result[:house_color].nil?
        result = result.merge(send(LOOKUP["house"].first, str))
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
    # iterate through clues, find one with reference to house_color
    @clues.each do |clue|
      if clue[:house_color]
        house = House.new()
        house.color = clue[:house_color]
        house.nationality = clue[:nationality]
        house.pets = clue[:pets]
        house.cigarettes = clue[:cigarettes]
        house.drinks = clue[:drinks]
        houses << house
        
        # erase all recorded properties in the clue except hosue color and neighbor information
        clue.each do |key, val|
          if [:nationality, :pets, :drinks, :cigarettes].include?(key)
            clue[key] = nil
          end
        end
      end
    end
    
    
    # result = []
 #    @clues.each do |clue|
 #      temp_clues = @clues - [clue]
 #      clue.each do |key, value|
 #        temp_clues.each do |temp_clue|
 #          # merge two clues
 #          result << clue.merge(temp_clue) if temp_clue[key] == value
 #        end
 #      end
 #    end
 #    puts "RESULT >>>>>>>>>>"
 #    puts result
 #    
 #    result
  end
    
end

# functions declared outside the class
# move them later into a module
def reverse_role(hash)
  result = {}
  hash.each do |key, val|
    new_key = "neighbor_" + key.to_s
    result[new_key] = val
  end
  
  result
end

def complex_parse(str)
  result = {}
  
  subject = str.split("is").first
  puts subject.capitalize
  words_subj = subject.split(" ")
  words_subj.each_with_index do |word, idx|
    color = words_subj[idx - 1]
    result[:house_color] = color #if Game::COLORS.include?(color)
  end
  
  object = str.split("is").last
  words_obj = object.chomp(".").split(" ")
  words_obj.each_with_index do |word, idx|
    color = words_obj[idx - 1]
    result[:neighbor_house_color] = color if Game::COLORS.include?(color)
    result[:position_to_neighbor] = word if Game::POSITION.include?(word)
  end
  # puts ".........................."
  # puts result
  
  result
end

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
    if word == "house" || word == "house's"
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