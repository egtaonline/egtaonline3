require 'spec_helper'

describe 'GenericSchedulersController' do
  let(:user) { FactoryGirl.create(:approved_user) }
  let(:token) { user.authentication_token }

  describe 'POST /api/v3/generic_schedulers/:id/add_profile' do
    let(:url){ '/api/v3/generic_schedulers/1/add_profile' }
    let(:query){ { auth_token: token, assignment: 'All: 2 A', count: 20 } }

    context 'when the scheduler does not exist' do
      it "returns an appropriate 404" do
        post "#{url}.json", query
        response.status.should eql(404)
        response.body.should eql({error:
          "the GenericScheduler you were looking for could" +
          " not be found"}.to_json)
      end
    end
    context 'when the scheduler exists' do
      let!(:scheduler){ FactoryGirl.create(:generic_scheduler, id: 1) }

      before do
        scheduler.simulator.add_role('All')
        scheduler.simulator.add_strategy('All', 'A')
      end

      context 'and a specified role does not exist on the scheduler' do
        it "returns an appropriate 422" do
          post "#{url}.json", query
          response.status.should eql(422)
          response.body.should eql({errors: { assignment:
            ["cannot be scheduled by this Scheduler due to mismatch on" +
            " role partition"]}}.to_json)
        end
      end
      context 'and the specified roles exist on the scheduler' do
        before do
          scheduler.add_role('All', 2)
        end
        context 'but a specified strategy does not exist on the simulator' do
          before do
            scheduler.simulator.remove_strategy('All', 'A')
          end
          it "returns an appropriate 422" do
            post "#{url}.json", query
            response.status.should eql(422)
            response.body.should eql({errors: {assignment: ["A is not present" +
              " in the Simulator"]}}.to_json)
          end
        end

        context 'and the assignment is valid' do
          it "returns the Profile and creates a SchedulingRequirement" do
            post "#{url}.json", query
            response.status.should eql(201)
            scheduler.reload
            scheduling_requirement = scheduler.scheduling_requirements.last
            scheduling_requirement.count.should == 20
            scheduling_requirement.profile.assignment.should == 'All: 2 A'
          end
        end
      end
    end
  end

  describe 'POST /api/v3/generic_schedulers/:id/remove_profile' do
    let(:url){ '/api/v3/generic_schedulers/1/remove_profile' }
    let(:query){ { auth_token: token, profile_id: 1 } }

    context 'when the scheduler does not exist' do
      it "returns an appropriate 404" do
        post "#{url}.json", query
        response.status.should eql(404)
        response.body.should eql({error:
          "the GenericScheduler you were looking for could" +
          " not be found"}.to_json)
      end
    end

    context 'when the scheduler does exist' do
      let!(:scheduler){ FactoryGirl.create(:generic_scheduler, id: 1) }

      before do
        scheduler.simulator.add_strategy('All', 'A')
        scheduler.simulator.add_strategy('All', 'B')
        scheduler.add_role('All', 2)
        @to_be_destroyed = scheduler.add_profile('All: 2 A')
        @not_destroyed = scheduler.add_profile('All: 2 B')
      end

      it 'only destroys the SchedulingRequirement of the requested Profile' do
        post "#{url}.json", auth_token: token, profile_id: @to_be_destroyed.id
        response.status.should eql(204)
        Profile.count.should == 2
        scheduler.reload
        scheduler.scheduling_requirements.count.should == 1
        scheduler.scheduling_requirements.first.profile.should == @not_destroyed
      end
    end
  end

  describe 'GET /api/v3/generic_schedulers' do
    let!(:scheduler){ FactoryGirl.create(:generic_scheduler) }
    let!(:scheduler2){ FactoryGirl.create(:generic_scheduler) }
    let(:url){ '/api/v3/generic_schedulers' }

    it 'returns summary info for the available schedulers' do
      get "#{url}.json", auth_token: token
      response.status.should == 200
      response.body.should == { generic_schedulers: [scheduler.reload, scheduler2.reload] }.to_json
    end
  end

  describe 'POST /api/v3/generic_schedulers' do
    let(:url){ '/api/v3/generic_schedulers' }
    let(:simulator){ FactoryGirl.create(:simulator) }

    context "when everything is present as expected" do
      it "responds with the new scheduler" do
        post "#{url}.json", auth_token: token, scheduler: {
          simulator_id: simulator.id, name: "test", active: true,
          process_memory: 1000, size: 4, time_per_observation: 120,
          observations_per_simulation: 30, nodes: 1,
          default_observation_requirement: 30, configuration: { "A" => "B" }}
        scheduler = GenericScheduler.last
        scheduler.simulator.should == simulator
        scheduler.simulator_instance.configuration.should == { "A" => "B" }
        response.status.should eql(201)
        MultiJson.load(response.body)["id"].should eql(scheduler.id)
      end
    end

    context "when there are errors" do
      it "responds with those errors" do
        post "#{url}.json", auth_token: token, scheduler: {
          simulator_id: simulator.id, name: "test", active: true,
          size: 4, time_per_observation: 120,
          observations_per_simulation: 30, nodes: 1,
          default_observation_requirement: 30, configuration: { "A" => "B" }}
        response.status.should eql(422)
        errors = {"errors" => {"process_memory" =>
          ["can't be blank","is not a number"]}}.to_json
        response.body.should eql(errors)
      end
    end
  end

  describe 'GET /api/v3/generic_schedulers/:id' do
    let!(:scheduler){ FactoryGirl.create(:generic_scheduler, id: 1) }
    let(:url){ '/api/v3/generic_schedulers/1' }

    it 'returns the appropriate json from a SchedulerPresenter' do
      get "#{url}.json", auth_token: token, granularity: 'summary'
      response.status.should == 200
      response.body.should == SchedulerPresenter.new(scheduler.reload).to_json(
        granularity: 'summary')
    end
  end

  describe 'PUT /api/v3/generic_schedulers/:id' do
    let!(:scheduler){ FactoryGirl.create(:generic_scheduler, id: 1) }
    let(:url) { "/api/v3/generic_schedulers/1" }

    it "updates normally" do
      put "#{url}.json", :auth_token => token, :scheduler => {
        time_per_observation: 60}
      scheduler.reload
      scheduler.time_per_observation.should eql(60)
      response.status.should eql(204)
    end
  end

  describe 'DELETE /api/v3/generic_schedulers/:id' do
    let!(:scheduler){ FactoryGirl.create(:generic_scheduler, id: 1) }
    let(:url) { "/api/v3/generic_schedulers/1" }

    it 'deletes the scheduler' do
      delete "#{url}.json", :auth_token => token
      Scheduler.count.should == 0
      response.status.should eql(204)
    end
  end
end