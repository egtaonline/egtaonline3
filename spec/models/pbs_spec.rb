require 'spec_helper'

describe Pbs do
	before(:each) do
		@analysis = create(:analysis, :running_status)
		@params = {
		day: 0,
      	hour: 6,
      	minute: 0,
      	memory: 4000,
      	memory_unit: "mb",
      	user_email: "abc@d.com"
		}
		@analysis.create_pbs(@params)

		walltime = "#{sprintf('%02d',6)}:#{sprintf('%02d',0)}:00"
			output_file = "#{@analysis.game.id}-analysis-#{@analysis.id}-pbs.o"
			remote_path = File.join("/nfs/wellman_ls/","egtaonline","analysis", @analysis.game.id.to_s, @analysis.id.to_s, "pbs")
			output_path = File.join(remote_path, output_file)
			error_file = "#{@analysis.game.id}-analysis-#{@analysis.id}-pbs.e"
			error_path = File.join(remote_path, error_file)
			@com = <<-COM
#!/bin/bash
#PBS -N analysis-#{@analysis.id}

#PBS -A wellman_flux
#PBS -q flux
#PBS -l qos=flux
#PBS -W group_list=wellman

#PBS -l walltime=#{walltime}
#PBS -l nodes=1:ppn=1,pmem=4000mb

#PBS -e #{error_path}
#PBS -o #{output_path}

#PBS -M abc@d.com
#PBS -m abe
#PBS -V
#PBS -W umask=0022

umask 0022

abc
def
ghi
			COM

	end

	describe 'validate' do
		it 'validates the model' do
			@analysis.pbs.should be_valid
		end
	end

	describe '#prepare_pbs' do
		it 'prepares content of the pbs file' do			
			expect(@analysis.pbs.prepare_pbs("abc","def","ghi")).to eq(@com)
		end
	end

	describe '#format' do
		it 'saves content of pbs file' do
			@analysis.pbs.format("abc", "def", "ghi")
			expect(@analysis.pbs.reload.scripts).to eq(@com)
		end
	end
end
