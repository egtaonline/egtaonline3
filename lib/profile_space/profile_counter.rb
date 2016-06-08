class ProfileCounter 

  def self.num_profiles(klass, counts, strategies, deviating_strategies)
    roles = []
    for i in 0...counts.length
      roles.push(i)
    end

    if klass == GameScheduler || klass == HierarchicalScheduler || klass == DeviationScheduler || klass == HierarchicalDeviationScheduler
      total1 = 1
      total2 = 0
      for r in roles
        total1 *= ((strategies[r])..(counts[r]+strategies[r]-1)).inject(:*)/(1..counts[r]).inject(:*)
        intermediate = 1
        for r_a in roles
          s = strategies[r_a]
          n = counts[r_a]
          if r == r_a
            n -= 1
          end
          if n > 0
            intermediate *= ((s)..(n+s-1)).inject(:*)/(1..n).inject(:*)
          end
        end
        total2 += deviating_strategies[r] * intermediate
      end
      return total1 + total2
 
    elsif klass == DprScheduler || klass == DprDeviationScheduler
      total1 = 0
      total3 = 0
      for r in roles
        intermediate = 1
        for r_a in roles
          s = strategies[r_a]
          n = counts[r_a]
          if r == r_a
            n -= 1
          end
          if n > 0
            intermediate *= ((s)..(n+s-1)).inject(:*)/(1..n).inject(:*)
          end
        end
        total1 += strategies[r] * intermediate
        total3 += deviating_strategies[r] * intermediate
      end
  
      pset = []
      for i in 2..roles.length
        pset.concat(roles.combination(i).to_a)
      end
      total2 = 0
      for set in pset
        inter1 = 1
        for r in set
          inter2 = 1
          others = roles - set
          for r_a in others
            n = counts[r_a]
            s = strategies[r_a]
            inter2 *= ((s)..(n+s-1)).inject(:*)/(1..n).inject(:*) - s
          end
          inter1 *= strategies[r] * inter2
        end
        total2 += (set.length - 1) * inter1
      end  
  
      total4 = 0
      for r in roles
        inter1 = 0 
        for r_a in roles
          inter2 = 1
          for r_b in roles
            s = strategies[r_b]
            n = counts[r_b]
            if r == r_b
              n -= 1
            end
            if r_a == r_b
              n -= 1
            end
            if n == -1
              inter2 *= 0
            elsif n > 0
              inter2 *= ((s)..(n+s-1)).inject(:*)/(1..n).inject(:*)
            end
          end
          inter1 += strategies[r_a] * inter2
        end
        total4 += deviating_strategies[r] * inter1
      end 
  
      return total1 - total2 + total3 + total4  

    end
  end
end
