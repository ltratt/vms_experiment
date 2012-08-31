require "./mda.rb"

class Record_Type
  attr_accessor :record_Comp
  attr_accessor :discr
  attr_accessor :enum_Comp
  attr_accessor :int_Comp
  attr_accessor :string_Comp
  attr_accessor :enum_Comp_2
  attr_accessor :string_Comp_2
  attr_accessor :char_Comp_1
  attr_accessor :char_Comp_2
end

class Dhry #< GlobalVariables
  attr_accessor :number_Of_Runs

  def initialize()
    #super()

    #/* copied from DhrystoneConstants*
    @Ident_1     = 0
    @Ident_2     = 1
    @Ident_3     = 2
    @Ident_4     = 3
    @Ident_5     = 4
    #/*end*/

    #/* copied from GlobalVariables */
    @Record_Glob = nil
    @Next_Record_Glob = nil
    @Int_Glob = nil

    @Bool_Glob = false
    
    @Char_Glob_1 = 'A'[0]
    @Char_Glob_2 = 'A'[0]

    @Array_Glob_1 = Array.new(128, 0)

    @Array_Glob_2 = MultiDimArray(128,128)

    @First_Record = Record_Type.new()
    @Second_Record = Record_Type.new()
    #/*end*/

  end
  def execute()
    
    int_Loc_3_Ref = Array.new(1, 0.0); 
    int_Loc_1_Ref = Array.new(1, 0.0); 
    
    enum_Loc = Array.new(1, 0.0); 
    

    
    @Next_Record_Glob = @Second_Record
    @Record_Glob = @First_Record
    @Record_Glob.record_Comp = @Next_Record_Glob
    @Record_Glob.discr = @Ident_1
    @Record_Glob.enum_Comp = @Ident_3
    @Record_Glob.int_Comp = 40
    @Record_Glob.string_Comp = "DHRYSTONE PROGRAM, SOME STRING"
    string_Loc_1 = "DHRYSTONE PROGRAM, 1'ST STRING"
    puts("Execution starts, " + @number_Of_Runs.to_s + " runs through Dhrystone")
    begin_time = Time.now #System.currentTimeMillis()
# this loop cannot be expressed as a for-loop in Ruby.
# translated into while-do loop.
    run_Index = 1
    while run_Index <= @number_Of_Runs do
        proc_5()
        proc_4()
        int_Loc_1 = 2
        int_Loc_2 = 3
        string_Loc_2 = "DHRYSTONE PROGRAM, 2'ND STRING"
        enum_Loc[0] = @Ident_2
        @Bool_Glob = (not func_2(string_Loc_1, string_Loc_2))
        while int_Loc_1 < int_Loc_2 do
            int_Loc_3_Ref[0] = 5 * int_Loc_1 - int_Loc_2
            proc_7(int_Loc_1, int_Loc_2, int_Loc_3_Ref)
            int_Loc_1 += 1
        end
        int_Loc_3 = int_Loc_3_Ref[0]
        proc_8(@Array_Glob_1, @Array_Glob_2, int_Loc_1, int_Loc_3)
        proc_1(@Record_Glob)
