require 'spec_helper'

describe Analysis do
  # pending "add some examples to (or delete) #{__FILE__}"

  it "validates a working factory" do
  	create(:analysis, :running_status).should be_valid
  end

  describe '#active' do
  	it "returns array of active and running status" do
	  	create(:analysis, :running_status)
  		create(:analysis, :pending_status)
  		create(:analysis, :queued_status)
  		create(:analysis, :failed_status)

  		expect(Analysis.active.length).to eq(2)
  	end
  end

  describe '#queueable' do
  	it "returns an array of pending analysis sorted descending by creation" do
  		create_list(:analysis, 6, :pending_status)

  		expect(Analysis.queueable.length).to eq(5)
  		Analysis.queueable.each { |x|
  			expect(x.status).to eq('pending')
  		}
  	end
  end

  describe '#fail' do
  	let(:analysis) {create(:analysis, :running_status)}
  	it 'updates a record with an error and fail message' do  		
  		error_message = "fake_error"
  		analysis.fail(error_message)
  		expect(analysis.reload.status).to eq('failed')
  	end
  end

  describe '#queue_as' do
  	it 'updates a record if its job has been queued' do 
  		analysis = create(:analysis, :pending_status)
  		expect(analysis.status).to eq('pending')
  		id = analysis.id
  		analysis.queue_as(298)

  		confirm = Analysis.find(id)
  		expect(confirm.status).to eq('queued')
		expect(confirm.job_id).to eq(298)
  	end
  end

  describe '#start' do
  	it 'changes waiting jobs to running' do	
  		analysis = create(:analysis, :queued_status)
  		analysis.start
  		
  		expect(analysis.reload.status).to eq('running')
  	end	
  end

  describe '#finish' do 
  	it 'changes status of finished jobs' do
  		analysis = create(:analysis, :queued_status)
  		analysis2 = create(:analysis, :failed_status)
  		expect(analysis.status).to eq('queued')
  		expect(analysis2.status).to eq('failed')
  		analysis.finish
  		analysis2.finish

  		expect(analysis.reload.status).to eq('complete')
  		expect(analysis2.reload.status).not_to eq('complete')
  	end
  end


  #Change the debugging paths and make it pass
  describe '#process' do
    let(:AnalysisDataParser){double('AnalysisDataParser')}
    it 'changes queued and running to processing and parses the data' do
      analysis2 = create(:analysis, :running_status)
      analysis2.process  
      expect(analysis2.reload.error_message).to eq('Incorrect analysis output,')
      expect(analysis2.reload.status).to eq('failed')
    end
  end
end