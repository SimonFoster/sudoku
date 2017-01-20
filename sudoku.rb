#! /usr/bin/env ruby

# require 'benchmark'

module SudokuSolver

  ROWS = 
    [[ 0,  1,  2,  3,  4,  5,  6,  7,  8],
     [ 9, 10, 11, 12, 13, 14, 15, 16, 17],
     [18, 19, 20, 21, 22, 23, 24, 25, 26],
     [27, 28, 29, 30, 31, 32, 33, 34, 35],
     [36, 37, 38, 39, 40, 41, 42, 43, 44],
     [45, 46, 47, 48, 49, 50, 51, 52, 53],
     [54, 55, 56, 57, 58, 59, 60, 61, 62],
     [63, 64, 65, 66, 67, 68, 69, 70, 71],
     [72, 73, 74, 75, 76, 77, 78, 79, 80]]

  COLS =
    [[ 0,  9, 18, 27, 36, 45, 54, 63, 72],
     [ 1, 10, 19, 28, 37, 46, 55, 64, 73],
     [ 2, 11, 20, 29, 38, 47, 56, 65, 74],
     [ 3, 12, 21, 30, 39, 48, 57, 66, 75],
     [ 4, 13, 22, 31, 40, 49, 58, 67, 76],
     [ 5, 14, 23, 32, 41, 50, 59, 68, 77],
     [ 6, 15, 24, 33, 42, 51, 60, 69, 78],
     [ 7, 16, 25, 34, 43, 52, 61, 70, 79],
     [ 8, 17, 26, 35, 44, 53, 62, 71, 80]]

  BOXS =
    [[ 0,  1,  2,  9, 10, 11, 18, 19, 20],
     [ 3,  4,  5, 12, 13, 14, 21, 22, 23],
     [ 6,  7,  8, 15, 16, 17, 24, 25, 26],
     [27, 28, 29, 36, 37, 38, 45, 46, 47],
     [30, 31, 32, 39, 40, 41, 48, 49, 50],
     [33, 34, 35, 42, 43, 44, 51, 52, 53],
     [54, 55, 56, 63, 64, 65, 72, 73, 74],
     [57, 58, 59, 66, 67, 68, 75, 76, 77],
     [60, 61, 62, 69, 70, 71, 78, 79, 80]]

  UNITS = ROWS + COLS + BOXS

  PEERS = 
    [[ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 18, 19, 20, 27, 36, 45, 54, 63, 72],
     [ 0,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 18, 19, 20, 28, 37, 46, 55, 64, 73],
     [ 0,  1,  3,  4,  5,  6,  7,  8,  9, 10, 11, 18, 19, 20, 29, 38, 47, 56, 65, 74],
     [ 0,  1,  2,  4,  5,  6,  7,  8, 12, 13, 14, 21, 22, 23, 30, 39, 48, 57, 66, 75],
     [ 0,  1,  2,  3,  5,  6,  7,  8, 12, 13, 14, 21, 22, 23, 31, 40, 49, 58, 67, 76],
     [ 0,  1,  2,  3,  4,  6,  7,  8, 12, 13, 14, 21, 22, 23, 32, 41, 50, 59, 68, 77],
     [ 0,  1,  2,  3,  4,  5,  7,  8, 15, 16, 17, 24, 25, 26, 33, 42, 51, 60, 69, 78],
     [ 0,  1,  2,  3,  4,  5,  6,  8, 15, 16, 17, 24, 25, 26, 34, 43, 52, 61, 70, 79],
     [ 0,  1,  2,  3,  4,  5,  6,  7, 15, 16, 17, 24, 25, 26, 35, 44, 53, 62, 71, 80],
     [ 0,  1,  2, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 27, 36, 45, 54, 63, 72],
     [ 0,  1,  2,  9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 28, 37, 46, 55, 64, 73],
     [ 0,  1,  2,  9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 29, 38, 47, 56, 65, 74],
     [ 3,  4,  5,  9, 10, 11, 13, 14, 15, 16, 17, 21, 22, 23, 30, 39, 48, 57, 66, 75],
     [ 3,  4,  5,  9, 10, 11, 12, 14, 15, 16, 17, 21, 22, 23, 31, 40, 49, 58, 67, 76],
     [ 3,  4,  5,  9, 10, 11, 12, 13, 15, 16, 17, 21, 22, 23, 32, 41, 50, 59, 68, 77],
     [ 6,  7,  8,  9, 10, 11, 12, 13, 14, 16, 17, 24, 25, 26, 33, 42, 51, 60, 69, 78],
     [ 6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 17, 24, 25, 26, 34, 43, 52, 61, 70, 79],
     [ 6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 24, 25, 26, 35, 44, 53, 62, 71, 80],
     [ 0,  1,  2,  9, 10, 11, 19, 20, 21, 22, 23, 24, 25, 26, 27, 36, 45, 54, 63, 72],
     [ 0,  1,  2,  9, 10, 11, 18, 20, 21, 22, 23, 24, 25, 26, 28, 37, 46, 55, 64, 73],
     [ 0,  1,  2,  9, 10, 11, 18, 19, 21, 22, 23, 24, 25, 26, 29, 38, 47, 56, 65, 74],
     [ 3,  4,  5, 12, 13, 14, 18, 19, 20, 22, 23, 24, 25, 26, 30, 39, 48, 57, 66, 75],
     [ 3,  4,  5, 12, 13, 14, 18, 19, 20, 21, 23, 24, 25, 26, 31, 40, 49, 58, 67, 76],
     [ 3,  4,  5, 12, 13, 14, 18, 19, 20, 21, 22, 24, 25, 26, 32, 41, 50, 59, 68, 77],
     [ 6,  7,  8, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 26, 33, 42, 51, 60, 69, 78],
     [ 6,  7,  8, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 34, 43, 52, 61, 70, 79],
     [ 6,  7,  8, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 35, 44, 53, 62, 71, 80],
     [ 0,  9, 18, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 45, 46, 47, 54, 63, 72],
     [ 1, 10, 19, 27, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 45, 46, 47, 55, 64, 73],
     [ 2, 11, 20, 27, 28, 30, 31, 32, 33, 34, 35, 36, 37, 38, 45, 46, 47, 56, 65, 74],
     [ 3, 12, 21, 27, 28, 29, 31, 32, 33, 34, 35, 39, 40, 41, 48, 49, 50, 57, 66, 75],
     [ 4, 13, 22, 27, 28, 29, 30, 32, 33, 34, 35, 39, 40, 41, 48, 49, 50, 58, 67, 76],
     [ 5, 14, 23, 27, 28, 29, 30, 31, 33, 34, 35, 39, 40, 41, 48, 49, 50, 59, 68, 77],
     [ 6, 15, 24, 27, 28, 29, 30, 31, 32, 34, 35, 42, 43, 44, 51, 52, 53, 60, 69, 78],
     [ 7, 16, 25, 27, 28, 29, 30, 31, 32, 33, 35, 42, 43, 44, 51, 52, 53, 61, 70, 79],
     [ 8, 17, 26, 27, 28, 29, 30, 31, 32, 33, 34, 42, 43, 44, 51, 52, 53, 62, 71, 80],
     [ 0,  9, 18, 27, 28, 29, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 54, 63, 72],
     [ 1, 10, 19, 27, 28, 29, 36, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 55, 64, 73],
     [ 2, 11, 20, 27, 28, 29, 36, 37, 39, 40, 41, 42, 43, 44, 45, 46, 47, 56, 65, 74],
     [ 3, 12, 21, 30, 31, 32, 36, 37, 38, 40, 41, 42, 43, 44, 48, 49, 50, 57, 66, 75],
     [ 4, 13, 22, 30, 31, 32, 36, 37, 38, 39, 41, 42, 43, 44, 48, 49, 50, 58, 67, 76],
     [ 5, 14, 23, 30, 31, 32, 36, 37, 38, 39, 40, 42, 43, 44, 48, 49, 50, 59, 68, 77],
     [ 6, 15, 24, 33, 34, 35, 36, 37, 38, 39, 40, 41, 43, 44, 51, 52, 53, 60, 69, 78],
     [ 7, 16, 25, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 44, 51, 52, 53, 61, 70, 79],
     [ 8, 17, 26, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 51, 52, 53, 62, 71, 80],
     [ 0,  9, 18, 27, 28, 29, 36, 37, 38, 46, 47, 48, 49, 50, 51, 52, 53, 54, 63, 72],
     [ 1, 10, 19, 27, 28, 29, 36, 37, 38, 45, 47, 48, 49, 50, 51, 52, 53, 55, 64, 73],
     [ 2, 11, 20, 27, 28, 29, 36, 37, 38, 45, 46, 48, 49, 50, 51, 52, 53, 56, 65, 74],
     [ 3, 12, 21, 30, 31, 32, 39, 40, 41, 45, 46, 47, 49, 50, 51, 52, 53, 57, 66, 75],
     [ 4, 13, 22, 30, 31, 32, 39, 40, 41, 45, 46, 47, 48, 50, 51, 52, 53, 58, 67, 76],
     [ 5, 14, 23, 30, 31, 32, 39, 40, 41, 45, 46, 47, 48, 49, 51, 52, 53, 59, 68, 77],
     [ 6, 15, 24, 33, 34, 35, 42, 43, 44, 45, 46, 47, 48, 49, 50, 52, 53, 60, 69, 78],
     [ 7, 16, 25, 33, 34, 35, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 53, 61, 70, 79],
     [ 8, 17, 26, 33, 34, 35, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 62, 71, 80],
     [ 0,  9, 18, 27, 36, 45, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 72, 73, 74],
     [ 1, 10, 19, 28, 37, 46, 54, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 72, 73, 74],
     [ 2, 11, 20, 29, 38, 47, 54, 55, 57, 58, 59, 60, 61, 62, 63, 64, 65, 72, 73, 74],
     [ 3, 12, 21, 30, 39, 48, 54, 55, 56, 58, 59, 60, 61, 62, 66, 67, 68, 75, 76, 77],
     [ 4, 13, 22, 31, 40, 49, 54, 55, 56, 57, 59, 60, 61, 62, 66, 67, 68, 75, 76, 77],
     [ 5, 14, 23, 32, 41, 50, 54, 55, 56, 57, 58, 60, 61, 62, 66, 67, 68, 75, 76, 77],
     [ 6, 15, 24, 33, 42, 51, 54, 55, 56, 57, 58, 59, 61, 62, 69, 70, 71, 78, 79, 80],
     [ 7, 16, 25, 34, 43, 52, 54, 55, 56, 57, 58, 59, 60, 62, 69, 70, 71, 78, 79, 80],
     [ 8, 17, 26, 35, 44, 53, 54, 55, 56, 57, 58, 59, 60, 61, 69, 70, 71, 78, 79, 80],
     [ 0,  9, 18, 27, 36, 45, 54, 55, 56, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74],
     [ 1, 10, 19, 28, 37, 46, 54, 55, 56, 63, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74],
     [ 2, 11, 20, 29, 38, 47, 54, 55, 56, 63, 64, 66, 67, 68, 69, 70, 71, 72, 73, 74],
     [ 3, 12, 21, 30, 39, 48, 57, 58, 59, 63, 64, 65, 67, 68, 69, 70, 71, 75, 76, 77],
     [ 4, 13, 22, 31, 40, 49, 57, 58, 59, 63, 64, 65, 66, 68, 69, 70, 71, 75, 76, 77],
     [ 5, 14, 23, 32, 41, 50, 57, 58, 59, 63, 64, 65, 66, 67, 69, 70, 71, 75, 76, 77],
     [ 6, 15, 24, 33, 42, 51, 60, 61, 62, 63, 64, 65, 66, 67, 68, 70, 71, 78, 79, 80],
     [ 7, 16, 25, 34, 43, 52, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 71, 78, 79, 80],
     [ 8, 17, 26, 35, 44, 53, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 78, 79, 80],
     [ 0,  9, 18, 27, 36, 45, 54, 55, 56, 63, 64, 65, 73, 74, 75, 76, 77, 78, 79, 80],
     [ 1, 10, 19, 28, 37, 46, 54, 55, 56, 63, 64, 65, 72, 74, 75, 76, 77, 78, 79, 80],
     [ 2, 11, 20, 29, 38, 47, 54, 55, 56, 63, 64, 65, 72, 73, 75, 76, 77, 78, 79, 80],
     [ 3, 12, 21, 30, 39, 48, 57, 58, 59, 66, 67, 68, 72, 73, 74, 76, 77, 78, 79, 80],
     [ 4, 13, 22, 31, 40, 49, 57, 58, 59, 66, 67, 68, 72, 73, 74, 75, 77, 78, 79, 80],
     [ 5, 14, 23, 32, 41, 50, 57, 58, 59, 66, 67, 68, 72, 73, 74, 75, 76, 78, 79, 80],
     [ 6, 15, 24, 33, 42, 51, 60, 61, 62, 69, 70, 71, 72, 73, 74, 75, 76, 77, 79, 80],
     [ 7, 16, 25, 34, 43, 52, 60, 61, 62, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 80],
     [ 8, 17, 26, 35, 44, 53, 60, 61, 62, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79]]

  def self.empty_board
    (1..81).map { |c| Array(1..9) }
  end
  
  def self.from_s s
    raise "Invalid board" if s.length != 81
    bd = empty_board
    s.scan(/./).each_with_index do |char,i|
      c = char.to_i
      if c != 0 then assign( bd, i, c ) end
    end
    completed = bd.count { |c| c.length == 1 }
    # puts "loaded #{completed}"
    bd
  end
  
  def self.to_s bd
    bd.map { |c| c[0].to_s }.join
  end
