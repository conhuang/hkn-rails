require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe AlumnisController do
  before :each do login_as_officer('alumrel'=>true) end

  def mock_alumni(stubs={})
    @mock_alumni ||= double(Alumni, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all alumnis as @alumnis" do
      allow(Alumni).to receive(:all) { [mock_alumni] }
      get :index
      assigns(:alumnis).should eq([mock_alumni])
    end
  end

  describe "GET show" do
    it "assigns the requested alumni as @alumni" do
      allow(Alumni).to receive(:find).with("37") { mock_alumni }
      get :show, id: "37"
      assigns(:alumni).should be(mock_alumni)
    end
  end

  describe "GET new" do
    it "assigns a new alumni as @alumni" do
      allow(Alumni).to receive(:new) { mock_alumni }
      get :new
      assigns(:alumni).should be(mock_alumni)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created alumni as @alumni" do
        post :create, alumni: {person_id: 1},
                      grad_season: "Fall",
                      grad_year: 1945
        expect(assigns(:alumni).person_id).to be(1)
        expect(assigns(:alumni).grad_semester).to eq("Fall 1945")
      end

      it "redirects to the created alumni" do
        allow(@current_user).to receive(:save).and_return true
        post :create, alumni: {
                        person_id: 9999,
                        perm_email: "derp@derp.com"
                      },
                      grad_season: "Fall",
                      grad_year: 1945

        response.should redirect_to(alumni_url(assigns(:alumni)))
      end
    end

    describe "with invalid params" do
      before :each do
        allow(@current_user).to receive(:alumni=)
      end

      it "assigns a newly created but unsaved alumni as @alumni" do
        post :create, alumni: {'these' => 'params'},
                      grad_season: "Fall",
                      grad_year: 1945
        expect(assigns(:alumni).save).not_to be(true)
      end

      it "re-renders the 'new' template" do
        post :create, alumni: {"these" => "params"},
                      grad_season: "Fall",
                      grad_year: 1945
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    let(:alum) do
      Alumni.new({id: 37, person_id: 9999,
                  grad_semester: "Fall 1944",
                  perm_email: "derp@derp.com"})
    end
    describe "with valid params" do

      it "updates the requested alumni" do
        allow(Alumni).to receive(:find).with(
          :first,
          {conditions: "\"alumnis\".person_id = 9999"}
        ) { alum }
        allow(Alumni).to receive(:find).with("37") { alum }

        expect(alum).to receive(:update_attributes).with(
          { "person_id" => "9999", "grad_semester" => "Fall 1945" }
        )

        put :update, id: "37",
                     alumni: { person_id: 9999 },
                     grad_season: "Fall",
                     grad_year: 1945

      end

      it "assigns the requested alumni as @alumni" do
        allow(Alumni).to receive(:find) { alum }
        put :update, id: "37",
                     alumni: { person_id: 9999 },
                     grad_season: 'Fall',
                     grad_year: 1945
        assigns(:alumni).should be(alum)
      end

      it "redirects to the alumni" do
        allow(Alumni).to receive(:find) { alum }
        put :update, id: "37",
                     alumni: { person_id: 9999 },
                     grad_season: 'Fall',
                     grad_year: 1945
        response.should redirect_to(alumni_url(alum))
      end
    end

    describe "with invalid params" do
      it "assigns the alumni as @alumni" do
        allow(Alumni).to receive(:find) { alum }
        put :update, id: "37",
                     alumni: { salary: -100 },
                     grad_season: 'Fall',
                     grad_year: 1945
        assigns(:alumni).should be(alum)
      end

      it "re-renders the 'edit' template" do
        allow(Alumni).to receive(:find) { alum }
        put :update, id: "37",
                     alumni: { salary: -100 },
                     grad_season: 'Fall',
                     grad_year: 1945
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested alumni" do
      allow(Alumni).to receive(:find).with("37") { mock_alumni }
      expect(mock_alumni).to receive(:destroy)
      delete :destroy, id: "37"
    end

    it "redirects to the alumnis list" do
      allow(Alumni).to receive(:find) { mock_alumni }
      delete :destroy, id: "1"
      response.should redirect_to(alumnis_url)
    end
  end
end