# this loop cannot be expressed as a for-loop in Ruby.
# translated into while-do loop.
        char_Index = 65 #'A'[0]
        while char_Index <= @Char_Glob_2 do
            if enum_Loc[0] == func_1(char_Index, 67) then #67 = 'C'[0]
              proc_6(@Ident_1, enum_Loc)
            else
            end
          char_Index += 1
        end
        int_Loc_3 = int_Loc_2 * int_Loc_1
        int_Loc_2 = int_Loc_3 / int_Loc_1
        int_Loc_2 = 7 * (int_Loc_3 - int_Loc_2) - int_Loc_1
        int_Loc_1_Ref[0] = int_Loc_1
        proc_2(int_Loc_1_Ref)
        int_Loc_1 = int_Loc_1_Ref[0]
      run_Index += 1
    end
    end_time = Time.now #System.currentTimeMillis()
    total_time = end_time - begin_time
    puts("total time: " + (total_time.to_f).to_s + "sec") # * 1000 
    puts("Result: " + (@number_Of_Runs / total_time.to_f).to_s + " dhrystone/sec.")
    puts("VAX MIPS: "+ ((@number_Of_Runs / total_time.to_f) / 1757).to_s)
  end

  def proc_1(pointer_Par_Val)
    next_Record = pointer_Par_Val.record_Comp; 
    pointer_Par_Val.record_Comp = @Record_Glob
    pointer_Par_Val.int_Comp = 5
    next_Record.int_Comp = pointer_Par_Val.int_Comp
    next_Record.record_Comp = pointer_Par_Val.record_Comp
    proc_3(next_Record.record_Comp)
    int_Ref = Array.new(1, 0.0); 
    if next_Record.discr == @Ident_1 then
        next_Record.int_Comp = 6
        int_Ref[0] = next_Record.enum_Comp
        proc_6(pointer_Par_Val.enum_Comp, int_Ref)
        next_Record.enum_Comp = int_Ref[0]
        next_Record.record_Comp = @Record_Glob.record_Comp
        int_Ref[0] = next_Record.int_Comp
        proc_7(next_Record.int_Comp, 10, int_Ref)
        next_Record.int_Comp = int_Ref[0]
    else
      pointer_Par_Val = pointer_Par_Val.record_Comp
    end
  end

  def proc_2(int_Par_Ref)
    
    
    int_Loc = int_Par_Ref[0] + 10
    enum_Loc = 0
    if (@Char_Glob_1 == 65) then # 'A'[0]) then
    int_Loc -= 1;
    int_Par_Ref[0] = int_Loc - int_Glob;
    enum_Loc = @Ident_1;
    end while (enum_Loc != @Ident_1)
  end

  def proc_3(pointer_Par_Ref)
    if @Record_Glob !=  nil  then
      pointer_Par_Ref = @Record_Glob.record_Comp
    else
      @int_Glob = 100
    end
    int_Comp_Ref = Array.new(1, 0.0); 
    int_Comp_Ref[0] = @Record_Glob.int_Comp
    proc_7(10, @int_Glob, int_Comp_Ref)
    @Record_Glob.int_Comp = int_Comp_Ref[0]
  end

  def proc_4()
    
    bool_Loc = (@Char_Glob_1 == 65) #'A'[0]
    bool_Loc = bool_Loc or @Bool_Glob
    @Char_Glob_2 = 66 #'B'[0]
  end

  def proc_5()
    @Char_Glob_1 = 65 #'A'[0]
    @Bool_Glob = false
  end

  def proc_6(enum_Par_Val, enum_Par_Ref)
    enum_Par_Ref[0] = enum_Par_Val
    if not func_3(enum_Par_Val) then
      enum_Par_Ref[0] = @Ident_4
    else
    end
    case enum_Par_Val
    when @Ident_1
      enum_Par_Ref[0] = @Ident_1
    when @Ident_2
      if @int_Glob > 100 then
        enum_Par_Ref[0] = @Ident_1
      else
        enum_Par_Ref[0] = @Ident_4
      end
    when @Ident_3
      enum_Par_Ref[0] = @Ident_2
    #when @Ident_4
    #  break
    when @Ident_5
      enum_Par_Ref[0] = @Ident_3
    end
  end

  def proc_7(int_Par_Val1, int_Par_Val2, int_Par_Ref)
    
    int_Loc = int_Par_Val1 + 2
    int_Par_Ref[0] = int_Par_Val2 + int_Loc
  end

  def proc_8(array_Par_1_Ref, array_Par_2_Ref, int_Par_Val_1, int_Par_Val_2)
    
    int_Loc = int_Par_Val_1 + 5
    array_Par_1_Ref[int_Loc] = int_Par_Val_2
    array_Par_1_Ref[int_Loc + 1] = array_Par_1_Ref[int_Loc]
    array_Par_1_Ref[int_Loc + 30] = int_Loc
# this loop cannot be expressed as a for-loop in Ruby.
# translated into while-do loop.
    int_Index = int_Loc
    while int_Index <= int_Loc + 1 do
      array_Par_2_Ref[int_Loc][int_Index] = int_Loc
      int_Index += 1
    end
    array_Par_2_Ref[int_Loc][int_Loc - 1] += 1
    array_Par_2_Ref[int_Loc + 20][int_Loc] = array_Par_1_Ref[int_Loc]
    @int_Glob = 5
  end

  def func_1(char_Par_1_Val, char_Par_2_Val)
    
    char_Loc_1 = char_Par_1_Val
    char_Loc_2 = char_Loc_1
    if char_Loc_2 != char_Par_2_Val then
      return @Ident_1
    else
      return @Ident_2
    end
  end

  def func_2(string_Par_1_Ref, string_Par_2_Ref)
    
    char_Loc = 0 #'\0'[0] 
    int_Loc = 2
    while int_Loc <= 2 do
      if func_1(string_Par_1_Ref[int_Loc], string_Par_2_Ref[int_Loc + 1]) == @Ident_1 then
          char_Loc = 65 #'A'[0]
          int_Loc += 1
      else
      end
    end
    if char_Loc >= 87 and #'W'[0] and
        char_Loc < 90 then #'Z'[0] then
      int_Loc = 7
    else
    end
    if char_Loc == 88 then # 'X'[0] then
      return true
    else
        if string_Par_1_Ref > string_Par_2_Ref then
            int_Loc += 7
            return true
        else
          return false
        end
    end
  end

  def func_3(enum_Par_Val)
    
    enum_Loc = enum_Par_Val
    if enum_Loc == @Ident_3 then
      return true
    else
      return false
    end
  end

  def run()
    execute()
    if @exitObserver !=  nil  then
        @exitObserver.exitNotify()
    else
    end
  end

  def setExitObserver(eo)
    @exitObserver = eo
  end

end

  def main(argv)
    ##Msg.out = System.err
    puts("Dhrystone Benchmark, Version 2.1 (Language: Ruby)")
    puts("")
    print("Please give the number of runs through the benchmark: ")
    dh = Dhry.new(); 
    num = 1000000
    line = ARGV.shift
    if line.to_i > 0 then
      num = line.to_i
    else 
      puts("No input. Using default value(1000000)...")
    end
    dh.number_Of_Runs = num
    dh.execute()
  end

main(ARGV)
