# puzzle data was taken from http://thebrainteasers.com/view/Zebra-Puzzle/

require_relative 'game'

def solve_zebra_puzzle(file_name)
  contnet = File.read(file_name)
  game = Game.new(content)
  
  
end

if $PROGRAM_NAME == __FILE__
  solve_zebra_puzzle('zebra_puzzle.txt')
end