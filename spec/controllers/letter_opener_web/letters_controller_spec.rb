require 'spec_helper'

describe LetterOpenerWeb::LettersController do
  describe 'GET index' do
    before do
      LetterOpenerWeb::Letter.stub(search: :all_letters)
      get :index
    end
    it { should assign_to(:letters).with(:all_letters) }
  end
end
