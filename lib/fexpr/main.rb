module FExpr

  class Main

    def main(argv)
      puts real_main argv
    end

    # Void -> String
    def real_main(argv)

      # maybe help
      print_help and return 0 if argv.empty?
      
      # maybe testing
      run_test and return if argv[0] == '-test'
      if argv[0][0..0] == '-'
        @opt_trace = true
        argv.shift
      end
      
      # cleanse the arguments
      args = argv.map {|arg| arg.gsub /,/,''}
      
      # run
      evaluator = Evaluator.new args
      evaluator.eval
    end
    
    private
    
    def print_help
      puts '***************************************************'
      puts 'Replace integer (or int) with floating point number'
      puts 'And forget about the \':\' operator'
      puts '***************************************************'
      sleep 2
      system 'man', 'expr'
      true
    end
  end
end
