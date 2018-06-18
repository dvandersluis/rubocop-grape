RSpec.describe RuboCop::Cop::Grape::StatusNoContent do
  subject(:cop) { described_class.new }

  it 'registers an offense for status :no_content' do
    expect_offense(<<-RUBY.strip_indent)
      status :no_content
      ^^^^^^^^^^^^^^^^^^ Use `body false` instead of `status :no_content`.
    RUBY
  end

  it 'registers an offense for status 204' do
    expect_offense(<<-RUBY.strip_indent)
      status 204
      ^^^^^^^^^^ Use `body false` instead of `status 204`.
    RUBY
  end

  it 'does not register an offense for a different status symbol' do
    expect_no_offenses('status :unauthorized')
  end

  it 'does not register an offense for a different status code' do
    expect_no_offenses('status 401')
  end

  context 'auto-correct' do
    it 'replaces status :no_content with body false' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        status :no_content
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        body false
      RUBY
    end

    it 'replaces status :no_content with body false' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        status 204
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        body false
      RUBY
    end
  end
end
