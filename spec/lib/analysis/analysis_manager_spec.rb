require 'analysis'
describe AnalysisManager do

    let(:game) { double(id: 1) }
    let(:scripts_argument_setter_obj) {double("scripts_argument_setter_obj")}
    let(:pbs_formatter_obj) {double("pbs_formatter_obj")}
    let(:time) {Time.new(2007,8,1,16,53,0, "-04:00") }
    let(:format_time) {Time.new(2007,8,1,16,53,0, "-04:00").strftime('%Y%m%d%H%M%S%Z')}
    let(:path_finder) {AnalysisPathFinder.new(game.id.to_s, format_time,"/mnt/nfs/home/egtaonline","/nfs/wellman_ls")}

    describe '#initialize' do
      it "creates the manager correctly" do
        Time.stub(:now).and_return(time)     
        AnalysisPathFinder.stub(:new).with(game.id.to_s, format_time, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls").and_return(path_finder)
        scripts_argument_setter_obj.stub(:set_path).with(path_finder)
        @manager = AnalysisManager.new(game, scripts_argument_setter_obj, pbs_formatter_obj)
      end

      it "sets the time format correctly" do
        Time.stub(:now).and_return(time)     
        AnalysisPathFinder.stub(:new).with(game.id.to_s, format_time, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls").and_return(path_finder)
        scripts_argument_setter_obj.stub(:set_path).with(path_finder)
        @manager = AnalysisManager.new(game, scripts_argument_setter_obj, pbs_formatter_obj)
        @manager.time.should == format_time
      end

      it "sets the path finder object" do
        Time.stub(:now).and_return(time)     
        AnalysisPathFinder.stub(:new).with(game.id.to_s, format_time, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls").and_return(path_finder)
        scripts_argument_setter_obj.should_receive(:set_path).with(path_finder)
        @manager = AnalysisManager.new(game, scripts_argument_setter_obj, pbs_formatter_obj)
        @manager.instance_variable_get(:@path_finder).should == path_finder
      end
    end

    describe '#created_folder' do
      before(:each) do
        Time.stub(:now).and_return(time)     
        path_finder = AnalysisPathFinder.new("1", "20070108165300+04:00","/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
        AnalysisPathFinder.stub(:new).with(game.id.to_s, format_time, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls").and_return(path_finder) 
        scripts_argument_setter_obj.stub(:set_path).with(path_finder)
        @manager = AnalysisManager.new(game, scripts_argument_setter_obj, pbs_formatter_obj)     
      end

      it "creates the right folder" do
        FileUtils.should_receive(:mkdir_p).with("#{path_finder.local_output_path}", mode: 0770)
        FileUtils.should_receive(:mkdir_p).with("#{path_finder.local_input_path}", mode: 0770)
        FileUtils.should_receive(:mkdir_p).with("#{path_finder.local_pbs_path}", mode: 0770)
        FileUtils.should_receive(:mkdir_p).with("#{path_finder.local_subgame_path}", mode: 0770)
        @manager.send(:created_folder)
      end
    end

    describe '#prepare_input' do
      before(:each) do
        Time.stub(:now).and_return(time)     
        path_finder = AnalysisPathFinder.new("1", "20070108165300+04:00","/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
        AnalysisPathFinder.stub(:new).with(game.id.to_s, format_time, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls").and_return(path_finder) 
        scripts_argument_setter_obj.stub(:set_path).with(path_finder)
        @manager = AnalysisManager.new(game, scripts_argument_setter_obj, pbs_formatter_obj)     
      end

      it "prepares the input for the game" do
        scripts_argument_setter_obj.should_receive(:prepare_input).with(game)
        @manager.send(:prepare_input)
      end
    end

    describe '#set_script_arguments' do
      before(:each) do
        Time.stub(:now).and_return(time)     
        path_finder = AnalysisPathFinder.new("1", "20070108165300+04:00","/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
        AnalysisPathFinder.stub(:new).with(game.id.to_s, format_time, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls").and_return(path_finder) 
        scripts_argument_setter_obj.stub(:set_path).with(path_finder)
        @manager = AnalysisManager.new(game, scripts_argument_setter_obj, pbs_formatter_obj)     
      end

      it "sets the scripts command" do
        set_up_remote_command = "set_up_remote_command"
        running_script_command = "running_script_command"
        clean_up_remote_command = "clean_up_remote_command"
        scripts_argument_setter_obj.should_receive(:set_up_remote_command).and_return(set_up_remote_command)
        scripts_argument_setter_obj.should_receive(:get_script_command).and_return(running_script_command)
        scripts_argument_setter_obj.should_receive(:clean_up_remote_command).and_return(clean_up_remote_command)
        @manager.send(:set_script_arguments)
        @manager.instance_variable_get(:@set_up_remote_command).should == "set_up_remote_command"
        @manager.instance_variable_get(:@running_script_command).should == "running_script_command"
        @manager.instance_variable_get(:@clean_up_command).should == "clean_up_remote_command"
      end
    end

    describe '#submit_job' do
      before(:each) do
        Time.stub(:now).and_return(time)     
        path_finder = AnalysisPathFinder.new("1", "20070108165300+04:00","/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
        AnalysisPathFinder.stub(:new).with(game.id.to_s, format_time, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls").and_return(path_finder) 
        scripts_argument_setter_obj.stub(:set_path).with(path_finder)
        @manager = AnalysisManager.new(game, scripts_argument_setter_obj, pbs_formatter_obj)     
      end

      it "prepares the pbs file" do
        set_up_remote_command = "set_up_remote_command"
        running_script_command = "running_script_command"
        clean_up_remote_command = "clean_up_remote_command"
        scripts_argument_setter_obj.stub(:set_up_remote_command).and_return(set_up_remote_command)
        scripts_argument_setter_obj.stub(:get_script_command).and_return(running_script_command)
        scripts_argument_setter_obj.stub(:clean_up_remote_command).and_return(clean_up_remote_command)
        @manager.send(:set_script_arguments)
        pbs_formatter_obj.should_receive(:prepare_pbs).with(File.join(path_finder.remote_pbs_path, path_finder.pbs_error_file), File.join(path_finder.remote_pbs_path,path_finder.pbs_output_file), set_up_remote_command, running_script_command, clean_up_remote_command)
        pbs_formatter_obj.stub(:write_pbs)
        pbs_formatter_obj.stub(:submit)
        @manager.send(:submit_job)
      end

      it "writes pbs to the right path" do
        set_up_remote_command = "set_up_remote_command"
        running_script_command = "running_script_command"
        clean_up_remote_command = "clean_up_remote_command"
        pbs_file = double("pbs_file")
        scripts_argument_setter_obj.stub(:set_up_remote_command).and_return(set_up_remote_command)
        scripts_argument_setter_obj.stub(:get_script_command).and_return(running_script_command)
        scripts_argument_setter_obj.stub(:clean_up_remote_command).and_return(clean_up_remote_command)
        @manager.send(:set_script_arguments)
        pbs_formatter_obj.stub(:prepare_pbs).with(File.join(path_finder.remote_pbs_path, path_finder.pbs_error_file), File.join(path_finder.remote_pbs_path,path_finder.pbs_output_file), set_up_remote_command, running_script_command, clean_up_remote_command).and_return(pbs_file)
        pbs_formatter_obj.should_receive(:write_pbs).with(pbs_file, File.join("#{path_finder.local_pbs_path}","#{path_finder.pbs_file_name}"))
        pbs_formatter_obj.stub(:submit)
        @manager.send(:submit_job)
      end

      it "submits the job" do
        set_up_remote_command = "set_up_remote_command"
        running_script_command = "running_script_command"
        clean_up_remote_command = "clean_up_remote_command"
        pbs_file = double("pbs_file")
        scripts_argument_setter_obj.stub(:set_up_remote_command).and_return(set_up_remote_command)
        scripts_argument_setter_obj.stub(:get_script_command).and_return(running_script_command)
        scripts_argument_setter_obj.stub(:clean_up_remote_command).and_return(clean_up_remote_command)
        @manager.send(:set_script_arguments)
        pbs_formatter_obj.stub(:prepare_pbs).with(File.join(path_finder.remote_pbs_path, path_finder.pbs_error_file), File.join(path_finder.remote_pbs_path,path_finder.pbs_output_file), set_up_remote_command, running_script_command, clean_up_remote_command).and_return(pbs_file)
        pbs_formatter_obj.stub(:write_pbs).with(pbs_file, File.join("#{path_finder.local_pbs_path}","#{path_finder.pbs_file_name}"))
        pbs_formatter_obj.should_receive(:submit).with(File.join("#{path_finder.remote_pbs_path}","#{path_finder.pbs_file_name}"))
        @manager.send(:submit_job)
      end
    end
end

