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
            scheduling_requirement = scheduler.scheduling_requirements.last
            response.body.should eql(scheduling_requirement.profile.to_json)
            scheduling_requirement.count.should == 20
            scheduling_requirement.profile.assignment.should == 'All: 2 A'
          end
        end
      end
    end
  end
  # remove_profile_api_v3_generic_scheduler POST   /api/v3/generic_schedulers/:id/remove_profile(.:format)           api/v3/generic_schedulers#remove_profile
  #       add_role_api_v3_generic_scheduler POST   /api/v3/generic_schedulers/:id/add_role(.:format)                 api/v3/generic_schedulers#add_role
  #    remove_role_api_v3_generic_scheduler POST   /api/v3/generic_schedulers/:id/remove_role(.:format)              api/v3/generic_schedulers#remove_role
  #               api_v3_generic_schedulers GET    /api/v3/generic_schedulers(.:format)                              api/v3/generic_schedulers#index
  #                                         POST   /api/v3/generic_schedulers(.:format)                              api/v3/generic_schedulers#create
  #                api_v3_generic_scheduler GET    /api/v3/generic_schedulers/:id(.:format)                          api/v3/generic_schedulers#show
  #                                         PATCH  /api/v3/generic_schedulers/:id(.:format)                          api/v3/generic_schedulers#update
  #                                         PUT    /api/v3/generic_schedulers/:id(.:format)                          api/v3/generic_schedulers#update
  #                                         DELETE /api/v3/generic_schedulers/:id(.:format)
end