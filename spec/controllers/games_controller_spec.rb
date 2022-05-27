require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  describe '#show' do
    context 'user is not authorized' do
      it 'should not have access' do
        get :show, id: game_w_questions.id
        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    context 'user is logged in' do
      let!(:signed_in) { sign_in user }

      it 'should have access to his game' do
        get :show, id: game_w_questions.id
        game = assigns(:game)
        expect(game.finished?).to be false
        expect(game.user).to eq(user)

        expect(response.status).to eq(200)
        expect(response).to render_template('show')
      end

      it 'should not have access to alien game' do
        alien_game = FactoryBot.create(:game_with_questions)

        get :show, id: alien_game.id

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be
      end
    end
  end

  describe '#create' do
    context 'user is not authorized' do
      it 'should not have access' do
        get :create, id: game_w_questions.id
        expect(response.status).to eq 302
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be
      end
    end

    context 'user is logged in' do
      before(:each) { sign_in user }

      it 'sholud have access to create game' do
        generate_questions(15)

        post :create
        game = assigns(:game)

        expect(game.finished?).to be false
        expect(game.user).to eq(user)
        expect(response).to redirect_to(game_path(game))
        expect(flash[:notice]).to be
      end

      it 'shuold not create second game' do
        expect(game_w_questions.finished?).to be false

        expect { post :create }.to change(Game, :count).by(0)
  
        game = assigns(:game)
        expect(game).to be_nil

        expect(response).to redirect_to(game_path(game_w_questions))
        expect(flash[:alert]).to be
      end
    end
  end

  describe '#answer' do
    context 'user is not authorized' do
      it 'should not have access' do
        put :create, id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key

        expect(response.status).to eq 302
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be
      end
    end

    context 'user is logged in' do
      before(:each) { sign_in user }

      it 'should accept correct answer' do
        put :answer, id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key
        game = assigns(:game)

        expect(game.finished?).to be false
        expect(game.current_level).to be > 0
        expect(response).to redirect_to(game_path(game))
        expect(flash.empty?).to be true
      end
    end
  end

  describe '#take_money' do
    context 'user is not authorized' do
      it 'should not have access' do
        put :take_money, id: game_w_questions.id

        expect(response.status).to eq 302
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be
      end
    end

    context 'user is logged in' do
      before(:each) { sign_in user }

      it 'shoould stops the game & update user balance' do
        game_w_questions.update_attribute(:current_level, 2)

        put :take_money, id: game_w_questions.id
        game = assigns(:game)
        expect(game.finished?).to be true
        expect(game.prize).to eq(200)

        user.reload
        expect(user.balance).to eq(200)

        expect(response).to redirect_to(user_path(user))
        expect(flash[:warning]).to be
      end
    end
  end
end
