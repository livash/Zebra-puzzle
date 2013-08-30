puzzle data was taken from http://thebrainteasers.com/view/Zebra-Puzzle/

+++ Approach to solve Zebra puzzle +++

1. read in the puzzle
2. parse each clue into a hash like so {:nationality => "Swede", :pets => "dogs"}
3. to solve the puzzle iterate through array of clue hashes and merge nhashes with common key-value pairs
4. By the end we should have an aray with five hashes.
5. In this array of five hashes find {:pet => fish} or {:pet => null}