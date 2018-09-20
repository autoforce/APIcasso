require 'rails_helper'

RSpec.describe Apicasso::ApplicationController, type: :controller do

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AppointmentsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "returns a success response" do
      Appointment.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      appointment = Appointment.create! valid_attributes
      get :show, params: {id: appointment.to_param}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      appointment = Appointment.create! valid_attributes
      get :edit, params: {id: appointment.to_param}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Appointment" do
        expect {
          post :create, params: {appointment: valid_attributes}, session: valid_session
        }.to change(Appointment, :count).by(1)
      end

      it "redirects to the created appointment" do
        post :create, params: {appointment: valid_attributes}, session: valid_session
        expect(response).to redirect_to(Appointment.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: {appointment: invalid_attributes}, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested appointment" do
        appointment = Appointment.create! valid_attributes
        put :update, params: {id: appointment.to_param, appointment: new_attributes}, session: valid_session
        appointment.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the appointment" do
        appointment = Appointment.create! valid_attributes
        put :update, params: {id: appointment.to_param, appointment: valid_attributes}, session: valid_session
        expect(response).to redirect_to(appointment)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        appointment = Appointment.create! valid_attributes
        put :update, params: {id: appointment.to_param, appointment: invalid_attributes}, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested appointment" do
      appointment = Appointment.create! valid_attributes
      expect {
        delete :destroy, params: {id: appointment.to_param}, session: valid_session
      }.to change(Appointment, :count).by(-1)
    end

    it "redirects to the appointments list" do
      appointment = Appointment.create! valid_attributes
      delete :destroy, params: {id: appointment.to_param}, session: valid_session
      expect(response).to redirect_to(appointments_url)
    end
  end

end
