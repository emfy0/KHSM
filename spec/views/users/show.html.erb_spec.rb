require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) { create(:user, name: 'Ваня') }
  before do
    assign(:user, user)
    assign(:games, [
      build_stubbed(:game, id: 1234),
      build_stubbed(:game, id: 12345)
    ])
  end
  
  it 'renders user nickname' do
    render
    expect(rendered).to match 'Ваня'
  end

  it 'renders game' do
    stub_template 'users/_game.html.erb' => "<%= game.id %><br/>"
    render
    expect(rendered).to match /1234.*12345/m
  end

  context 'when user is account owner' do
    before do
      sign_in user
      render
    end

    it 'renders registration editing path link' do
      expect(rendered).to match('Сменить имя и пароль')
    end
  end

  context 'when user is not account owner' do
    it 'does not renders registration editing path link when user is not signed in' do
      render
      expect(rendered).not_to match('Сменить имя и пароль')
    end

    it 'does not renders registration editing path link when other user is signed in' do
      sign_in create(:user, name: 'Петя')
      render

      expect(rendered).not_to match('Сменить имя и пароль')
    end
  end
end
