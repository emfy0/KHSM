# (c) goodprogrammer.ru

require 'rails_helper'

# Тестовый сценарий для модели игрового вопроса, в идеале весь наш функционал
# (все методы) должны быть протестированы.
RSpec.describe GameQuestion, type: :model do
  # Задаем локальную переменную game_question, доступную во всех тестах этого
  # сценария: она будет создана на фабрике заново для каждого блока it,
  # где она вызывается.
  let(:game_question) do
    FactoryBot.create(:game_question, a: 2, b: 1, c: 4, d: 3)
  end

  # Группа тестов на игровое состояние объекта вопроса
  context 'game status' do
    # Тест на правильную генерацию хэша с вариантами
    describe '#variants' do
      it 'should return correct variants' do
        expect(game_question.variants).to eq(
          'a' => game_question.question.answer2,
          'b' => game_question.question.answer1,
          'c' => game_question.question.answer4,
          'd' => game_question.question.answer3
        )
      end
    end

    describe '#answer_correct?' do
      it 'should rightly say if the answer is correct' do
        expect(game_question.answer_correct?('b')).to be true
      end
    end

    describe 'Question deligates' do
      it 'should correctly work for #level' do
        expect(game_question.text).to eq(game_question.question.text)
      end
      
      it 'should correctly work for #text' do
        expect(game_question.level).to eq(game_question.question.level)
      end
    end

    describe '#correct_answer_key' do
      it 'should correctly ditermine the correct answer key' do
        expect(game_question.correct_answer_key).to eq('b')
      end
    end

    describe '#help_hash' do
      it 'should return empty hash for new question' do
        expect(game_question.help_hash).to eq({})
      end

     it 'should save help hashes correctly' do
      game_question.help_hash[:some_key1] = 'blabla1'
      game_question.help_hash['some_key2'] = 'blabla2'

      expect(game_question.save).to be_truthy

      gq = GameQuestion.find(game_question.id)

      expect(gq.help_hash).to eq({some_key1: 'blabla1', 'some_key2' => 'blabla2'})
     end
    end
  end

  context 'User helpers' do
    it 'should not present any audience_help for new question' do
      expect(game_question.help_hash).not_to include(:audience_help)
    end
    
    it 'should not present any fifty_fifty for new question' do
      expect(game_question.help_hash).not_to include(:fifty_fifty)
    end

    it 'should not present any friend_call for new question' do
      expect(game_question.help_hash).not_to include(:friend_call)
    end

    describe '#add_audience_help' do
      before { game_question.add_audience_help }

      it 'should add audience_help in .help_hash' do
        expect(game_question.help_hash).to include(:audience_help)
      end

      it 'should add a, b, c, d for an :audience_help key' do
        expect(game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
      end
    end

    describe '#add_fifty_fifty' do
      before { game_question.add_fifty_fifty }

      it 'should add audience_help in .help_hash' do
        expect(game_question.help_hash).to include(:fifty_fifty)
      end

      it 'should contain 2 elements exactly' do
        expect(game_question.help_hash[:fifty_fifty].size).to eq 2
      end

      it 'should contain correct answer' do
        expect(game_question.help_hash[:fifty_fifty]).to include 'b'
      end
    end

    describe '#add_friend_call' do
      before { game_question.add_friend_call }

      it 'should add audience_help in .help_hash' do
        expect(game_question.help_hash).to include(:friend_call)
      end

      it 'should contain string' do
        expect(game_question.help_hash[:friend_call]).to be_a String
      end

      it 'should contain a || b || c || d if theres no :fifty_fifty' do
        letter = game_question.help_hash[:friend_call][-1]
        expect(%w[A B C D].include?(letter)).to be true
      end

      it 'should contain :fifty_fifty variants if they exist' do
        game_question.help_hash.delete(:friend_call)
        game_question.add_fifty_fifty
        game_question.add_friend_call

        available_leeters = game_question.help_hash[:fifty_fifty].map(&:upcase)
        letter = game_question.help_hash[:friend_call][-1]
        expect(available_leeters.include?(letter)).to be true
      end
    end
  end
end
