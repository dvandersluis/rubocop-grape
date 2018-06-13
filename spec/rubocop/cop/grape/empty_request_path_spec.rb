RSpec.describe RuboCop::Cop::Grape::EmptyRequestPath do
  subject(:cop) { described_class.new }

  shared_examples_for :request do |method|
    context "with #{method}" do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          #{method} '' do
          #{' ' * method.size} ^^ Do not pass a blank path to `#{method}`.
          end
        RUBY
      end

      it 'registers an offense, with multiple arguments' do
        expect_offense(<<-RUBY.strip_indent)
          #{method} '', root: false do
          #{' ' * method.size} ^^ Do not pass a blank path to `#{method}`.
          end
        RUBY
      end

      it 'registers an offense when the string is in parens' do
        expect_offense(<<-RUBY.strip_indent)
          #{method}('') do
          #{' ' * method.size} ^^ Do not pass a blank path to `#{method}`.
          end
        RUBY
      end

      it 'registers an offense, with multiple arguments in parens' do
        expect_offense(<<-RUBY.strip_indent)
          #{method} '', root: false do
          #{' ' * method.size} ^^ Do not pass a blank path to `#{method}`.
          end
        RUBY
      end

      it 'does not register an offense if the path is not empty' do
        expect_no_offenses(<<-RUBY.strip_indent)
          #{method} 'path' do
          end
        RUBY
      end

      context 'auto-correction' do
        it 'removes the blank string' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            #{method} '' do
            end
          RUBY

          expect(new_source).to eq(<<-RUBY.strip_indent)
            #{method} do
            end
          RUBY
        end

        it 'removes the blank string but keeps arguments' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            #{method} '', root: true do
            end
          RUBY

          expect(new_source).to eq(<<-RUBY.strip_indent)
            #{method} root: true do
            end
          RUBY
        end

        it 'removes the blank string but keeps arguments when spacing is bad' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            #{method} '',root: true do
            end
          RUBY

          expect(new_source).to eq(<<-RUBY.strip_indent)
            #{method} root: true do
            end
          RUBY
        end

        it 'removes the blank string and parens' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            #{method}('') do
            end
          RUBY

          expect(new_source).to eq(<<-RUBY.strip_indent)
            #{method} do
            end
          RUBY
        end

        it 'removes the blank string but keeps arguments in parens' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            #{method}('', root: true) do
            end
          RUBY

          expect(new_source).to eq(<<-RUBY.strip_indent)
            #{method}(root: true) do
            end
          RUBY
        end
      end
    end
  end

  %w(get post put head delete options patch).each do |method|
    it_should_behave_like :request, method
  end
end
