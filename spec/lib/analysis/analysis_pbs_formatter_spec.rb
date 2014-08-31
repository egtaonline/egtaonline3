require 'analysis'

describe AnalysisPbsFormatter do
  module Backend
  end
  before(:each) do
    @formatter = AnalysisPbsFormatter.new("example@example.com", "1", "2", "10", "4000", "mb")
  end
  describe "#initialize" do
    it "sets right format of walltime" do
      @formatter.instance_variable_get(:@walltime).should eq "26:10:00"
    end
    it "sets right format of memory" do
      @formatter.instance_variable_get(:@memory).should eq "4000mb"
    end
  end

  describe "#write_pbs" do
    it "writes the pbs into file" do
      path = "path"
      pbs = double("pbs")
      f = double('file')     
      File.should_receive(:open).with("#{path}", 'w', 0770).and_yield(f)
      f.should_receive(:write).with(pbs)
      @formatter.write_pbs(pbs, path)
    end
  end
  describe "#submit" do 
    context "when connection to flux lost" do
      it "returns lost connection message" do
        pbs_path = "pbs_path"
        connection = double("connection")
        proxy = nil
        Backend.stub(:connection).and_return(connection)
        connection.stub(:acquire).and_return(proxy)
        
        proxy = Backend.connection.acquire      
        @formatter.submit(pbs_path).should eq("Lost connection to flux")
      end
    end
    context "when exec succeeds" do
      it "returns right response message" do
        pbs_path = "pbs_path"
        connection = double("connection")
        proxy = double("proxy")
        response = double("response")
        Backend.stub(:connection).and_return(connection)
        connection.stub(:acquire).and_return(proxy)
        proxy = Backend.connection.acquire
        proxy.should_receive(:exec!).with("qsub -V -r n #{pbs_path}").and_return(response)     
        @formatter.submit(pbs_path).should == response
      end
    end

    context "when exec raises error" do
      it "returns right response message" do
        pbs_path = "pbs_path"
        connection = double("connection")
        proxy = double("proxy")
        Backend.stub(:connection).and_return(connection)
        connection.stub(:acquire).and_return(proxy)
        proxy = Backend.connection.acquire
        proxy.should_receive(:exec!).with("qsub -V -r n #{pbs_path}").and_raise("submit failed")     
        @formatter.submit(pbs_path).should == "submit failed"
      end
    end
  end
  describe "#prepare_pbs" do 
    it "prepares the right pbs" do
      pbs_error_file = "pbs_error_file"
      pbs_output_file = "pbs_output_file"
      set_up_remote_command = "set_up_remote_command"
      running_script_command = "running_script_command"
      clean_up_command = "clean_up_command"

      @formatter.prepare_pbs(pbs_error_file,pbs_output_file,set_up_remote_command,running_script_command,clean_up_command).should eq(
        "#!/bin/bash\n" \
        "#PBS -N analysis\n" \
        "\n" \
        "#PBS -A wellman_flux\n" \
        "#PBS -q flux\n" \
        "#PBS -l qos=flux\n" \
        "#PBS -W group_list=wellman\n" \
        "\n" \
        "#PBS -l walltime=26:10:00\n" \
        "#PBS -l nodes=1:ppn=1,pmem=4000mb\n" \
        "\n" \
        "#PBS -e pbs_error_file\n" \
        "#PBS -o pbs_output_file\n" \
        "\n" \
        "#PBS -M example@example.com\n" \
        "#PBS -m abe\n" \
        "#PBS -V\n" \
        "#PBS -W umask=0022\n" \
        "\n" \
        "umask 0022\n" \
        "\n" \
        "set_up_remote_command\n" \
        "running_script_command\n" \
        "clean_up_command\n")
    end
  end
end


