# -*- coding: utf-8 -*-
def MultiDimArray_i(x, xs)
  #puts "x:"+x.to_s
  #puts "xs:"+ (xs.join(","))
  array = Array.new(x, 0.0)
  if xs.size > 0 then
    array.each_index{ |y|
      array[y] = MultiDimArray_i(xs[0], xs[1..-1]);
    }
  end
  return array
end
def MultiDimArray(x, *xs)
  #puts "x:"+x.to_s
  #puts "xs:"+ (xs.join(","))
  array = Array.new(x)
  if xs.size > 0 then
    array.each_index{ |y|
      array[y] = MultiDimArray_i(xs[0], xs[1..-1]);
    }
  end
  return array
end