[0]
  def self.solve bd
    return bd if complete? bd
    next_boards( bd ) do |b|
      solution = solve b
      solution and return solution
    end
    false
  end
  
  def self.complete? bd
    bd.all? { |c| c.length == 1 }
  end

  def self.assign( bd, pos, val )
    # puts "[#{pos}] = #{val}"
    bd[pos] = [val]
    eliminate_from_peers( bd, pos, val )
  end

  def self.eliminate_from_peers( bd, pos, val )
    PEERS[pos].all? { |p| eliminate( bd, p, val ) }
  end
  
  def self.eliminate( bd, pos, val )
    # Calling Array#delete returns the last object
    # deleted or nil if the object was not found
    if bd[pos].delete val
      # If a value was successfully removed then
      # we need to check the number of values remaining
      case bd[pos].length
        when 0 
          # an empty cell is a always a contradiction
          return false  
        when 1
          # If the cell only has a single value then
          # that value must be eliminated from the peers
          # puts "[#{pos}] = #{val} by constraint 1"
          return false unless eliminate_from_peers( bd, pos, bd[pos][0] )
      end
      # If there is only one place that a value
      # can go then assign it there
      UNITS.each do |unit|
        # puts "#{unit}"
        (1..9).each do |digit|
          cells = unit.select { |cell| bd[cell].include? digit }
          if cells.length == 1 and bd[cells[0]].length > 1
            pos = cells[0]
            # puts "[#{pos}] = #{digit} by constraint 2"
            return assign( bd, cells[0], digit )
          end
        end
      end
    end
    true
  end

  def self.next_boards bd
    # puts "next_boards #{to_s(bd)}"
    mrv = minimum_remaining_values bd
    bd[mrv].each do |guess|
      # puts "guess [#{mrv}] = #{guess} #{bd[mrv]}"
      newbd = bd.map( &:dup )
      assign( newbd, mrv, guess ) and yield newbd
    end
  end
  
  # Given a board return the index of (one of) the entries
  # with the least number of possible values remaining
  # (but excluding solved locations).  This strategy should
  # reduce the search space most quickly.  eg. if there are 
  # only two possible values remaining for a cell then we
  # have a 50:50 chance of being correct
    
  def self.minimum_remaining_values bd
    min_remain = bd.select { |c| c.length > 1 }.min_by( &:length ).length
    bd.index { |c| c.length == min_remain }
  end

end

ARGF.each_line do |line|
  p line.chomp
  p SudokuSolver.to_s SudokuSolver.solve SudokuSolver.from_s line.chomp
end


