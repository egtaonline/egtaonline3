require "spec_helper"

describe SimulatorsController do
  describe "routing" do

    it "routes to #index" do
      get("/simulators").should route_to("simulators#index")
    end

    it "routes to #new" do
      get("/simulators/new").should route_to("simulators#new")
    end

    it "routes to #show" do
      get("/simulators/1").should route_to("simulators#show", :id => "1")
    end

    it "routes to #edit" do
      get("/simulators/1/edit").should route_to("simulators#edit", :id => "1")
    end

    it "routes to #create" do
      post("/simulators").should route_to("simulators#create")
    end

    it "routes to #update" do
      put("/simulators/1").should route_to("simulators#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/simulators/1").should route_to("simulators#destroy", :id => "1")
    end

  end
end
