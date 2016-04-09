class BootstrapScript < ActiveRecord::Base
    belongs_to :analysis
    after_initialize :prepare
    
    def get_command
        "python #{@script_name} -input #{@path_obj.input_file_name} -output ./out/#{@path_obj.bootstrap_json_file_name} #{self.interval} #{self.points}"
    end
    
    def set_up_remote
        "cp -r #{@path_obj.scripts_path}/#{@script_name} #{@path_obj.working_dir}"
    end
    
    private

    def prepare
        @script_name = "Bootstrap.py"
        @path_obj = AnalysisPathFinder.new(Analysis.find(analysis_id).game_id.to_s, analysis_id.to_s, "/mnt/nfs/home/egtaonline","/nfs/wellman_ls")
    end

    def set_output_file(output_file_name)
        @output_file_name = output_file_name
    end

end