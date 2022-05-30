require 'rails_helper'

RSpec.feature 'USER visit profile of another user', type: :feature do
  let(:page_owner) { create :user, name: 'Петя' }
  let(:user_visitor) { create :user, name: 'Вася' }
  let!(:games) do
    create(:game, user: page_owner,
                  created_at: Time.parse('2020.05.30, 13:00'),
                  prize: 1000
    )
    create(:game, user: page_owner,
                  created_at: Time.parse('2020.05.30, 13:01'),
                  prize: 2000,
                  finished_at: Time.parse('2020.05.30, 13:02')
    )
  end

  before { login_as user_visitor }

  feature 'page renders correctly' do
    before { visit '/users/1' }

    it 'should have page owner name' do
      expect(page).to have_content 'Петя'
    end

    it 'should not have profile edit button' do
      expect(page).not_to have_content 'Сменить имя и пароль'
    end

    context 'and render page owner`s games correctly' do
      it 'should show correct prizes' do
        expect(page).to have_content '1 000 ₽'
        expect(page).to have_content '2 000 ₽'
      end

      it 'should show correct time' do
        expect(page).to have_content '30 мая, 13:00'
        expect(page).to have_content '30 мая, 13:01'
      end

      it 'should show correct status' do
        expect(page).to have_content 'в процессе'
      end
    end
  end
end
